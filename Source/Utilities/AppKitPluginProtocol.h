//
//  AppKitPluginProtocol.m
//  Rooster (iOS)
//
//  Created by Mike Fullerton on 11/19/20.
//

#import <Foundation/Foundation.h>

@class EKCalendar;
@class EKEventStore;

// not sure how to do this with swift protocol

@protocol AppKitPluginProtocol <NSObject>

- (void)requestPermissionToDelegateCalendarsForEventStore:(EKEventStore *)eventStore
                                               completion:(void (^)(BOOL success, EKEventStore* delegateEventStore, NSError *error)) completion;

@end

