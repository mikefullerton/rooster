//
//  AppKitPlugin.h
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

#import <Foundation/Foundation.h>
#import "AppKitPluginProtocol.h"

NS_ASSUME_NONNULL_BEGIN

__attribute__((visibility("default"))) @interface AppKitPlugin : NSObject <AppKitPluginProtocol>

@end

NS_ASSUME_NONNULL_END
