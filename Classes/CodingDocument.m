//
//  CodingDocument.m
//  VCode
//
//  Created by Joey Hagedorn on 9/15/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "CodingDocument.h"

pascal Boolean MyActionFilter (MovieController mc, short action, void* params, long refCon);

@implementation CodingDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		eventTracks = [[[NSMutableArray alloc] initWithCapacity:5] retain];
		movieStartOffset = 0;
		recordingEvents = [[[NSMutableArray alloc] initWithCapacity:5] retain];
		
		auxMovies = [[[NSMutableArray alloc] initWithCapacity:5] retain];
		auxMoviePaths = [[[NSMutableArray alloc] initWithCapacity:5] retain];
		auxMovieOffsets = [[[NSMutableArray alloc] initWithCapacity:5] retain];

		
		skipInterval = 3;
		isInIntervalMode = NO;
		intervalContinuous = NO;
		isShowingAdminWindow = YES;
		isStacked = NO;
		isShowingSound = NO;
    }else{
		[self release];
		return nil;
	}
    return self;
}

- (void)dealloc{
	[recordingEvents release];
	[eventTracks release];
	[super dealloc];
}




- (NSString *)windowNibName
{
    // Override returning the nib file name of the document

	return @"CodingDocument";
}


- (NSString *) representedFilename{
	if([[[self fileURL] path] lastPathComponent]){
		return [[[[self fileURL] path] lastPathComponent] stringByDeletingPathExtension];
	}
	return @"Untitled";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
	
	[timelineController sizeToMovie];
	[timelineController updateTimeline];
	[docController updateGUI];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    
    // For applications targeted for Tiger or later systems, you should use the new Tiger API -dataOfType:error:.  In this case you can also choose to override -writeToURL:ofType:error:, -fileWrapperOfType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

	NSMutableData * data;
	NSKeyedArchiver *archiver;
	data = [NSMutableData data];
	archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		
	[archiver encodeObject:moviePath forKey:@"CDmoviepath"];
	[archiver encodeQTTime:[movie currentTime] forKey:@"CDmovietime"];
	[archiver encodeObject:dataFile forKey:@"CDdatafile"];
    [archiver encodeObject:eventTracks forKey:@"CDeventtracks"];
    [archiver encodeObject:recordingEvents forKey:@"CDrecordingEvents"];
	[archiver encodeInt64:movieStartOffset forKey:@"CDMovieStartOffset"];
	[archiver encodeInt32:skipInterval forKey:@"CDskipinterval"];
	[archiver encodeBool:isInIntervalMode forKey:@"CDisinintervalmode"];
	[archiver encodeBool:intervalContinuous forKey:@"CDintervalcontinuous"];
	[archiver encodeBool:isShowingAdminWindow forKey:@"CDisshowingadminwindow"];

	
	
	[archiver encodeBool:isStacked forKey:@"CD2isStacked"];
	[archiver encodeObject:auxMoviePaths forKey:@"CD2auxMoviePaths"];
    [archiver encodeObject:auxMovieOffsets forKey:@"CD2auxMovieOffsets"];
	
	[archiver encodeBool:isShowingSound forKey:@"CD3isshowingsound"];



	[archiver finishEncoding];

	[archiver release];
    return data;
	 
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	NSKeyedUnarchiver *unarchiver;
	unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	[self setMovie:[unarchiver decodeObjectForKey:@"CDmoviepath"]];
	
	[movie setCurrentTime:[unarchiver decodeQTTimeForKey:@"CDmovietime"]];

	[dataFile release];
	dataFile = [[unarchiver decodeObjectForKey:@"CDdatafile"] retain];

	[eventTracks release];
	eventTracks = [[unarchiver decodeObjectForKey:@"CDeventtracks"] retain];
	[recordingEvents release];
	recordingEvents = [[unarchiver decodeObjectForKey:@"CDrecordingEvents"] retain];
	movieStartOffset = [unarchiver decodeInt64ForKey:@"CDMovieStartOffset"];
	skipInterval = [unarchiver decodeInt32ForKey:@"CDskipinterval"];
	isInIntervalMode = [unarchiver decodeBoolForKey:@"CDisinintervalmode"];
	intervalContinuous = [unarchiver decodeBoolForKey:@"CDintervalcontinuous"];
	isShowingAdminWindow = [unarchiver decodeBoolForKey:@"CDisshowingadminwindow"];
	
	
	//hcked in version 2 of the file format
	if( [unarchiver containsValueForKey:@"CD2auxMoviePaths"] &&  [unarchiver containsValueForKey:@"CD2auxMovieOffsets"]){
		//print out some debug stuff ehre? i dunno... what about updating the GUI???
		//move this code in to nice method setAuxMoviesWithOffsets!
		while([auxMovies count] > 0){
			[self removeAuxMovieAtIndex:0];
		}

		NSArray * offsets = [unarchiver decodeObjectForKey:@"CD2auxMovieOffsets"];
		NSArray * paths = [unarchiver decodeObjectForKey:@"CD2auxMoviePaths"];
		for(int i=0; i<[paths count]; i++){
			[self addAuxMovie:[paths objectAtIndex:i] withOffset:[offsets objectAtIndex:i]];
		}
		isStacked = [unarchiver decodeBoolForKey:@"CD2isStacked"];
	}else{
		isStacked = NO;
	}
	
	if([unarchiver containsValueForKey:@"CD3isshowingsound"] )
	   isShowingSound = [unarchiver decodeBoolForKey:@"CD3isshowingsound"];
	else
	   isShowingSound = NO;
	
	[unarchiver finishDecoding];
	[unarchiver release];
	

	return YES;
}

