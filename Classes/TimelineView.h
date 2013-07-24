//
//  TimelineView.h
//  VCode
//
//  Created by Joey Hagedorn on 9/30/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import "TimelineEventTrackView.h"
#import "EventTrack.h"
#import "TimelineVolumeTrackView.h"
#import "RealAudioTrackView.h"

@interface TimelineView : NSView {
	TimelineEventTrackView * instantTrack;
	RealAudioTrackView * dataFileVolumeTrack;
	NSMutableArray * rangedTracks;
	NSMutableArray * metricTracks;
	
	

	float pixelsPerSecond;
	float nominalTrackHeight;
	IBOutlet id doc; //Coding Document
	
}
- (void) syncMetricTracks;
- (void) setPixelsPerSecond:(float)pps;
- (void) addTrack:(EventTrack *)track;
- (void) removeTrack:(EventTrack *)track;
//- (void) syncTracks;
- (NSArray *) myTracks;
- (void) sortTracks;

- (void) swapTrackToRanged:(EventTrack *)track;
- (void) swapTrackToInstant:(EventTrack *)track;
- (void) arrangeTracks;
- (void) drawPlayHead;

- (float) nominalTrackHeight;
- (void) setNominalTrackHeight:(float)newHeight;


@end
