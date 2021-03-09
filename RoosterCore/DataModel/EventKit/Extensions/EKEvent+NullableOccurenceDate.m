//
//  RCEvent+NullableOccurenceDate.m
//  Rooster
//
//  Created by Mike Fullerton on 3/18/21.
//

#import "EKEvent+NullableOccurenceDate.h"
//#import <EventKit/EventKit_Private.h>

@interface EKEvent (Private)
@property (readwrite, assign, nonatomic) EKParticipantStatus participationStatus;
@property (readonly, assign, nonatomic) BOOL allowsParticipationStatusModifications;
@end

@implementation EKEvent (NullableOccurenceDate)

- (NSDate *)nullableOccurenceDate {
    return self.occurrenceDate;
}

- (EKParticipantStatus) participationStatus_ {
    return self.participationStatus;
}

- (void)setParticipationStatus_:(EKParticipantStatus)status {
    
    if ([self respondsToSelector:@selector(setParticipationStatus:)]) {
        self.participationStatus = status;
    }
}

- (BOOL) allowsParticipationStatusModifications_ {
    if ([self respondsToSelector:@selector(allowsParticipationStatusModifications)]) {
        return [self allowsParticipationStatusModifications];
    }
    
    return YES;
}
@end
