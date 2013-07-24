//
//  AgreementController.m
//  AnalysisTool
//
//  Created by Joey Hagedorn on 11/30/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "AgreementController.h"
#import "Foundation/Foundation.h"


@implementation AgreementController

- (id)init
{
    self = [super init];
    if (self) {
		primaryCoderDoc = [[[MiniDoc alloc] init] retain];
		secondaryCoderDoc = [[[MiniDoc alloc] init] retain];
		totaledTracks = [[[NSMutableArray alloc] init] retain];
		markTolerance = 1.0;
		durationTolerance = 1.0;
		evta = 0.0;
		evto = 0.0;
		evtp = 0.0;
		dura = 0.0;
		duro = 0.0;
		durp = 0.0;
		cmta = 0.0;
		cmto = 0.0;
		cmtp = 0.0;
    }else{
		[self release];
		return nil;
	}
    return self;
}

- (void)dealloc{
	[primaryCoderDoc release];
	[secondaryCoderDoc release];
	[totaledTracks release];
	[super dealloc];
}


- (void) awakeFromNib{

	NSArray *datafileTypes = [NSArray arrayWithObjects:@"cod",nil];
	[primarySelector setFileTypes:datafileTypes];
	[secondarySelector setFileTypes:datafileTypes];

}

#pragma mark - IBActions

- (IBAction)openHelpPDF:(id)sender{
	[[NSWorkspace sharedWorkspace] openFile:[[NSBundle mainBundle] pathForResource:@"VCodeVDataDocs" ofType:@"pdf"]
							withApplication:@"Preview"];	
}


-(IBAction) primarySelected:(id)sender{
	NSString * path = (NSString *)[[sender alias] fullPath];
	MiniDoc * file = [[MiniDoc alloc] initWithPath:path];
	if(file){
		[file retain];
		if(primaryCoderDoc!= nil){
			[primaryCoderDoc release];
		}
		primaryCoderDoc = file;
	}else{
		//throw up dialog box about not being able to load file
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Could not load VCode File."];
		[alert setInformativeText:[NSString stringWithFormat:@"There was a problem loading the file located at path: %@.", path]];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		[alert runModal];
		[alert release];
	}
	[totaledTracks release];
	totaledTracks = [[[NSMutableArray alloc] init] retain];

	[self updateGUI];
	return;
}

-(IBAction) secondarySelected:(id)sender{
	NSString * path = (NSString *)[[sender alias] fullPath];
	MiniDoc * file = [[MiniDoc alloc] initWithPath:path];
	if(file){
		[file retain];
		if(secondaryCoderDoc!= nil){
			[secondaryCoderDoc release];
		}
		secondaryCoderDoc = file;
		
	}else{
		//throw up dialog box about not being able to load file
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Could not load VCode File."];
		[alert setInformativeText:[NSString stringWithFormat:@"There was a problem loading the file located at path: %@.", path]];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		[alert runModal];
		[alert release];
	}
	[totaledTracks release];
	totaledTracks = [[[NSMutableArray alloc] init] retain];
	
	[self updateGUI];
	return;
}

- (IBAction) mergeTracks:(id)sender{
	EventTrack * newPrimaryTrack = [[EventTrack alloc] init];
	EventTrack * newSecondaryTrack = [[EventTrack alloc] init];
	
	NSIndexSet * selectedRows = [trackTable selectedRowIndexes];
	
	if([selectedRows count] > 1){
		NSMutableString * trackName = [NSMutableString string];
		int mergeIndex = [selectedRows firstIndex];
		while (mergeIndex!=NSNotFound) {
				// do Stuff
			EventTrack * primaryTrack = [[primaryCoderDoc eventTracks] objectAtIndex:mergeIndex];
			EventTrack * secondaryTrack = [[secondaryCoderDoc eventTracks] objectAtIndex:mergeIndex];
			NSArray * primaryEvents = [primaryTrack eventList];
			NSArray * secondaryEvents = [secondaryTrack eventList];

			for(int j = 0; j<[primaryEvents count]; j++){
				[newPrimaryTrack addEvent:[primaryEvents objectAtIndex:j]];
			}
			for(int j = 0; j<[secondaryEvents count]; j++){
				[newSecondaryTrack addEvent:[secondaryEvents objectAtIndex:j]];
			}
			[trackName appendString:[primaryTrack name]];
			mergeIndex=[selectedRows indexGreaterThanIndex:mergeIndex];

		}
		
		
		
		//set ranged track accordingly!
		
		[newPrimaryTrack setName:trackName];
		[newSecondaryTrack setName:trackName];
		
		[primaryCoderDoc addEventTrack:newPrimaryTrack];
		[secondaryCoderDoc addEventTrack:newSecondaryTrack];
		[self updateGUI];
	}
		
	[self updateGUI];
}



