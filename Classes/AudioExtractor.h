//
//  AudioExtractor.h
//  VCode
//
//  Created by Joey Hagedorn on 3/17/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import <QuickTime/QuickTime.h>
#import  <CoreAudio/CoreAudio.h>




@interface AudioExtractor : NSObject {
	QTMovie * movie;
	NSMutableArray * samples;
	int samplecount;

}

- (id)init;
- (id)initWithSamplecount:(int)newSamplecount;

- (QTMovie *) movie;
- (void) setMovie:(QTMovie *)newMovie;
- (void) resampleMovie;
- (NSArray *) samples;
- (int) samplecount;
- (void) setSamplecount:(int)newSamplecount;



//private
- (float) movieLength;
- (float) samplerate;

@end
