#import "cocos2d.h"

//#define RESET_DEFAULTS

#define kFPS 60

#define kMinCloudStep		20
#define kMaxCloudStep		80
#define kNumClouds			24

#define kMinPlatformStep	50
#define kMaxPlatformStep	300
#define kNumPlatforms		10
#define kPlatformTopPadding 10

#define kMinBonusStep		30
#define kMaxBonusStep		50

enum {
	kSpriteManager = 0,
	kBird,
	kScoreLabel,
	kCloudsStartTag = 100,
	kPlatformsStartTag = 200,
	kBonusStartTag = 300
};

enum {
	kBonus5 = 0,
	kBonus10,
	kBonus50,
	kBonus100,
	kNumBonuses
};

@interface Main : Layer
{
	float currentCloudY;
	int currentCloudTag;
}
- (void)resetClouds;
- (void)resetCloud;
- (void)step:(ccTime)dt;
@end