- (IBAction) compareTracks:(id)sender{

	
	NSIndexSet * selectedRows = [trackTable selectedRowIndexes];
	
	if([selectedRows count] > 0){
		MiniDoc * temporaryComparisonDoc = [[[MiniDoc alloc] init] autorelease];
		if([primaryCoderDoc moviePath]){
			[temporaryComparisonDoc setMovie:[primaryCoderDoc moviePath]];
		}else{
			NSLog(@"No Movie File Found! Comparison file won't contain reference.");
		}
		if([primaryCoderDoc dataFilePath]){
			[temporaryComparisonDoc setDataFile:[primaryCoderDoc dataFilePath]];
		}else{
			NSLog(@"No Data File Found! Comparison file won't contain reference.");
		}
		[temporaryComparisonDoc setMovieOffset:[primaryCoderDoc offset]];
		[temporaryComparisonDoc setSkipInterval:[primaryCoderDoc interval]];
		
		int mergeIndex = [selectedRows firstIndex];
		while (mergeIndex!=NSNotFound) {

			EventTrack * primaryTrack = [[primaryCoderDoc eventTracks] objectAtIndex:mergeIndex];
			EventTrack * newPrimaryTrack = [EventTrack eventTrackWithEventTrack: primaryTrack];
			EventTrack * secondaryTrack = [[secondaryCoderDoc eventTracks] objectAtIndex:mergeIndex];
			EventTrack * newSecondaryTrack = [EventTrack eventTrackWithEventTrack: secondaryTrack];
			[newSecondaryTrack setTrackColor:[[newSecondaryTrack trackColor] blendedColorWithFraction:0.5 ofColor:[NSColor blackColor]]];


			NSMutableString * firstTrackName = [NSMutableString stringWithString:@"A - "];
			NSMutableString * secondTrackName = [NSMutableString stringWithString:@"B - "];
			[firstTrackName appendString:[primaryTrack name]];
			[secondTrackName appendString:[primaryTrack name]];

			[newPrimaryTrack setName:firstTrackName];
			[newSecondaryTrack setName:secondTrackName];
			
			[temporaryComparisonDoc addEventTrack:newPrimaryTrack];
			[temporaryComparisonDoc addEventTrack:newSecondaryTrack];
		
			mergeIndex=[selectedRows indexGreaterThanIndex:mergeIndex];
			
		}
		NSArray * paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
		NSString * desktop_path = [paths objectAtIndex:0];
		
		NSMutableString * savePath = [[NSMutableString alloc] initWithCapacity:128];
		[savePath appendString:desktop_path];
		[savePath appendString:@"/comparison.cod"];
		[[temporaryComparisonDoc dataRepresentationOfType:@"cod"] writeToFile:savePath atomically:YES];

		//open it with VCode
		[[NSWorkspace sharedWorkspace] openFile:savePath withApplication:@"VCode"];
							 
	}
	

}


-(IBAction) exportEventTextFile:(id)sender{
	NSString* directory = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastUsedPathKey"];
	if( directory == nil ) {
		directory = NSHomeDirectory();
	}

	NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel beginSheetForDirectory: directory
								 file: @"Untitled.txt"
                       modalForWindow: window
                        modalDelegate: self
                       didEndSelector: @selector(exportPanelDidEnd:returnCode:contextInfo:)
                          contextInfo: nil];
	
	return;
}

