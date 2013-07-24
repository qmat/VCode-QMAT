//
//  MetricController.m
//  VCode
//
//  Created by Joey Hagedorn on 3/6/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "MetricController.h"
#import "ColorCell.h"



@implementation MetricController

- (void) awakeFromNib {
	NSTableColumn* column;
	ColorCell* colorCell;
	
	column = [[metricTable tableColumns] objectAtIndex: 1];
	colorCell = [[[ColorCell alloc] init] autorelease];
    [colorCell setEditable: YES];
	[colorCell setTarget: self];
	[colorCell setAction: @selector (colorClick:)];
	[column setDataCell: colorCell];
	
	//drag & drop
	[metricTable registerForDraggedTypes:[NSArray arrayWithObject:@"PrivateMetricItemDataType"]];
	[metricTable reloadData];
}
- (IBAction)updateTimeline: (id) sender{
	[timelineController updateTimelineAndSync];
}


- (void) colorClick: (id) sender {    // sender is the table view
	NSColorPanel* panel;
	
	colorRow = [sender clickedRow];
	panel = [NSColorPanel sharedColorPanel];
	[panel setTarget: self];
	[panel setAction: @selector (colorChanged:)];

	//set panel to color of given metric
	[panel setColor: [[doc dataFile] colorForKey:[[doc dataFile] keyAtIndex:colorRow]]];

	//In the Doc we'll store SortedMetricNames and SortedMetricColors and SortedMetricEnabled
	//Also Stacked
	//also what are we going to do about Video Media?
	
	
	//upon the IBAction to set metric we'll reset these to keys, and default Colors.
	
	[panel makeKeyAndOrderFront: self];
}

- (void) colorChanged: (id) sender {    // sender is the NSColorPanel
	//[[[doc getEventTracks] objectAtIndex:colorRow] setTrackColor:[sender color]];
	[[doc dataFile] setColorForKey:[[doc dataFile] keyAtIndex:colorRow] to:[sender color]];
	[metricTable reloadData];
	//set needs display for our metric views
	//[indexCustomView setNeedsDisplay:YES];
	[timelineController updateTimeline];
	
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView{
	return [[[doc dataFile] dataColumns] count]; //eventually add one more, the video volume
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	if([doc dataFile]){
		if([[aTableColumn identifier] compare: @"datametric"]==NSOrderedSame){
			return [[[doc dataFile] orderedMetricKeys] objectAtIndex:rowIndex];   
		}else if([[aTableColumn identifier] compare: @"color"]==NSOrderedSame){
			return [[doc dataFile] colorForKey:[[doc dataFile] keyAtIndex:rowIndex]];
		}else if([[aTableColumn identifier] compare: @"enabled"]==NSOrderedSame){
			return [[doc dataFile] enabledForKey:[[doc dataFile] keyAtIndex:rowIndex]];
		}else if([[aTableColumn identifier] compare: @"style"]==NSOrderedSame){
			[[aTableColumn dataCellForRow:rowIndex] addItemsWithTitles:[doc metricStyles]];

			
			return [NSNumber numberWithInt:[[doc metricStyles] indexOfObject:
					[[doc dataFile] styleForKey:[[doc dataFile] keyAtIndex:rowIndex]]]];
		}
	}

	return nil;
}
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	if([[aTableColumn identifier] compare: @"enabled"]==NSOrderedSame){
		[[doc dataFile] setEnabledForKey:[[doc dataFile] keyAtIndex:rowIndex] to:anObject];
		[timelineController updateTimelineAndSync];
		[metricTable reloadData];
	}else 	if([[aTableColumn identifier] compare: @"style"]==NSOrderedSame){

		[[doc dataFile] setStyleForKey:[[doc dataFile] keyAtIndex:rowIndex] to:[[doc metricStyles] objectAtIndex:[anObject intValue]]];

		[timelineController updateTimeline];
		[metricTable reloadData];
	}

}
//Drag and drop support for the table

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:@"PrivateMetricItemDataType"] owner:self];
    [pboard setData:data forType:@"PrivateMetricItemDataType"];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
	if(op== NSTableViewDropAbove){
		//Check to validate index, to see if we're moving to a valid row
		return NSDragOperationMove;
	}
	
	return NSDragOperationNone;
}
- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:@"PrivateMetricItemDataType"];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    int dragRow = [rowIndexes firstIndex];
	
	if (row>dragRow){
		[[doc dataFile] moveMetricFromIndex:dragRow toIndex:row-1];
	}else{
		[[doc dataFile] moveMetricFromIndex:dragRow toIndex:row];
		
	}
	
	[timelineController updateTimeline];
	[metricTable reloadData];
	
    // Move the specified row to its new location...
	return YES;
}

@end
