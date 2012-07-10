/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */



#import "CCMenu.h"
#import "CCDirector.h"
#import "Support/CGPointExtension.h"
#import "ccMacros.h"

#import <Availability.h>
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import "Platforms/iOS/CCDirectorIOS.h"
#import "Platforms/iOS/CCTouchDispatcher.h"
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#import "Platforms/Mac/MacGLView.h"
#import "Platforms/Mac/CCDirectorMac.h"
#endif

enum {
	kDefaultPadding =  5,
};

@implementation CCMenu

@synthesize opacity = opacity_, color = color_;

- (id) init
{
	NSAssert(NO, @"CCMenu: Init not supported.");
	[self release];
	return nil;	
}

+(id) menuWithItems: (CCMenuItem*) item, ...
{
	va_list args;
	va_start(args,item);
	
	id s = [[[self alloc] initWithItems: item vaList:args] autorelease];
	
	va_end(args);
	return s;
}

-(id) initWithItems: (CCMenuItem*) item vaList: (va_list) args
{
	if( (self=[super init]) ) {

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		self.isTouchEnabled = YES;
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
		self.isMouseEnabled = YES;
#endif
		
		// menu in the center of the screen
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		self.isRelativeAnchorPoint = NO;
		anchorPoint_ = ccp(0.5f, 0.5f);
		[self setContentSize:s];
		
		// XXX: in v0.7, winSize should return the visible size
		// XXX: so the bar calculation should be done there
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		CGRect r = [[UIApplication sharedApplication] statusBarFrame];
		ccDeviceOrientation orientation = [[CCDirector sharedDirector] deviceOrientation];
		if( orientation == CCDeviceOrientationLandscapeLeft || orientation == CCDeviceOrientationLandscapeRight )
			s.height -= r.size.width;
		else
			s.height -= r.size.height;
#endif
		self.position = ccp(s.width/2, s.height/2);

		int z=0;
		
		if (item) {
			[self addChild: item z:z];
			CCMenuItem *i = va_arg(args, CCMenuItem*);
			while(i) {
				z++;
				[self addChild: i z:z];
				i = va_arg(args, CCMenuItem*);
			}
		}
	//	[self alignItemsVertically];
		
		selectedItem_ = nil;
		state_ = kCCMenuStateWaiting;
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

/*
 * override add:
 */
-(void) addChild:(CCMenuItem*)child z:(NSInteger)z tag:(NSInteger) aTag
{
	NSAssert( [child isKindOfClass:[CCMenuItem class]], @"Menu only supports MenuItem objects as children");
	[super addChild:child z:z tag:aTag];
}

- (void) onExit
{
	if(state_ == kCCMenuStateTrackingTouch)
	{
		[selectedItem_ unselected];		
		state_ = kCCMenuStateWaiting;
		selectedItem_ = nil;
	}
	[super onExit];
}
	
#pragma mark Menu - Touches

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority swallowsTouches:YES];
}

-(CCMenuItem *) itemForTouch: (UITouch *) touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	
	CCMenuItem* item;
	CCARRAY_FOREACH(children_, item){
		// ignore invisible and disabled items: issue #779, #866
		if ( [item visible] && [item isEnabled] ) {
			
			CGPoint local = [item convertToNodeSpace:touchLocation];
			CGRect r = [item rect];
			r.origin = CGPointZero;
			
			if( CGRectContainsPoint( r, local ) )
				return item;
		}
	}
	return nil;
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if( state_ != kCCMenuStateWaiting || !visible_ )
		return NO;
	
	for( CCNode *c = self.parent; c != nil; c = c.parent )
		if( c.visible == NO )
			return NO;

	selectedItem_ = [self itemForTouch:touch];
	[selectedItem_ selected];
	
	if( selectedItem_ ) {
		state_ = kCCMenuStateTrackingTouch;
		return YES;
	}
	return NO;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchEnded] -- invalid state");
	
	[selectedItem_ unselected];
	[selectedItem_ activate];
	
	state_ = kCCMenuStateWaiting;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchCancelled] -- invalid state");
	
	[selectedItem_ unselected];
	
	state_ = kCCMenuStateWaiting;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	NSAssert(state_ == kCCMenuStateTrackingTouch, @"[Menu ccTouchMoved] -- invalid state");
	
	CCMenuItem *currentItem = [self itemForTouch:touch];
	
	if (currentItem != selectedItem_) {
		[selectedItem_ unselected];
		selectedItem_ = currentItem;
		[selectedItem_ selected];
	}
}

#pragma mark Menu - Mouse

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

