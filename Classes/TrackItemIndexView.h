//
//  TrackItemIndexView.h
//  VCode
//
//  Created by Joey Hagedorn on 9/22/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
//#import <DarkKit/DarkKit.h>
#import "EventTrack.h"

@interface TrackItemIndexView : NSView {
	id  doc; //CodingDocument
	int trackTag;
	NSButton *recordEventButton;
	NSButton *recordEventButtonComment;
	NSTextView *trackName;
	NSText *keyText;
	EventTrack *myTrack;
}

-(void) setDoc:(id)document;

-(void) setButtonTag:(int)tag;
-(void) setEventTrack:(EventTrack *)newTrack;
-(EventTrack *)eventTrack;
- (BOOL) myTrackIsRecording;

@end
