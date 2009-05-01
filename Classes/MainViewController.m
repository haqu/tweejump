#import "MainViewController.h"
#import "InfoViewController.h"

@implementation MainViewController

- (id)init {
	if (self = [super init]) {
		self.title = @"TweeJump";
	}
	return self;
}

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
	
	UIImageView *bgr = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bgr.png"]];
	[self.view addSubview:bgr];
	[bgr release];
}

- (void)dealloc {
	[self.view release];
	[super dealloc];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	NSLog(@"touchesBegan");
}

@end
