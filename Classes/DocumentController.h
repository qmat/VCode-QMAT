//
//  DocumentController.h
//  VCode
//
//  Created by Joey Hagedorn on 10/6/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import "NJRFSObjectSelector.h"
#import "MultiMovieView.h"
@class CodingDocument;

@interface DocumentController : NSObject {
	IBOutlet id doc; //CodingDocument
	IBOutlet NJRFSObjectSelector *movieSelector;
	IBOutlet NJRFSObjectSelector *dataFileSelector;
	IBOutlet id moviesTable;
	IBOutlet id metricTable;

}

-(IBAction) movieSelected:(id)sender;
-(IBAction) datafileSelected:(id)sender;

-(IBAction) addAuxMovie:(id)sender;
-(IBAction) removeSelectedMovie:(id)sender;

-(void) updateGUI;


@end
