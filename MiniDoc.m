//
//  MiniDoc.m
//  AnalysisTool
//
//  Created by Joey Hagedorn on 11/30/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "MiniDoc.h"
#import <QTKit/QTKit.h>


@implementation MiniDoc

- (id)init
{
    self = [super init];
    if (self) {
		
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		eventTracks = [[[NSMutableArray alloc] initWithCapacity:5] retain];
		offsets = [[[NSMutableArray alloc] initWithCapacity:5] retain];
		paths = [[[NSMutableArray alloc] initWithCapacity:5] retain];
		isShowingSound = YES;
		isStacked = NO;
		movieLength = QTMakeTime(0,0);
    }else{
		[self release];
		return nil;
	}
    return self;
}

- (void)dealloc{
	[eventTracks release];
	[super dealloc];
}

- (id)initWithPath:(NSString *)inputPath{
	self = [super init];
	
    if ( self ) {
		NSData * data;
		data = [NSData dataWithContentsOfFile:inputPath];
		[self loadDataRepresentation:data ofType: @"cod"];
    }else{
		return nil;
	}
	
	return self;
}


- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	NSKeyedUnarchiver *unarchiver;
	unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	[eventTracks release];
	eventTracks = [[unarchiver decodeObjectForKey:@"CDeventtracks"] retain];
	movieStartOffset = [unarchiver decodeInt64ForKey:@"CDMovieStartOffset"];
	skipInterval = [unarchiver decodeInt32ForKey:@"CDskipinterval"];
	[self setMovie:[unarchiver decodeObjectForKey:@"CDmoviepath"]];
	[dataFile release];
	dataFile = [[unarchiver decodeObjectForKey:@"CDdatafile"] retain];	
	
	isShowingSound = [unarchiver decodeBoolForKey:@"CD3isshowingsound"];
	isStacked = [unarchiver decodeBoolForKey:@"CD2isStacked"];
	[offsets release];
	offsets = [[unarchiver decodeObjectForKey:@"CD2auxMovieOffsets"] retain];
	[paths release];
	paths = [[unarchiver decodeObjectForKey:@"CD2auxMoviePaths"] retain];

	
	[unarchiver finishDecoding];
	[unarchiver release];
	
	return YES;
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
	[archiver encodeQTTime:QTTimeFromString(@"0:00:00:00.00/600") forKey:@"CDmovietime"];
	[archiver encodeObject:dataFile forKey:@"CDdatafile"];
    [archiver encodeObject:eventTracks forKey:@"CDeventtracks"];
    [archiver encodeObject:[NSMutableArray arrayWithCapacity:0] forKey:@"CDrecordingEvents"];
	[archiver encodeInt64:movieStartOffset forKey:@"CDMovieStartOffset"];
	[archiver encodeInt32:skipInterval forKey:@"CDskipinterval"];
	[archiver encodeBool:NO forKey:@"CDisinintervalmode"];
	[archiver encodeBool:NO forKey:@"CDintervalcontinuous"];
	[archiver encodeBool:NO forKey:@"CDisshowingadminwindow"];
	
	[archiver encodeBool:isShowingSound forKey:@"CD3isshowingsound"];
	[archiver encodeBool:isStacked forKey:@"CD2isStacked"];
	[archiver encodeObject:offsets forKey:@"CD2auxMovieOffsets"];
	[archiver encodeObject:paths forKey:@"CD2auxMoviePaths"];
	
	[archiver finishEncoding];
	
	[archiver release];
    return data;
	
}



- (void)addEventTrack:(EventTrack *)evtTrk{
	[eventTracks addObject:evtTrk];
}

- (void)addEventTrack:(EventTrack *)evtTrk atIndex:(int)index{
	[eventTracks insertObject:evtTrk atIndex:index];
}


- (void)removeEventTrack:(EventTrack *)evtTrk{
	if([eventTracks containsObject:evtTrk]){
		[eventTracks removeObject:evtTrk];
	}
}

- (void)setMovieOffset:(unsigned long long)offset{
	movieStartOffset = offset;
}


- (void)setSkipInterval:(int)interval{
	skipInterval = interval;
}

- (unsigned long long) offset{
	return movieStartOffset;
}
- (unsigned int) interval{
	return skipInterval;
}


- (void)setMovie:(NSString *)newMovie{
	[newMovie retain];
	[moviePath release];
	moviePath = newMovie;
	NSData * movieData = [NSData dataWithContentsOfFile:moviePath];
	if(movieData){
		QTMovie * movieTemp = [QTMovie movieWithData:movieData error:nil];
		if (movieTemp){
			movieLength = [movieTemp duration];
		}else{
			
			movieLength = QTMakeTime(0,0);
		}
		//NSLog(@"%@", QTStringFromTime(movieLength));
	}else{
		movieLength = QTMakeTime(0,0);
	}
	
}

- (NSString *) moviePath{
	if(moviePath){
		return moviePath;
	}else{
		return nil;
	}
}

- (QTTime) movieLength {
	return movieLength;
}

- (void)setDataFile:(NSString *)newDatafilePath
{
	DataFileLog * file = [[DataFileLog alloc] initWithPath:newDatafilePath];
	if(file){
		[file retain];
		if(dataFile!= nil){
			[dataFile release];
		}
		dataFile = file;
	}else{
		//throw up dialog box about not being able to load file
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Could not load Data File."];
		[alert setInformativeText:[NSString stringWithFormat:@"There was a problem loading the data file located at path: %@.", newDatafilePath]];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		[alert runModal];
		[alert release];
	}
	return;
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



- (NSArray *) eventTracks{
	return [[[NSArray alloc] initWithArray:eventTracks] autorelease];
}

- (EventTrack *) trackNamed:(NSString *)name{
	for(int i = 0; i<[eventTracks count]; i++){
		EventTrack * track = [eventTracks objectAtIndex:i];
		if([name isEqualToString:[track name]]){
			return track;
		}
	}
	return nil;
}

@end
