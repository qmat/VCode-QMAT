//
//  EventfulController.h
//  VCode
//
//  Created by Joey Hagedorn on 9/16/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "Event.h"
#import "EventTrack.h"
#import "TimelineController.h"
#import "TrackListView.h"

@interface EventfulController : NSObject {
	IBOutlet id doc; //type CodingDocument
	IBOutlet NSTableView *indexTable;
	IBOutlet TrackListView *indexCustomView;
	IBOutlet NSScrollView *indexScrollView;
	IBOutlet TimelineController *timelineController;
	
	IBOutlet NSPanel * commentSheet;
	IBOutlet NSWindow * docWindow;
	IBOutlet NSTextField * commentField;


	
	//These are used to hold data while a sheet is open.
	bool wasPlaying; //if movie was playing when we clicked add
	int trackIndex; //track that this was called on.
	Event * editingEvent;
	
	//This is for the color admin table
	int colorRow;        // the row color changes apply to
    
    EventTrack *activeTrack;
    Event *activeEvent;
}

- (IBAction) addEventNow:(id)sender;
- (IBAction) addConsecutiveEventNow:(id)sender;
- (IBAction) addEventNowWithComment:(id)sender;
- (IBAction) doneCommenting:(id)sender;
- (IBAction) insertSpecialChar:(id)sender;

- (void) setActiveEventComment:(NSString*)comment;

- (Event *) addEventToTrack:(EventTrack *)activeTrack;


- (void) destroyEvent:(Event *)evt;
- (void) editEventComment:(Event *)evt;

- (void) setActiveEvent:(Event *)evt;
- (Event *) activeEvent;
- (void) setActiveTrack:(EventTrack *)eventTrack;
- (EventTrack *) activeTrack;
- (EventTrack *) trackContainingEvent:(Event *)event;

//silly helper stuff
-(BOOL) array:(NSArray *)array containsEventOnTrack:(EventTrack *)aTrack;



//for the color admin table too
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
@end
