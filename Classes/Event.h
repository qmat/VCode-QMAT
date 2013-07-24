//
//  Event.h
//  VCode
//
//  Created by Joey Hagedorn on 9/15/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>


@interface Event : NSObject {
	unsigned long long startTime; //milliseconds since Jan 1, 1970
	unsigned long long duration; //milliseconds
	NSString * comment;//NSString comment, Nil if there is none.
}

//constructors
- (Event *) initEventAtTime:(unsigned long long)ms withLength:(unsigned long long)length;
- (Event *) initInstantEventAtTime:(unsigned long long)ms;

//Setters
- (void)setStartTime:(unsigned long long)ms;
- (void)setDuration:(unsigned long long)ms;
- (void)setComment:(NSString *)newComment;

//Accessors
//some of these need to be refactored
- (unsigned long long)startTime;
- (unsigned long long)duration;
- (int)intDuration;
- (NSString *)comment;

- (NSComparisonResult)sortComparator:(id)otherObject;
@end
