//
//  AppKitWindowController.h
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/20/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AppKitWindowController <NSObject>
- (void)restoreWindowPositionForWindow:(id)window windowName:(NSString*)name;
- (void)bringWindowToFront:(id)window;
@end

NS_ASSUME_NONNULL_END