- (void)exportPanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo{
	
	if(returnCode == NSOKButton){

		
		NSMutableString * header;
		header = [[NSMutableString alloc] init];
		[header appendFormat:@"Possible Tracks: %@\n",[self intersectingTrackNames]];
		[header appendFormat:@"Tracks Included In Total: %@\n\n",totaledTracks];

		[header appendString:@"Track,evtAgr,evtOpp,evtPct,durAgr,durOpp,durPct,cmtAgr,cmtOpp,cmtPct,Op,Os,Np,Ns,U,A,Pa,Pc,K\n"];
		for(int i=0;i<[[self intersectingTrackNames] count];i++){
			NSString * thisTrackName = [[self intersectingTrackNames] objectAtIndex:i];
			[header appendFormat:@"%@,%f,%f,%f,%f,%f,%f,%f,%f,%f,%@\n",
			 thisTrackName,
			 (float)[self agreeingEventCountForTrackNamed:thisTrackName],
			 (float)[self opportunityEventCountForTrackNamed:thisTrackName],
			 ((float)[self agreeingEventCountForTrackNamed:thisTrackName])/
			 ((float)[self opportunityEventCountForTrackNamed:thisTrackName]),
			 (float)[self agreeingDurationCountForTrackNamed:thisTrackName],
			 (float)[self opportunityDurationCountForTrackNamed:thisTrackName],
			 ((float)[self agreeingDurationCountForTrackNamed:thisTrackName])/
			 ((float)[self opportunityDurationCountForTrackNamed:thisTrackName]),
			 (float)[self agreeingCommentCountForTrackNamed:thisTrackName],
			 (float)[self opportunityCommentCountForTrackNamed:thisTrackName],
			 ((float)[self agreeingCommentCountForTrackNamed:thisTrackName])/
			 ((float)[self opportunityCommentCountForTrackNamed:thisTrackName]),
			 ((NSString*)[kappaController exportDataToCSForTrackNamed:thisTrackName  row:i])
			];

		}

		[header appendString:@"\n"];
		[header appendFormat:@"%@,%f,%f,%f,%f,%f,%f,%f,%f,%f,nan,nan,nan,nan,nan,nan,nan,nan,nan\n",
		 @"TOTALS",
		 evta,
		 evto,
		 evtp,
		 dura,
		 duro,
		 durp,
		 cmta,
		 cmto,
		 cmtp
		];
		[header writeToURL:[sheet URL] atomically:YES];
	}
}




#pragma mark - Agreement Calculations

//returns array of strings of tracknames that occur in both files
-(NSArray *)intersectingTrackNames{
	if(primaryCoderDoc != nil && secondaryCoderDoc !=nil){
		NSArray * evtTracks = [primaryCoderDoc eventTracks];
		NSMutableArray *primaryCoderTracknames = [NSMutableArray array];
		NSMutableArray *secondaryCoderTracknames = [NSMutableArray array];
		for(int i = 0; i<[evtTracks count]; i++){
			EventTrack * track = [evtTracks objectAtIndex:i];
			[primaryCoderTracknames addObject:[track name]];
		}

		
		evtTracks = [secondaryCoderDoc eventTracks];
		for(int i = 0; i<[evtTracks count]; i++){
			EventTrack * track = [evtTracks objectAtIndex:i];
			[secondaryCoderTracknames addObject:[track name]];
		}
		
		NSMutableArray * intersectTracknames = [NSMutableArray array];
		
		for(int i = 0; i<[primaryCoderTracknames count]; i++){
			NSString * primaryTrackName = [primaryCoderTracknames objectAtIndex:i];
			for(int j = 0; j<[secondaryCoderTracknames count]; j++){
				if([primaryTrackName isEqualToString:[secondaryCoderTracknames objectAtIndex:j]]){
					[intersectTracknames addObject:primaryTrackName];
					break;
				}
			}
		}
		return intersectTracknames;
	}
	return [NSArray array];
	
}

