//
//  AppKitPlugin.m
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

#import "AppKitPlugin.h"

#import "RoosterAppKitPlugin-Swift.h"

@interface AppKitPlugin()
@property (readwrite, strong, nonatomic, nullable) id<AppKitMenuBarController> menuBarPopover;
@property (readwrite, strong, nonatomic) id<AppKitEventKitHelper> eventKitHelper;
@property (readwrite, strong, nonatomic) id<AppKitUtilities> utilities;
@property (readwrite, strong, nonatomic) id<AppKitInstallationUpdater> installationUpdater;
@end

@implementation AppKitPlugin

- (instancetype)init {
    self = [super init];
    if (self) {
        _menuBarPopover = [[MenuBarController alloc] init];
        _eventKitHelper = [[EventKitHelper alloc] init];
        _utilities = [[Utilities alloc] init];
        _installationUpdater = [[InstallationUpdater alloc] init];
    }
    return self;
}

@end
