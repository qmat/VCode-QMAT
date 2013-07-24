//
//  AgreementController.h
//  AnalysisTool
//
//  Created by Joey Hagedorn on 11/30/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import "NJRFSObjectSelector.h"
#import "NSString-NJRExtensions.h"
#import "EventTrack.h"
#import "MiniDoc.h"

@class KappaController;

@interface AgreementController : NSObject {
	MiniDoc * primaryCoderDoc;
	MiniDoc * secondaryCoderDoc;
	
	NSMutableArray * totaledTracks;
	
	IBOutlet float markTolerance;
	IBOutlet float durationTolerance;
	
	IBOutlet NSTableView *trackTable;
	IBOutlet KappaController *kappaController;

	IBOutlet NJRFSObjectSelector *primarySelector;
	IBOutlet NJRFSObjectSelector *secondarySelector;
	
	IBOutlet NSWindow * window;
	
	IBOutlet float evta;
	IBOutlet float evto;
	IBOutlet float evtp;
	IBOutlet float dura;
	IBOutlet float duro;
	IBOutlet float durp;
	IBOutlet float cmta;
	IBOutlet float cmto;
	IBOutlet float cmtp;

}

-(IBAction)openHelpPDF:(id)sender;
-(IBAction) primarySelected:(id)sender;
-(IBAction) secondarySelected:(id)sender;
- (IBAction) mergeTracks:(id)sender;
- (IBAction) compareTracks:(id)sender;

-(IBAction) exportEventTextFile:(id)sender;

- (void)exportPanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo;

-(NSArray *)intersectingTrackNames;
-(NSArray *)agreeingEventsForTrackNamed:(NSString *)trackName;
-(int)agreeingEventCountForTrackNamed:(NSString *)trackName;
-(int)opportunityEventCountForTrackNamed:(NSString *)trackName;
-(NSArray *)agreeingEventsNoToleranceForTrackNamed:(NSString *)trackName;
-(int)agreeingEventCountNoToleranceForTrackNamed:(NSString *)trackName;
-(int)agreeingDurationCountForTrackNamed:(NSString *)trackName;
-(int)opportunityDurationCountForTrackNamed:(NSString *)trackName;
-(int)agreeingCommentCountForTrackNamed:(NSString *)trackName;
-(int)opportunityCommentCountForTrackNamed:(NSString *)trackName;

-(MiniDoc*) primaryCoderDoc;
-(MiniDoc*) secondaryCoderDoc;
-(float) markTolerance;
-(void) setMarkTolerance:(float)tol;
-(float) durationTolerance;
-(void) setDurationTolerance:(float)tol;
- (float) evta;
- (void) setEvta:(float)newEvta;
- (float) evto;
- (void) setEvto:(float)newEvto;
- (float) evtp;
- (void) setEvtp:(float)newEvtp;
- (float) dura;
- (void) setDura:(float)newDura;
- (float) duro;
- (void) setDuro:(float)newDuro;
- (float) durp;
- (void) setDurp:(float)newDurp;
- (float) cmta;
- (void) setCmta:(float)newCmta;
- (float) cmto;
- (void) setCmto:(float)newCmto;
- (float) cmtp;
- (void) setCmtp:(float)newCmtp;


- (void)updateGUI;
- (void)calculateTotals;

@end
