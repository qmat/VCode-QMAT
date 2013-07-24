//
//  ClickResult.h
//  VCode
//
//  Created by Joey Hagedorn on 1/20/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import "Event.h"

#define EVENTHEAD 1
#define EVENTINTERIM 2
#define EVENTTAIL 3


@interface ClickResult : NSObject {
	
	Event * clickedEvent;
	int clickedPart;
}
- (id)initWithEvent:(Event *)event atPart:(int)part;
- (Event *)clickedEvent;
- (int)clickedPart;

@end