-(NSInteger) mouseDelegatePriority
{
	return kCCMenuMousePriority+1;
}

-(CCMenuItem *) itemForMouseEvent: (NSEvent *) event
{
	CGPoint location = [(CCDirectorMac*)[CCDirector sharedDirector] convertEventToGL:event];
	
	CCMenuItem* item;
	CCARRAY_FOREACH(children_, item){
		// ignore invisible and disabled items: issue #779, #866
		if ( [item visible] && [item isEnabled] ) {
			
			CGPoint local = [item convertToNodeSpace:location];
			
			CGRect r = [item rect];
			r.origin = CGPointZero;
			
			if( CGRectContainsPoint( r, local ) )
				return item;
		}
	}
	return nil;
}

-(BOOL) ccMouseUp:(NSEvent *)event
{
	if( ! visible_ )
		return NO;

	if(state_ == kCCMenuStateTrackingTouch) {
		if( selectedItem_ ) {
			[selectedItem_ unselected];
			[selectedItem_ activate];
		}
		state_ = kCCMenuStateWaiting;
		
		return YES;
	}
	return NO;
}

-(BOOL) ccMouseDown:(NSEvent *)event
{
	if( ! visible_ )
		return NO;
	
	selectedItem_ = [self itemForMouseEvent:event];
	[selectedItem_ selected];

	if( selectedItem_ ) {
		state_ = kCCMenuStateTrackingTouch;
		return YES;
	}

	return NO;	
}

-(BOOL) ccMouseDragged:(NSEvent *)event
{
	if( ! visible_ )
		return NO;

	if(state_ == kCCMenuStateTrackingTouch) {
		CCMenuItem *currentItem = [self itemForMouseEvent:event];
		
		if (currentItem != selectedItem_) {
			[selectedItem_ unselected];
			selectedItem_ = currentItem;
			[selectedItem_ selected];
		}
		
		return YES;
	}
	return NO;
}

#endif // Mac Mouse support

#pragma mark Menu - Alignment
-(void) alignItemsVertically
{
	[self alignItemsVerticallyWithPadding:kDefaultPadding];
}
-(void) alignItemsVerticallyWithPadding:(float)padding
{
	float height = -padding;
	
	CCMenuItem *item;
	CCARRAY_FOREACH(children_, item)
	    height += item.contentSize.height * item.scaleY + padding;

	float y = height / 2.0f;
	
	CCARRAY_FOREACH(children_, item) {
		CGSize itemSize = item.contentSize;
	    [item setPosition:ccp(0, y - itemSize.height * item.scaleY / 2.0f)];
	    y -= itemSize.height * item.scaleY + padding;
	}
}

-(void) alignItemsHorizontally
{
	[self alignItemsHorizontallyWithPadding:kDefaultPadding];
}

-(void) alignItemsHorizontallyWithPadding:(float)padding
{
	
	float width = -padding;
	CCMenuItem *item;
	CCARRAY_FOREACH(children_, item)
	    width += item.contentSize.width * item.scaleX + padding;

	float x = -width / 2.0f;
	
	CCARRAY_FOREACH(children_, item){
		CGSize itemSize = item.contentSize;
		[item setPosition:ccp(x + itemSize.width * item.scaleX / 2.0f, 0)];
		x += itemSize.width * item.scaleX + padding;
	}
}

-(void) alignItemsInColumns: (NSNumber *) columns, ...
{
	va_list args;
	va_start(args, columns);
	
	[self alignItemsInColumns:columns vaList:args];
	
	va_end(args);
}

