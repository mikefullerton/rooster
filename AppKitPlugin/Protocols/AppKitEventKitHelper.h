//
//  AppKitEventKitController.h
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//
#import <Foundation/Foundation.h>

@class EKCalendar;
@class EKEventStore;
@class EKEvent;

NS_ASSUME_NONNULL_BEGIN

@protocol AppKitEventKitHelper <NSObject>

- (void)requestPermissionToDelegateCalendarsForEventStore:(EKEventStore *)eventStore
                                               completion:(nullable void (^)(BOOL success, EKEventStore* _Nullable delegateEventStore, NSError * _Nullable error)) completion;

@end

NS_ASSUME_NONNULL_END
