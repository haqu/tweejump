#import "GameScene.h"
#import "GameLayer.h"

@implementation GameScene

- (id)init {
	if(self = [super init]) {
		[self addChild:[GameLayer node]];
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

@end
