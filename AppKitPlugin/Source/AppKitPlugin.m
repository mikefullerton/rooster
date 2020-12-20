//
//  AppKitPlugin.m
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

#import "AppKitPlugin.h"

#import "RoosterAppKitPlugin-Swift.h"

@implementation AppKitPlugin

- (instancetype)init {
    self = [super init];
    if (self) {
        _menuBarPopover = [[MenuBarController alloc] init];
        _eventKitHelper = [[EventKitHelper alloc] init];
        _utilities = [[Utilities alloc] init];
        _installationUpdater = [[InstallationUpdater alloc] init];
        _windowController = [[WindowController alloc] init];
    }
    return self;
}

@end
