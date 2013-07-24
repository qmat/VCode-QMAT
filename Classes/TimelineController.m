//
//  TimelineController.m
//  VCode
//
//  Created by Joey Hagedorn on 9/30/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "TimelineController.h"
#import "CodingDocument.h"


@implementation TimelineController

- (id)init
{
    self = [super init];
    if (self) {
		/*
		 defaultColors = [[NSArray arrayWithObjects:
		 [NSColor colorWithCalibratedRed:(float)(71.0/255.0) green:(float)(72.0/255.0) blue:(float)(249.0/255.0) alpha:(float)1.0],
		 [NSColor colorWithCalibratedRed:(float)(189.0/255.0) green:(float)(40.0/255.0) blue:(float)(44.0/255.0) alpha:(float)1.0],
		 [NSColor colorWithCalibratedRed:(float)(255.0/255.0) green:(float)(226.0/255.0) blue:(float)(21.0/255.0) alpha:(float)1.0],
		 [NSColor colorWithCalibratedRed:(float)(54.0/255.0) green:(float)(204.0/255.0) blue:(float)(12.0/255.0) alpha:(float)1.0],
		 [NSColor colorWithCalibratedRed:(float)(255.0/255.0) green:(float)(161.0/255.0) blue:(float)(0.0/255.0) alpha:(float)1.0],
		 [NSColor colorWithCalibratedRed:(float)(119.0/255.0) green:(float)(214.0/255.0) blue:(float)(255.0/255.0) alpha:(float)1.0],
		 [NSColor colorWithCalibratedRed:(float)(134.0/255.0) green:(float)(61.0/255.0) blue:(float)(255.0/255.0) alpha:(float)1.0],
		 [NSColor colorWithCalibratedRed:(float)(153.0/255.0) green:(float)(102.0/255.0) blue:(float)(50.0/255.0) alpha:(float)1.0],
		 nil] retain];
		 */
		defaultColors = [[NSArray arrayWithObjects:
						  [NSColor colorWithCalibratedRed:0.74901960784313726 green:0.11372549019607843 blue:0.11372549019607843 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.45098039215686275 green:0.023529411764705882 blue:0.023529411764705882 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.45098039215686275 green:0.38823529411764707 blue:0.023529411764705882 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.16470588235294117 green:0.15686274509803921 blue:0.45098039215686275 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.078431372549019607 green:0.22745098039215686 blue:0.11764705882352941 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.39215686274509803 green:0.20392156862745098 blue:0.60784313725490191 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.27843137254901962 green:0.15294117647058825 blue:0.15294117647058825 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.58039215686274515 green:0.25882352941176473 blue:0.25882352941176473 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.24705882352941178 green:0.32941176470588235 blue:0.26666666666666666 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.73725490196078436 green:0.35686274509803922 blue:0.16470588235294117 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.18431372549019609 green:0.1803921568627451 blue:0.28235294117647058 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.0 green:0.46274509803921571 blue:0.46274509803921571 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:1.0 green:0.34901960784313724 blue:0.34901960784313724 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.32156862745098042 green:0.45098039215686275 blue:0.77647058823529413 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.16862745098039217 green:0.47843137254901963 blue:0.090196078431372548 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.10588235294117647 green:0.0 blue:0.38039215686274508 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.38039215686274508 green:0.14117647058823529 blue:0.0 alpha:(float)1.0],
						  [NSColor colorWithCalibratedRed:0.33725490196078434 green:0.058823529411764705 blue:0.36862745098039218 alpha:(float)1.0],
						  nil] retain];
    }
    return self;
}

- (void) dealloc{
	[defaultColors release];		
	return [super dealloc];
}


#pragma mark Add/Delete/Edit Tracks

- (IBAction) addTrack:(id)sender{
	EventTrack * newTrack = [[EventTrack alloc] init];
	
	int selectedRow = [indexTable selectedRow];
	if(selectedRow>-1){
		[doc addEventTrack:newTrack atIndex:(selectedRow+1)];
	}else{
		[doc addEventTrack:newTrack];
		selectedRow = [[doc eventTracks] count]-1;
	}
	[newTrack setTrackColor:[defaultColors objectAtIndex:(([[doc eventTracks] count] - 1)%[defaultColors count])]];
	
	[timelineView addTrack:newTrack];	
	[indexTable reloadData];
	[indexTable selectRow:(selectedRow+1) byExtendingSelection:NO];
	//[indexTable selectRowIndexes:[NSIndexSet indexSetWithIndex:(selectedRow+1)] byExtendingSelection:NO];
	[indexCustomView setNeedsDisplay:YES];
}

