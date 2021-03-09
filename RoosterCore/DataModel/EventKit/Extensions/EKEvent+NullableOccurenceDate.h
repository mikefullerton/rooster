//
//  RCEvent+NullableOccurenceDate.h
//  Rooster
//
//  Created by Mike Fullerton on 3/18/21.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EKEvent (NullableOccurenceDate)
// the swift header is wrong in EKEvent
@property (readonly, strong, nonatomic, nullable) NSDate *nullableOccurenceDate;

@property (readwrite, assign, nonatomic) EKParticipantStatus participationStatus_;
@property (readonly, assign, nonatomic) BOOL allowsParticipationStatusModifications_;
@end

NS_ASSUME_NONNULL_END
