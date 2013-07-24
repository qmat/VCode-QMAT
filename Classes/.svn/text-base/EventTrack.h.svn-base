//
//  EventTrack.h
//  VCode
//
//  Created by Joey Hagedorn on 9/15/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import "Event.h"


@interface EventTrack : NSObject {
	NSMutableArray *events;
	NSColor *trackColor;
	BOOL instantaneous;//instantaneous or range
	//order in list???
	NSString *trackName;
	NSString *triggerKey;
}

+ (EventTrack *) eventTrackWithEventTrack:(EventTrack *)aTrack;

- (void) addEvent: (Event *)evt;
- (void) removeEvent: (Event *)evt;
- (void) setInstantaneousMode: (BOOL)isInstant;
- (BOOL) instantaneousMode;
- (void) setTrackColor: (NSColor *)newColor;
- (NSColor *) trackColor;
- (Event *) eventAtTime:(unsigned long long)time;
- (Event *) eventEndingAtTime:(unsigned long long)time;
- (Event *) eventInMiddleAtTime:(unsigned long long)time;

- (NSArray *) eventList;

- (NSString *) name;
- (NSString *) key;
- (void) setName: (NSString *)newName;
- (void) setKey: (NSString *)key;
- (NSUndoManager *) undoManager;

@end