- (IBAction) removeTrack:(id)sender{
	if([[doc eventTracks] count]>0){
		int selectedRow = [indexTable selectedRow];
		if(selectedRow>(-1)){
			EventTrack * oldTrack = [[doc eventTracks] objectAtIndex:selectedRow];

			[timelineView removeTrack:oldTrack];

			[doc removeEventTrack:oldTrack];
			[timelineView removeTrack:oldTrack];
			
			[indexTable reloadData];
			[indexCustomView setNeedsDisplay:YES];

		}
	}
}


- (IBAction) toggleRange:(id)sender{
	int clickedRow = [sender clickedRow];
	EventTrack *activeTrack;
	
	activeTrack = [[doc eventTracks] objectAtIndex:clickedRow];
	
	
	//if any of the track's events are currently in the doc's recordingEvents
	//  then remove them from recording events
	//  reenable thingy.
	
	
	[activeTrack setInstantaneousMode:(![activeTrack instantaneousMode])];
	[indexCustomView syncSubviews];

	if(	[activeTrack instantaneousMode]){
		[timelineView swapTrackToInstant:activeTrack];
	}else{
		[timelineView swapTrackToRanged:activeTrack];
	}
	
}






- (void) scrollToNow{
	float percentPlayed;
	percentPlayed = [doc percentPlayed];
	
	NSRect tvBounds = [timelineView bounds];
	NSRect viewingPortal = [[timelineView enclosingScrollView] bounds];
	[timelineView scrollPoint:NSMakePoint((percentPlayed * tvBounds.size.width)-(viewingPortal.size.width/2),
										  [timelineView visibleRect].origin.y)];
	[timelineView setNeedsDisplay:YES];
}

- (void) sizeToMovie{
	//insert if movie protecting garbage
	
	float movieSeconds;
	float pixelsPerSecond = 50;
	movieSeconds = (float) ([doc timelineEnd] - [doc timelineStart])/1000;
	NSRect tvBounds = [timelineView bounds];
	[timelineView setPixelsPerSecond:pixelsPerSecond];
    [timelineView setFrameSize:NSMakeSize(movieSeconds*pixelsPerSecond,tvBounds.size.height)];
	[timelineView setNeedsDisplay:YES];
}


- (void) updateTimeline{
	if(doc && timelineView){

		 //make sure view has all tracks in document.
		NSMutableArray * docTracks = [NSMutableArray arrayWithArray:[doc eventTracks]];
		[docTracks removeObjectsInArray:[timelineView myTracks]];

		for(int i=0;i<[docTracks count];i++){
			[timelineView addTrack:[docTracks objectAtIndex:i]];
		}

		//make sure it has no more.
		NSMutableArray * viewTracks = [NSMutableArray arrayWithArray:[timelineView myTracks]];
		[viewTracks removeObjectsInArray:[doc eventTracks]];
		for(int i=0;i<[viewTracks count];i++){
			[timelineView removeTrack:[viewTracks objectAtIndex:i]];
		}
		
		//[timelineView syncMetricTracks];
		[timelineView sortTracks]; 
		[timelineView setNeedsDisplay:YES];
		}
}
- (void) updateTimelineAndSync{
	if(doc && timelineView){
		
		//make sure view has all tracks in document.
		NSMutableArray * docTracks = [NSMutableArray arrayWithArray:[doc eventTracks]];
		[docTracks removeObjectsInArray:[timelineView myTracks]];
		
		for(int i=0;i<[docTracks count];i++){
			[timelineView addTrack:[docTracks objectAtIndex:i]];
		}
		
		//make sure it has no more.
		NSMutableArray * viewTracks = [NSMutableArray arrayWithArray:[timelineView myTracks]];
		[viewTracks removeObjectsInArray:[doc eventTracks]];
		for(int i=0;i<[viewTracks count];i++){
			[timelineView removeTrack:[viewTracks objectAtIndex:i]];
		}
		
		[timelineView syncMetricTracks];
		[timelineView sortTracks]; 
		[timelineView setNeedsDisplay:YES];
	}
}

@end
