//
//  AppKitPlugin.m
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/19/20.
//

#import "AppKitPlugin.h"

#import "RoosterAppKitPlugin-Swift.h"

@interface AppKitPlugin()

@property (readonly, strong, nonatomic) ActualAppKitPlugin *plugin;

@end

@implementation AppKitPlugin

@synthesize menuBarPopover = _menuBarPopover;

- (instancetype)init {
    self = [super init];
    if (self) {
        _plugin = [[ActualAppKitPlugin alloc] init];
    }
    return self;
}

- (void)bringAnotherAppToFront:(nonnull NSString *)bundleIdentier {
    [_plugin bringAnotherAppToFront:bundleIdentier];
}

- (void)bringAppToFront {
    [_plugin bringAppToFront];
}

- (void)openURLDirectlyInAppIfPossible:(nonnull NSURL *)url completion:(nullable void (^)(BOOL, NSError * _Nullable))completion {
    [_plugin openURLDirectlyInAppIfPossible:url completion:completion];
}

- (void)requestPermissionToDelegateCalendarsForEventStore:(nonnull EKEventStore *)eventStore
                                               completion:(nullable void (^)(BOOL, EKEventStore * _Nullable, NSError * _Nullable))completion {
    
    [_plugin requestPermissionToDelegateCalendarsForEventStore:eventStore completion:completion];
}

- (id<MenuBarPopoverProtocol>)menuBarPopover {
    return [_plugin menuBarPopover];
}

@end
