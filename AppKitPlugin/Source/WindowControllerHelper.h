//
//  WindowController.h
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/20/20.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WindowControllerHelper : NSObject
// this is unavailable in swift. Wth.
- (nullable NSWindow*)hostWindowForUIWindow:(id)uiWindow;
@end

NS_ASSUME_NONNULL_END
