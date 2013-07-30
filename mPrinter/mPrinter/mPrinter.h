//
//  mPrinter.h
//  mPrinter
//
//  Created by Andy Muldowney on 7/5/13.
//  Copyright (c) 2013 mPrinter, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CocoaAsyncSocket/GCDAsyncSocket.h"
#import "CocoaAsyncSocket/GCDAsyncUdpSocket.h"

@protocol mPrinterDelegate <NSObject>
@optional
- (void)didDiscoverPrinter:(NSString *)ip;

@end

@interface mPrinter : NSObject <UIWebViewDelegate, GCDAsyncUdpSocketDelegate> {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    
    UIWebView *printerWebView;
    NSMutableData *htmlData;
    
    NSString *printerIP;
    
    long socketTag;
}

typedef enum MPrinterLineStyle: NSUInteger {
    MPrinterLineStyleDiagonal = 1,
    MPrinterLineStyleDiagonal2,
    MPrinterLineStyleHatch,
    MPrinterLineStyleDots,
    MPrinterLineStyleWave1,
    MPrinterLineStyleWave2,
    MPrinterLineStyleDots2,
    MPrinterLineStyleDiagonal3
} MPrinterLineStyle;

@property (nonatomic, assign) id <mPrinterDelegate> delegate;

// Printing
- (void)addBlankLines:(NSUInteger)lines;
- (void)addLine;
- (void)addLine:(MPrinterLineStyle)style;
- (void)addLine:(MPrinterLineStyle)style height:(CGFloat)height;
- (void)addHTML:(NSString *)html;
- (void)addText:(NSString *)text;
- (void)addText:(NSString *)text size:(CGFloat)size;
- (void)addText:(NSString *)text font:(UIFont *)font;
- (void)addText:(NSString *)text size:(CGFloat)size font:(UIFont *)font;
- (void)addImage:(UIImage *)image;
- (void)clear;
- (void)print;

// Utility
- (void)feed;
- (void)feed:(NSUInteger)lines;

// Discovery
- (NSError *)discoverPrinters;
- (void)setPrinterIP:(NSString *)ip;

// I/O
- (NSError *)sendData:(NSData *)data;

@end
