//
//  AppKitEventKitController.h
//  Rooster
//
//  Created by Mike Fullerton on 12/20/20.
//
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol AppKitInstallationUpdaterDelegate;

@protocol AppKitInstallationUpdater <NSObject>

@property (readwrite, weak, nonatomic) id<AppKitInstallationUpdaterDelegate> delegate;

- (void)configureWithAppBundle:(NSBundle*)appBundle;

- (void)checkForUpdates;

@end

@protocol AppKitInstallationUpdaterDelegate <NSObject>
- (void) appKitInstallationUpdater:(id<AppKitInstallationUpdater>)updater didCheckForUpdate:(BOOL)updateAvailable error:(NSError* _Nullable)error;
@end

NS_ASSUME_NONNULL_END
