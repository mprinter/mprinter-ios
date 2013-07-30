//
//  UIImage+Extensions.h
//  mPrinter
//
//  Created by Andy Muldowney on 7/5/13.
//  Copyright (c) 2013 mPrinter, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "floyd_steinberg_dither.h"

@interface UIImage (Dithering)

// Dithering
- (PalettizedImage)imageBytesWithDithering;
- (UIImage *)imageWithDithering;
- (UIImage *)imageFromPalletizedImage:(PalettizedImage *)imageData withPallette:(RGBPalette *)palette;

// Resizing
- (UIImage*)imageByScalingToSize:(CGSize)targetSize;
- (UIImage *)resizeWithMaxDimension:(NSInteger)maxSize;
- (UIImage *)resizeWithMaxWidth:(NSInteger)maxWidth;

@end