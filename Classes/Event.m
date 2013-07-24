//
//  Event.m
//  VCode
//
//  Created by Joey Hagedorn on 9/15/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "Event.h"


@implementation Event

//Constructors
- (Event *) init{
	self = [super init];
	
    if ( self ) {
        startTime = 0;
		duration = 0;
    }
	
    return self;
}

- (Event *) initEventAtTime:(unsigned long long)ms withLength:(unsigned long long)length{
	self = [super init];
	
    if ( self ) {
        startTime = ms;
		duration = length;
    }
    return self;
}

- (Event *) initInstantEventAtTime:(unsigned long long)ms{
	self = [super init];
	
    if ( self ) {
        startTime = ms;
		duration = 0;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
    comment = [[coder decodeObjectForKey:@"EVcomment"] retain];
	startTime = [coder decodeInt64ForKey:@"EVstarttime"];
	duration = [coder decodeInt64ForKey:@"EVduration"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    //[super encodeWithCoder:coder];
    [coder encodeInt64:startTime forKey:@"EVstarttime"];
    [coder encodeInt64:duration forKey:@"EVduration"];
    [coder encodeObject:comment forKey:@"EVcomment"];
    return;
}

//Accessors
- (void)setStartTime:(unsigned long long)ms{
	startTime = ms;
}

- (void)setDuration:(unsigned long long)ms{
	duration = ms;
}

- (void)setComment:(NSString *)newComment{
	//[[[doc undoManager] prepareWithInvocationTarget:self] setComment:comment];

	[newComment retain];
	[comment release];
	comment = newComment;
}

- (unsigned long long)startTime{
	return startTime;
}
- (unsigned long long)duration{
	return duration;
}

- (int)intDuration{
	int dur = (int)duration;
	return dur;
}

- (NSComparisonResult)sortComparator:(id)otherObject {
	NSComparisonResult result = NSOrderedSame;
	if([otherObject respondsToSelector:@selector(startTime)]){
		if([self startTime] > [otherObject startTime]) {
			result = NSOrderedDescending;
		} else if ([self startTime] < [otherObject startTime]) {
			result = NSOrderedAscending;
		}
	}
	return result;
}

- (NSString *)comment{
	return comment;	
}
@end
