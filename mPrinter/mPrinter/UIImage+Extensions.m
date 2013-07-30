//
//  UIImage+Extensions.m
//  mPrinter
//
//  Created by Andy Muldowney on 7/5/13.
//  Copyright (c) 2013 mPrinter, LLC. All rights reserved.
//

#import "UIImage+Extensions.h"

#define BITS_PER_PIXEL 32
#define BITS_PER_COMPONENT (BITS_PER_PIXEL/4)
#define BYTES_PER_PIXEL (BITS_PER_PIXEL/BITS_PER_COMPONENT)

static inline double radians (double degrees) {return degrees * M_PI/180;}

@implementation UIImage (Dithering)

- (PalettizedImage)imageBytesWithDithering
{
    RGBImage image;
    RGBPalette palette;
    PalettizedImage result;
    
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    size_t bytesPerRow = (int)self.size.width * BYTES_PER_PIXEL;
	unsigned char* bitmapData = (unsigned char*) malloc(bytesPerRow*self.size.height);
    
    CGContextRef context = CGBitmapContextCreate(bitmapData,self.size.width,self.size.height,BITS_PER_COMPONENT,bytesPerRow,colourSpace,kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colourSpace);
	CGRect rect = CGRectMake(0.0,0.0,self.size.width,self.size.height);
	CGContextDrawImage(context,rect,self.CGImage);
	unsigned char* pixelData = (unsigned char*)CGBitmapContextGetData(context);
    CGContextRelease(context);
    
    image.pixels = malloc(sizeof(RGBTriple) * (int)self.size.width * (int)self.size.height);
    image.height = (int)self.size.height;
    image.width = (int)self.size.width;
    for(int y=0;y<self.size.height;y++)
	{
        for(int x=0;x<self.size.width;x++)
		{
            memcpy((void *)&image.pixels[x + y * (int)self.size.width], pixelData + ((x * 4) + (y * 4 * (int)self.size.width)), 3);
        }
    }
    
    palette.size = 2;
    palette.table = malloc(sizeof(RGBTriple) * palette.size);
    palette.table[0].R = 0;
    palette.table[0].G = 0;
    palette.table[0].B = 0;
    palette.table[1].R = 255;
    palette.table[1].G = 255;
    palette.table[1].B = 255;
    
    result = FloydSteinbergDither(image, palette);
    return result;
}

- (UIImage *)imageWithDithering
{
    RGBImage image;
    RGBPalette palette;
    PalettizedImage result;
    
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    size_t bytesPerRow = (int)self.size.width * BYTES_PER_PIXEL;
	unsigned char* bitmapData = (unsigned char*) malloc(bytesPerRow*self.size.height);
    
    CGContextRef context = CGBitmapContextCreate(bitmapData,self.size.width,self.size.height,BITS_PER_COMPONENT,bytesPerRow,colourSpace,kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colourSpace);
	CGRect rect = CGRectMake(0.0,0.0,self.size.width,self.size.height);
	CGContextDrawImage(context,rect,self.CGImage);
	unsigned char* pixelData = (unsigned char*)CGBitmapContextGetData(context);
    CGContextRelease(context);
    
    image.pixels = malloc(sizeof(RGBTriple) * (int)self.size.width * (int)self.size.height);
    image.height = (int)self.size.height;
    image.width = (int)self.size.width;
    for(int y=0;y<self.size.height;y++)
	{
        for(int x=0;x<self.size.width;x++)
		{
            memcpy((void *)&image.pixels[x + y * (int)self.size.width], pixelData + ((x * 4) + (y * 4 * (int)self.size.width)), 3);
        }
    }
    
    palette.size = 2;
    palette.table = malloc(sizeof(RGBTriple) * palette.size);
    palette.table[0].R = 0;
    palette.table[0].G = 0;
    palette.table[0].B = 0;
    palette.table[1].R = 255;
    palette.table[1].G = 255;
    palette.table[1].B = 255;
    
    result = FloydSteinbergDither(image, palette);
    UIImage *tempImage = [self imageFromPalletizedImage:&result withPallette:&palette];
    
    free(bitmapData);
    free(image.pixels);
    free(palette.table);
    
    return tempImage;
}

- (UIImage *)imageFromPalletizedImage:(PalettizedImage *)imageData withPallette:(RGBPalette *)palette
{
    unsigned char *pixelData = malloc(sizeof(RGBTriple) * imageData->width * imageData->height);
    for (int y = 0; y < imageData->height; y++) {
        for (int x = 0; x < imageData->width; x++) {
            memcpy((void *)&pixelData[(x * sizeof(RGBTriple)) + (y * sizeof(RGBTriple) * imageData->width)], (void *)&palette->table[imageData->pixels[x + y * imageData->width]], 3);
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(pixelData, (int)self.size.width, (int)self.size.height, 8, (int)self.size.width * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaNoneSkipLast|kCGBitmapByteOrder32Big);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *rawImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(context);
    CGImageRelease(imageRef);
    
    free(pixelData);
    
    return rawImage;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage*)imageByScalingToSize:(CGSize)targetSize
{
    UIImage* sourceImage = self;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    size_t width = (int)targetWidth;
    size_t height = (int)targetHeight;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, kCGImageAlphaPremultipliedFirst);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, kCGImageAlphaPremultipliedFirst);
        
    }
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}

- (UIImage *)resizeWithMaxDimension:(NSInteger)maxSize;
{
    CGSize newSize;
    CGFloat ratio, height, width;
    
    // If we're not up/down, flip
    height = self.size.height;
    width = self.size.width;
    if (self.imageOrientation !=  UIImageOrientationUp && self.imageOrientation != UIImageOrientationDown)
    {
        height = self.size.width;
        width = self.size.height;
    }
    
    if (height > width)
    {
        // Taller
        ratio = maxSize / height;
        if (height < maxSize)
            return [self imageByScalingToSize:CGSizeMake(width, height)];
    }
    else
    {
        // Wider
        ratio = maxSize / width;
        if (width < maxSize)
            return [self imageByScalingToSize:CGSizeMake(width, height)];
    }
    
    newSize.height = height * ratio;
    newSize.width = width * ratio;
    
    return [self imageByScalingToSize:newSize];
}

- (UIImage *)resizeWithMaxWidth:(NSInteger)maxWidth
{
    CGSize newSize;
    CGFloat ratio, height, width;
    
    // If we're not up/down, flip
    height = self.size.height;
    width = self.size.width;
    
    ratio = maxWidth / width;
    newSize.height = height * ratio;
    newSize.width = width * ratio;
    
    return [self imageWithImage:self scaledToSize:newSize];
}

@end
