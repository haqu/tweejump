#import "cocos2d.h"

@interface GameLayer : Layer
{
	AtlasSpriteManager *mgr;
	AtlasSprite *background;
	AtlasSprite *bird;
	NSMutableArray *platforms;
	ccVertex2F bird_pos;
	ccVertex2F bird_vel;
	ccVertex2F bird_acc;	

	float highestPlatformY;
}
@end
