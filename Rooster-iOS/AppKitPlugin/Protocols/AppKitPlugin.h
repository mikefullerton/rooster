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

@interface AppKitPlugin : NSObject <RoosterAppKitPlugin>

@property (readonly, strong, nonatomic) id<AppKitMenuBarController> menuBarPopover;

@property (readonly, strong, nonatomic) id<AppKitEventKitHelper> eventKitHelper;

@property (readonly, strong, nonatomic) id<AppKitUtilities> utilities;

@property (readonly, strong, nonatomic) id<AppKitInstallationUpdater> installationUpdater;

@property (readonly, strong, nonatomic) id<AppKitWindowController> windowController;


@end

NS_ASSUME_NONNULL_END