- (void)windowWillClose:(NSNotification *)notification {
	if(adminWindow){
		[adminWindow close];
	}
	[self removeMovieIdleCallback];
}




- (EventfulController *)eventfulController{
	return myController;
}


- (QTMovie *) movie{
	if(movie){
		return movie;
	}else{
		return nil;
	}
}

- (NSString *) moviePath{
	if(moviePath){
		return moviePath;
	}else{
		return nil;
	}
}

- (MultiMovieView *) movieView{
	return movieView;
}

- (void)setMovie:(NSString *)path
{
	[path retain];
	[moviePath release];
	moviePath = path;
	
	if(movie){
		[self removeMovieIdleCallback];
		[movieView removeMovie:movie];
	}
	
	BOOL success = NO;

	NSData * movieData = [NSData dataWithContentsOfFile:path];
	movie = [QTMovie movieWithData:movieData error:nil];

    success = (movie != nil);
	
	if (success)
	{
		[self installMovieIdleCallback];
		[timelineController sizeToMovie];

	}else{
		NSLog(@"Had trouble loading movie; bail");
		
		//throw up dialog box about not being able to load file
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Could not load Movie."];
		[alert setInformativeText:[NSString stringWithFormat:@"There was a problem loading the movie located at path: %@.", path]];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		[alert runModal];
		[alert release];
	}
	
	//Movie needs to invalidate document somewhere other than here;
	//because this will be called upon opening a saved doc
	//so it happens in the controller
	
	[docController updateGUI];
	return;
}
- (void)addAuxMovie:(NSString *)path withOffset:(NSNumber *)offset{

	BOOL contains = NO;
	for (id existingPath in auxMoviePaths){
		if([existingPath isEqualTo:path]){
			contains = YES;
		}
	}
	if(!contains){
		
		NSData * movieData = [NSData dataWithContentsOfFile:path];
		QTMovie * newMovie = [QTMovie movieWithData:movieData error:nil];
		
		
		if (newMovie != nil){
			[auxMoviePaths addObject:path];
			[auxMovies addObject:newMovie];
			[auxMovieOffsets addObject:offset];
			[movieView addMovie:newMovie withOffset:[offset longValue]];
			
		}else{
			NSLog(@"Had trouble loading movie; bail");
			
			//throw up dialog box about not being able to load file
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"Could not load Movie."];
			[alert setInformativeText:[NSString stringWithFormat:@"There was a problem loading the movie located at path: %@.", path]];
			[alert setAlertStyle:NSWarningAlertStyle];
			
			[alert runModal];
			[alert release];
		}
	}
}

- (void)removeAuxMovie:(NSString *)path{
	int existingIndex = -1;
	for (int i = 0; i<[auxMoviePaths count]; i++){
		if([[auxMoviePaths objectAtIndex:i] isEqualTo:path]){
			existingIndex = i;
			break;
		}
	}
	if(existingIndex > -1){
		[self removeAuxMovieAtIndex:existingIndex];
	}
}

