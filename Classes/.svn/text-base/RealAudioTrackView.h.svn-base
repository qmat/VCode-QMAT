//
//  TimelineVolumeTrackView.h
//  VCode
//
//  Created by Joey Hagedorn on 10/21/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import "DataFileLog.h"
#import <QTKit/QTKit.h>
#import <AppKit/AppKit.h>

@interface RealAudioTrackView : NSView {
	id doc; //CodingDocument
	NSColor * cachedColor;
	DataFileLog * referenceDataFileLog;
	QTMovie * referenceMovie;
	unsigned long long referenceOffset;
	NSImage * cachedImage;
	BOOL drawsBackground;
	float pixelsPerSecond;
}

- (void) setDoc:(id)document; //CodingDocument
- (void) setDrawsBackground:(BOOL)state;

- (float)millisecondsToX:(unsigned long long)milliseconds;
- (void)drawPlayHead;
- (void)drawTickAtMS:(unsigned long long)milliseconds withHeight:(float)height;
- (void)drawTickAtFraction:(float)position withHeight:(float)height;
- (void)redrawCachedImage;

- (int) sampleCount;
- (float) pixelsPerSecond;
- (void) setPixelsPerSecond:(float)newPixelsPerSecond;


@end


/*
	DataFileLog * file = [[DataFileLog alloc] initWithPath:[[sender alias] fullPath]];
	NSLog(@"path%@",[file path]);
	NSLog(@"start%qu",[file start]);
	NSLog(@"end%qu",[file end]);
	NSLog(@"length%qu",[file length]);
	NSLog(@"pointcount%d",[file pointCount]);
	NSLog(@"volpoints%@",[file volPoints]);
 */