#import "cocos2d.h"
#import "Main.h"

@interface Game : Main
{
	CGPoint bird_pos;
	ccVertex2F bird_vel;
	ccVertex2F bird_acc;	

	float currentPlatformY;
	int currentPlatformTag;
	float currentMaxPlatformStep;
	int currentBonusPlatformIndex;
	int currentBonusType;
	int platformCount;
	
	BOOL gameSuspended;
	BOOL birdLookingRight;
	
	int score;
}

+ (CCScene *)scene;

@end
