#import "cocos2d.h"
#import "GameLayer.h"

@interface Platform : NSObject {
	GameLayer *gameLayer;
	AtlasSprite *sprite;
	ccVertex2F pos;
}
@property ccVertex2F pos;
- (id)initWithGameLayer:(GameLayer*)parentGameLayer;
- (void)reset;
- (BOOL)checkCollisionWithBirdPos:(ccVertex2F)birdPos birdSize:(CGSize)birdSize;
- (void)moveDownBy:(float)delta;
@end
