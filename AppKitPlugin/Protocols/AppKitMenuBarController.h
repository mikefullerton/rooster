//
//  AppKitMenuBarController.h
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AppKitMenuBarControllerDelegate;

@protocol AppKitMenuBarController <NSObject>

@property (readwrite, weak, nonatomic) id<AppKitMenuBarControllerDelegate> delegate;

@property (readwrite, assign, nonatomic, getter=isPopoverHidden) BOOL popoverHidden;

@property (readwrite, assign, nonatomic) BOOL isAlarmFiring;

- (void)showIconInMenuBar;

@end

@protocol AppKitMenuBarControllerDelegate <NSObject>
- (void)menuBarButtonWasClicked:(id<AppKitMenuBarController>)popover;
@end

NS_ASSUME_NONNULL_END
