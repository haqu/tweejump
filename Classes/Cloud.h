#import "cocos2d.h"

@interface Cloud : NSObject {
	AtlasSprite *sprite;
	ccVertex2F pos;
	float distance;
	float scaled_width;
	float scaled_height;
}
- (id)initWithSpriteManager:(AtlasSpriteManager*)sprites;
- (void)reset;
- (void)moveDownBy:(float)delta;
@end
