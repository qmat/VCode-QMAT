//
//  DocumentController.m
//  VCode
//
//  Created by Joey Hagedorn on 10/6/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "DocumentController.h"
#import "CodingDocument.h"
#import "MultiMovieView.h"


@implementation DocumentController

- (void) awakeFromNib{
	NSArray *movieTypes = [QTMovie movieFileTypes:QTIncludeCommonTypes];	
	//check QTMovieFileTypeOptions for more types.
	[movieSelector setFileTypes:movieTypes];
	
	NSArray *datafileTypes = [NSArray arrayWithObjects:@"txt",@"text",nil];
	[dataFileSelector setFileTypes:datafileTypes];
	
	[[NSDocumentController sharedDocumentController] setAutosavingDelay:30];
	
	//Doc MovieView setMovies with Offsets
	[[doc movieView] setMovies:[doc auxMovies] withOffsets:[doc auxMovieOffsets]];
	
}

-(IBAction) movieSelected:(id)sender{
	[doc setMovie:(NSString *)[[sender alias] fullPath]];
	//this needs to happen here, because setting movie happens in unarchiver
	
	[[doc movieView] addMovie:(QTMovie *)[doc movie]];
	[[doc movieView] setKeyMovie:(QTMovie *)[doc movie]];
	[[doc movieView] setSyncedMovie:(QTMovie *)[doc movie]];
	
	[doc updateChangeCount:NSChangeDone];
	[[doc timelineController] updateTimeline];

	return;
}

-(IBAction) datafileSelected:(id)sender{
	[doc setDatafile:(NSString *)[[sender alias] fullPath]];
	
	[metricTable reloadData];

	//init offset to beginning of file
	[doc setMovieStartOffset:[[doc dataFile] start]];
	[[doc timelineController] updateTimeline];
	return;
}

-(IBAction) addAuxMovie:(id)sender{
    NSOpenPanel *openPanel = [[NSOpenPanel openPanel] retain];
    [openPanel setAllowsMultipleSelection: NO];
    [openPanel setCanChooseDirectories: NO];
    [openPanel setCanChooseFiles: YES];
    [openPanel beginSheetForDirectory: nil
                                 file: nil
                                types: [QTMovie movieFileTypes:QTIncludeCommonTypes]
                       modalForWindow: nil
                        modalDelegate: self
                       didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
                          contextInfo: nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    [sheet close];
	
    if (returnCode == NSOKButton) {
        NSArray *files = [sheet filenames];
		[doc addAuxMovie:[files objectAtIndex:0] withOffset:[NSNumber numberWithLong:0]];

    }
	[moviesTable reloadData];
	[sheet release];
}


-(IBAction) removeSelectedMovie:(id)sender{
	int selectedRow = [moviesTable selectedRow];
	if(selectedRow>-1){
		[doc removeAuxMovieAtIndex:(selectedRow)];
	}
	[moviesTable reloadData];
}


//Set the file selectors to display the appropriate file name
- (void) updateGUI{
	if([doc dataFile]){
		if([doc dataFilePath] && [doc dataFilePath] !=@""){
			[dataFileSelector setPath:[doc dataFilePath]];
		}
	}
	if([doc movie]){
		if([doc moviePath] && [doc moviePath] !=@""){
			[movieSelector setPath:[doc moviePath]];
			
			[[doc movieView] addMovie:(QTMovie *)[doc movie]];
			[[doc movieView] setKeyMovie:(QTMovie *)[doc movie]];
			[[doc movieView] setSyncedMovie:(QTMovie *)[doc movie]];
		}
	}
	//[[doc timelineController] updateTimeline];

}
#pragma mark Admin Window Table Glue Code

// just returns the item for the right row
- (id)     tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn row:(int) rowIndex{  
	//log or something to figure out which table column?
	if(doc){
		if([[aTableColumn identifier] compare: @"videoFiles"]==NSOrderedSame){
			return [[[doc auxMoviePaths] objectAtIndex:rowIndex] lastPathComponent];  
		}else if([[aTableColumn identifier] compare: @"offset"]==NSOrderedSame){

			return [[doc auxMovieOffsets] objectAtIndex:rowIndex]; 
		}
	}
	return nil;
	
}

// just returns the number of items we have.
- (int)numberOfRowsInTableView:(NSTableView *)aTableView{
	if(doc){
		return [[doc auxMoviePaths] count];  
	}
	return 0;
}


- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	if(doc){

		if([[aTableColumn identifier] compare: @"offset"]==NSOrderedSame){
			[doc setOffsetOfAuxMovieAtIndex:rowIndex to:anObject];
		}

		//Update movie view offsets !!!
		[[doc movieView] setOffsetForMovie:[[doc auxMovies] objectAtIndex:rowIndex] to:[anObject longValue]];
		}
}

@end
