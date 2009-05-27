#import "AppDelegate.h"
#import "GameScene.h"
#import "Constants.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];	


	[[Director sharedDirector] setPixelFormat:kRGBA8];
	[[Director sharedDirector] attachInWindow:window];
//	[[Director sharedDirector] setDisplayFPS:YES];
	[[Director sharedDirector] setAnimationInterval:1.0/kFPS];

	[Texture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888]; 
	
	[window makeKeyAndVisible];
	
	[[Director sharedDirector] runWithScene: [GameScene node]];
}

- (void)dealloc {
	[window release];
	[super dealloc];
}

@end
