//
//  MultiMovieView.m
//  MovieViewTest
//
//  Created by Joey Hagedorn on 3/1/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "MultiMovieView.h"

#define BORDERSIZE 15

@implementation MultiMovieView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        movies = [[[NSMutableArray alloc] initWithCapacity:5] retain];
		offsets = [[[NSMutableArray alloc] initWithCapacity:5] retain];

		keyMovie = nil;
		syncedMovie = nil;
		controllerVisible = YES;
		[self setWantsLayer:YES];

    }
    return self;
}

- (void)dealloc{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[movies release];
	[offsets release];
	[super dealloc];
}

- (void)awakeFromNib {
	[self setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(boundsDidChange:)
												 name:@"NSViewFrameDidChangeNotification" object:self];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyMovieTimeChanged:)
												 name:@"QTMovieTimeDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyMovieRateChanged:)
												 name:@"QTMovieRateDidChangeNotification" object:nil];
	
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.

	[[NSColor grayColor] setFill];
	NSRectFill([self frame]);
	
	//do I need to tell children to refresh? or no?
}

- (void)keyDown:(NSEvent *)theEvent {
	if(keyMovie && ([[theEvent charactersIgnoringModifiers] isEqualTo:@" "] ||
					[[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSLeftArrowFunctionKey ||
					[[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSRightArrowFunctionKey))
		[[self viewForMovie:keyMovie] keyDown:theEvent];
	else
		[super keyDown:theEvent];
}


- (BOOL) acceptsFirstResponder{
	return YES;
}
- (BOOL)canBecomeKeyView{
	return YES;
}

- (BOOL)isFlipped {
	return YES;
}

- (void) addMovie:(QTMovie * )movie withOffset:(signed long)offset{
	if(! [[self movies] containsObject:movie]){
		ClickyQTMovieView * newView = [[[ClickyQTMovieView alloc] initWithFrame:[self frame]] autorelease];
		[newView setPreservesAspectRatio:YES];
		[newView setControllerVisible:NO];
		[newView setMovie:movie];
		[movies addObject:newView];
		[offsets addObject:[NSNumber numberWithLong:offset]];

		if(keyMovie == nil){
			keyMovie = movie;
		}
		if(syncedMovie == nil){
			syncedMovie = movie;
		}
		
		[self addSubview:newView];
		[self positionSubviews];
		[self syncMovies];
	}
}

- (void) addMovie:(QTMovie * )movie{
	[self addMovie:movie withOffset:0];
}


- (void) removeMovie:(QTMovie * )movie{

	//Maybe we should do something else if it is the syncedMovie
	if([[self movies] containsObject:movie]){
		if(movie == keyMovie){
			keyMovie = nil;
			if([[self movies] count] > 0){
				[self setKeyMovie:[[self movies] objectAtIndex:0]];
			}
		}
		if(movie == syncedMovie){
			syncedMovie = nil;
			if([[self movies] count] > 0){
				[self setSyncedMovie:[[self movies] objectAtIndex:0]];
			}

		}
		QTMovieView * moviesView = [self viewForMovie:movie];
		[moviesView removeFromSuperview];
		[offsets removeObjectAtIndex:[movies indexOfObject:moviesView]];
		[movies removeObject:moviesView];
		//release it's qtmovieview if this is necessary;
		//this might happen when it is removed from the dict
		[self positionSubviews];
	}
}

- (NSArray *) movies{
	NSMutableArray * movRefs = [[[NSMutableArray alloc] initWithCapacity:5] autorelease];
	id view;
	for (view in movies){
		[movRefs addObject:[view movie]];
	}
	
	return [NSArray arrayWithArray:movRefs];
}

- (void) setMovies:(NSArray *)newMovies{
	id movie;

	for(movie in [self movies]){
		[self removeMovie:movie];
	}

	for(movie in newMovies){
		[self addMovie:movie];
	}
}

- (void) setMovies:(NSArray *)newMovies withOffsets:(NSArray *)newOffsets{
	int length = [newMovies count];
	if(length == [newOffsets count]){
		for(id movie in [self movies]){
			[self removeMovie:movie];
		}
	
		for(int i=0; i<length; i++){
			[self addMovie:[newMovies objectAtIndex:i]
				withOffset:[[newOffsets objectAtIndex:i] longValue]];			
		}
	}
}

- (signed long) offsetForMovie:(QTMovie *)movie{
	NSArray * allMovies = [self movies];
	if ([allMovies containsObject:movie]){
		int i = [allMovies indexOfObject:movie];
		return [[offsets objectAtIndex:i] longValue];
	}else{
		return 0;
	}
		
}

- (void) setOffsetForMovie:(QTMovie *)movie to:(signed long)offset{
	NSArray * allMovies = [self movies];
	if ([allMovies containsObject:movie]){
		int i = [allMovies indexOfObject:movie];
		[offsets replaceObjectAtIndex:i withObject:[NSNumber numberWithLong:offset]];
		[self syncMovies];
	}
}




- (QTMovie *) keyMovie{
	return keyMovie;
}

- (void) setKeyMovie:(QTMovie *)movie{
	if([[self movies] containsObject:movie]){
		keyMovie = movie;
		id view;
		for(view in movies){
			if((QTMovie *)[view movie] != keyMovie){
				[view setControllerVisible:NO];
			}else{
				[view setControllerVisible:controllerVisible];
			}
		}
		[self positionSubviews];
	}	
}

- (QTMovie *) syncedMovie{
	return syncedMovie;
}

//The offset of a synced movie is inherently 0;
- (void) setSyncedMovie:(QTMovie *)movie{
	if([[self movies] containsObject:movie]){
		syncedMovie = movie;
		//[self setOffsetForMovie:syncedMovie to:0];		
	}
	
	
	for(id view in movies){
		if((QTMovie *)[view movie] != syncedMovie){
			[(QTMovie *)[view movie] setMuted:YES];
		}else{
			[(QTMovie *)[view movie] setMuted:NO];
		}
		
	}
	
	
}

- (BOOL) isControllerVisible{
	return controllerVisible;
}
- (void) setControllerVisible:(BOOL)boolean{
	controllerVisible = boolean;
	[[self viewForMovie:keyMovie] setControllerVisible:boolean];
}


- (void) play{
	[keyMovie play];
}

- (void) stop{
	[keyMovie stop];
}

- (bool) isPlaying{
	id movie;
	for (movie in [self movies]){
		if([movie rate] != 0){
			return YES;
		}
	}
	return NO;
}



//Syncronization

- (void)syncMovies{
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"QTMovieRateDidChangeNotification" object:keyMovie];
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"QTMovieTimeDidChangeNotification" object:keyMovie];
}

//when synced movie ends, etc, stop everything else. When synced movie is at end, set other movies
//when synced movie is at beginning, make sure that sets the other times too.
//we're going to do MS conversion here...
//get idle events of synced movie
//always resync to synced movie on stop/start




//First make sure synced movie and key movie aren't same.
//if they are not, first set syncedMovieTime relative to this one
//if it is not already the correct time
//then set keyMovieTime to what it would be relative to syncedMovie,
- (void)keyMovieTimeChanged:(NSNotification *)notification{
	QTMovie * observedMovie = [notification object];

	if(observedMovie == keyMovie){
		QTTime incTime;
		QTTime adjustedTime;
		QTTime keyMovieCurrentTime;
		QTTime syncedMovieCurrentTime;
		long milliseconds;

		if(keyMovie != syncedMovie){
			keyMovieCurrentTime = [keyMovie currentTime];
			milliseconds = [self offsetForMovie:keyMovie];
			incTime = QTMakeTime(abs([self offsetForMovie:keyMovie]),(long)1000);
			if(milliseconds > 0){
				adjustedTime = QTTimeDecrement(keyMovieCurrentTime, incTime);
			}else{
				adjustedTime = QTTimeIncrement(keyMovieCurrentTime, incTime);
			}
			if(NSOrderedSame != QTTimeCompare([syncedMovie currentTime],adjustedTime)){
				[syncedMovie setCurrentTime:adjustedTime];
			}
			
			syncedMovieCurrentTime = [syncedMovie currentTime];
			milliseconds = [self offsetForMovie:keyMovie];
			incTime = QTMakeTime(abs([self offsetForMovie:keyMovie]),(long)1000);
			if(milliseconds < 0){
				adjustedTime = QTTimeDecrement(syncedMovieCurrentTime, incTime);
			}else{
				adjustedTime = QTTimeIncrement(syncedMovieCurrentTime, incTime);
			}
			if(NSOrderedSame != QTTimeCompare([keyMovie currentTime],adjustedTime)){
				[keyMovie setCurrentTime:[self boundedTimeForMovie:keyMovie intendedTime:adjustedTime]];
			}
			
			
		}
		syncedMovieCurrentTime = [syncedMovie currentTime];

		for(id view in movies){
			if((QTMovie *)[view movie] != keyMovie){
				milliseconds = [self offsetForMovie:(QTMovie *)[view movie]];
				incTime = QTMakeTime(abs(milliseconds),(long)1000);
				if(milliseconds < 0){
					adjustedTime = QTTimeDecrement(syncedMovieCurrentTime, incTime);
				}else{
					adjustedTime = QTTimeIncrement(syncedMovieCurrentTime, incTime);
				}
				if(NSOrderedSame != QTTimeCompare([(QTMovie *)[view movie] currentTime],adjustedTime)){
					[(QTMovie *)[view movie] setCurrentTime:[self boundedTimeForMovie:(QTMovie *)[view movie] intendedTime:adjustedTime]];
				}
			}
		}


	}else if(observedMovie == syncedMovie){//synced movie time changed, and not directly
		//NSLog(@"SyncedMovieChangedTime!");
		//synced movie changed time and it is not key, 
		
		//First set syncedMovieTime relative to KeyMovie
		//if key movie is not already the correct time
		//then set keyMovieTime to what it would be relative to syncedMovie, 
	}

}

- (void)keyMovieRateChanged:(NSNotification *)notification{
	QTMovie * observedMovie = [notification object];
	if(observedMovie == keyMovie){
		//special case, check for if you pressed play and it was at the end of synced movie.
		if(observedMovie != syncedMovie){
			if(NSOrderedSame == QTTimeCompare([syncedMovie currentTime],[syncedMovie duration])){
				if([observedMovie rate] != 0.0){
					[observedMovie setRate:0.0];
				}
				return;
			}
		}
		for(id view in movies){
			QTMovie * thisMovie = (QTMovie *)[view movie];
			if(thisMovie != keyMovie){
				if([thisMovie rate] != [keyMovie rate]){
					if(!([thisMovie rate] == 0 && NSOrderedSame == QTTimeCompare([thisMovie currentTime],[thisMovie duration]))){
						[(QTMovie *)[view movie] setRate:[keyMovie rate]];
						

					}
				}
			}
		}
	}
	//also watch for rate change of synced movie. Be careful not to create a loop.
	if(observedMovie == syncedMovie){
		if([keyMovie rate] != [syncedMovie rate]){
			[keyMovie setRate:[syncedMovie rate]];
		}
	}
		
}

- (void)boundsDidChange:(NSNotification *)notification{
	[self positionSubviews];
}


//Private things


- (void)positionSubviews {
	if([movies count] > 0){
		if(!keyMovie){
			keyMovie = [[self movies] objectAtIndex:0];
		}
	}
	
	if ([movies count]>5){
		NSLog(@"Not Implemented for this many movies!");
	}else if([movies count] == 1){
		float xOriginBig = [self frame].origin.x;
		float yOriginBig = [self frame].origin.y;
		float keyWidthBig = [self frame].size.width;
		float keyHeightBig = [self frame].size.height;
		[[self viewForMovie:keyMovie] setFrame:NSMakeRect(xOriginBig,yOriginBig,
														  keyWidthBig,keyHeightBig)];
	}else if([movies count] > 0){
		float xOrigin = [self frame].origin.x;
		float yOrigin = [self frame].origin.y;
		float keyWidth = ([self frame].size.width)/4 * 3;
		float keyHeight = [self frame].size.height;
		float xAuxOrigin = [self frame].origin.x + keyWidth + 0.5 * BORDERSIZE;
		float yAuxOrigin = [self frame].origin.y + BORDERSIZE;
		float auxWidth = [self frame].size.width/4 - 2*BORDERSIZE;
		float auxHeight = [self frame].size.height/4 - 2*BORDERSIZE;
		float auxVStep = [self frame].size.height/4 - 0.5 * BORDERSIZE;

		int auxLayedOut = 0;
		id view;
		for (view in movies) {
			if(view == [self viewForMovie:keyMovie]){
				[[view animator] setFrame:NSMakeRect(xOrigin,yOrigin,keyWidth,keyHeight)];
			}else{
				[[view animator] setFrame:NSMakeRect(xAuxOrigin,
													 yAuxOrigin + (auxVStep * auxLayedOut),
													 auxWidth,
													 auxHeight)];
				auxLayedOut++;
			}

		}

	}
	for(id view in movies){
		if((QTMovie *)[view movie] != syncedMovie){
			[(QTMovie *)[view movie] setMuted:YES];
		}else{
			[(QTMovie *)[view movie] setMuted:NO];
		}
		
	}
}

- (ClickyQTMovieView *) viewForMovie:(QTMovie *) movie{
	id view;
	for(view in movies){
		if((QTMovie *)[view movie] == movie){
			return view;
		}
	}
	return nil;
}

- (QTTime) boundedTimeForMovie:(QTMovie *) movie intendedTime:(QTTime)time{
	if(NSOrderedDescending == QTTimeCompare(QTMakeTime(0,1),time)){
		return QTMakeTime(0,1);
	}else if(NSOrderedAscending == QTTimeCompare([movie duration],time)){
		return [movie duration];
	}
	return time;
}

@end
