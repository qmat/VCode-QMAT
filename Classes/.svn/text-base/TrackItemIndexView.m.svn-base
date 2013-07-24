//
//  TrackItemIndexView.m
//  VCode
//
//  Created by Joey Hagedorn on 9/22/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "TrackItemIndexView.h"
#import "CodingDocument.h"


@implementation TrackItemIndexView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		keyText = [[NSText alloc] init];
		[keyText setFrame:NSMakeRect(5.0,4.0,20.0,20.0)];
		[keyText setFont:[NSFont systemFontOfSize:0]];
		[keyText setTextColor:[NSColor colorWithDeviceWhite:.75 alpha:1]];
		[keyText setEditable:NO];
		[keyText setDrawsBackground:NO];
		[keyText setSelectable:NO];
		[self addSubview:keyText];

		
		trackName = [[NSTextView alloc] init];
		[trackName setFrame:NSMakeRect(20.0,4.0,140.0,20.0)];
		[trackName setFont:[NSFont systemFontOfSize:0]];
		[trackName setTextColor:[NSColor colorWithDeviceWhite:.75 alpha:1]];
		[trackName setEditable:NO];
		[trackName setDrawsBackground:NO];
		[trackName setSelectable:NO];
		
		NSTextContainer *textContainer = [trackName textContainer];
		[textContainer setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
		[textContainer setWidthTracksTextView:NO];
		[trackName setTextContainer:textContainer];
		
		[self addSubview:trackName];
		
		[NSButton setCellClass:[NSButtonCell class]];
		recordEventButton = [[NSButton alloc] init];
		[recordEventButton setTitle:@"Mark"];
		[recordEventButton setBezelStyle:NSRoundedBezelStyle];
		[[recordEventButton cell] setControlSize:NSSmallControlSize];
		[recordEventButton setFrame:NSMakeRect(150.0,0.0,55.0,21.0)];
		[self addSubview:recordEventButton];

		recordEventButtonComment = [[NSButton alloc] init];
		[recordEventButtonComment setTitle:@"+Note"];
		[recordEventButtonComment setBezelStyle:NSRoundedBezelStyle];
		[[recordEventButtonComment cell] setControlSize:NSSmallControlSize];
		[recordEventButtonComment setFrame:NSMakeRect(200.0,0.0,65.0,21.0)];
		[self addSubview:recordEventButtonComment];
		
		
		myTrack = nil;
    }
    return self;
}


-(void) dealloc{
	if(myTrack){
		[myTrack release];
	}
	[trackName release];
	[keyText release];
	[recordEventButton release];
	[recordEventButtonComment release];
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	[trackName setString:[myTrack name]];
	[keyText setString:[myTrack key]];

	NSRect bounds = [self bounds];
    [[myTrack trackColor] set];
    [NSBezierPath fillRect:bounds];
	
	if([myTrack instantaneousMode]){
		[recordEventButton setTitle:@"Mark"];
		[recordEventButtonComment setEnabled:YES];
	}else{
		if([self myTrackIsRecording]){
			[recordEventButton setTitle:@"Out"];
			[recordEventButtonComment setEnabled:NO];
		}else{
			[recordEventButton setTitle:@"In"];
			[recordEventButtonComment setEnabled:YES];
		}
	}
	[recordEventButton setKeyEquivalent:[myTrack key]];//Is this the right place for this?
	[recordEventButtonComment setKeyEquivalent:[myTrack key]];
	[recordEventButtonComment setKeyEquivalentModifierMask:NSAlternateKeyMask];
}
-(void) setDoc:(id)document{ //CodingDocument *
	doc = document;
	[recordEventButton setTarget:[doc eventfulController]];
	[recordEventButton setAction:@selector(addEventNow:)];
	
	[recordEventButtonComment setTarget:[doc eventfulController]];
	[recordEventButtonComment setAction:@selector(addEventNowWithComment:)];
}
-(void) setEventTrack:(EventTrack *)newTrack{
	if(myTrack != nil){
		[myTrack release];
	}
	myTrack = [newTrack retain];
}

-(void) setButtonTag:(int)tag{
	[recordEventButton setTag:tag];
	[recordEventButtonComment setTag:(0-tag)];//Comment button has same ID but negative
}

-(EventTrack *)eventTrack{
	return myTrack;
}

- (BOOL) myTrackIsRecording{
	if(myTrack){
		
		if([[doc recordingEvents] count] == 0){		//Performance Shortcut
			return NO;
		}
		NSArray * myEventList;
		myEventList = [myTrack eventList];
		for(int i=0; i<[myEventList count]; i++){
			if([[doc recordingEvents] containsObject:[myEventList objectAtIndex:i]]){
				return YES;
			}
		}
		
	}
	return NO;
}


@end
