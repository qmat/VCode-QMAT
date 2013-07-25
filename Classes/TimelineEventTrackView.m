//
//  TimelineEventTrackView.m
//  VCode
//
//  Created by Joey Hagedorn on 9/29/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "TimelineEventTrackView.h"

#import "EventfulController.h"
#import "TimelineView.h"
#import "CodingDocument.h"


@implementation TimelineEventTrackView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		thisEvent = nil;
		currentOffset = 0.0;
		myTracks = [[[NSMutableArray alloc] initWithCapacity:5] retain];
		nominalTrackHeight = [self frame].size.height;
		[super setAutoresizingMask:NSViewWidthSizable];
		
    }
    return self;
}

- (void)dealloc{
	[myTracks release];
	[super dealloc];
}


- (void)drawRect:(NSRect)rect {	
	//White Background
	[[NSColor colorWithDeviceWhite:0.75 alpha:1] set];
	[NSBezierPath fillRect:[self bounds]];


	Event * currentEvent;
	EventTrack * currentTrack;
	unsigned long long milliseconds;
	unsigned long long duration;
	bool hasComment = NO;
	
	for(int i = 0; i<[myTracks count];i++){
		currentTrack = [myTracks objectAtIndex:i];

		NSArray * currentEventArray = [currentTrack eventList];
		int eventCount = [currentEventArray count];
		for(int j = 0; j<eventCount; j++){
			currentEvent = [currentEventArray objectAtIndex:j];
			milliseconds = [currentEvent startTime];
			duration = [currentEvent duration];
            
            if([currentEvent comment] && [[currentEvent comment] length] == 0)
            {
				NSLog(@"comment exists but length is zero");
			}
            
			[self drawChevronAtMS:milliseconds withColor:[currentTrack trackColor] andRow:([myTracks count] -i -1) invertedBorder:hasComment withLabel:[currentTrack key]];
			
			//if the track is !instantaneous AND event duration >0 then 
			if((![currentTrack instantaneousMode]) && (duration > 0)){
				[self drawChevronAtMS:(milliseconds+duration) withColor:[currentTrack trackColor] invertedBorder:NO withLabel:[currentTrack key]];
                [self drawFillFromMS:milliseconds toMS:milliseconds+duration fillColor:[currentTrack trackColor] strokeColor:[NSColor whiteColor] label:[currentEvent comment]];
			}
		}
	}
	
	[self drawPlayHead];
}

- (void)drawFillFromMS:(unsigned long long)start toMS:(unsigned long long)end withColor:(NSColor*)color
{
	[self drawFillFromMS:(start) toMS:(end) fillColor:color strokeColor:[NSColor whiteColor] label:nil];
}

- (void)drawFillFromMS:(unsigned long long)start toMS:(unsigned long long)end withColor:(NSColor*)color invertedBorder:(BOOL)inverted
{
    [self drawFillFromMS:start toMS:end fillColor:color strokeColor:inverted ? [NSColor blackColor] : [NSColor whiteColor] label:nil];
}

- (void)drawFillFromMS:(unsigned long long)start toMS:(unsigned long long)end fillColor:(NSColor*)fillColor strokeColor:(NSColor*)strokeColor label:(NSString*)label
{
	float startX = 0.0;
	float endX = 0.0;
	float viewHeight = [self bounds].size.height;
	
	startX = [self millisecondsToX:start];
	endX = [self millisecondsToX:end];
	
	[fillColor setFill];
    [strokeColor setStroke];
	
	//NSRect fillRect = NSMakeRect(startX,(0.25*viewHeight),(endX-startX),(0.5*viewHeight));
	//NSRectFill(fillRect);

	NSBezierPath* thePath = [NSBezierPath bezierPath];
	[thePath setLineWidth:1.0]; // Has no effect.
    [thePath moveToPoint:NSMakePoint(startX+(0.25*viewHeight),(0.25*viewHeight))];
	[thePath lineToPoint:NSMakePoint(endX-(0.25*viewHeight),(0.25*viewHeight))]; 

    [thePath lineToPoint:NSMakePoint(endX-(0.25*viewHeight),(0.75*viewHeight))]; 
	[thePath lineToPoint:NSMakePoint(startX+(0.25*viewHeight),(0.75*viewHeight))]; 

    [thePath lineToPoint:NSMakePoint(startX+(0.25*viewHeight),(0.25*viewHeight))];
	[thePath closePath];
	[thePath fill];

	NSBezierPath* strokePath = [NSBezierPath bezierPath];
    [strokePath moveToPoint:NSMakePoint(startX+(0.25*viewHeight),(0.25*viewHeight))];
	[strokePath lineToPoint:NSMakePoint(endX-(0.25*viewHeight),(0.25*viewHeight))]; 
	
    [strokePath moveToPoint:NSMakePoint(endX-(0.25*viewHeight),(0.75*viewHeight))]; 
	[strokePath lineToPoint:NSMakePoint(startX+(0.25*viewHeight),(0.75*viewHeight))]; 
	
    //[strokePath moveToPoint:NSMakePoint(startX+(0.25*viewHeight),(0.25*viewHeight))];
	[strokePath closePath];
    [strokePath stroke];
	
    if (label)
    {
        NSRect textBounds = NSMakeRect(startX, 0.25*viewHeight, endX-startX, 0.5*viewHeight);
        [label drawInRect:textBounds withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, nil]];
    }
    
	return;
}


