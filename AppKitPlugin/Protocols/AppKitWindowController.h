//
//  AppKitWindowController.h
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/20/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AppKitWindowController <NSObject>
- (void)restoreWindowPositionForWindow:(id)window
                            windowName:(NSString*)name
                           initialSize:(CGSize)size;
- (void)bringWindowToFront:(id)window;
- (void)setContentSize:(CGSize)size forWindow:(id)window;
@end

NS_ASSUME_NONNULL_END
