//
//  TimelineEventTrackView.h
//  VCode
//
//  Created by Joey Hagedorn on 9/29/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import "Event.h"
#import "EventTrack.h"
#import "ClickResult.h"




@interface TimelineEventTrackView : NSView {
	id doc; //CodingDocument
	NSMutableArray *myTracks;
	float nominalTrackHeight;
	ClickResult * clickResult;
	float currentOffset;
	float currentTailOffset;
	unsigned long long playHeadTime;

}

- (void) setDoc:(id)document; //must be a CodingDocument
- (void)addManagedTrack:(EventTrack *)newEventTrack;
- (void)removeManagedTrack:(EventTrack *)oldEventTrack;
- (NSArray *)managedTracks;
- (void)sortManagedTracks;

- (void)drawChevronAtMS:(unsigned long long)milliseconds withColor:(NSColor*)color invertedBorder:(bool)inverted withLabel:(NSString *)label;
- (void)drawChevronAtMS:(unsigned long long)milliseconds withColor:(NSColor*)color andRow:(int)row invertedBorder:(bool)inverted withLabel:(NSString *)label;
- (void)drawFillFromMS:(unsigned long long)start toMS:(unsigned long long)end withColor:(NSColor*)color;
- (void)drawFillFromMS:(unsigned long long)start toMS:(unsigned long long)end withColor:(NSColor*)color invertedBorder:(BOOL)inverted;

- (void)drawPlayHead;
- (ClickResult *)eventAtX:(float)x y:(float)y;
- (float)millisecondsToX:(unsigned long long)milliseconds;
- (unsigned long long) xToMilliseconds:(float)x;



@end
