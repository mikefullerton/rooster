//
//  AppKitEventKitController.h
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CalendarItem;

@protocol AppKitUtilities <NSObject>

- (void)openURLDirectlyInAppIfPossible:(NSURL *)url
                            completion:(nullable void (^)(BOOL success, NSError * _Nullable))completion;

- (void)bringAppToFront;
- (void)bringAnotherAppToFront:(NSString*)bundleIdentifier
                    completion:(nullable void (^)(BOOL success, NSError * _Nullable))completion;

- (void)bounceAppIconOnce;
- (void)startBouncingAppIcon;
- (void)stopBouncingAppIcon;

- (void)openNotificationSettings;

- (void)openLocationURL:(NSURL *)url
             completion:(nullable void (^)(BOOL success, NSError * _Nullable))completion;

- (void)bringLocationAppsToFrontForURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
