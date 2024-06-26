//
//  MWTWindowMonitor.m
//  MacWindowTamer
//

#import "MWTWindowMonitor.h"
#import "NSWindow+MWTWindowSwizzle.h"
#import "NSApplication+MWTApplicationSwizzle.h"

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

#include <Core/CoreAll.h>
#include <Fusion/FusionAll.h>

@implementation MWTWindowMonitor

static bool IsSwizzled = NO;

// On Swizzle, we interpose two of our own methods between the actual AppKit calls.
//
// -[NSWindow orderFront:] so that we can fix up the parent/child releationships
// -[NSApplication activateIgnoringOtherApps:] to prevent the progress bar widget from jumping the app to the front.
//
+ (void)swizzle {
    if (IsSwizzled == NO) {
        [MWTWindowMonitor swizzleSelectorString:@"orderFront:" withSelectorString:@"MWT_orderFront:" forClass:[NSWindow class]];
        [MWTWindowMonitor swizzleSelectorString:@"makeKeyAndOrderFront:" withSelectorString:@"MWT_makeKeyAndOrderFront:" forClass:[NSWindow class]];
        [MWTWindowMonitor swizzleSelectorString:@"activateIgnoringOtherApps:" withSelectorString:@"MWT_activateIgnoringOtherApps:" forClass:[NSApplication class]];
        IsSwizzled = YES;
    }
}

// Puts everything back
+ (void)unswizzle {
    if (IsSwizzled == YES) {
        [MWTWindowMonitor swizzleSelectorString:@"orderFront:" withSelectorString:@"MWT_orderFront:" forClass:[NSWindow class]];
        [MWTWindowMonitor swizzleSelectorString:@"activateIgnoringOtherApps:" withSelectorString:@"MWT_activateIgnoringOtherApps:" forClass:[NSApplication class]];
        IsSwizzled = NO;
    }
}

// Points the original selector to our implementation and our selector back to the original.
// For example, -[NSWindow orderFront:] will call the implementation of the MWT_orderFront:] method and -[NSWindow MWT_orderFront:] will call
// the original [NSWindow orderFront:] implementation.
+ (void)swizzleSelectorString:(NSString*)originalSelectorString withSelectorString:(NSString*)swizzledSelectorString forClass:(Class)aClass {

    SEL originalSelector = NSSelectorFromString(originalSelectorString);
    SEL swizzledSelector = NSSelectorFromString(swizzledSelectorString);

    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);

    IMP originalImp = method_getImplementation(originalMethod);
    IMP swizzledImp = method_getImplementation(swizzledMethod);

    class_replaceMethod(aClass,
            swizzledSelector,
            originalImp,
            method_getTypeEncoding(originalMethod));
    class_replaceMethod(aClass,
            originalSelector,
            swizzledImp,
            method_getTypeEncoding(swizzledMethod));
}

// Singleton of our monitor
+ (MWTWindowMonitor*)sharedInstance {
    static MWTWindowMonitor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MWTWindowMonitor alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    
    // Setup the initial relationships. They'll be updated as windows order front.
    [self updateRelationships];

    return self;
}

// Pulls all the window numbers and returns NSWindow objects for them (if they exist)
- (NSArray*)windows {
    NSMutableArray* windows = [[NSMutableArray alloc] init];
        
    for (NSNumber* windowNumber in [NSWindow windowNumbersWithOptions:NSWindowNumberListAllSpaces]) {
        NSWindow* window = [NSApp windowWithWindowNumber:[windowNumber intValue]];
        if (window != nil) {
            [windows addObject:window];
        }
    }
    
    [windows sortUsingComparator:^NSComparisonResult(NSWindow* windowA, NSWindow* windowB) {
        if ([windowA orderedIndex] > [windowB orderedIndex]) {
            return NSOrderedDescending;
        } else if ([windowA orderedIndex] < [windowB orderedIndex]) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    return windows;
}

// Loops through the windows to find the "main window"
- (NSWindow*)mainWindow {
    for (NSWindow* window in [self windows]) {
        if ([window MWTIsMainWindow]) {
            return window;
        }
    }
    return NULL;
}

// Loops through the windows to find "tool" windows.
- (NSArray*)currentToolWindows {
    NSMutableArray* toolWindows = [[NSMutableArray alloc] init];
    
    for (NSWindow* window in [self windows]) {
        if ([window MWTIsToolWindow]) {
            [toolWindows addObject:window];
        }
    }
    return toolWindows;
}

// Once we know what the main window is, we can update relationships
- (void)noteMainWindowChanged:(NSNotification*)notificaiton {
    [self updateRelationships];
}

// Makes all the toolWindows children of the main window
- (void)updateRelationships {
    
    @try {
        NSWindow* mainWindow = [self mainWindow];
        if (mainWindow != NULL) {
            for (NSWindow* toolWindow in [self currentToolWindows]) {
                [mainWindow addChildWindow:toolWindow ordered:NSWindowAbove];
            }
        }
    }
    @catch(id anException) {
        NSLog(@"MWT failed to update relationships %@", anException);
    }
}

// Start swizzle
- (void)startMonitoring {
    // Listen for changes to the main window
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noteMainWindowChanged:) name:NSWindowDidBecomeMainNotification  object:NULL];

    [MWTWindowMonitor swizzle];
}

// Undo swizzle & unset parent/child relationshis
- (void)stopMonitoring {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [MWTWindowMonitor unswizzle];
    
    NSWindow* mainWindow = [self mainWindow];
    for (NSWindow* childWindow in [mainWindow childWindows]) {
        [mainWindow removeChildWindow:childWindow];
    }
}

@end
