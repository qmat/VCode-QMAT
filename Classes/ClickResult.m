//
//  ClickResult.m
//  VCode
//
//  Created by Joey Hagedorn on 1/20/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "ClickResult.h"


@implementation ClickResult

- (id)initWithEvent:(Event *)event atPart:(int)part withPrevious:(Event *)pEvent andNext:(Event *)nEvent{
    if (self) {
        clickedEvent = [event retain];
        clickedPart = part;
        
        prevEvent = [pEvent retain];
        nextEvent = [nEvent retain];
    }
    return self;
}

- (id)initWithEvent:(Event *)event atPart:(int)part{

    return [self initWithEvent:event atPart:part withPrevious:nil andNext:nil];
}

- (void)dealloc{
	[clickedEvent release];
    [prevEvent release];
    [nextEvent release];
	[super dealloc];
}

- (Event *)clickedEvent{
	return clickedEvent;
}
- (Event *)prevEvent{
	return prevEvent;
}
- (Event *)nextEvent{
	return nextEvent;
}


- (int)clickedPart{
	return clickedPart;
}


@end
