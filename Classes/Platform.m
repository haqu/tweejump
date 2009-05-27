#import "Platform.h"
#import "Constants.h"

@implementation Platform

- (id)initWithGameLayer:(GameLayer*)parentGameLayer {

	gameLayer = [parentGameLayer retain];
	
	CGRect rect;
	switch(random()%2) {
		case 0: rect = CGRectMake(608,64,102,36); break;
		case 1: rect = CGRectMake(608,128,90,32); break;
	}
	sprite = [AtlasSprite spriteWithRect:rect spriteManager:gameLayer.sprites];
	[gameLayer.sprites addChild:sprite];
	
	return self;
}

- (ccVertex2F)pos {
	return pos;
}

- (void)setPos:(ccVertex2F)newPos {
	pos = newPos;
	sprite.position = pos;
}

- (void)reset {
	
	if(random()%2==1) {
		sprite.scaleX = -1.0f;
	} else {
		sprite.scaleX = 1.0f;
	}

	if(gameLayer.platformCurrentMaxStep < kPlatformMaxStep) {
		gameLayer.platformCurrentMaxStep += 1.0f;
	}

	CGSize size = sprite.contentSize;

	float x;
	if(gameLayer.highestPlatformY == 0.0f) {
		x = 160.0f;
	} else {
		x = random() % (320-(int)size.width) + size.width/2;
	}

	float deltaY = random() % (int)(gameLayer.platformCurrentMaxStep-size.height) + size.height;
	gameLayer.highestPlatformY += deltaY;
	float y = gameLayer.highestPlatformY;

	pos = CGPointMake(x,y);
	
	sprite.position = pos;
}

- (void)dealloc {
	[sprite release];
	[gameLayer release];
	[super dealloc];
}

- (BOOL)checkCollisionWithBirdPos:(ccVertex2F)birdPos birdSize:(CGSize)birdSize {
	CGSize size = sprite.contentSize;
	float min_y = pos.y + (size.height+birdSize.height)/2-kPlatformFromTopOfSpriteToGround;
	if(birdPos.x > pos.x-size.width/2-10 &&
	   birdPos.x < pos.x+size.width/2+10 &&
	   birdPos.y > pos.y &&
	   birdPos.y < min_y) {
		return YES;
	}
	return NO;
}

- (void)moveDownBy:(float)delta {
	pos.y -= delta;
	
	CGSize size = sprite.contentSize;
	if(pos.y < -size.height/2) {
		[self reset];
	}
	
	sprite.position = pos;
}

@end
