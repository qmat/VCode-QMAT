//
//  EventTrack.m
//  VCode
//
//  Created by Joey Hagedorn on 9/15/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "EventTrack.h"


@implementation EventTrack

+ (EventTrack *) eventTrackWithEventTrack:(EventTrack *)aTrack {
	EventTrack * newTrack = [[[EventTrack alloc] init] autorelease];

	NSArray * trackEvents = [aTrack eventList];
	
	for(int j = 0; j<[trackEvents count]; j++){
		[newTrack addEvent:[trackEvents objectAtIndex:j]];
	}

	[newTrack setInstantaneousMode:[aTrack instantaneousMode]];
	
	[newTrack setTrackColor:[aTrack trackColor]];

	[newTrack setName:[aTrack name]];
	
	[newTrack setKey:[aTrack key]];

	return newTrack;
}

- (id)init
{
    self = [super init];
    if (self) {
        events = [[[NSMutableArray alloc] initWithCapacity:10] retain];
		trackName = [[[NSString alloc] initWithString:@"Untitled Track"] retain];
		triggerKey = [[[NSString alloc] init] retain];
		trackColor = [[NSColor blueColor] retain];//Later this should pick the next in a list each time
		instantaneous = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	events = [[coder decodeObjectForKey:@"ETevents"] retain];
    trackName = [[coder decodeObjectForKey:@"ETname"] retain];
    triggerKey = [[coder decodeObjectForKey:@"ETkey"] retain];
    trackColor = [[coder decodeObjectForKey:@"ETcolor"] retain];
	instantaneous = [coder decodeBoolForKey:@"ETinstant"];
	return self;
}



- (void) dealloc{
	[trackName release];
	[triggerKey release];
	[trackColor release];
	[events release];//Does this free all of the contained elements?
	
	return [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    //[super encodeWithCoder:coder];
    [coder encodeObject:events forKey:@"ETevents"];
    [coder encodeObject:trackName forKey:@"ETname"];
    [coder encodeObject:triggerKey forKey:@"ETkey"];
    [coder encodeObject:trackColor forKey:@"ETcolor"];
	[coder encodeBool:instantaneous forKey:@"ETinstant"];
    return;
}

//evt isn't copied; just inserted; is this wrong?
- (void) addEvent: (Event *)evt
{
	[events insertObject:evt atIndex:[events count]];
    
    [events sortUsingSelector:@selector(sortComparator:)];
    
	[[self undoManager] registerUndoWithTarget:self selector:@selector(removeEvent:) object:evt];
	[[self undoManager] setActionName:@"Mark"];
}

//you actually pass the one you want to remove--is this wrong?
- (void) removeEvent: (Event *)evt{
	[events removeObject:evt];
	[[self undoManager] registerUndoWithTarget:self selector:@selector(addEvent:) object:evt];
	[[self undoManager] setActionName:@"Mark"];
}

//sets instantaneous mode
//1 if instant
- (void) setInstantaneousMode: (BOOL)isInstant{
	instantaneous = isInstant;
}

//YES if ranges are disallowed
//1 if instant
- (BOOL) instantaneousMode{
	return instantaneous;
}

//unimplemented
- (void) setTrackColor: (NSColor *)newColor{
	if (newColor != trackColor){
		if(trackColor)
			[trackColor release];
		trackColor = [newColor retain];
	}
}

//How do we handle memory management with this nscolor?
- (NSColor *) trackColor{
	return trackColor;
}

//return event at given time if one exists, else nil
- (Event *) eventAtTime:(unsigned long long)time{
	int sizeOfEvents = [events count];
	for(int i = 0; i<sizeOfEvents;i++){
		if ( [[events objectAtIndex:i] startTime] == time){
			return [events objectAtIndex:i];
		}
	}
	return nil;
}

//return event at given time if one exists, else nil
- (Event *) eventEndingAtTime:(unsigned long long)time{
	int sizeOfEvents = [events count];
	for(int i = 0; i<sizeOfEvents;i++){
		//The following line fails, and i'm not sure why!!!!
		int duration =  [[events objectAtIndex:i] intDuration];
		unsigned long long startTime = [[events objectAtIndex:i] startTime];
		if(duration != 0){
			if ( startTime + duration == time){
				return [events objectAtIndex:i];
			}
		}
	}
	return nil;
}

//return event at given time if one exists, else nil
- (Event *) eventInMiddleAtTime:(unsigned long long)time{
	int sizeOfEvents = [events count];
	for(int i = 0; i<sizeOfEvents;i++){
		int duration =  [[events objectAtIndex:i] intDuration];

		if(duration != 0){
			if ( [[events objectAtIndex:i] startTime] <= time &&
				[[events objectAtIndex:i] startTime] +
				duration >= time){
				return [events objectAtIndex:i];
			}
		}
	}
	return nil;
}

// Return event previous to supplied event.
// By start time.
// Returns nil if event isn't found or is the first.
// Relies on [events] being sorted
- (Event *) eventPreviousToEvent:(Event *)event
{
    int indexOfEvent = [events indexOfObject:event];
    
    if (indexOfEvent == NSNotFound) return nil;
    if (indexOfEvent == 0) return nil;
    
    return [events objectAtIndex:indexOfEvent - 1];
}

// Return event previous to supplied event.
// By start time.
// Returns nil if event isn't found or is the last.
// Relies on [events] being sorted
- (Event *) eventSubsequentToEvent:(Event *)event
{
    int indexOfEvent = [events indexOfObject:event];
    
    if (indexOfEvent == NSNotFound) return nil;
    if (indexOfEvent == [events count] - 1) return nil;
    
    return [events objectAtIndex:indexOfEvent + 1];
}


//returns copy of events array
//How do we handle memory management with this nsarray?
- (NSArray *) eventList{
	return [[[NSArray alloc] initWithArray:events] autorelease];
}

- (NSString *) name{
	return [[[NSString alloc] initWithString:trackName] autorelease];
}

- (NSString *) key{
	return [[[NSString alloc] initWithString:triggerKey] autorelease];
}

- (void) setName: (NSString *)newName{
	[trackName release];
	trackName = [[[NSString alloc] initWithString:newName] retain];
}
- (void) setKey: (NSString *)key{
	[triggerKey release];
	if([key length]>0){
		triggerKey = [[key substringToIndex:1] retain];
	}else{
		triggerKey = [[NSString stringWithString:@""] retain];
	}
}

- (NSUndoManager *) undoManager{
	return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}

@end
