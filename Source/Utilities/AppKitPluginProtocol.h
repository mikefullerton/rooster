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

@protocol AppKitPluginProtocol <NSObject>

- (void)requestPermissionToDelegateCalendarsForEventStore:(EKEventStore *)eventStore
                                               completion:(void (^)(BOOL success, EKEventStore* delegateEventStore, NSError *error)) completion;


- (NSArray<EKEvent *> *)findEventsWithCalendars:(NSArray<EKCalendar *> *)calendars
                                          store:(EKEventStore *)store;

@end

