//
//  mPrinter.m
//  mPrinter
//
//  Created by Andy Muldowney on 7/5/13.
//  Copyright (c) 2013 mPrinter, LLC. All rights reserved.
//

#import "mPrinter.h"
#import <QuartzCore/QuartzCore.h>

#import "UIImage+Extensions.h"
#import "NSData+Base64.h"

@implementation mPrinter

@synthesize delegate = _delegate;

- (id)init {
    self = [super init];
    if (self) {
        // Create a buffer for HTML content
        htmlData = [[NSMutableData alloc] init];
        
        // Setup an offscreen UIWebView for content rendering
        UIWindow *offscreenWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 576, 100)];
        printerWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 576, 100)];
        printerWebView.delegate = self;
        printerWebView.scalesPageToFit = YES;
        printerWebView.opaque = YES;
        [offscreenWindow addSubview:printerWebView];
    }
    
    return self;
}

#pragma mark - Printing

/*
 * Add a horizontal rule with an optional style and height to the HTML buffer
 */
- (void)addLine {
    [self addLine:MPrinterLineStyleDots height:1.0f];
}

- (void)addLine:(MPrinterLineStyle)style {
    [self addLine:style height:1.0f];
}

- (void)addLine:(MPrinterLineStyle)style height:(CGFloat)height {
    NSString *html = [NSString stringWithFormat:@"<hr class='hr_%d' style='height: %fpx' />", style, height];
    [htmlData appendBytes:[html UTF8String] length:[html length]];
}

/*
 * Add blank lines with a specified height to the HTML buffer
 */
- (void)addBlankLines:(NSUInteger)lines {
    NSString *html = [NSString stringWithFormat:@"<div style='height: %dpx'></div>", lines];
    [htmlData appendBytes:[html UTF8String] length:[html length]];
}

/*
 * Add text with an optional font and size to the HTML buffer
 */
- (void)addText:(NSString *)text {
    [self addText:text size:12.0f font:nil];
}

- (void)addText:(NSString *)text size:(CGFloat)size {
    [self addText:text size:size font:nil];
}

- (void)addText:(NSString *)text font:(UIFont *)font {
    [self addText:text size:12.0f font:nil];
}

- (void)addText:(NSString *)text size:(CGFloat)size font:(UIFont *)font {
    NSString *fontString = (font != nil) ? [font familyName] : @"inherit";
    NSString *html = [NSString stringWithFormat:@"<p style='font-size: %fpt; font-family: %@'>%@</p>", size, fontString, text];
    [htmlData appendBytes:[html UTF8String] length:[html length]];
}

/*
 * Add an image to the HTML buffer
 */
- (void)addImage:(UIImage *)image {
    NSData *imageData = UIImagePNGRepresentation(image);
    
    // Embed the image as Base64 data in the HTML buffer
    NSString *html = [NSString stringWithFormat:@"<img src='data:image/png;base64,%@' />", [imageData base64EncodedString]];
    [htmlData appendBytes:[html UTF8String] length:[html length]];
}

/*
 * Add raw HTML to the buffer
 */
- (void)addHTML:(NSString *)html {
    [htmlData appendBytes:[html UTF8String] length:[html length]];
}

/*
 * Print the content in the HTML buffer
 */
- (void)print {
    // Load HTML content into the hidden UIWebView
    NSString *path = [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"mPrinter" ofType:@"bundle"]] pathForResource:@"template" ofType:@"html"];
    NSString *templateHTML = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:nil];
    NSString *html = [[NSString alloc] initWithData:htmlData encoding:NSASCIIStringEncoding];
    if (templateHTML && html) {
        NSString *fullHTML = [templateHTML stringByReplacingOccurrencesOfString:@"%%CONTENT%%" withString:html];
        [printerWebView loadHTMLString:fullHTML baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mPrinter" ofType:@"bundle"]]];
    }
}


/*
 * Clear the HTML buffer - this is not automatically done and should be performed before adding any content
 */
- (void)clear {
    htmlData = [[NSMutableData alloc] init];
    [printerWebView loadHTMLString:@"" baseURL:nil];
}

