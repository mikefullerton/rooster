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
@end

NS_ASSUME_NONNULL_END
