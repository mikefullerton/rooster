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

- (void)requestPermissionToDelegateCalendarsForEventStore:(EKEventStore *)eventStore
                                               completion:(nullable void (^)(BOOL success, EKEventStore* _Nullable delegateEventStore, NSError * _Nullable error)) completion;

- (void)openURLDirectlyInAppIfPossible:(NSURL *)url completion:(nullable void (^)(BOOL success, NSError * _Nullable))completion;

- (void)bringAppToFront;
- (void)bringAnotherAppToFront:(NSString*)bundleIdentier;


- (id<MenuBarPopoverProtocol>)createMenuBarPopover;
@end


@protocol MenuBarPopoverProtocol <NSObject>
@property (readwrite, assign, nonatomic, getter=isHidden) BOOL hidden;
@end

NS_ASSUME_NONNULL_END
