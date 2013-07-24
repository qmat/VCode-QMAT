//
//  MetricController.h
//  VCode
//
//  Created by Joey Hagedorn on 3/6/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import "TimelineController.h"
#import "CodingDocument.h"
#import "DataFileLog.h"
#import "TimelineView.h"

@interface MetricController : NSObject {
	IBOutlet NSTableView *metricTable;
	IBOutlet TimelineController *timelineController;
	IBOutlet TimelineView * timelineView;
	IBOutlet CodingDocument *doc;
	int colorRow;        // the row color changes apply to
	
}
- (IBAction)updateTimeline: (id) sender;

//for the metric table
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
@end
