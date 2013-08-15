//
//  PlaybackController.m
//  VCode
//
//  Created by Joey Hagedorn on 9/24/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "PlaybackController.h"
#import "CodingDocument.h"
#import "Event.h"


@implementation PlaybackController

- (IBAction) playPause:(id)sender{
	if((QTMovie *)[doc movie]){
		if([(QTMovie *)[doc movie] rate]>0.0){
			[(QTMovie *)[doc movie] stop];
		}else{
			[(QTMovie *)[doc movie] play];
		}
	}

}

- (IBAction) skipAnInterval:(id)sender{
	if([doc movie]){
		QTTime currentTime = [(QTMovie *)[doc movie] currentTime];
		QTTime incTime = QTTimeFromString(  [NSString stringWithFormat:@"00:00:00:%d.00/600", [doc skipInterval] ]);
		QTTime roundedTime =  QTTimeFromString(@"00:00:00:00.00/600");


		//round currentTime down to multiple of skipInterval
		while(NSOrderedAscending == QTTimeCompare(QTTimeIncrement(roundedTime, incTime), currentTime) ||
			  NSOrderedSame == QTTimeCompare(QTTimeIncrement(roundedTime, incTime), currentTime)){
			roundedTime = QTTimeIncrement(roundedTime, incTime);
		}
		
		QTTime newTime = QTTimeIncrement(roundedTime, incTime);
		[(QTMovie *)[doc movie] setRate:0];

		[(QTMovie *)[doc movie] setCurrentTime:newTime];
	}
}
- (IBAction) skipAnIntervalBackwards:(id)sender{
	if([doc movie]){
		QTTime currentTime = [(QTMovie *)[doc movie] currentTime];
		QTTime incTime = QTTimeFromString(  [NSString stringWithFormat:@"00:00:00:%d.00/600", [doc skipInterval] ]);
		QTTime roundedTime =  QTTimeFromString(@"00:00:00:00.00/600");
		
		
		//round currentTime down to multiple of skipInterval
		while(NSOrderedAscending == QTTimeCompare(QTTimeIncrement(roundedTime, incTime), currentTime) ||
			  NSOrderedSame == QTTimeCompare(QTTimeIncrement(roundedTime, incTime), currentTime)){
			roundedTime = QTTimeIncrement(roundedTime, incTime);
		}
		
		QTTime newTime = QTTimeDecrement(roundedTime, incTime);
		[(QTMovie *)[doc movie] setRate:0];
		
		[(QTMovie *)[doc movie] setCurrentTime:newTime];
	}
}

- (IBAction) playAnInterval:(id)sender{
	if([doc movie]){
		QTTime currentTime = [(QTMovie *)[doc movie] currentTime];
		QTTime incTime = QTTimeFromString(  [NSString stringWithFormat:@"00:00:00:%d.00/600", [doc skipInterval] ]);
		QTTime roundedTime =  QTTimeFromString(@"00:00:00:00.00/600");
		
		//round currentTime down to multiple of skipInterval
		while(NSOrderedAscending == QTTimeCompare(QTTimeIncrement(roundedTime, incTime), currentTime) ||
			  NSOrderedSame == QTTimeCompare(QTTimeIncrement(roundedTime, incTime), currentTime)){
			roundedTime = QTTimeIncrement(roundedTime, incTime);
		}
		
		QTTimeRange timeRange = QTMakeTimeRange(roundedTime, incTime);
		
		[(QTMovie *)[doc movie] setSelection:timeRange];
		[[doc movie] setPlaysSelectionOnly:YES];
		[(QTMovie *)[doc movie] play];
		
		//Idle handler sets plays selection to NO if movie is stopped.
	}
}

- (IBAction) skipForward:(id)sender{
	if([doc movie]){
		QTTime currentTime = [(QTMovie *)[doc movie] currentTime];
		QTTime incTime = QTTimeFromString(  @"00:00:00:02.00/600" );
		QTTime newTime = QTTimeIncrement(currentTime, incTime);
		[(QTMovie *)[doc movie] setCurrentTime:newTime];
	}
}
- (IBAction) skipBackward:(id)sender{
	if((QTMovie *)[doc movie]){
		QTTime currentTime = [(QTMovie *)[doc movie] currentTime];
		QTTime incTime = QTTimeFromString( @"00:00:00:02.00/600");
		QTTime newTime = QTTimeDecrement(currentTime, incTime);
		[(QTMovie *)[doc movie] setCurrentTime:newTime];
	}
}

