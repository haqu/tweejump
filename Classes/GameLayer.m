#import "GameLayer.h"
#import "Constants.h"
#import <mach/mach_time.h>

#define RANDOM_SEED() srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF))

#define kPlatformStep 100.0f

@interface GameLayer (Private)
- (void)jump;
@end

@implementation GameLayer

- (id)init {
	
	if(self = [super init]) {
		
		mgr = [AtlasSpriteManager spriteManagerWithFile:@"sprites.png" capacity:3];
		[self addChild:mgr];
		
		background = [AtlasSprite spriteWithRect:CGRectMake(0,0,320,480) spriteManager:mgr];
		[mgr addChild:background];
		[background setPosition:CGPointMake(160,240)];

		platforms = [[NSMutableArray alloc] init];
		AtlasSprite *platform;

		float x = 160;
		float y = 30;
		int pwidth;
		for(int i=0; i<5; i++) {
			NSLog(@"x = %f, y = %f",x,y);
			platform = [AtlasSprite spriteWithRect:CGRectMake(321,64,86,24) spriteManager:mgr];
			[mgr addChild:platform];
			[platform setPosition:CGPointMake(x,y)];
			[platforms addObject:platform];
			[platform release];
			pwidth = (int)platform.contentSize.width;
			x = random() % (320-pwidth) + pwidth/2;
			y += kPlatformStep;
		}
		highestPlatformY = y - kPlatformStep;
		
		NSLog(@"platforms count = %d",[platforms count]);

		bird = [AtlasSprite spriteWithRect:CGRectMake(321,0,63,45) spriteManager:mgr];
		[mgr addChild:bird];
		
		bird_pos.x = 160;
		bird_pos.y = 160;
		[bird setPosition:bird_pos];
		
		bird_vel.x = 0;
		bird_vel.y = 0;

		bird_acc.x = 0;
		bird_acc.y = -0.25;
		
		isTouchEnabled = YES;
		isAccelerometerEnabled = YES;
	
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kFPS)];
	}
	
	return self;
}

- (void)dealloc {
	for(AtlasSprite *platform in platforms) {
		[platform release];
	}
	[platforms removeAllObjects];
	[bird release];
	[background release];
	[mgr release];
	[super dealloc];
}

- (void)draw {
	bird_pos.x += bird_vel.x;
	
	CGSize bsize = CGSizeMake(64,40);
	float max_x = 320-bsize.width/2;
	float min_x = 0+bsize.width/2;
	
	if(bird_pos.x>max_x) bird_pos.x = max_x;
	if(bird_pos.x<min_x) bird_pos.x = min_x;
	
	bird_vel.y += bird_acc.y;
	bird_pos.y += bird_vel.y;
	
	if(bird_vel.y < 0) {
		
		CGSize psize;
		CGPoint ppos;
		for(AtlasSprite *platform in platforms) {
			psize = platform.contentSize;
			ppos = platform.position;
			if(bird_pos.x > ppos.x-psize.width/2-10 &&
			   bird_pos.x < ppos.x+psize.width/2+10 &&
			   bird_pos.y > ppos.y &&
			   bird_pos.y < ppos.y+(psize.height+bsize.height)/2) {
				[self jump];
			}
		}
		
		if(bird_pos.y < bsize.height/2) {
			bird_pos.y = bsize.height/2;
			[self jump];
		}
		
	} else if(bird_pos.y > 240) {
		
		float delta = bird_pos.y - 240;
		bird_pos.y = 240;
		highestPlatformY -= delta;
		
		CGPoint ppos;
		int pwidth;
		float x;
		for(AtlasSprite *platform in platforms) {
			ppos = platform.position;
			platform.position = CGPointMake(ppos.x,ppos.y-delta);
			
			ppos = platform.position;
			if(ppos.y < -platform.contentSize.height/2) {
				pwidth = (int)platform.contentSize.width;
				x = random() % (320-pwidth) + pwidth/2;
				highestPlatformY += kPlatformStep;
				platform.position = CGPointMake(x,highestPlatformY);
			}
		}
	
	}
	
	[bird setPosition:CGPointMake(bird_pos.x,bird_pos.y)];
}

- (void)jump {
	bird_vel.y = 9;
}

- (BOOL)ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	NSLog(@"ccTouchesEnded");
	[self jump];
	return kEventHandled;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	float accel_filter = 0.2f;
	bird_vel.x = bird_vel.x * accel_filter + acceleration.x * (1.0f - accel_filter) * 15;
}

@end
