//
//  ClickyQTMovieView.m
//  MovieViewTest
//
//  Created by Joey Hagedorn on 3/3/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "ClickyQTMovieView.h"

#import "PlaybackController.h"
#import "CodingDocument.h"


@implementation ClickyQTMovieView
- (void)mouseDown:(NSEvent *)theEvent {
	if(! [self isControllerVisible]){
		[[self superview] setKeyMovie:(QTMovie *)[self movie]];
	}else{
		 [super mouseDown:theEvent];
	}
}

- (void)keyDown:(NSEvent *)theEvent {
    if ([[theEvent charactersIgnoringModifiers] isEqualTo:@" "]) {
		if([theEvent isARepeat]==NO){
			NSDocumentController *documentController;
			documentController = [NSDocumentController sharedDocumentController];
			CodingDocument *codeDocument;
			codeDocument = [documentController documentForWindow: [self window]];
			if([codeDocument isInIntervalMode]){
				if([codeDocument intervalContinuous]){
					[[codeDocument playbackController] playAnInterval:nil];
					
				}else{
					[[codeDocument playbackController] skipAnInterval:nil];
				}
			}else{
				if ([[self movie] rate] == 0) [self play:nil];
                else [self pause:nil];
			}
		}
    }else if ([@[@"j", @"k", @"l"] containsObject:[theEvent charactersIgnoringModifiers]]) {
        if([theEvent isARepeat]==NO)
        {
            NSDocumentController *documentController;
            documentController = [NSDocumentController sharedDocumentController];
            CodingDocument *codeDocument;
            codeDocument = [documentController documentForWindow: [self window]];
            if ([[theEvent charactersIgnoringModifiers] isEqualTo:@"j"])
            {
                [self jklRate:false];
            }
            else if ([[theEvent charactersIgnoringModifiers] isEqualTo:@"k"])
            {
                rateIndex = rateIndexForPause;
                [self pause:nil];
            }
            else if ([[theEvent charactersIgnoringModifiers] isEqualTo:@"l"])
            {
                [self jklRate:true];
            }
        }
	}else if ([[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSLeftArrowFunctionKey) {
		NSDocumentController *documentController;
		documentController = [NSDocumentController sharedDocumentController];
		CodingDocument *codeDocument;
		codeDocument = [documentController documentForWindow: [self window]];
		if([theEvent modifierFlags] & NSControlKeyMask) {
			[[codeDocument playbackController] skipToPreviousEvent];
		} else if([codeDocument isInIntervalMode]){
			[[codeDocument playbackController] skipAnIntervalBackwards:nil];
		}else{
			[super keyDown:theEvent];	
		}
		
	}else if ([[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSRightArrowFunctionKey) {
		NSDocumentController *documentController;
		documentController = [NSDocumentController sharedDocumentController];
		CodingDocument *codeDocument;
		codeDocument = [documentController documentForWindow: [self window]];
		if([theEvent modifierFlags] & NSControlKeyMask) {
			[[codeDocument playbackController] skipToNextEvent];
		} else if([codeDocument isInIntervalMode]){
			[[codeDocument playbackController] skipAnInterval:nil];
		}else{
			[super keyDown:theEvent];
		}
	}else if ([[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSUpArrowFunctionKey) {
		//Do Nothing....
	}else if ([[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSDownArrowFunctionKey) {
		//Do Nothing....
	}else {
		[super keyDown:theEvent];
	}
}

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        rateSteps = [[NSArray alloc] initWithObjects:@-10, @-4, @-2, @-1, @-0.5, @0, @0.5, @1, @2, @4, @10, nil];
        rateIndexForPause = [rateSteps indexOfObject:@0];
        rateIndex = NSNotFound;
    }
    return self;
}

- (void) dealloc
{
    [rateSteps release];
    [super dealloc];
}

- (IBAction)play:(id)sender
{
    // resume previous rateStep unless that is pause itself, in which case reset to normal speed
    if (rateIndex == rateIndexForPause) rateIndex = [rateSteps indexOfObject:@1];
    
    [[self movie] setRate:[[rateSteps objectAtIndex:rateIndex] floatValue]];
}

- (IBAction)pause:(id)sender
{
    // don't set rateIndex to pause here, as for play/pause we want to flip between paused and rateStep speed.
    
    [[self movie] setRate:0];
}

- (void) jklRate:(bool)stepUp
{
    if (rateIndex == NSNotFound) rateIndex = [rateSteps indexOfObject:[NSNumber numberWithFloat:[[self movie] rate]]];
    if (rateIndex == NSNotFound) rateIndex = stepUp ? [rateSteps indexOfObject:@1] : [rateSteps indexOfObject:@-1];
    
    // if movie is paused, first press resumes play at previous rateStep
    // if rateStep is at pause, always act on it
    if ([[self movie] rate] != 0 || rateIndex == rateIndexForPause)
    {
        if (stepUp)
        {
            if (rateIndex == [rateSteps count] -1) return;
            if (rateIndex == rateIndexForPause) rateIndex = [rateSteps indexOfObject:@1];
            else rateIndex++;
        }
        else
        {
            if (rateIndex == 0) return;
            if (rateIndex == rateIndexForPause) rateIndex = [rateSteps indexOfObject:@-1];
            else rateIndex--;
        }
    }
    
    [[self movie] setRate:[[rateSteps objectAtIndex:rateIndex] floatValue]];
}

@end
