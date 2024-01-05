
#include <Core/CoreAll.h>
#include <Fusion/FusionAll.h>

#import "MWTWindowMonitor.h"

using namespace adsk::core;
using namespace adsk::fusion;

adsk::core::Ptr<Application> app;
adsk::core::Ptr<UserInterface> ui;

extern "C" XI_EXPORT bool run(const char* context)
{
    NSLog(@"MWT is running");
	app = Application::get();
	if (!app)
		return false;

	ui = app->userInterface();
	if (!ui)
		return false;

    // Buid our monitor and tell it to start.
    [[MWTWindowMonitor sharedInstance] startMonitoring];
    
	return true;
}

extern "C" XI_EXPORT bool stop(const char* context)
{
    NSLog(@"MWT is stopped");

    // Tell our monitor to stop.
    [[MWTWindowMonitor sharedInstance] stopMonitoring];

	return true;
}


#ifdef XI_WIN

#include <windows.h>

BOOL APIENTRY DllMain(HMODULE hmodule, DWORD reason, LPVOID reserved)
{
	switch (reason)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

#endif // XI_WIN