- (void)removeAuxMovieAtIndex:(int)index{
	[movieView removeMovie:[auxMovies objectAtIndex:index]];
	[auxMoviePaths removeObjectAtIndex:index];
	[auxMovies removeObjectAtIndex:index];
	[auxMovieOffsets removeObjectAtIndex:index];
}

- (NSArray *)auxMoviePaths{
	return [NSArray arrayWithArray:auxMoviePaths];
}

- (NSArray *)auxMovieOffsets{
	return [NSArray arrayWithArray:auxMovieOffsets];
}

- (NSArray *)auxMovies{
	return [NSArray arrayWithArray:auxMovies];
}
- (void) setOffsetOfAuxMovieAtIndex:(int)index to:(NSNumber *)anObject{
	[auxMovieOffsets replaceObjectAtIndex:index withObject:anObject];
}



- (DataFileLog *) dataFile{
	if(dataFile){
		return dataFile;
	}else{
		return nil;
	}
}

- (NSString *) dataFilePath{
	if([dataFile path]){
		return [dataFile path];
	}else{
		return nil;
	}
}

- (void)setDatafile:(NSString *)path
{
	DataFileLog * file = [[DataFileLog alloc] initWithPath:path];
	if(file){
		[file retain];
		if(dataFile!= nil){
			[dataFile release];
		}
		dataFile = file;

		[self updateChangeCount:NSChangeDone];

		[docController updateGUI];
	}else{
		//throw up dialog box about not being able to load file
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Could not load Data File."];
		[alert setInformativeText:[NSString stringWithFormat:@"There was a problem loading the data file located at path: %@.", path]];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		[alert runModal];
		[alert release];
	}
	return;
}

- (TimelineController *) timelineController{
	if(timelineController){
		return timelineController;
	}else{
		return nil;
	}
}

- (DocumentController *) docController{
	if(docController){
		return docController;
	}else{
		return nil;
	}
}

- (PlaybackController *) playbackController{
	if(playbackController){
		return playbackController;
	}else{
		return nil;
	}
}

//returns time in miliseconds since jan1, 1970 of playhead
- (unsigned long long) playheadTime{
	unsigned long long milliseconds;
	QTTime rightNow;
	if(movie != nil){
		rightNow = [movie currentTime];
	}else{
		rightNow.timeValue = 0.0; rightNow.timeScale = 1.0;
	}
	if(rightNow.timeScale==0.0)
		rightNow.timeScale = 1.00;
	
	milliseconds = ((float)rightNow.timeValue/(float)rightNow.timeScale)*1000.00;
	
	return movieStartOffset + milliseconds;
}


- (unsigned long long) timelineStart{
	return movieStartOffset;
}
- (unsigned long long) timelineEnd{
	unsigned long long milliseconds;
	QTTime length;
	if(movie != nil){
		length = [movie duration];
	}else{
		length.timeValue = 0.0; length.timeScale = 1.0;
	}
	if(length.timeScale==0.0)
		length.timeScale = 1.00;
	
	milliseconds = ((float)length.timeValue/(float)length.timeScale)*1000.00;
	
	return movieStartOffset + milliseconds;
}

- (unsigned long long) movieStartOffset{
	return movieStartOffset;
}

- (void) setMovieStartOffset:(unsigned long long)newOffset{
	movieStartOffset = newOffset;
	[self updateChangeCount:NSChangeDone];
}

//---------(Stuff for setting/getting skip playback mode)----------
- (int) skipInterval{
	return skipInterval;
}

- (void) setSkipInterval:(int)newInterval{
	skipInterval = newInterval;
	[self updateChangeCount:NSChangeDone];
}

- (BOOL) isInIntervalMode{
	return isInIntervalMode;
}

- (void) setIsInIntervalMode:(BOOL)state{
	isInIntervalMode = state;
	[movieView setControllerVisible:(!state)];
	[self updateChangeCount:NSChangeDone];
}

- (BOOL) intervalContinuous{
	return intervalContinuous;
}

- (void) setIntervalContinuous:(BOOL)state{
	intervalContinuous = state;
	[self updateChangeCount:NSChangeDone];
}

- (BOOL) isShowingAdminWindow{
	return isShowingAdminWindow;
}

- (void) setIsShowingAdminWindow:(BOOL)state{
	isShowingAdminWindow = state;
	[self updateChangeCount:NSChangeDone];
}

