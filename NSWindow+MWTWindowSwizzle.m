//
//  NSWindow+MWTWindowSwizzle.m
//  MacWindowTamer
//

#import "NSWindow+MWTWindowSwizzle.h"
#import "MWTWindowMonitor.h"

@implementation NSWindow (MWTWindowSwizzle)

- (bool)MWTIsMainWindow {
    NSWindowStyleMask mask = [self styleMask];
    
    return (mask & NSWindowStyleMaskTitled) &&
           (mask & NSWindowStyleMaskClosable) &&
           (mask & NSWindowStyleMaskMiniaturizable) &&
           (mask & NSWindowStyleMaskResizable) &&
           [[[self contentView] description] containsString:@"MW1_0Window"];
}

- (bool)MWTIsToolWindow {
    return [[[self contentView] description] containsString:@"QTToolFrame"] ||
    [[[self contentView] description] containsString:@"Progress"] ||
    [[[self contentView] description] containsString:@"Notification"] ||
    [[[self contentView] description] containsString:@"Browser"];
}

#pragma mark - Swizzled Methods

- (void)MWT_orderFront:(nullable id)sender {
    [self MWT_orderFront:sender];
    
    [[MWTWindowMonitor sharedInstance] updateRelationships];
}

@end
