//
//  TrackListView.h
//  VCode
//
//  Created by Joey Hagedorn on 9/22/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import "EventTrack.h"
#import "TrackItemIndexView.h"

@interface TrackListView : NSView {
	IBOutlet id doc;
}

-(TrackItemIndexView*)viewForEventTrack:(EventTrack *)track;
-(void)syncSubviews;

@end
