//
//  NSImage+Tinting.h
//  Rooster-macOS
//
//  Created by Mike Fullerton on 2/1/21.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (Tinting)
- (NSImage *)imageTintedWithColor:(NSColor *)tint;
//- (NSImage*)imageCroppedToRect:(NSRect)rect;

@end

NS_ASSUME_NONNULL_END
