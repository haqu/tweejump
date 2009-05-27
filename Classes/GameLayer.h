#import "cocos2d.h"

@interface GameLayer : Layer
{
	AtlasSpriteManager *sprites;
	AtlasSprite *background;
	AtlasSprite *bird;
	NSMutableArray *platforms;
	NSMutableArray *clouds;

	LabelAtlas *scoreLabel;
	
	ccVertex2F bird_pos;
	ccVertex2F bird_vel;
	ccVertex2F bird_acc;	

	float highestPlatformY;
	float platformCurrentMaxStep;

	BOOL gameSuspended;
	BOOL birdLookingRight;
	
	int score;
}
@property (nonatomic,retain) AtlasSpriteManager *sprites;
@property float highestPlatformY;
@property float platformCurrentMaxStep;

@end