#pragma mark - Utility
/*
 * Issue a feed command to the printer with an optional number of lines (defaults to 1)
 */
- (void)feed {
    [self feed:1];
}

- (void)feed:(NSUInteger)lines {
    unsigned char *blankLine = malloc(72);
    memset(blankLine, 0, 72);
    NSData *feedData = [[NSData alloc] initWithBytes:blankLine length:72];
    for (int i = 0; i < lines; i++) {
        [self sendData:feedData];
    }
    free(blankLine);
}

#pragma mark - Discovery
/*
 * Set the active printer IP address
 */
- (void)setPrinterIP:(NSString *)ip {
    printerIP = ip;
}

/*
 * Discover printers on the network by sending a broadcast message
 */
- (NSError *)discoverPrinters {   
    GCDAsyncUdpSocket *udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [udpSocket enableBroadcast:YES error:nil];
    NSData *data = [@"STR_BCAST" dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket beginReceiving:nil];
    [udpSocket sendData:data toHost:@"255.255.255.255" port:22222 withTimeout:-1 tag:0];
    
    return nil;
}

#pragma mark - I/O
/*
 * Send raw data to the specified printer
 */
- (NSError *)sendData:(NSData *)data {
    NSError *error;
    
    if ([data length] <= 0)
        return [NSError errorWithDomain:@"mprinter" code:200 userInfo:nil];
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)printerIP, 9100, &readStream, &writeStream);
    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    if (inputStream == nil) {
        return [NSError errorWithDomain:@"mprinter" code:201 userInfo:nil];
    } else {
        unsigned char startBuf[4];
        
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];
        [outputStream open];
        
        // ESC raster mode start bytes
        // TODO: Add darkness and other overrides
        startBuf[0] = 0x1b;
        startBuf[1] = 0x2a;
        startBuf[2] = 0x72;
        startBuf[3] = 0x45;
        [outputStream write:startBuf maxLength:2];
        
        float delay = 50.0f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            unsigned char buf[75];
            
            unsigned char *bytes = (unsigned char *)[data bytes];
            for (int i = 0; i < [data length]; i+= 74) {
                buf[0] = 0x00;
                buf[1] = 0x00;
                buf[74] = 0x00;
                
                // TODO: Boundary checks
                memcpy(&buf[2], bytes + i + 2, 72);
                [outputStream write:buf maxLength:75];
            }
            
            [inputStream close];
            [outputStream close];
        });
        
    }
    
    return error;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    // Get the true height of the document for printing
    NSString *heightString = [webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"];
    int height = [heightString intValue];
    
    webView.frame = CGRectMake(0, 0, webView.frame.size.width, height);
    
    // Render the UIWebView content to a UIImage for further processing
    CGSize contentSize = webView.scrollView.contentSize;
    webView.frame = CGRectMake(0, 0, contentSize.width, height);
    UIGraphicsBeginImageContext(contentSize);
    [[UIColor whiteColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, contentSize.width, contentSize.height));
    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *rawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Dither the UIImage to a black and white palette
    PalettizedImage result = [rawImage imageBytesWithDithering];
    
    unsigned char byte = 0;
    unsigned char lineStart[2];
    lineStart[0] = 0x00;
    lineStart[1] = 0x00;
    int bufferIndex = 0;
    NSMutableData *data = [[NSMutableData alloc] init];
    
    // Create a 2-bit data stream from the image data to send to the printer
    for (int y = 0; y < contentSize.height; y++) {
        [data appendBytes:lineStart length:2];
        for (int x = 0; x < contentSize.width; x++) {
            if (result.pixels[x + y * result.width] == 0x00)
                byte = byte ^ (1 << (7 - (x % 8)));
            if ((x + 1) % 8 == 0) {
                [data appendBytes:&byte length:1];
                byte = 0;
                bufferIndex++;
            }
        }
    }
    
    // Send the data to the active printer
    [self sendData:[data copy]];
}

#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *host;
    uint16_t port;
    
    // We received a discovery reply, let our delegate know about it
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    if ([self.delegate respondsToSelector:@selector(didDiscoverPrinter:)]) {
        [self.delegate didDiscoverPrinter:host];
    }
}

@end