-(void) alignItemsInColumns: (NSNumber *) columns vaList: (va_list) args
{
	NSMutableArray *rows = [[NSMutableArray alloc] initWithObjects:columns, nil];
	columns = va_arg(args, NSNumber*);
	while(columns) {
        [rows addObject:columns];
		columns = va_arg(args, NSNumber*);
	}
    
	int height = -5;
    NSUInteger row = 0, rowHeight = 0, columnsOccupied = 0, rowColumns;
	CCMenuItem *item;
	CCARRAY_FOREACH(children_, item){
		NSAssert( row < [rows count], @"Too many menu items for the amount of rows/columns.");
        
		rowColumns = [(NSNumber *) [rows objectAtIndex:row] unsignedIntegerValue];
		NSAssert( rowColumns, @"Can't have zero columns on a row");
        
		rowHeight = fmaxf(rowHeight, item.contentSize.height);
		++columnsOccupied;
        
		if(columnsOccupied >= rowColumns) {
			height += rowHeight + 5;

			columnsOccupied = 0;
			rowHeight = 0;
			++row;
		}
	}
	NSAssert( !columnsOccupied, @"Too many rows/columns for available menu items." );

	CGSize winSize = [[CCDirector sharedDirector] winSize];
    
	row = 0; rowHeight = 0; rowColumns = 0;
	float w, x, y = height / 2;
	CCARRAY_FOREACH(children_, item) {
		if(rowColumns == 0) {
			rowColumns = [(NSNumber *) [rows objectAtIndex:row] unsignedIntegerValue];
			w = winSize.width / (1 + rowColumns);
			x = w;
		}

		CGSize itemSize = item.contentSize;
		rowHeight = fmaxf(rowHeight, itemSize.height);
		[item setPosition:ccp(x - winSize.width / 2,
							  y - itemSize.height / 2)];
            
		x += w;
		++columnsOccupied;
		
		if(columnsOccupied >= rowColumns) {
			y -= rowHeight + 5;
			
			columnsOccupied = 0;
			rowColumns = 0;
			rowHeight = 0;
			++row;
		}
	}

	[rows release];
}

-(void) alignItemsInRows: (NSNumber *) rows, ...
{
	va_list args;
	va_start(args, rows);
	
	[self alignItemsInRows:rows vaList:args];
	
	va_end(args);
}

-(void) alignItemsInRows: (NSNumber *) rows vaList: (va_list) args
{
	NSMutableArray *columns = [[NSMutableArray alloc] initWithObjects:rows, nil];
	rows = va_arg(args, NSNumber*);
	while(rows) {
		[columns addObject:rows];
		rows = va_arg(args, NSNumber*);
	}

	NSMutableArray *columnWidths = [[NSMutableArray alloc] init];
	NSMutableArray *columnHeights = [[NSMutableArray alloc] init];
	
	int width = -10, columnHeight = -5;
	NSUInteger column = 0, columnWidth = 0, rowsOccupied = 0, columnRows;
	CCMenuItem *item;
	CCARRAY_FOREACH(children_, item){
		NSAssert( column < [columns count], @"Too many menu items for the amount of rows/columns.");
		
		columnRows = [(NSNumber *) [columns objectAtIndex:column] unsignedIntegerValue];
		NSAssert( columnRows, @"Can't have zero rows on a column");
		
		CGSize itemSize = item.contentSize;
		columnWidth = fmaxf(columnWidth, itemSize.width);
		columnHeight += itemSize.height + 5;
		++rowsOccupied;
		
		if(rowsOccupied >= columnRows) {
			[columnWidths addObject:[NSNumber numberWithUnsignedInteger:columnWidth]];
			[columnHeights addObject:[NSNumber numberWithUnsignedInteger:columnHeight]];
			width += columnWidth + 10;
			
			rowsOccupied = 0;
			columnWidth = 0;
			columnHeight = -5;
			++column;
		}
	}
	NSAssert( !rowsOccupied, @"Too many rows/columns for available menu items.");
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	column = 0; columnWidth = 0; columnRows = 0;
	float x = -width / 2, y;
	
	CCARRAY_FOREACH(children_, item){
		if(columnRows == 0) {
			columnRows = [(NSNumber *) [columns objectAtIndex:column] unsignedIntegerValue];
			y = ([(NSNumber *) [columnHeights objectAtIndex:column] intValue] + winSize.height) / 2;
		}
		
		CGSize itemSize = item.contentSize;
		columnWidth = fmaxf(columnWidth, itemSize.width);
		[item setPosition:ccp(x + [(NSNumber *) [columnWidths objectAtIndex:column] unsignedIntegerValue] / 2,
							  y - winSize.height / 2)];
		
		y -= itemSize.height + 10;
		++rowsOccupied;
		
		if(rowsOccupied >= columnRows) {
			x += columnWidth + 5;
			
			rowsOccupied = 0;
			columnRows = 0;
			columnWidth = 0;
			++column;
		}
	}
	
	[columns release];
	[columnWidths release];
	[columnHeights release];
}

#pragma mark Menu - Opacity Protocol

/** Override synthesized setOpacity to recurse items */
- (void) setOpacity:(GLubyte)newOpacity
{
	opacity_ = newOpacity;
	
	id<CCRGBAProtocol> item;
	CCARRAY_FOREACH(children_, item)
		[item setOpacity:opacity_];
}

-(void) setColor:(ccColor3B)color
{
	color_ = color;
	
	id<CCRGBAProtocol> item;
	CCARRAY_FOREACH(children_, item)
		[item setColor:color_];
}
@end
