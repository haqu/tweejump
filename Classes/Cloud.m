#import "Cloud.h"

@implementation Cloud

- (id)initWithSpriteManager:(AtlasSpriteManager*)sprites {

	CGRect rect;
	switch(random()%3) {
		case 0: rect = CGRectMake(336,16,256,106); break;
		case 1: rect = CGRectMake(336,128,257,108); break;
		case 2: rect = CGRectMake(336,240,252,117); break;
	}
	sprite = [AtlasSprite spriteWithRect:rect spriteManager:sprites];
	[sprites addChild:sprite];

	sprite.opacity = 90;
	
	return self;
}

- (void)reset {
	
	distance = random()%20;
	
	float scaleX = 3.0f / (distance + 1.0f);
	float scaleY = 3.0f / (distance + 1.0f);
	if(random()%2==1) scaleX = -scaleX;
	sprite.scaleX = scaleX;
	sprite.scaleY = scaleY;
	
	CGSize size = sprite.contentSize;
	scaled_width = fabsf(size.width * sprite.scaleX);
	scaled_height = fabsf(size.height * sprite.scaleY);
	float x = random()%(320+(int)scaled_width) - scaled_width/2;
	float y = random()%(960+(int)scaled_height) - scaled_height/2;
	pos = CGPointMake(x,y);
	
	sprite.position = pos;
}

- (void)dealloc {
	NSLog(@"cloud dealloc");
	NSLog(@"sprite retainCount = %d",[sprite retainCount]);
	[sprite release];
	[super dealloc];
}

- (void)moveDownBy:(float)delta {
	pos.y -= delta / (distance * 2.0f + 1.0f);
	
	if(pos.y < -scaled_height/2) {
		[self reset];
	}
	
	sprite.position = pos;
}

@end
