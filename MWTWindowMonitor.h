//
//  MWTWindowMonitor.h
//  MacWindowTamer
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class NSWindow;

@interface MWTWindowMonitor : NSObject
{
}

// Singleton for MWTWindowMonitor
+ (MWTWindowMonitor*)sharedInstance;

// Assigns tool windows as children of the main app window
- (void)updateRelationships;

// Interpose our own methods to fix up window ordering
- (void)startMonitoring;

// Stop interposing our methods
- (void)stopMonitoring;

@end

NS_ASSUME_NONNULL_END
