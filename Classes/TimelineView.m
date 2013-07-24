//
//  TimelineView.m
//  VCode
//
//  Created by Joey Hagedorn on 9/30/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.
#import "TimelineView.h"
#import "CodingDocument.h"


@implementation TimelineView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		instantTrack = [[TimelineEventTrackView alloc]initWithFrame:NSMakeRect(0.0,0.0,(frame.size.width),24)];
		dataFileVolumeTrack = [[RealAudioTrackView alloc]initWithFrame:NSMakeRect(0.0,25,(frame.size.width),48)];

		[super addSubview:instantTrack];
		[super addSubview:dataFileVolumeTrack];

		nominalTrackHeight = 24.0;
		rangedTracks = [[NSMutableArray alloc] initWithCapacity:5];
		metricTracks = [[NSMutableArray alloc] initWithCapacity:5];

	}
    return self;
}
- (void)awakeFromNib {
//Setup Rulers!

	[[self enclosingScrollView] setHasHorizontalRuler:YES];
	[[self enclosingScrollView] setRulersVisible:YES];
	[[[self enclosingScrollView] horizontalRulerView] setClientView:self];
	[instantTrack setDoc:doc];
	[self syncMetricTracks];
	[dataFileVolumeTrack setDoc:doc];
	[dataFileVolumeTrack setDrawsBackground:YES];
	[dataFileVolumeTrack setNeedsDisplay:YES];

}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.

	//gray background
    [[NSColor colorWithDeviceWhite:0.95 alpha:1] set];
    [NSBezierPath fillRect:[self bounds]];
	
	
	[self drawPlayHead];
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

- (void) syncMetricTracks{
	for(id volumeView in metricTracks){
		[volumeView removeFromSuperview];
	}
	[metricTracks removeAllObjects];
	
	NSArray * keys = [[doc dataFile] orderedMetricKeys];
	NSArray * enabled = [[doc dataFile] orderedMetricEnabled];
	for(int i=0; i<[keys count] ; i++){
		if([[enabled objectAtIndex:i] isEqual:[NSNumber numberWithInt:NSOnState]]){
			id newView = [[TimelineVolumeTrackView alloc]initWithFrame:NSMakeRect(0.0,25,([self frame].size.width),[self nominalTrackHeight] * 2)];
			[newView setDoc:doc];
			[newView setKey:[keys objectAtIndex:i]];
			[metricTracks addObject:newView];
			[self addSubview:newView];
		}
	}
	
	
	
	

	
	
	
	[self arrangeTracks];
}

- (void) addTrack:(EventTrack *)track{
//Also set Docs for instantTrack; because itdoesn't work in init
	if([track instantaneousMode]){
		[instantTrack addManagedTrack:track];
		[self arrangeTracks];
	}else{
		TimelineEventTrackView * newTrack = [[TimelineEventTrackView alloc]initWithFrame:NSMakeRect(0.0,0.0,([self frame].size.width),24)];
		[newTrack setDoc:doc];
		[newTrack addManagedTrack:track];
		[rangedTracks addObject:newTrack];
		[self addSubview:newTrack];
		[self arrangeTracks];
		[self setNeedsDisplay:YES];
		//Alloc a new view, etc
	}
}

- (void) removeTrack:(EventTrack *)track{
	if([[instantTrack managedTracks] containsObject:track]){
		[instantTrack removeManagedTrack:track];
	}else{

		//dealloc corresponding view; etc
		for(int i=0; i<[rangedTracks count];i++){
			TimelineEventTrackView * thisView = [rangedTracks objectAtIndex:i];
			EventTrack * thisTrack = [[thisView managedTracks] objectAtIndex:0];
			
			if(track==thisTrack){
				[thisView removeFromSuperview];
				[rangedTracks removeObject:thisView];//last reference, so it should go away now.
				
			}
		}
		[self arrangeTracks];
	}
}

- (void) setPixelsPerSecond:(float)pps{
	
	if(pps>0){
		pixelsPerSecond = pps;
		
		NSArray *upArray;
		NSArray *downArray;
		upArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:2.0], nil];
		
		downArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5],[NSNumber numberWithFloat:0.2], nil];
		[NSRulerView registerUnitWithName:@"Seconds" 
							 abbreviation:NSLocalizedString(@"sec", @"Seconds abbreviation string")
			 unitToPointsConversionFactor:pps
							  stepUpCycle:upArray
							stepDownCycle:downArray];
		
		[[[self enclosingScrollView] horizontalRulerView] setMeasurementUnits:@"Seconds"];
		[dataFileVolumeTrack setPixelsPerSecond:pixelsPerSecond];
	}
	

}

