//
//  NSWindow+MWTWindowSwizzle.h
//  MacWindowTamer
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSWindow (MWTWindowSwizzle)

// Is this window the "Main" window?
- (bool)MWTIsMainWindow;

// Is this window a "Tool" window?
- (bool)MWTIsToolWindow;

@end

NS_ASSUME_NONNULL_END
