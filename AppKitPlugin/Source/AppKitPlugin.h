//
//  AppKitPlugin.h
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

#import <Foundation/Foundation.h>
#import "RoosterAppKitPlugin.h"

NS_ASSUME_NONNULL_BEGIN

// there's a crappy bug where if you have more than one swift file in the bundle, it returns the wrong principle class.
// using a ObjectiveC class works around this

__attribute__((visibility("default")))
@interface AppKitPlugin : NSObject <RoosterAppKitPlugin>

@end

NS_ASSUME_NONNULL_END
