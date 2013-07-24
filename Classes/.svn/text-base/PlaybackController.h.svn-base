//
//  PlaybackController.h
//  VCode
//
//  Created by Joey Hagedorn on 9/24/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface PlaybackController : NSObject {
	IBOutlet id doc; //CodingDocument
}

- (IBAction) playPause:(id)sender;
- (IBAction) skipAnInterval:(id)sender;
- (IBAction) skipAnIntervalBackwards:(id)sender;
- (IBAction) playAnInterval:(id)sender;
- (IBAction) skipForward:(id)sender;
- (IBAction) skipBackward:(id)sender;
- (void) moveToPercent:(float)percentage;
- (void) moveForward:(unsigned long long)milliseconds;
- (void) moveBackward:(unsigned long long)milliseconds;
- (void) moveTo:(unsigned long long)milliseconds;
- (void) skipToNextEvent;
- (void) skipToPreviousEvent;

@end
