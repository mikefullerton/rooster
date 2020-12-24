//
//  AppKitMenuBarController.h
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Alarmable;
@protocol AppKitMenuBarControllerDelegate;

@protocol AppKitMenuBarController <NSObject>

@property (readwrite, weak, nonatomic) id<AppKitMenuBarControllerDelegate> delegate;

@property (readwrite, assign, nonatomic, getter=isPopoverHidden) BOOL popoverHidden;

- (void)showIconInMenuBar;

- (void)alarmStateDidChange;

- (void)showNowFiringItem:(id)item;

- (void)hideNowFiringItem:(id)item;

@end

@protocol AppKitMenuBarControllerDelegate <NSObject>
- (void)menuBarButtonWasClicked:(id<AppKitMenuBarController>)popover;

- (BOOL)appKitMenuBarControllerAreAlarmsFiring:(id<AppKitMenuBarController>)controller;

@end

NS_ASSUME_NONNULL_END