//returns an array of NSArrays[2] (primaryEvent, secondaryEvent)
//of events pairs that occur in given trackname
-(NSArray *)agreeingEventsForTrackNamed:(NSString *)trackName{
	NSMutableArray * agreeingEvents = [NSMutableArray array];
	if(primaryCoderDoc != nil && secondaryCoderDoc != nil){
		EventTrack * primaryTrack = [primaryCoderDoc trackNamed:trackName];
		EventTrack * secondaryTrack = [secondaryCoderDoc trackNamed:trackName];
		
		if(primaryTrack != nil && secondaryTrack != nil){
			NSArray * primaryEvents = [primaryTrack eventList];
			NSMutableArray * secondaryEvents = [NSMutableArray arrayWithArray:[secondaryTrack eventList]];
			for(int i = 0; i<[primaryEvents count]; i++){
				Event * primaryEvent = [primaryEvents objectAtIndex:i];
				for(int j = 0; j<[secondaryEvents count]; j++){
					Event * secondaryEvent = [secondaryEvents objectAtIndex:j];
					if((float)(abs([secondaryEvent startTime] - [primaryEvent startTime])) <= (markTolerance * 1000)){
						[agreeingEvents addObject:[NSArray arrayWithObjects:primaryEvent, secondaryEvent, nil]];
						[secondaryEvents removeObject:secondaryEvent];
						break;
					}
				}
			}
		}
	}
	return agreeingEvents;

}

//returns number of events that agree for start time
-(int)agreeingEventCountForTrackNamed:(NSString *)trackName{
	return [[self agreeingEventsForTrackNamed:trackName] count];

}

//returns an array of NSArrays[2] (primaryEvent, secondaryEvent)
//of events pairs that occur in given trackname
-(NSArray *)agreeingEventsNoToleranceForTrackNamed:(NSString *)trackName{
	NSMutableArray * agreeingEvents = [NSMutableArray array];
	if(primaryCoderDoc != nil && secondaryCoderDoc != nil){
		EventTrack * primaryTrack = [primaryCoderDoc trackNamed:trackName];
		EventTrack * secondaryTrack = [secondaryCoderDoc trackNamed:trackName];
		
		if(primaryTrack != nil && secondaryTrack != nil){
			NSArray * primaryEvents = [primaryTrack eventList];
			NSMutableArray * secondaryEvents = [NSMutableArray arrayWithArray:[secondaryTrack eventList]];
			for(int i = 0; i<[primaryEvents count]; i++){
				Event * primaryEvent = [primaryEvents objectAtIndex:i];
				for(int j = 0; j<[secondaryEvents count]; j++){
					Event * secondaryEvent = [secondaryEvents objectAtIndex:j];
					if((float)(abs([secondaryEvent startTime] - [primaryEvent startTime])) <= (0 * 1000)){
						[agreeingEvents addObject:[NSArray arrayWithObjects:primaryEvent, secondaryEvent, nil]];
						[secondaryEvents removeObject:secondaryEvent];
						break;
					}
				}
			}
		}
	}
	return agreeingEvents;
	
}

//returns number of events that agree for start time
-(int)agreeingEventCountNoToleranceForTrackNamed:(NSString *)trackName{
	return [[self agreeingEventsNoToleranceForTrackNamed:trackName] count];
	
}


//returns number of events in track
-(int)opportunityEventCountForTrackNamed:(NSString *)trackName{
	if(primaryCoderDoc != nil ){
		EventTrack * track = [primaryCoderDoc trackNamed:trackName];
		if(track != nil){
			NSArray * events = [track eventList];
			return [events count];
		}
	}
	return 0;
}

//returns number of ranged events that agree for startTime and Duration
-(int)agreeingDurationCountForTrackNamed:(NSString *)trackName{
	int agreeCount = 0;
	NSArray * agreeingEventPairs = [self agreeingEventsForTrackNamed:trackName];
	for(int i = 0; i<[agreeingEventPairs count]; i++){
		Event * primaryEvent = [[agreeingEventPairs objectAtIndex:i] objectAtIndex:0];
		Event * secondaryEvent = [[agreeingEventPairs objectAtIndex:i] objectAtIndex:1];

		if([primaryEvent duration] > 0){
			if(abs([primaryEvent duration] - [secondaryEvent duration]) <= (durationTolerance * 1000)){
				agreeCount++;
			}
		}
	}
	return agreeCount;
}


//returns number of ranged events that agree for startTime
-(int)opportunityDurationCountForTrackNamed:(NSString *)trackName{
	int opportunityCount = 0;
	NSArray * agreeingEventPairs = [self agreeingEventsForTrackNamed:trackName];
	for(int i = 0; i<[agreeingEventPairs count]; i++){
		Event * evt = [[agreeingEventPairs objectAtIndex:i] objectAtIndex:0];
		if([evt duration] > 0){
			opportunityCount++;
		}
	}
	return opportunityCount;
}

