#import "InfoViewController.h"

@implementation InfoViewController

- (id)init {
	if (self = [super init]) {
		self.title = @"About";
	}
	return self;
}

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
}

- (void)dealloc {
	[self.view release];
	[super dealloc];
}

@end
