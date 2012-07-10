//
//  AppDelegate.h
//  tweejump
//
//  Created by Yannick Loriot on 10/07/12.
//  Copyright Yannick Loriot 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
