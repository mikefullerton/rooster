//
//  RoosterAppKitPlugin.h
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//

#import "AppKitMenuBarController.h"
#import "AppKitEventKitHelper.h"
#import "AppKitUtilities.h"
#import "AppKitInstallationUpdater.h"
#import "AppKitWindowController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RoosterAppKitPlugin <NSObject>

@property (readonly, strong, nonatomic) id<AppKitMenuBarController> menuBarPopover;

@property (readonly, strong, nonatomic) id<AppKitEventKitHelper> eventKitHelper;

@property (readonly, strong, nonatomic) id<AppKitUtilities> utilities;

@property (readonly, strong, nonatomic) id<AppKitInstallationUpdater> installationUpdater;

@property (readonly, strong, nonatomic) id<AppKitWindowController> windowController;

@end


NS_ASSUME_NONNULL_END
