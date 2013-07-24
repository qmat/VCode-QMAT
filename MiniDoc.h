//
//  MiniDoc.h
//  AnalysisTool
//
//  Created by Joey Hagedorn on 11/30/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import "EventTrack.h"
#import "DataFileLog.h"
#import <QTKit/QTKit.h>

@interface MiniDoc : NSObject {
	NSMutableArray *eventTracks;
	NSString *moviePath;
	DataFileLog *dataFile;
	unsigned long long movieStartOffset;
	unsigned int skipInterval;
	
	BOOL isShowingSound;
	NSMutableArray *paths; //their Paths, we'll archive and rebuild this
	NSMutableArray *offsets; //NSNumbers representing signed longs of ms off main video.
	BOOL isStacked;
	QTTime movieLength;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType;
- (NSData *)dataRepresentationOfType:(NSString *)aType;

- (void)addEventTrack:(EventTrack *)evtTrk;
- (void)addEventTrack:(EventTrack *)evtTrk atIndex:(int)index;
- (void)removeEventTrack:(EventTrack *)evtTrk;

- (void)setMovieOffset:(unsigned long long)offset;
- (unsigned long long) offset;
- (void)setSkipInterval:(int)interval;
- (unsigned int) interval;

- (void)setMovie:(NSString *)newMoviePath;
- (NSString *)moviePath;
- (QTTime) movieLength;
- (void)setDataFile:(NSString *)newDatafilePath;
- (NSString *)dataFilePath;
- (DataFileLog *)dataFile;


- (NSArray *) eventTracks;
- (EventTrack *) trackNamed:(NSString *)name;


@end