- (void) moveToPercent:(float)percentage{
	if([doc movie]){
		QTTime duration = [(QTMovie *)[doc movie] duration];
		QTTime scaledTime = QTMakeTimeScaled(duration, (long)(duration.timeScale * percentage));
		QTTime newTime = QTMakeTime (scaledTime.timeValue, duration.timeScale);
		[(QTMovie *)[doc movie] setCurrentTime:newTime];
	}
}

- (void) moveForward:(unsigned long long)milliseconds{
	if([doc movie]){
		QTTime currentTime = [(QTMovie *)[doc movie] currentTime];
		QTTime incTime = QTMakeTime(milliseconds,(long)1000);
		QTTime newTime = QTTimeIncrement(currentTime, incTime);
		[(QTMovie *)[doc movie] setCurrentTime:newTime];
	}
}
- (void) moveBackward:(unsigned long long)milliseconds{
	if((QTMovie *)[doc movie]){
		QTTime currentTime = [(QTMovie *)[doc movie] currentTime];
		QTTime incTime = QTMakeTime(milliseconds,(long)1000);
		QTTime newTime = QTTimeDecrement(currentTime, incTime);
		[(QTMovie *)[doc movie] setCurrentTime:newTime];
	}
}
- (void) moveTo:(unsigned long long)milliseconds{
	if([doc movie]){
		QTTime newTime = QTMakeTime(milliseconds,(long)1000);
		[(QTMovie *)[doc movie] setCurrentTime:newTime];
	}
}

- (void) skipToNextEvent{
	if((QTMovie *)[doc movie]) {
		unsigned long long currentTime = [doc playheadTime];
		NSMutableArray * allEvents = [NSMutableArray array];
		for (id track in [doc eventTracks]){
			[allEvents addObjectsFromArray:[track eventList]];
		}
		[allEvents sortUsingSelector:@selector(sortComparator:)];
		Event * targetEvent = nil;
		for (id event in allEvents){
			if ([event startTime] > (currentTime + 10)){
				targetEvent = event;
				break;
			}
		}
		if(targetEvent){
			unsigned long milliseconds = (long)([targetEvent startTime] - [doc movieStartOffset]);
			QTTime newTime = QTMakeTime(milliseconds,(long)1000);
			[(QTMovie *)[doc movie] setCurrentTime:newTime];
		}
	}
}
- (void) skipToPreviousEvent {
	if((QTMovie *)[doc movie]) {
		unsigned long long currentTime = [doc playheadTime];
		NSMutableArray * allEvents = [NSMutableArray array];
		for (id track in [doc eventTracks]){
			[allEvents addObjectsFromArray:[track eventList]];
		}
		[allEvents sortUsingSelector:@selector(sortComparator:)];
		Event * targetEvent = nil;
		for (int i = ([allEvents count] - 1); i>=0; i--){
			Event * event = [allEvents objectAtIndex:i];
			if ([event startTime] < (currentTime - 10)){
				targetEvent = event;
				break;
			}
		}
		if(targetEvent){
			unsigned long milliseconds = (long)([targetEvent startTime] - [doc movieStartOffset]);
			QTTime newTime = QTMakeTime(milliseconds,(long)1000);
			[(QTMovie *)[doc movie] setCurrentTime:newTime];
		}
	}
}

- (void) jklRate:(bool)stepUp
{
    NSArray* rateSteps = @[@-10, @-4, @-2, @-1, @-0.5, @0, @0.5, @1, @2, @4, @10];
    
    float currentRate = [(QTMovie *)[doc movie] rate];
    
    NSUInteger currentRateIndex = [rateSteps indexOfObject:[NSNumber numberWithFloat:currentRate]];
    
    if (currentRateIndex == NSNotFound) currentRateIndex = 0;
    
    if (stepUp)
    {
        if (currentRateIndex == [rateSteps count] -1) return;
        
        [(QTMovie *)[doc movie] setRate:[[rateSteps objectAtIndex:currentRateIndex + 1] floatValue]];
    }
    else
    {
        if (currentRateIndex == 0) return;
        
        [(QTMovie *)[doc movie] setRate:[[rateSteps objectAtIndex:currentRateIndex - 1] floatValue]];
    }
}

@end