//returns number of ranged events that agree for startTime and Duration
-(int)agreeingCommentCountForTrackNamed:(NSString *)trackName{
	int agreeCount = 0;
	NSArray * agreeingEventPairs = [self agreeingEventsForTrackNamed:trackName];
	for(int i = 0; i<[agreeingEventPairs count]; i++){
		Event * primaryEvent = [[agreeingEventPairs objectAtIndex:i] objectAtIndex:0];
		Event * secondaryEvent = [[agreeingEventPairs objectAtIndex:i] objectAtIndex:1];
		
		if([primaryEvent comment] != nil && [secondaryEvent comment] != nil){
			if([[primaryEvent comment] caseInsensitiveCompare:[secondaryEvent comment]] == NSOrderedSame){
				agreeCount++;
			}
		}
	}
	return agreeCount;
}


//returns number of ranged events that agree for startTime
-(int)opportunityCommentCountForTrackNamed:(NSString *)trackName{
	int opportunityCount = 0;
	NSArray * agreeingEventPairs = [self agreeingEventsForTrackNamed:trackName];
	for(int i = 0; i<[agreeingEventPairs count]; i++){
		Event * evt = [[agreeingEventPairs objectAtIndex:i] objectAtIndex:0];
		if([evt comment] != nil){
			opportunityCount++;
		}
	}
	return opportunityCount;
}



#pragma mark - Accessors

-(MiniDoc*) primaryCoderDoc{
	return primaryCoderDoc;
}

-(MiniDoc*) secondaryCoderDoc{
	return secondaryCoderDoc;
}

-(float) markTolerance{
	return markTolerance;
}
-(void) setMarkTolerance:(float)tol{
	markTolerance = tol;
	[self updateGUI];
}
-(float) durationTolerance{
	return durationTolerance;
}
-(void) setDurationTolerance:(float)tol{
	durationTolerance = tol;
	[self updateGUI];
}
- (float) evta {
	return evta;
}
- (void) setEvta:(float)newEvta {
	evta = newEvta;
}

- (float) evto {
	return evto;
}
- (void) setEvto:(float)newEvto {
	evto = newEvto;
}

- (float) evtp {
	return evtp;
}
- (void) setEvtp:(float)newEvtp {
	evtp = newEvtp;
}

- (float) dura {
	return dura;
}
- (void) setDura:(float)newDura {
	dura = newDura;
}

- (float) duro {
	return duro;
}
- (void) setDuro:(float)newDuro {
	duro = newDuro;
}

- (float) durp {
	return durp;
}
- (void) setDurp:(float)newDurp {
	durp = newDurp;
}

- (float) cmta {
	return cmta;
}
- (void) setCmta:(float)newCmta {
	cmta = newCmta;
}

- (float) cmto {
	return cmto;
}
- (void) setCmto:(float)newCmto {
	cmto = newCmto;
}

- (float) cmtp {
	return cmtp;
}
- (void) setCmtp:(float)newCmtp {
	cmtp = newCmtp;
}


#pragma mark - Helpers

- (void)updateGUI{
	[trackTable reloadData];
	[self calculateTotals];
	[kappaController updateGUI];
	return;
}

- (void)calculateTotals{
	[self setEvta:0.0];
	[self setEvto:0.0];
	[self setDura:0.0];
	[self setDuro:0.0];
	[self setCmta:0.0];
	[self setCmto:0.0];
	for(int i = 0; i<[totaledTracks count]; i++){
		NSString * trackname = [totaledTracks objectAtIndex:i];
		[self setEvta:evta + [self agreeingEventCountForTrackNamed:trackname]];
		[self setEvto:evto + [self opportunityEventCountForTrackNamed:trackname]];
		[self setDura:dura + [self agreeingDurationCountForTrackNamed:trackname]];
		[self setDuro:duro + [self opportunityDurationCountForTrackNamed:trackname]];
		[self setCmta:cmta + [self agreeingCommentCountForTrackNamed:trackname]];
		[self setCmto:cmto + [self opportunityCommentCountForTrackNamed:trackname]];
	}

	if(evto==0.0){
		[self setEvtp:-1.0];
	}else{
		[self setEvtp:((float)evta)/((float)evto)];
	}
	if(duro==0.0){
		[self setDurp:-1.0];
	}else{
		[self setDurp:((float)dura)/((float)duro)];
	}
	if(cmto==0.0){
		[self setCmtp:-1.0];
	}else{
		[self setCmtp:((float)cmta)/((float)cmto)];
	}
	return;
}

