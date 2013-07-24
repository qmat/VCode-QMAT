//
//  KeyMovieView.m
//  VCode
//
//  Created by Joey Hagedorn on 10/23/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "KeyMovieView.h"
#import "PlaybackController.h"

@implementation KeyMovieView


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
	}else if ([[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSLeftArrowFunctionKey) {
		NSDocumentController *documentController;
		documentController = [NSDocumentController sharedDocumentController];
		CodingDocument *codeDocument;
		codeDocument = [documentController documentForWindow: [self window]];
		if([theEvent modifierFlags] & NSControlKeyMask){
			[[codeDocument playbackController] skipToPreviousEvent];
		} else {
			if([codeDocument isInIntervalMode]){
					[[codeDocument playbackController] skipAnIntervalBackwards:nil];
			}else{
				[super keyDown:theEvent];	
			}
		}
				
	}else if ([[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSRightArrowFunctionKey) {
		NSDocumentController *documentController;
		documentController = [NSDocumentController sharedDocumentController];
		CodingDocument *codeDocument;
		codeDocument = [documentController documentForWindow: [self window]];
		if([theEvent modifierFlags] & NSControlKeyMask){
			[[codeDocument playbackController] skipToNextEvent];
		} else {			
			if([codeDocument isInIntervalMode]){
				[[codeDocument playbackController] skipAnInterval:nil];
			}else{
				[super keyDown:theEvent];
			}
		}
	}else if ([[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSUpArrowFunctionKey) {
		//Do Nothing....
		//Override to stop volume control
	}else if ([[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSDownArrowFunctionKey) {
		//Do Nothing....
		//Override to stop volume control
	}else {
		[super keyDown:theEvent];
	}

	
}

@end