- (NSArray *) myTracks{
	NSMutableArray * allTracks = [[NSMutableArray alloc] initWithCapacity:5];
	[allTracks addObjectsFromArray:	[instantTrack managedTracks]];
	
	for(int i = 0; i<([rangedTracks count]);i++){
		[allTracks addObject:[[[rangedTracks objectAtIndex:i] managedTracks] objectAtIndex:0]];
	}
	
	return [allTracks autorelease];
}


//move each track to the correct y-height
- (void) arrangeTracks{
	[self sortTracks];
	
	float ypos = 0.0;
	float yheight = [self nominalTrackHeight];
	if([[instantTrack managedTracks] count] > 0){
	[instantTrack setFrame:NSMakeRect(0.0,0.0,([self frame].size.width)
									  ,(yheight+(([[instantTrack managedTracks] count]-1)*(yheight/4))))];
	}else{
		[instantTrack setFrame:NSMakeRect(0.0,0.0,([self frame].size.width)
										  ,1.0)];
	}
	
	for(int i =0; i<[rangedTracks count];i++){
		ypos = ((float)i * (yheight + 1)) + ([instantTrack frame].size.height + 1); //heights of those above you plus 1 pixel padding[self bounds]
		[[rangedTracks objectAtIndex:i] setFrame:NSMakeRect(0.0,ypos,([self frame].size.width),yheight)];
	}
	ypos = ((float)[rangedTracks count] * (yheight + 1)) + ([instantTrack frame].size.height + 1);
	if([doc isStacked]){
		BOOL first = YES;
		for(id view in metricTracks){
			if(first){
				[view setDrawsBackground:YES];
				first = NO;
			}else{
				[view setDrawsBackground:NO];
			}			
			[view setFrame:NSMakeRect(0.0,ypos,([self frame].size.width),yheight*2)];
		}
		ypos = (ypos + (yheight*2 + 1));
	}else{
		for(id view in metricTracks){
			[view setDrawsBackground:YES];
			[view setFrame:NSMakeRect(0.0,ypos,([self frame].size.width),yheight*2)];
			ypos = (ypos + (yheight*2 + 1));
		}
	}
	if([doc isShowingSound]){
		[dataFileVolumeTrack setFrame:NSMakeRect(0.0,ypos,([self frame].size.width),yheight*2)];
	}else{
		[dataFileVolumeTrack setFrame:NSMakeRect(0.0,ypos,([self frame].size.width),1.0)];
	}
	ypos = (ypos + ([dataFileVolumeTrack frame].size.height + 1));
	[self setFrameSize:NSMakeSize([self frame].size.width, ypos)];
}


- (BOOL)isFlipped{
	return YES;
}


//perhaps there are more efficient implementations
- (void) swapTrackToRanged:(EventTrack *)track{
	[self removeTrack:track];
	[self addTrack:track];
}

//perhaps there are more efficient implementations
- (void) swapTrackToInstant:(EventTrack *)track{
	[self removeTrack:track];
	[self addTrack:track];
}

- (float) nominalTrackHeight{
	return nominalTrackHeight;
}

- (void) setNominalTrackHeight:(float)newHeight{
	nominalTrackHeight = newHeight;
}


- (void) sortTracks{
	[instantTrack sortManagedTracks];
	
	NSMutableArray * sortedRangedTracks = [NSMutableArray arrayWithCapacity:[rangedTracks count]+1];
	NSArray * evtTracks = [doc eventTracks];
	for(int i=0;i<[evtTracks count];i++){
		for(int j = 0; j<[rangedTracks count]; j++){
			if([[[rangedTracks objectAtIndex:j] managedTracks]objectAtIndex:0] == [evtTracks objectAtIndex:i]){
				[sortedRangedTracks addObject:[rangedTracks objectAtIndex:j]];
			}
		}
	}
	[rangedTracks release];
	rangedTracks = sortedRangedTracks;
	[rangedTracks retain];
	
	return;
}




@end
