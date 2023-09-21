//
//  NSApplication+MWTApplicationSwizzle.m
//  MacWindowTamer
//

#import "NSApplication+MWTApplicationSwizzle.h"
#import "MWTWindowMonitor.h"

@implementation NSApplication (MWTApplicationSwizzle)

#pragma mark - Swizzled Methods

- (void)MWT_activateIgnoringOtherApps:(BOOL)flag {
    /*
         For some reason, the progress bar is activating the app over everyone else. It'd be great if it didn't.
     
         0   MacWindowTamer.dylib                0x0000000358183dc4 -[NSApplication(MWTApplicationSwizzle) MWT_activateIgnoringOtherApps:] + 128
         1   libqcocoa.dylib                     0x0000000134166090 _ZN12QCocoaWindow5raiseEv + 476
         2   QtWidgets                           0x000000010596e50c _ZN7QWidget5raiseEv + 516
         3   QtWidgets                           0x000000010596dfb8 _ZN14QWidgetPrivate11show_helperEv + 168
         4   QtWidgets                           0x000000010596ecd8 _ZN14QWidgetPrivate10setVisibleEb + 864
         5   NuBase10.dylib                      0x000000010e3279c4 _ZN13QTProgressBar4showEiib + 176
         6   NuBase10.dylib                      0x000000010e6c65e8 _ZN2Nu17BusyOperationImpl12showProgressEv + 112
         7   NuBase10.dylib                      0x000000010e6c6348 _ZN2Nu17BusyOperationImpl7_handleEv + 116
         8   NuBase10.dylib                      0x000000010e6c62c4 _ZN2Nu17BusyOperationImpl6handleEv + 60
         9   NuCommands10.dylib                  0x000000010759df6c _ZN16OpenDocumentUtil12openDocume

         and something else does it on the PCB side:
     
         0   MacWindowTamer.dylib                0x00000002e36c53c4 -[NSApplication(MWTApplicationSwizzle) MWT_activateIgnoringOtherApps:] + 100
         1   libqcocoa.dylib                     0x0000000131cee090 _ZN12QCocoaWindow5raiseEv + 476
         2   QtWidgets                           0x000000010376e50c _ZN7QWidget5raiseEv + 516
         3   NuBase10.dylib                      0x000000010c764aec _ZN2Nu15WorkspaceWindow21setWindowsInitializedEb + 76
         4   NuBase10.dylib                      0x000000010c6d6aa0 _ZNK2Nu8ShellMgr19postActivateWindowsEPNS_15WorkspaceWindowE + 40
         5   NuBase10.dylib                      0x000000010c6d68ac _ZN2Nu8ShellMgr11activeShellEPNS_5ShellE + 1488
         6   NuCommands10.dylib                  0x000000010561a3bc _ZN2Nu8Commands15SharedWorkflows18activateDocumentUIEPN2Ns8DocumentE + 628
         7   QtCore                              0x0000000107c60d50 _Z10doActivateILb0EEvP7QObjectiPPv + 764
         8   NuClientBase10.dylib                0x000000010a166d1c _ZN2Nu21DocumentSessionFacade29documentActivatedStateC
    */
    
    for (NSString* symbol in NSThread.callStackSymbols) {
        if ([symbol containsString:@"QCocoaWindow"] && [symbol containsString:@"raise"]) {
            flag = NO;
        }
    }
    
    [self MWT_activateIgnoringOtherApps:flag];
}

@end
