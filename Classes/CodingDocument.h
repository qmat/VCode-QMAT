//
//  CodingDocument.h
//  VCode
//
//  Created by Joey Hagedorn on 9/15/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.


#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "EventTrack.h"
#import "Event.h"
#import "DataFileLog.h"
#import "EventfulController.h"
#import "DocumentController.h"
#import "TimelineController.h"
#import "PlaybackController.h"
#import "MultiMovieView.h"


@interface CodingDocument : NSDocument
{	
	IBOutlet EventfulController *myController;
	IBOutlet TimelineController *timelineController;
	IBOutlet DocumentController *docController;
	IBOutlet PlaybackController *playbackController;
	
	IBOutlet MultiMovieView *movieView;
	IBOutlet NSWindow * docWindow;
	IBOutlet NSWindow * adminWindow;

	NSString *moviePath;
	QTMovie *movie;
	DataFileLog *dataFile;
	unsigned long long movieStartOffset; //exact time in ms since Jan 1 1970 where movie starts
	NSMutableArray *auxMovies; //QTMovies--we won't archive this
	NSMutableArray *auxMoviePaths; //their Paths, we'll archive and rebuild this
	NSMutableArray *auxMovieOffsets; //NSNumbers representing signed longs of ms off main video.
	
	NSMutableArray *eventTracks;
	NSMutableArray *recordingEvents;
	
	BOOL isStacked;
	BOOL isShowingSound;
	BOOL isShowingAdminWindow;
	BOOL isInIntervalMode;
	BOOL intervalContinuous;
	int skipInterval;
}


-(IBAction) toggleAdminWindow:(id)sender;
-(IBAction) exportEventTextFile:(id)sender;

- (IBAction) tbzAddConsecutiveEventNow:(id)sender;
- (IBAction) tbzSetActiveEventComment:(id)sender;
- (IBAction) tbzMakePreviousEventActive:(id)sender;
- (IBAction) tbzMakeSubsequentEventActive:(id)sender;
- (IBAction) tbzRewind:(id)sender;

- (NSString *) representedFilename;


- (void) setMovie:(NSString *)path;
- (QTMovie *) movie;
- (NSString *) moviePath;
- (MultiMovieView *) movieView;

- (void)addAuxMovie:(NSString *)path withOffset:(NSNumber *)offset;
- (void)removeAuxMovie:(NSString *)path;
- (void)removeAuxMovieAtIndex:(int)index;

- (NSArray *)auxMoviePaths;
- (NSArray *)auxMovieOffsets;
- (NSArray *)auxMovies;

- (void) setOffsetOfAuxMovieAtIndex:(int)index to:(NSNumber *)anObject;

- (DataFileLog *) dataFile;
- (void)setDatafile:(NSString *)path;
- (NSString *) dataFilePath;


- (unsigned long long) playheadTime;
- (unsigned long long) timelineStart;
- (unsigned long long) timelineEnd;

- (unsigned long long) movieStartOffset;
- (void) setMovieStartOffset:(unsigned long long)newOffset;

- (int) skipInterval;
- (void) setSkipInterval:(int)newInterval;
- (BOOL) isInIntervalMode;
- (void) setIsInIntervalMode:(BOOL)state;
- (BOOL) intervalContinuous;
- (void) setIntervalContinuous:(BOOL)state;
- (BOOL) isShowingAdminWindow;
- (void) setIsShowingAdminWindow:(BOOL)state;
- (BOOL) isStacked;
- (void) setIsStacked:(BOOL)state;

- (float) percentPlayed;
- (EventfulController *) eventfulController;
- (TimelineController *) timelineController;
- (DocumentController *) docController;
- (PlaybackController *) playbackController;

- (NSArray *) metricStyles;

- (void)addEventTrack:(EventTrack *)evtTrk;
- (void)addEventTrack:(EventTrack *)evtTrk atIndex:(int)index;
- (void)removeEventTrack:(EventTrack *)evtTrk;
- (void)moveEventTrackFromIndex:(int)beginIndex toIndex:(int)endIndex;

- (NSArray *) eventTracks;

- (void)addRecordingEvent:(Event *)newEvent;
- (void)removeRecordingEvent:(Event *)oldEvent;
- (NSArray *) recordingEvents;
- (void)stretchRecordingEvents;

- (void)removeMovieIdleCallback;
- (void)installMovieIdleCallback;

@end