- (void)drawChevronAtMS:(unsigned long long)milliseconds withColor:(NSColor*)color invertedBorder:(bool)inverted withLabel:(NSString *)label{
	[self drawChevronAtMS:milliseconds withColor:color andRow:0 invertedBorder:inverted withLabel:label];
	return;
}

- (void)drawChevronAtMS:(unsigned long long)milliseconds withColor:(NSColor*)color andRow:(int)row invertedBorder:(bool)inverted withLabel:(NSString *)label{
	float insertX = 0.0;
	insertX = [self millisecondsToX:milliseconds];
	float chevronHeight = nominalTrackHeight;
	//chevronHeight = [[self superview] nominalTrackHeight];
	
	//draw it
	if(!inverted){
		[[NSColor whiteColor] setStroke];
	}else{
		[[NSColor blackColor] setStroke];
	}
	[color setFill];
	NSBezierPath* thePath = [NSBezierPath bezierPath];
	[thePath setLineWidth:1.0]; // Has no effect.
    [thePath moveToPoint:NSMakePoint((float)insertX,((chevronHeight/4.0)*row))];
	[thePath lineToPoint:NSMakePoint((float)insertX+(chevronHeight/2),((chevronHeight/4.0)*row)+(chevronHeight/2))]; 
    [thePath lineToPoint:NSMakePoint((float)insertX,((chevronHeight/4.0)*row)+chevronHeight)]; 
	[thePath lineToPoint:NSMakePoint((float)insertX-(chevronHeight/2),((chevronHeight/4.0)*row)+(chevronHeight/2))]; 
    [thePath lineToPoint:NSMakePoint((float)insertX,((chevronHeight/4.0)*row))];
	[thePath closePath];
	[thePath fill];
    [thePath stroke];
	
	NSColor * textColor;
	if([color brightnessComponent] > 0.66){
		textColor= [NSColor blackColor];
	}else{
		textColor= [NSColor whiteColor];
	}
	NSMutableParagraphStyle *paragStyle = [[[NSMutableParagraphStyle  alloc] init] autorelease];
	[paragStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[paragStyle setAlignment:NSCenterTextAlignment];
	NSDictionary * attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:textColor, NSForegroundColorAttributeName, paragStyle, NSParagraphStyleAttributeName, [NSFont fontWithName:@"Lucida Grande" size:10.0], NSFontAttributeName, nil];
	[label drawInRect: NSMakeRect((float)insertX-(chevronHeight/4.0), ((chevronHeight/4.0)*row)+chevronHeight/4.0, (chevronHeight/2), (chevronHeight/2)) withAttributes:attributeDict];

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

//Event handling stuff

- (void)mouseDown:(NSEvent *)theEvent {
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	Event * clickedTimelineEvent = nil;
	ClickResult * clickedObject = [self eventAtX:(curPoint.x) y:(curPoint.y)];
	if(clickedObject != nil){
		clickedTimelineEvent = [clickedObject clickedEvent];
	}else{//else jump to this time.
		[[doc playbackController] moveToPercent:((float)(curPoint.x) / (float)[self bounds].size.width)];
	}

	if (([theEvent clickCount] > 1)) {
		if(clickedTimelineEvent){
			[[doc eventfulController] editEventComment: clickedTimelineEvent];
		}
    }
	
	if ([theEvent modifierFlags] & NSAlternateKeyMask) {
		//find event in tree, delete it!
		if(clickedTimelineEvent){
			[[doc eventfulController] destroyEvent: clickedTimelineEvent];
			thisEvent = nil;
		}
	}else{
		if(clickedTimelineEvent){
			thisEvent = clickedTimelineEvent;
			thisEventPart = [clickedObject clickedPart];
			currentOffset = curPoint.x - [self millisecondsToX:[clickedTimelineEvent startTime]];
			currentTailOffset = curPoint.x - [self millisecondsToX:([clickedTimelineEvent startTime] + [clickedTimelineEvent duration])];
		}else{
			thisEvent = nil;
			thisEventPart = 0;
			currentOffset = curPoint.x;
			currentTailOffset = 0;
			playHeadTime = [doc playheadTime];
		}


	}

}
- (void)mouseDragged:(NSEvent *)theEvent {
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if(thisEvent){
		if([thisEvent duration] != 0){
			if(thisEventPart == EVENTHEAD){
				unsigned long long difference = [self xToMilliseconds:(curPoint.x - currentOffset)] - [thisEvent startTime];
				[thisEvent setStartTime:[self xToMilliseconds:(curPoint.x - currentOffset)]];
				[thisEvent setDuration:([thisEvent duration] - difference)];
				
			}else if(thisEventPart == EVENTINTERIM){
				[thisEvent setStartTime:[self xToMilliseconds:(curPoint.x - currentOffset)]];
			}else if(thisEventPart == EVENTTAIL){
				unsigned long long difference = [self xToMilliseconds:(curPoint.x - currentTailOffset)] - [thisEvent startTime];
				[thisEvent setDuration:difference];

			}
		}else{
			[thisEvent setStartTime:[self xToMilliseconds:(curPoint.x - currentOffset)]];
		}
	}
	/*
	else{
		signed long long originalTime = playHeadTime - (unsigned long long)[doc timelineStart];
		signed long long millisecondsDifference = ([self xToMilliseconds:(abs(currentOffset - curPoint.x))] - (unsigned long long)[doc timelineStart]);
		signed long long currentTime = [doc getPlayHeadTime] - (unsigned long long)[doc timelineStart];
		signed long long difference = (originalTime + millisecondsDifference) - currentTime;
		
		if(difference>0){
			[[doc playbackController] moveForward:abs(difference)];
		}else if(difference<0){
			[[doc playbackController] moveBackward:abs(difference)];
		}

	
	}//It would be cool to add dragging here, but its harder than I though.
	*/
	
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
	if(thisEvent){
		thisEvent = nil;
	}
}









- (ClickResult *)eventAtX:(float)x y:(float)y{
	unsigned long long beginsearch = 0;
	unsigned long long endsearch = 0;
	int halfheight = (int)(nominalTrackHeight/2);
	beginsearch = [self xToMilliseconds:(x-halfheight)];
	endsearch = [self xToMilliseconds:(x+halfheight)];
	
	
	NSMutableArray * trackEventArrays = [NSMutableArray arrayWithCapacity:[[self managedTracks] count]];
	NSMutableArray * eventsOnThisTrack;
	Event * eventAtTime;
	Event * eventEndingAtTime;
	Event * eventInMiddleAtTime;

	for(int j = 0; j<[[self managedTracks] count] ; j++){

		eventsOnThisTrack = [NSMutableArray arrayWithCapacity:nominalTrackHeight];
		for(unsigned long long i = beginsearch; i <= endsearch; i++){
			eventAtTime = [[[self managedTracks] objectAtIndex:j] eventAtTime:i];
			if(eventAtTime != nil){
				[eventsOnThisTrack addObject:eventAtTime];
			}
			eventEndingAtTime = [[[self managedTracks] objectAtIndex:j] eventEndingAtTime:i];
			if(eventEndingAtTime != nil){
				[eventsOnThisTrack addObject:eventEndingAtTime];
			}
			eventInMiddleAtTime = [[[self managedTracks] objectAtIndex:j] eventInMiddleAtTime:i];
			if(eventInMiddleAtTime != nil){
				[eventsOnThisTrack addObject:eventInMiddleAtTime];
			}
		}
		[trackEventArrays addObject:eventsOnThisTrack];
	}

	//select correct event from 2D array of events
	
	//traverse from right to left, bottom to top searching for a hit.

	NSArray * array;
	Event * event;
	for(int i=0; i<[trackEventArrays count]; i++){
		array = [trackEventArrays objectAtIndex:([trackEventArrays count]-i-1)];
		for(int j = 0; j<[array count]; j++){
			event = [array objectAtIndex:([array count]-j-1)];
			float eventx;
			float relativeXFromEventOrigin;
			float relativeYFromEventOrigin;
			if([event duration] != 0){
				//check for tail
				eventx = [self millisecondsToX:([event startTime] + [event duration])];
				relativeXFromEventOrigin = ABS(x - eventx);
				relativeYFromEventOrigin = y - (float)nominalTrackHeight/4 * i;
				if(relativeYFromEventOrigin > (nominalTrackHeight/2)){
					relativeYFromEventOrigin = nominalTrackHeight-relativeYFromEventOrigin;
				}
			   
				if(relativeYFromEventOrigin>=relativeXFromEventOrigin){
					return [[[ClickResult alloc] initWithEvent:event atPart:EVENTTAIL] autorelease];
				}
				
				//check for interim
				eventx = [self millisecondsToX:[event startTime]];
				relativeXFromEventOrigin = ABS(x - eventx);
				relativeYFromEventOrigin = y - (float)nominalTrackHeight/4 * i;

				if(relativeYFromEventOrigin >= (float)nominalTrackHeight/4 &&
				   relativeYFromEventOrigin <= ((float)nominalTrackHeight * 3.0)/4 &&
				   relativeXFromEventOrigin >= ((float)nominalTrackHeight/2) &&
				   relativeXFromEventOrigin <= [event duration] - ((float)nominalTrackHeight/2)
					){
					return [[[ClickResult alloc] initWithEvent:event atPart:EVENTINTERIM] autorelease];
				}
			}
			
			//check for head
			eventx = [self millisecondsToX:[event startTime]];
			relativeXFromEventOrigin = ABS(x - eventx);
			relativeYFromEventOrigin = y - (float)nominalTrackHeight/4 * i;
			if(relativeYFromEventOrigin > (nominalTrackHeight/2)){
				relativeYFromEventOrigin = nominalTrackHeight-relativeYFromEventOrigin;
			}
			
			if(relativeYFromEventOrigin>=relativeXFromEventOrigin){
				return [[[ClickResult alloc] initWithEvent:event atPart:EVENTHEAD] autorelease];
			}
		}
	}
	
		
	return nil;
}

//-------util----------
- (float) millisecondsToX:(unsigned long long)milliseconds {
	float fractionalPosition = 0.0;
	NSRect boundsRect = [self bounds];
	int viewWidth = boundsRect.size.width;
	fractionalPosition = (float)(milliseconds - [doc timelineStart]) / ((float)([doc timelineEnd] - [doc timelineStart]));
	return (float)(fractionalPosition * viewWidth);
}

- (unsigned long long) xToMilliseconds:(float)x {
	unsigned long long milliseconds = 0;
	float fractionalPosition = 0.0;
	NSRect boundsRect = [self bounds];
	fractionalPosition = x/(boundsRect.size.width);
	milliseconds = (unsigned long long)[doc timelineStart] + (unsigned long long)(fractionalPosition * ([doc timelineEnd] - [doc timelineStart]));
	
	return milliseconds;
}


- (void)addManagedTrack:(EventTrack *)newEventTrack {
	
	[myTracks addObject:newEventTrack];
	[self sortManagedTracks];
	[self setNeedsDisplay:YES];
	return;
}
- (void)removeManagedTrack:(EventTrack *)oldEventTrack {
	[myTracks removeObject:oldEventTrack];
	[self setNeedsDisplay:YES];
	return;
}

- (NSArray *)managedTracks{
	return [[[NSArray alloc] initWithArray:myTracks] autorelease];
}


- (void)setDoc:(id)document{ //CodingDocument *
	doc = document;
	return;
}


- (void)sortManagedTracks{
	
	NSMutableArray * sortedMyTracks = [NSMutableArray arrayWithCapacity:[myTracks count]+1];
	NSArray * evtTracks = [doc eventTracks];
	for(int i=0;i<[evtTracks count];i++){
		if([myTracks containsObject:[evtTracks objectAtIndex:i]]){
			[sortedMyTracks addObject:[evtTracks objectAtIndex:i]];
		}
	}
	[myTracks release];
	myTracks = sortedMyTracks;
	[myTracks retain];
	
	return;
}

@end
