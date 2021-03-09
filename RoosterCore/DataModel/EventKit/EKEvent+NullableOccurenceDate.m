//
//  RCEvent+NullableOccurenceDate.m
//  Rooster
//
//  Created by Mike Fullerton on 3/18/21.
//

#import "EKEvent+NullableOccurenceDate.h"

@implementation EKEvent (NullableOccurenceDate)

- (NSDate *)nullableOccurenceDate {
    return self.occurrenceDate;
}

@end
