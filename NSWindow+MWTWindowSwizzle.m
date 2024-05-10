//
//  NSWindow+MWTWindowSwizzle.m
//  MacWindowTamer
//

#import "NSWindow+MWTWindowSwizzle.h"
#import "MWTWindowMonitor.h"

__weak NSWindow* MainWindow = NULL;

@implementation NSWindow (MWTWindowSwizzle)


- (bool)MWTIsMainWindow {
    if (MainWindow == NULL) {
        MainWindow = [[NSApplication sharedApplication] mainWindow];
    }
    return self == MainWindow;
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
