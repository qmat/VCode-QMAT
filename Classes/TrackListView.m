//
//  TrackListView.m
//  VCode
//
//  Created by Joey Hagedorn on 9/22/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "TrackListView.h"
#import "CodingDocument.h"

@implementation TrackListView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	//gray background
    [[NSColor colorWithDeviceWhite:0.95 alpha:1] set];
    [NSBezierPath fillRect:[self bounds]];
	
	
	[self syncSubviews];
	/*
	int views = [[self subviews] count];
	for(int i=0;i<views; i++){
		[[[self subviews] objectAtIndex:i] setNeedsDisplay:YES];
	}
	 */
}


- (BOOL)isFlipped{
	return YES;
}



-(TrackItemIndexView*)viewForEventTrack:(EventTrack *)track{

	//this really shouldn't go here, but must, because it dies in sync subviews
	[self setFrameSize:NSMakeSize([self frame].size.width,[[doc eventTracks] count]*(24 + 1))];

	if([self subviews]){

		for(int i=0;i<[[self subviews] count]; i++){
			TrackItemIndexView *theView = [[self subviews] objectAtIndex:i];
			if([theView eventTrack]==track){
				return theView;
			}
		}
	}//Else
	return nil;
}

-(void)syncSubviews{
	NSArray *eventTracks = [doc eventTracks];
	int trackQty = [eventTracks count];
	for(int i=0;i<trackQty;i++){
		EventTrack *theTrack = [eventTracks objectAtIndex:i];
		TrackItemIndexView *theView = [self viewForEventTrack:theTrack];
		if(theView==nil){
			theView = [[TrackItemIndexView alloc] initWithFrame:NSMakeRect(0.0,(float)((24 + 1)*i),([self frame].size.width),24.0)];
			[theView setDoc:doc];
			[theView setEventTrack:theTrack];
			[self addSubview:theView];
		}
		[theView setButtonTag:(i+1)];
	}

	for(int i=0;i<[[self subviews] count];i++){
		TrackItemIndexView *theView = [[self subviews] objectAtIndex:i];
		EventTrack *theTrack = [theView eventTrack];
		if([eventTracks containsObject:theTrack]==NO){
			[theView removeFromSuperview];
		}
	}

	
	for(int i=0;i<trackQty;i++){
		EventTrack *theTrack = [eventTracks objectAtIndex:i];
		TrackItemIndexView *theView = [self viewForEventTrack:theTrack];
		[theView setFrameOrigin:NSMakePoint(0.0,(float)((24 + 1)*i))];
	}
	
	//set my size
}


@end
