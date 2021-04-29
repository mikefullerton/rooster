//
//  NSImage+Tinting.m
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/1/21.
//

#import "NSImage+Tinting.h"

#import <CoreImage/CoreImage.h>

@implementation NSImage (Tinting)
- (NSImage *)imageTintedWithColor:(NSColor *)tint
{
    if (tint != nil) {
        NSSize size = [self size];
        NSRect bounds = { NSZeroPoint, size };
        NSImage *tintedImage = [[NSImage alloc] initWithSize:size];

        [tintedImage lockFocus];

        CIFilter *colorGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
        CIColor *color = [[CIColor alloc] initWithColor:tint];

        [colorGenerator setValue:color forKey:@"inputColor"];

        CIFilter *monochromeFilter = [CIFilter filterWithName:@"CIColorMonochrome"];
        CIImage *baseImage = [CIImage imageWithData:[self TIFFRepresentation]];

        [monochromeFilter setValue:baseImage forKey:@"inputImage"];
        [monochromeFilter setValue:[CIColor colorWithRed:0.75 green:0.75 blue:0.75] forKey:@"inputColor"];
        [monochromeFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputIntensity"];

        CIFilter *compositingFilter = [CIFilter filterWithName:@"CIMultiplyCompositing"];

        [compositingFilter setValue:[colorGenerator valueForKey:@"outputImage"] forKey:@"inputImage"];
        [compositingFilter setValue:[monochromeFilter valueForKey:@"outputImage"] forKey:@"inputBackgroundImage"];

        CIImage *outputImage = [compositingFilter valueForKey:@"outputImage"];

        [outputImage drawAtPoint:NSZeroPoint
                        fromRect:bounds
                       operation:NSCompositingOperationSourceIn //NSCompositingOperationCopy
                        fraction:1.0];

        [tintedImage unlockFocus];

        return tintedImage;
    }
    else {
        return [self copy];
    }
}

//- (NSImage*)imageCroppedToRect:(NSRect)rect
//{
//    NSPoint point = { -rect.origin.x, -rect.origin.y };
//    NSImage *croppedImage = [[NSImage alloc] initWithSize:rect.size];
//
//    [croppedImage lockFocus];
//    {
//        [self dr:point operation:NSCompositingOperationCopy];
//    }
//    [croppedImage unlockFocus];
//
//    return croppedImage;
//}
//
@end