- (BOOL) isStacked{
	return isStacked;
}
- (void) setIsStacked:(BOOL)state{
	isStacked = state;
	[self updateChangeCount:NSChangeDone];
}	

- (BOOL) isShowingSound{
	return isShowingSound;
}
- (void) setIsShowingSound:(BOOL)state{
	isShowingSound = state;
	[self updateChangeCount:NSChangeDone];
}	

- (NSArray *) metricStyles{
	return [NSArray arrayWithObjects:@"Bar", @"Points", @"Line", nil];
}

//---------------------

- (float) percentPlayed{
	return ((float)([self playheadTime] - movieStartOffset))/((float)([self timelineEnd] - [self timelineStart]));
}

-(IBAction) toggleAdminWindow:(id)sender{
	[self setIsShowingAdminWindow:(![self isShowingAdminWindow])];
	return;
}
-(IBAction) exportEventTextFile:(id)sender{
	NSString* directory = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUsedPathKey"];
	if( directory == nil ) {
		directory = NSHomeDirectory();
	}
	NSMutableString* filename = [NSMutableString stringWithString:[self representedFilename]];
	[filename appendString:@"-evts.txt"];
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetForDirectory: directory
								 file: filename
                       modalForWindow: docWindow
                        modalDelegate: self
                       didEndSelector: @selector(exportPanelDidEnd:returnCode:contextInfo:)
                          contextInfo: nil];
	
	return;
}

