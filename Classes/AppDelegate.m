#import "AppDelegate.h"
#import "MainViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(UIApplication*)application {    

	// window
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	// status bar
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

	// main view and navigation controller
	MainViewController *mainView = [[MainViewController alloc] init];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mainView];
	[mainView release];
	nav.delegate = self;
	nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	nav.navigationBar.frame = CGRectMake(0,20,320,44);
	nav.view.frame = CGRectMake(0,0,320,480);
		
	// window
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSLog(@"navigationController");
	NSLog(@"viewController.title = %@",viewController.title);
	if([viewController.title isEqualToString:@"TweeJump"]) {
		navigationController.navigationBarHidden = YES;
	} else {
		navigationController.navigationBarHidden = NO;
	}
}

@end
