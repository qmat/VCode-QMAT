//
//  MultiMovieView.h
//  MovieViewTest
//
//  Created by Joey Hagedorn on 3/1/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011

//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "ClickyQTMovieView.h"


@interface MultiMovieView : NSView {
	NSMutableArray * movies;
	NSMutableArray * offsets;
	QTMovie * keyMovie;
	QTMovie * syncedMovie;
	BOOL controllerVisible;
}

//+ (MultiMovieView *) multiMovieViewWithMovies:(NSArray *)movies;


- (void) addMovie:(QTMovie * )movie;
- (void) addMovie:(QTMovie * )movie withOffset:(signed long)offset;
- (void) removeMovie:(QTMovie * )movie;

- (NSArray *) movies;
- (void) setMovies:(NSArray *)newMovies;
//second array is an array of NSNumbers holding Signed Longs
- (void) setMovies:(NSArray *)newMovies withOffsets:(NSArray *)offsets;


- (signed long) offsetForMovie:(QTMovie *)movie;
- (void) setOffsetForMovie:(QTMovie *)movie to:(signed long)offset;

- (QTMovie *) keyMovie;
- (void) setKeyMovie:(QTMovie *)movie;

- (QTMovie *) syncedMovie;
- (void) setSyncedMovie:(QTMovie *)movie;

- (BOOL) isControllerVisible;
- (void) setControllerVisible:(BOOL)boolean;

- (void) play;
- (void) stop;
- (bool) isPlaying;




//Position in decimal percent?--Just emulate whatever calls we use on QTMovie, and do them on syncedMovie

//position in milliseconds?

//setPosition (in ms?)

//Private
- (void)positionSubviews;
- (ClickyQTMovieView *) viewForMovie:(QTMovie *) movie;
- (QTTime) boundedTimeForMovie:(QTMovie *) movie intendedTime:(QTTime)time;
- (void)syncMovies;
//well not private, but you know
- (void)keyMovieTimeChanged:(NSNotification *)notification;
- (void)keyMovieRateChanged:(NSNotification *)notification;
- (void)boundsDidChange:(NSNotification *)notification;


@end
