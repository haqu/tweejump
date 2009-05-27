#import "GameLayer.h"
#import "Constants.h"
#import "Cloud.h"
#import "Platform.h"
#import <mach/mach_time.h>

#define RANDOM_SEED() srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF))

@interface GameLayer (Private)
- (void)initSpriteManager;
- (void)initBackground;
- (void)initClouds;
- (void)initPlatforms;
- (void)initBird;
- (void)startGame;
- (void)resetClouds;
- (void)resetPlatforms;
- (void)resetBird;
- (void)step:(ccTime)dt;
- (void)jump;
- (void)gameOver;
@end

@implementation GameLayer

@synthesize sprites;
@synthesize highestPlatformY;
@synthesize platformCurrentMaxStep;

- (id)init {
	
	if(self = [super init]) {
	
		RANDOM_SEED();

		gameSuspended = YES;
		
		[self initSpriteManager];
		[self initBackground];
		[self initClouds];
		[self initPlatforms];
		[self initBird];

		scoreLabel = [LabelAtlas labelAtlasWithString:@"0" charMapFile:@"charmap.png" itemWidth:24 itemHeight:32 startCharMap:' '];
		[self addChild:scoreLabel];
		scoreLabel.opacity = 128;
		scoreLabel.position = ccp(160-12,430);

		[self schedule:@selector(step:)];
		
		isTouchEnabled = YES;
		isAccelerometerEnabled = YES;
	
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kFPS)];
		
		[self startGame];
	}
	
	return self;
}

- (void)dealloc {
	[scoreLabel release];
	[bird release];
	[platforms release];
	[clouds release];
	[background release];
	[sprites release];
	[super dealloc];
}

- (void)initSpriteManager {
	NSLog(@"initSpriteManager");

	sprites = [AtlasSpriteManager spriteManagerWithFile:@"sprites.png" capacity:7];
	[self addChild:sprites];
}

- (void)initBackground {
	NSLog(@"initBackground");

	background = [AtlasSprite spriteWithRect:CGRectMake(0,0,320,480) spriteManager:sprites];
	[sprites addChild:background];
	background.position = CGPointMake(160,240);
}

- (void)initBird {
	NSLog(@"initBird");
	
	bird = [AtlasSprite spriteWithRect:CGRectMake(608,16,44,32) spriteManager:sprites];
	[sprites addChild:bird];
}

- (void)initClouds {
	NSLog(@"initClouds");
	
	clouds = [[NSMutableArray alloc] init];
	
	Cloud *cloud;
	int count = 0;
	while(true) {
		cloud = [[Cloud alloc] initWithSpriteManager:sprites];
		[clouds addObject:cloud];
		[cloud release];
		if(++count == 20) break;
	}
}

- (void)initPlatforms {
	NSLog(@"initPlatforms");
	
	platforms = [[NSMutableArray alloc] init];
	
	Platform *platform;
	float platformHeight = 20.0f;
	int count = (int)(480.0f / platformHeight);
	while(true) {
		platform = [[Platform alloc] initWithGameLayer:self];
		[platforms addObject:platform];
		[platform release];
		if(--count == 0) break;
	}
}

- (void)startGame {
	NSLog(@"startGame");
	[self resetClouds];
	[self resetPlatforms];
	[self resetBird];
	
	score = 0;
	gameSuspended = NO;
}

- (void)resetClouds {
	NSLog(@"resetClouds");
	for(Cloud *cloud in clouds) {
		[cloud reset];
	}
}

- (void)resetPlatforms {
	NSLog(@"resetPlatforms");
	
	platformCurrentMaxStep = 50.0f;
	highestPlatformY = 0.0f;
	
	for(Platform *platform in platforms) {
		[platform reset];
	}
}

- (void)resetBird {
	NSLog(@"resetBird");
	
	bird_pos.x = 160;
	bird_pos.y = 160;
	bird.position = bird_pos;
	
	bird_vel.x = 0;
	bird_vel.y = 0;
	
	bird_acc.x = 0;
	bird_acc.y = -500.0f;
	
	birdLookingRight = YES;
}

- (void)step:(ccTime)dt {
	if(gameSuspended) return;
	
	bird_pos.x += bird_vel.x * dt;
	
	if(bird_vel.x < -30.0f && birdLookingRight) {
		birdLookingRight = NO;
		bird.scaleX = -1.0f;
	} else if (bird_vel.x > 30.0f && !birdLookingRight) {
		birdLookingRight = YES;
		bird.scaleX = 1.0f;
	}
	
	CGSize bsize = bird.contentSize;
	float max_x = 320-bsize.width/2;
	float min_x = 0+bsize.width/2;
	
	if(bird_pos.x>max_x) bird_pos.x = max_x;
	if(bird_pos.x<min_x) bird_pos.x = min_x;
	
	bird_vel.y += bird_acc.y * dt;
	bird_pos.y += bird_vel.y * dt;
	
	if(bird_vel.y < 0) {
		
		for(Platform *platform in platforms) {
			if([platform checkCollisionWithBirdPos:bird_pos birdSize:bsize]) {
				[self jump];
			}
		}
		
		if(bird_pos.y < -bsize.height/2) {
			[self gameOver];
		}
		
	} else if(bird_pos.y > 240) {
		
		float delta = bird_pos.y - 240;
		bird_pos.y = 240;
		
		for(Cloud *cloud in clouds) {
			[cloud moveDownBy:delta];
		}
		
		highestPlatformY -= delta;
		score += (int)delta;
		NSString *scoreStr = [NSString stringWithFormat:@"%d",score];
		[scoreLabel setString:scoreStr];
		scoreLabel.position = ccp(160-12*[scoreStr length],430);
		
		for(Platform *platform in platforms) {
			[platform moveDownBy:delta];
		}
	}
	
	bird.position = bird_pos;
}

- (void)draw {

}

- (void)jump {
	bird_vel.y = 300.0f + fabsf(bird_vel.x);
}

- (void)gameOver {
	NSLog(@"gameOver");
	gameSuspended = YES;
	NSString *scoreStr = [NSString stringWithFormat:@"Your score: %d",score];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:scoreStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"Play Again",@"Post Score",nil];
	[alert show];
}

- (BOOL)ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	NSLog(@"ccTouchesEnded");
//	[self jump];
	return kEventHandled;
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	if(gameSuspended) return;
	float accel_filter = 0.1f;
	bird_vel.x = bird_vel.x * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"alertView:clickedButtonAtIndex: %i",buttonIndex);
	if(buttonIndex == 0) {
		[self startGame];
	} else {
		// send email with feedback
		[self startGame];
//		NSString *urlString = @"mailto:st@iplayful.com?subject=Lock%20Puzzle%20Feedback";
//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
	}
}

@end
