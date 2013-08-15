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
				[super keyDown:theEvent];
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
                [[codeDocument playbackController] jklRate:false];
            }
            else if ([[theEvent charactersIgnoringModifiers] isEqualTo:@"k"])
            {
                [super pause:nil];
            }
            else if ([[theEvent charactersIgnoringModifiers] isEqualTo:@"l"])
            {
                [[codeDocument playbackController] jklRate:true];
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
@end
