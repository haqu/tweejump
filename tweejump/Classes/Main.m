#import "Main.h"
#import <mach/mach_time.h>

#define RANDOM_SEED() srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF))

@interface Main(Private)
- (void)initClouds;
- (void)initCloud;
@end


@implementation Main

- (id)init {
//	NSLog(@"Main::init");
	
	if(![super init]) return nil;
	
	RANDOM_SEED();

	CCSpriteBatchNode *batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:10];
	[self addChild:batchNode z:-1 tag:kSpriteManager];

	CCSprite *background = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0,0,320,480)];
	[batchNode addChild:background];
	background.position = CGPointMake(160,240);

	[self initClouds];

	[self schedule:@selector(step:)];
	
	return self;
}

- (void)dealloc {
//	NSLog(@"Main::dealloc");
	[super dealloc];
}

- (void)initClouds {
//	NSLog(@"initClouds");
	
	currentCloudTag = kCloudsStartTag;
	while(currentCloudTag < kCloudsStartTag + kNumClouds) {
		[self initCloud];
		currentCloudTag++;
	}
	
	[self resetClouds];
}

- (void)initCloud {
	
	CGRect rect;
	switch(random()%3) {
		case 0: rect = CGRectMake(336,16,256,108); break;
		case 1: rect = CGRectMake(336,128,257,110); break;
		case 2: rect = CGRectMake(336,240,252,119); break;
	}	
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	CCSprite *cloud = [CCSprite spriteWithTexture:[batchNode texture] rect:rect];
	[batchNode addChild:cloud z:3 tag:currentCloudTag];
	
	cloud.opacity = 128;
}

- (void)resetClouds {
//	NSLog(@"resetClouds");
	
	currentCloudTag = kCloudsStartTag;
	
	while(currentCloudTag < kCloudsStartTag + kNumClouds) {
		[self resetCloud];

		CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
		CCSprite *cloud = (CCSprite*)[batchNode getChildByTag:currentCloudTag];
		CGPoint pos = cloud.position;
		pos.y -= 480.0f;
		cloud.position = pos;
		
		currentCloudTag++;
	}
}

- (void)resetCloud {
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	CCSprite *cloud = (CCSprite*)[batchNode getChildByTag:currentCloudTag];
	
	float distance = random()%20 + 5;
	
	float scale = 5.0f / distance;
	cloud.scaleX = scale;
	cloud.scaleY = scale;
	if(random()%2==1) cloud.scaleX = -cloud.scaleX;
	
	CGSize size = cloud.contentSize;
	float scaled_width = size.width * scale;
	float x = random()%(320+(int)scaled_width) - scaled_width/2;
	float y = random()%(480-(int)scaled_width) + scaled_width/2 + 480;
	
	cloud.position = ccp(x,y);
}

- (void)step:(ccTime)dt {
//	NSLog(@"Main::step");
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByTag:kSpriteManager];
	
	int t = kCloudsStartTag;
	for(t; t < kCloudsStartTag + kNumClouds; t++) {
		CCSprite *cloud = (CCSprite*)[batchNode getChildByTag:t];
		CGPoint pos = cloud.position;
		CGSize size = cloud.contentSize;
		pos.x += 0.1f * cloud.scaleY;
		if(pos.x > 320 + size.width/2) {
			pos.x = -size.width/2;
		}
		cloud.position = pos;
	}
	
}

@end
