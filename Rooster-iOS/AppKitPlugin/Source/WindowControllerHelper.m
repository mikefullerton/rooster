//
//  WindowController.m
//  RoosterAppKitPlugin
//
//  Created by Mike Fullerton on 12/20/20.
//

#import "WindowControllerHelper.h"
#import <AppKit/AppKit.h>

// sucks that this is private framework
#import <UIKitMacHelper/UINSApplicationDelegate.h>
#import <UIKitMacHelper/UINSWindow.h>

@implementation WindowControllerHelper

- (NSWindow*)hostWindowForUIWindow:(id)uiWindow {
    id <UINSWindow>hostWindow = [UINSSharedApplicationDelegate() hostWindowForUIWindow:uiWindow];
    return hostWindow != nil ? [[hostWindow sceneView] window] : nil;
}

@end