#pragma mark - Table Glue Code
// just returns the item for the right row
- (id)tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn row:(int) rowIndex{  
	//log or something to figure out which table column?
	NSString * thisTrackName = [[self intersectingTrackNames]objectAtIndex:rowIndex];
	if([[aTableColumn identifier] compare: @"trackName"]==NSOrderedSame){
		return thisTrackName;  
	}else if([[aTableColumn identifier] compare: @"evtAgree"]==NSOrderedSame){
		int agree =  [self agreeingEventCountForTrackNamed:thisTrackName];
		return [NSNumber numberWithInt:agree];
	}else if([[aTableColumn identifier] compare: @"evtOpportunity"]==NSOrderedSame){
		int opportunities =[self opportunityEventCountForTrackNamed:thisTrackName];
		return [NSNumber numberWithInt:opportunities];
	}else if([[aTableColumn identifier] compare: @"evtPctAgree"]==NSOrderedSame){
		float percentAgree = ((float)[self agreeingEventCountForTrackNamed:thisTrackName])/
		((float)[self opportunityEventCountForTrackNamed:thisTrackName]);
		return [NSNumber numberWithFloat:percentAgree];
	}else if([[aTableColumn identifier] compare: @"durAgree"]==NSOrderedSame){
		int agree =  [self agreeingDurationCountForTrackNamed:thisTrackName];
		return [NSNumber numberWithInt:agree];
	}else if([[aTableColumn identifier] compare: @"durOpportunity"]==NSOrderedSame){
		int opportunities =[self opportunityDurationCountForTrackNamed:thisTrackName];
		return [NSNumber numberWithInt:opportunities];
	}else if([[aTableColumn identifier] compare: @"durPctAgree"]==NSOrderedSame){
		float percentAgree = ((float)[self agreeingDurationCountForTrackNamed:thisTrackName])/
		((float)[self opportunityDurationCountForTrackNamed:thisTrackName]);
		return [NSNumber numberWithFloat:percentAgree];
	}else if([[aTableColumn identifier] compare: @"cmtAgree"]==NSOrderedSame){
		int agree =  [self agreeingCommentCountForTrackNamed:thisTrackName];
		return [NSNumber numberWithInt:agree];
	}else if([[aTableColumn identifier] compare: @"cmtOpportunity"]==NSOrderedSame){
		int opportunities =[self opportunityCommentCountForTrackNamed:thisTrackName];
		return [NSNumber numberWithInt:opportunities];
	}else if([[aTableColumn identifier] compare: @"cmtPctAgree"]==NSOrderedSame){
		float percentAgree = ((float)[self agreeingCommentCountForTrackNamed:thisTrackName])/
		((float)[self opportunityCommentCountForTrackNamed:thisTrackName]);
		return [NSNumber numberWithFloat:percentAgree];
	}else if([[aTableColumn identifier] compare: @"totaled"]==NSOrderedSame){
		for(int i = 0; i<[totaledTracks count]; i++){
			if([[totaledTracks objectAtIndex:i] isEqualTo:thisTrackName]){
				return [NSNumber numberWithBool:YES];
			}
		}
		return [NSNumber numberWithBool:NO];
	}

	
	return nil;
	
}

// just returns the number of items we have.
- (int)numberOfRowsInTableView:(NSTableView *)aTableView{

	return [[self intersectingTrackNames] count];
}


- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{

	if([[aTableColumn identifier] compare: @"totaled"]==NSOrderedSame){
		NSString * clickedTrackName = [[self intersectingTrackNames] objectAtIndex:rowIndex];
		if([totaledTracks containsObject:clickedTrackName]){
			[totaledTracks removeObject:clickedTrackName];

		}else{
			[totaledTracks addObject:clickedTrackName];
		}
	}
	[self updateGUI];
	return;
}



@end
