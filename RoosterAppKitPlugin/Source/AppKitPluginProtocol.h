//
//  AppKitPluginProtocol.m
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/19/20.
//

#import <Foundation/Foundation.h>

@class EKCalendar;
@class EKEventStore;
@class EKEvent;

// not sure how to do this with swift protocol
NS_ASSUME_NONNULL_BEGIN

@protocol MenuBarPopoverProtocol;

@protocol AppKitPluginProtocol <NSObject>

@property (readonly, strong, nonatomic, nullable) id<MenuBarPopoverProtocol> menuBarPopover;

- (void)requestPermissionToDelegateCalendarsForEventStore:(EKEventStore *)eventStore
                                               completion:(nullable void (^)(BOOL success, EKEventStore* _Nullable delegateEventStore, NSError * _Nullable error)) completion;

- (void)openURLDirectlyInAppIfPossible:(NSURL *)url completion:(nullable void (^)(BOOL success, NSError * _Nullable))completion;

- (void)bringAppToFront;
- (void)bringAnotherAppToFront:(NSString*)bundleIdentier;

@end

@protocol MenuBarPopoverProtocolDelegate;

@protocol MenuBarPopoverProtocol <NSObject>
- (void)showInMenuBar;
@property (readwrite, weak, nonatomic) id<MenuBarPopoverProtocolDelegate> delegate;
@property (readwrite, assign, nonatomic, getter=isPopoverHidden) BOOL popoverHidden;
@property (readwrite, assign, nonatomic) BOOL isAlarmFiring;
@end

@protocol MenuBarPopoverProtocolDelegate <NSObject>
- (void)menuBarButtonWasClicked:(id<MenuBarPopoverProtocol>)popover;
@end

NS_ASSUME_NONNULL_END
