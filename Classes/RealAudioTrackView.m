//
//  TimelineVolumeTrackView.m
//  VCode
//
//  Created by Joey Hagedorn on 10/21/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "RealAudioTrackView.h"
#import "CodingDocument.h"
#import "AudioExtractor.h"

@implementation RealAudioTrackView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[super setAutoresizingMask:NSViewWidthSizable];
		cachedImage = nil;
		referenceDataFileLog = nil;
		cachedColor = nil;
		drawsBackground = NO;

    }
    return self;
}

- (void)drawRect:(NSRect)rect {

	//if image==nil OR dataFileLog != [doc dataFile]
	if((cachedImage == nil || referenceDataFileLog != [doc dataFile] || referenceMovie != (QTMovie *)[doc movie]) &&  ([self bounds].size.height>10.0)){	
		[self redrawCachedImage];
		cachedColor = [NSColor blueColor];
		referenceDataFileLog = [doc dataFile];
		referenceOffset = [doc movieStartOffset];
	}
	if(cachedImage){
		[cachedImage drawAtPoint:NSMakePoint(0.0, 0.0)
					fromRect: NSMakeRect(0.0, 0.0, [cachedImage size].width, [cachedImage size].height)
				   operation: NSCompositeSourceOver
					fraction: 1.0];
	}
	[self drawPlayHead];
}


-(void)redrawCachedImage{
	//NSLog(@"Caching new WaveForm");
	if(cachedImage != nil){
		[cachedImage release];
	}
	cachedImage = [[NSImage alloc] initWithSize:([self bounds].size)];
	
	[cachedImage retain];
	[cachedImage lockFocus];
	//White Background
	if(drawsBackground){
		[[NSColor colorWithDeviceWhite:.75 alpha:1] set];
		[NSBezierPath fillRect:[self bounds]];
	}
	if(doc && [doc dataFilePath] && [doc movie] && ([self bounds].size.height>10.0)){
		referenceMovie = (QTMovie *)[doc movie];


		AudioExtractor *extractor = [[[AudioExtractor alloc] initWithSamplecount:[self sampleCount]] autorelease];
		
		[extractor setMovie:(QTMovie *)[doc movie]];
		
		NSArray * metric = [extractor samples];
		if([metric count] == 0){
			[@"Waveform unavailable for this video due to audio format incompatability" drawAtPoint:NSMakePoint(5,5) withAttributes:nil];
		}else{
			float maxVol = 0.0;
			for(int i=0; i<[metric count]; i++){
				if([[metric objectAtIndex:i] floatValue] > maxVol){
					maxVol = fabs([[metric objectAtIndex:i] floatValue]);
				}
			}
			for(int i = 0; i<[metric count] ; i++){
				
				[self drawTickAtFraction:((float)i / [metric count])
						withHeight:([[metric objectAtIndex:i] floatValue]/maxVol)];			
			}
		}
	}else{
		[@"Please load a datafile to render audio waveform" drawAtPoint:NSMakePoint(5,5) withAttributes:nil];
		
	}
	[cachedImage unlockFocus];
}

//height is a percentage of viewHeight
- (void)drawTickAtMS:(unsigned long long)milliseconds withHeight:(float)height {
	float insertX = 0.0;
	insertX = [self millisecondsToX:milliseconds];
	NSRect boundsRect = [self bounds];
	float viewHeight = boundsRect.size.height;
	
	//draw it
	[cachedColor setStroke];
	NSBezierPath* thePath = [NSBezierPath bezierPath];
	[thePath setLineWidth:1.0]; // Has no effect.
    [thePath moveToPoint:NSMakePoint((float)insertX,(viewHeight/2))];
    [thePath lineToPoint:NSMakePoint((float)insertX,(viewHeight/2) + ((height/2)*viewHeight))]; 
    [thePath stroke];
	return;
}

- (void)drawTickAtFraction:(float)position withHeight:(float)height {
	float insertX = 0.0;
	NSRect boundsRect = [self bounds];
	int viewWidth = boundsRect.size.width;
	float viewHeight = boundsRect.size.height;
	insertX = position * viewWidth;

	//draw it
	[cachedColor setStroke];
	NSBezierPath* thePath = [NSBezierPath bezierPath];
	[thePath setLineWidth:1.0]; // Has no effect.
    [thePath moveToPoint:NSMakePoint((float)insertX,(viewHeight/2))];
    [thePath lineToPoint:NSMakePoint((float)insertX,(viewHeight/2) + ((height/2)*viewHeight))]; 
    [thePath stroke];
	return;
}

- (void)drawPlayHead{
	if(doc){
		float viewHeight = [self bounds].size.height;
		float viewWidth = [self bounds].size.width;
		float playheadX = viewWidth * [doc percentPlayed];
		
		//draw it
		[[NSColor blackColor] setStroke];
		NSBezierPath* thePath = [NSBezierPath bezierPath];
		[thePath setLineWidth:1.0]; // Has no effect.
		[thePath moveToPoint:NSMakePoint((float)playheadX,0.0)];
		[thePath lineToPoint:NSMakePoint((float)playheadX,viewHeight)]; 
		[thePath stroke];
	}
	return;
}

- (float) millisecondsToX:(unsigned long long)milliseconds {
	
	float fractionalPosition = 0.0;
	NSRect boundsRect = [self bounds];
	int viewWidth = boundsRect.size.width;
	fractionalPosition = (float)(milliseconds - [doc timelineStart]) / ((float)([doc timelineEnd] - [doc timelineStart]));
	return (float)(fractionalPosition * viewWidth);
}


- (void)setDoc:(id)document{ //CodingDocument *
	doc = document;
	return;
}

- (int) sampleCount{
	return (((float)([doc timelineEnd] - [doc timelineStart])/1000) * pixelsPerSecond);
}

- (float) pixelsPerSecond {
	return pixelsPerSecond;
}
- (void) setPixelsPerSecond:(float)newPixelsPerSecond {
	pixelsPerSecond = newPixelsPerSecond;
}




- (void) setDrawsBackground:(BOOL)state{
	drawsBackground = state;
}

@end
