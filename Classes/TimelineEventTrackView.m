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
		clickResult = nil;
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


- (void)drawRect:(NSRect)dirtyRect {
	//White Background
	[[NSColor colorWithDeviceWhite:0.75 alpha:1] set];
	[NSBezierPath fillRect:dirtyRect];


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
            
            // Only draw if we're in the dirty rect
            if (NSIntersectsRect(NSMakeRect([self millisecondsToX:milliseconds], 0, [self millisecondsToX:duration], [self bounds].size.height), dirtyRect))
            {
                [self drawChevronAtMS:milliseconds withColor:[currentTrack trackColor] andRow:([myTracks count] -i -1) invertedBorder:hasComment withLabel:[currentTrack key]];
                
                //if the track is !instantaneous AND event duration >0 then 
                if((![currentTrack instantaneousMode]) && (duration > 0)){
                    [self drawChevronAtMS:(milliseconds+duration) withColor:[currentTrack trackColor] invertedBorder:NO withLabel:[currentTrack key]];
                    [self drawFillFromMS:milliseconds toMS:milliseconds+duration fillColor:[currentTrack trackColor] strokeColor:[NSColor whiteColor] label:[currentEvent comment]];
                }
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
	clickResult = [self eventAtX:(curPoint.x) y:(curPoint.y)];
	
    if(clickResult == nil)
    {
		// jump to this time.
		[[doc playbackController] moveToPercent:((float)(curPoint.x) / (float)[self bounds].size.width)];
        
        currentOffset = curPoint.x;
        currentTailOffset = 0;
        playHeadTime = [doc playheadTime];
	}
    else
    {
        if (([theEvent clickCount] > 1))
        {
            // Edit event's comment
            [[doc eventfulController] editEventComment: [clickResult clickedEvent]];
        }
        else if ([theEvent modifierFlags] & NSAlternateKeyMask)
        {
            // Delete event
            [[doc eventfulController] destroyEvent: [clickResult clickedEvent]];
            clickResult = nil;
        }
        else
        {
            currentOffset = curPoint.x - [self millisecondsToX:[[clickResult clickedEvent] startTime]];
            currentTailOffset = curPoint.x - [self millisecondsToX:([[clickResult clickedEvent] startTime] + [[clickResult clickedEvent] duration])];
            [clickResult retain];
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint curPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if(clickResult)
    {
        Event * thisEvent = [clickResult clickedEvent];
        BOOL ranged = [thisEvent duration] != 0;
        unsigned long long headTime = [self xToMilliseconds:curPoint.x - currentOffset];
        unsigned long long tailTime = [self xToMilliseconds:curPoint.x - currentTailOffset];
        unsigned long long leftBound = 0;
        unsigned long long rightBound = 0;
        unsigned long long difference = 0;
        
        switch ([clickResult clickedPart]) {
            case EVENTHEAD:
                leftBound = [[clickResult prevEvent] startTime] + [[clickResult prevEvent] duration];
                if (headTime < leftBound) return;
                
                rightBound = ranged ? [thisEvent startTime] + [thisEvent duration] : [[clickResult nextEvent] startTime];
                if (headTime >= rightBound && rightBound != 0) return;
                
                if (ranged)
                {
                    difference = headTime - [thisEvent startTime];
                    [thisEvent setDuration:([thisEvent duration] - difference)];
                }
                
                [thisEvent setStartTime:headTime];
                
                break;
                
            case EVENTINTERIM:
                leftBound = [[clickResult prevEvent] startTime] + [[clickResult prevEvent] duration];
                if (headTime < leftBound) return;
                
                rightBound = [[clickResult nextEvent] startTime];
                if (tailTime >= rightBound && rightBound > 0) return;
                
                [thisEvent setStartTime:headTime];
                
                break;
                
            case EVENTTAIL:
                leftBound = [thisEvent startTime] + 1;
                if (tailTime < leftBound) return;
                
                rightBound = [[clickResult nextEvent] startTime];
                if (tailTime >= rightBound && rightBound != 0) return;
                
                difference = tailTime - [thisEvent startTime];
				[thisEvent setDuration:difference];
                
                break;
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

- (void)mouseUp:(NSEvent *)theEvent
{
	if(clickResult)
    {
        [clickResult release];
		clickResult = nil;
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
	for(int i=0; i<[trackEventArrays count]; i++)
    {
        int trackIndex = [trackEventArrays count]-i-1;
		array = [trackEventArrays objectAtIndex: trackIndex];
		
        for(int j = 0; j<[array count]; j++)
        {
            int eventIndex = [array count]-j-1;
			event = [array objectAtIndex:eventIndex];
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
			   
				if(relativeYFromEventOrigin>=relativeXFromEventOrigin)
                {
                    EventTrack* eventTrack = [[self managedTracks] objectAtIndex:trackIndex];
					return [[[ClickResult alloc] initWithEvent:event atPart:EVENTTAIL withPrevious:[eventTrack eventPreviousToEvent:event] andNext:[eventTrack eventSubsequentToEvent:event]] autorelease];
				}
				
				//check for interim
				eventx = [self millisecondsToX:[event startTime]];
				relativeXFromEventOrigin = ABS(x - eventx);
				relativeYFromEventOrigin = y - (float)nominalTrackHeight/4 * i;

				if(relativeYFromEventOrigin >= (float)nominalTrackHeight/4 &&
				   relativeYFromEventOrigin <= ((float)nominalTrackHeight * 3.0)/4 &&
				   relativeXFromEventOrigin >= ((float)nominalTrackHeight/2) &&
				   relativeXFromEventOrigin <= [event duration] - ((float)nominalTrackHeight/2)
				  )
                {
                    EventTrack* eventTrack = [[self managedTracks] objectAtIndex:trackIndex];
					return [[[ClickResult alloc] initWithEvent:event atPart:EVENTINTERIM withPrevious:[eventTrack eventPreviousToEvent:event] andNext:[eventTrack eventSubsequentToEvent:event]] autorelease];
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
                EventTrack* eventTrack = [[self managedTracks] objectAtIndex:trackIndex];
				return [[[ClickResult alloc] initWithEvent:event atPart:EVENTHEAD withPrevious:[eventTrack eventPreviousToEvent:event] andNext:[eventTrack eventSubsequentToEvent:event]] autorelease];
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
