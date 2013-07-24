//
//  TimelineVolumeTrackView.m
//  VCode
//
//  Created by Joey Hagedorn on 10/21/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "TimelineVolumeTrackView.h"
#import "CodingDocument.h"


@implementation TimelineVolumeTrackView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[super setAutoresizingMask:NSViewWidthSizable];
		cachedImage = nil;
		referenceDataFileLog = nil;
		cachedColor = nil;
		drawsBackground = NO;
		cachedStyle = nil;

		key = [[NSString stringWithString:@"Volume"] retain];
    }
    return self;
}

- (void)dealloc{
	if(key){
		[key release];
	}
	[super dealloc];
}

- (void)drawRect:(NSRect)rect {

	//if image==nil OR dataFileLog != [doc dataFile]
	if(cachedImage == nil || referenceDataFileLog != [doc dataFile] || referenceOffset != [doc movieStartOffset] ||
		cachedColor != [[[doc dataFile] orderedMetricColor] objectAtIndex:[[doc dataFile] indexForKey:key] ] ||
		cachedStyle != [[[doc dataFile] orderedMetricStyle] objectAtIndex:[[doc dataFile] indexForKey:key]]){
		
		cachedColor = [[[doc dataFile] orderedMetricColor] objectAtIndex:[[doc dataFile] indexForKey:key]] ;
		cachedStyle = [[[doc dataFile] orderedMetricStyle] objectAtIndex:[[doc dataFile] indexForKey:key]] ;
		[self redrawCachedImage];
		referenceDataFileLog = [doc dataFile];
		referenceOffset = [doc movieStartOffset];
	}
	[cachedImage drawAtPoint:NSMakePoint(0.0, 0.0)
					fromRect: NSMakeRect(0.0, 0.0, [cachedImage size].width, [cachedImage size].height)
				   operation: NSCompositeSourceOver
					fraction: 1.0];
	
	[self drawPlayHead];
}


-(void)redrawCachedImage{
	//NSLog(@"Caching new Image");
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
	if(doc && [doc dataFilePath] && ([self bounds].size.height>10.0)){
		DataFileLog * dataFile =[doc dataFile];
		NSArray * timestamps = [dataFile timestamps];
		NSArray * metric = [[dataFile dataColumns] objectForKey:key];
		float maxVol = [[[dataFile dataColumnMaxes] objectAtIndex:[dataFile indexForKey:key]] floatValue];
		NSString * trackStyle = [[dataFile orderedMetricStyle] objectAtIndex:[dataFile indexForKey:key]];
		if([trackStyle isEqualTo:@"Points"]){
			for(int i = 0; i<[[dataFile timestamps] count] ; i++){
					[self drawPointAtMS:[[timestamps objectAtIndex:i] unsignedLongLongValue] 
							 withHeight:([[metric objectAtIndex:i] floatValue]/maxVol)];		
			}
		}else if([trackStyle isEqualTo:@"Line"]){

			float insertX = 0.0;
			insertX = [self millisecondsToX:[[timestamps objectAtIndex:0] unsignedLongLongValue]];
			NSRect boundsRect = [self bounds];
			float viewHeight = boundsRect.size.height;
			
			//draw it
			[cachedColor setStroke];
			NSBezierPath* thePath = [NSBezierPath bezierPath];
			[thePath setLineWidth:3.0]; // Has no effect.
			[thePath moveToPoint:NSMakePoint((float)insertX,([[metric objectAtIndex:0] floatValue]/maxVol))];
			for(int i = 1; i<[[dataFile timestamps] count] ; i++){
				insertX = [self millisecondsToX:[[timestamps objectAtIndex:i] unsignedLongLongValue]];
				[thePath lineToPoint:NSMakePoint((float)insertX,(([[metric objectAtIndex:i] floatValue]/maxVol)*viewHeight))]; 
			}
			[thePath stroke];
				
		}else{//trackStyle = @"Bar"
			for(int i = 0; i<[[dataFile timestamps] count] ; i++){
				[self drawTickAtMS:[[timestamps objectAtIndex:i] unsignedLongLongValue] 
						withHeight:([[metric objectAtIndex:i] floatValue]/maxVol)];
			}
		}
			
	}else{
		//draw some text that is like "Oh, you need to load a datafile"
		[@"Please load a datafile to render metrics" drawAtPoint:NSMakePoint(5,5) withAttributes:nil];
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
    [thePath moveToPoint:NSMakePoint((float)insertX,0.0)];
    [thePath lineToPoint:NSMakePoint((float)insertX,(height*viewHeight))]; 
    [thePath stroke];
	return;
}

- (void)drawPointAtMS:(unsigned long long)milliseconds withHeight:(float)height {
	
	float insertX = 0.0;
	insertX = [self millisecondsToX:milliseconds];
	NSRect boundsRect = [self bounds];
	float viewHeight = boundsRect.size.height;
	
	//draw it
	[cachedColor setStroke];
	NSBezierPath* thePath = [NSBezierPath bezierPath];
	[thePath setLineWidth:1.0]; // Has no effect.

	[thePath appendBezierPathWithOvalInRect:NSMakeRect((float) insertX-1, (height*viewHeight), 2.0, 2.0)];
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

- (void) setKey:(NSString *)newKey{
	[newKey retain];
	[key release];
	key = newKey;
	//[self redrawCachedImage];
	[self setNeedsDisplay:YES];
}



- (void) setDrawsBackground:(BOOL)state{
	drawsBackground = state;
}

@end