- (void)exportPanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo{
	
	if(returnCode == NSOKButton){

		//set the last path for the export dialog
		[[NSUserDefaults standardUserDefaults] setObject:[sheet directory] forKey:@"lastUsedPathKey"];
		
		NSMutableString *output;
		output = [NSMutableString stringWithCapacity:1024];
		

		NSMutableArray * trackList;
		trackList = [[NSMutableArray alloc] initWithCapacity:10];
		
		//replace commas with: &#44;

		//Time,Duration,TrackName,comment
		
		//eventTracks exists and is an instance variable.
		NSArray * events;
		NSMutableString * trackName;
		EventTrack * thisTrack;
		Event * thisEvent;
		for(int i = 0; i<[eventTracks count]; i++){
			thisTrack = [eventTracks objectAtIndex:i];
			trackName = [[NSMutableString alloc] initWithCapacity:1];
			[trackName appendString:[thisTrack name]];
			[trackName replaceOccurrencesOfString:@"," withString:@"&#44;" options:NSLiteralSearch range:NSMakeRange(0, [trackName length])];
			
			[trackList addObject:trackName];
			events = [thisTrack eventList];
			for(int j=0; j<[events count]; j++){
				thisEvent = [events objectAtIndex:j];
					NSMutableString * comment;
					comment = [[NSMutableString alloc] initWithCapacity:1];
					if([thisEvent comment]){
						[comment appendString:[thisEvent comment]];
					}else{
						[comment appendString:@"(null)"];
					}
					[comment replaceOccurrencesOfString:@"," withString:@"&#44;" options:NSLiteralSearch range:NSMakeRange(0, [comment length])];
					[output appendFormat:@"%qu,%qu,%@,%@\n",
					 [thisEvent startTime],
					 [thisEvent duration],
					 trackName,
					 comment];

			}
		}
		
		
		

		NSArray * sortableLines = [output componentsSeparatedByString:@"\n"];
		NSArray * sortedArray;
		sortedArray = [sortableLines sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		//Sort lines before exporting?????


		
		
		
		
		NSMutableString * header;
		header = [[NSMutableString alloc] initWithCapacity:(512 + [output length])];
		[header appendFormat:@"Offset: %qu, Movie: %@, DataFile: %@\n",[self movieStartOffset],@"MoviePathHere",[self dataFilePath]];

		[header appendString:@"Tracks: "];
		for(int i = 0; i<[trackList count]; i++){
			[header appendFormat:@"%@, ",[trackList objectAtIndex:i]];
		}
		if([trackList count]>0){
			[header deleteCharactersInRange:NSMakeRange([header length]-2, 2)];
		}
		
		[header appendString:@"\nTime,Duration,TrackName,comment\n"];
		//[header appendString:output];
		[header appendString:[sortedArray componentsJoinedByString:@"\n"]];
		[header appendString:@"\n"];

		
		[header writeToURL:[sheet URL] atomically:YES];
	}
}

-(void)stretchRecordingEvents{
	Event * iteratingEvent;
	unsigned long long duration = 0;
	for(int i = 0; i<[recordingEvents count]; i++){
		iteratingEvent = [recordingEvents objectAtIndex:i];
		duration = [self playheadTime] - [iteratingEvent startTime];
		[iteratingEvent setDuration: duration];
		[self updateChangeCount:NSChangeDone];
	}
}


- (IBAction) tbzAddConsecutiveEventNow:(id)sender
{
    [myController addConsecutiveEventNow:sender];
}

- (IBAction) tbzSetActiveEventComment:(id)sender
{
    [myController setActiveEventComment:[sender title]];
}

- (IBAction) tbzMakePreviousEventActive:(id)sender
{
    EventTrack* track = [myController trackContainingEvent:[myController activeEvent]];
    [myController setActiveEvent:[track eventPreviousToEvent:[myController activeEvent]]];
}

- (IBAction) tbzMakeSubsequentEventActive:(id)sender
{
    EventTrack* track = [myController trackContainingEvent:[myController activeEvent]];
    [myController setActiveEvent:[track eventSubsequentToEvent:[myController activeEvent]]];
}

- (IBAction) tbzRewind:(id)sender
{
    [playbackController skipBackward:sender];
}

- (void)addEventTrack:(EventTrack *)evtTrk{
	[eventTracks addObject:evtTrk];
	[self updateChangeCount:NSChangeDone];
}

- (void)addEventTrack:(EventTrack *)evtTrk atIndex:(int)index{
	[eventTracks insertObject:evtTrk atIndex:index];
	[self updateChangeCount:NSChangeDone];
}


- (void)removeEventTrack:(EventTrack *)evtTrk{
	if([eventTracks containsObject:evtTrk]){
		[eventTracks removeObject:evtTrk];
	}
}
- (void)moveEventTrackFromIndex:(int)beginIndex toIndex:(int)endIndex{
	if(beginIndex>-1 && beginIndex<[eventTracks count] &&
	   endIndex>-1 && endIndex<[eventTracks count] ){

		if(beginIndex != endIndex){
			EventTrack * tempTrack;
			tempTrack = [eventTracks objectAtIndex:beginIndex];
			[eventTracks removeObjectAtIndex:beginIndex];
			[eventTracks insertObject:tempTrack atIndex:endIndex];
		}//else do nothing
	}
	return;
}

- (NSArray *) eventTracks{
	return [[[NSArray alloc] initWithArray:eventTracks] autorelease];
}

- (void)addRecordingEvent:(Event *)newEvent{
	[recordingEvents addObject:newEvent];
	return;
}

- (void)removeRecordingEvent:(Event *)oldEvent{
	if([recordingEvents containsObject:oldEvent]){
		[recordingEvents removeObject:oldEvent];
	}
	return;
}

- (NSArray *) recordingEvents{
	return [[[NSArray alloc] initWithArray:recordingEvents] autorelease];
}




-(void)installMovieIdleCallback
{
    ComponentResult cr = noErr;
	
    MovieController mc = [movie quickTimeMovieController];
    if (!mc) goto bail;
	
    MCActionFilterWithRefConUPP upp = NewMCActionFilterWithRefConUPP(MyActionFilter);
    if (!upp) goto bail;
	
    cr = MCSetActionFilterWithRefCon(mc, upp, (long)self);
    DisposeMCActionFilterWithRefConUPP(upp);
	
bail:
		return;

}
- (NSUndoManager *) windowWillReturnUndoManager:(NSWindow *)window{
	return [self undoManager];
}

-(void)removeMovieIdleCallback
{
    MCSetActionFilterWithRefCon([movie quickTimeMovieController],
								 nil,
								 (long)self);
}
	
@end


pascal Boolean MyActionFilter (MovieController mc, short action, void* params, long refCon)
{
    CodingDocument *doc = (CodingDocument *)refCon;
	//perhaps check previous time and only do things if the time changed?
    switch (action)
    {
        // handle idle events
        case mcActionIdle:
			if(doc){
				[[doc timelineController] scrollToNow];
				[doc stretchRecordingEvents];
			
			//this changes movie mode depending on checkboxes (continous or not)
				if([(QTMovie *)[doc movie] rate] == 0){
					[[doc movie] setPlaysSelectionOnly:NO];
				}
			}
            break;
    }
	
    return false;
}




