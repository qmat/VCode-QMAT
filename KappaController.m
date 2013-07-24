//
//  KappaController.m
//  AnalysisTool
//
//  Created by Joshua Hailpern on 7/26/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KappaController.h"


@implementation KappaController

- (void) awakeFromNib{
	intervals = [[NSMutableArray alloc] init];
}

#pragma mark - Kappa Calculations
- (int)opportunitiesForInterval:(int)interval{
	QTTime movieLength = [[agreementController primaryCoderDoc] movieLength];
	if(movieLength.timeValue != QTMakeTime(0,0).timeValue || movieLength.timeScale != QTMakeTime(0,0).timeScale){
		QTTime scaled = QTMakeTimeScaled(movieLength, (long)1000);
		int lengthInSeconds = (int)(scaled.timeValue / (long long) 1000);
		int result = ceil((double)lengthInSeconds/(double)interval)+1;
		return result;
	}else{//couldn't load movie...
		return 0;
	}
}

//returns number of events in track
- (int)occurenceEventCountForTrackNamed:(NSString *)trackName forCoderDoc:(MiniDoc*)coderDoc withInterval:(int)interval{
	//could eventually put in check to make sure we are only checking at the interval
	if(coderDoc != nil ){
		EventTrack * track = [coderDoc trackNamed:trackName];
		if(track != nil){
			NSArray * events = [track eventList];
			return [events count];
		}
	}
	return 0;
}
//returns the non events
- (int)nonOccurenceEventCountForTrackNamed:(NSString *)trackName forCoderDoc:(MiniDoc*)coderDoc withInterval:(int)interval{
	//could eventually put in check to make sure we are only checking at the interval
	if(coderDoc != nil ){
		int occurences = [self occurenceEventCountForTrackNamed:trackName forCoderDoc:coderDoc withInterval:interval];
		int opportunities = [self opportunitiesForInterval:interval];
		return opportunities- occurences;
	}
	return 0;
}

//number of agreements for both occurrences AND nonoccurrence between both coders
- (int)numberOfAgreementsOfOccurencesAndNonOccurrencesForTrackNamed:(NSString *)trackName withInterval:(int)interval{
	int agreements = [agreementController agreeingEventCountNoToleranceForTrackNamed:trackName];
	int primaryOccurences = [self occurenceEventCountForTrackNamed:trackName forCoderDoc:[agreementController primaryCoderDoc] withInterval:interval];
	int secondaryOccurences = [self occurenceEventCountForTrackNamed:trackName forCoderDoc:[agreementController secondaryCoderDoc] withInterval:interval];
	int nonAgreements = [self opportunitiesForInterval:interval]-primaryOccurences-secondaryOccurences+agreements;
	
	return nonAgreements+agreements;
}

- (float)calculatePaForTrackNamed:(NSString *)trackName withInterval:(int)interval{
	float agreementsOfOccurencesAndNonOccurrences = [self numberOfAgreementsOfOccurencesAndNonOccurrencesForTrackNamed:trackName withInterval:interval];
	float opportunities = [self opportunitiesForInterval:interval];
	if (opportunities){
		return agreementsOfOccurencesAndNonOccurrences/opportunities;
	}else{
		return 0;
	}
}
- (float)calculatePcForTrackNamed:(NSString *)trackName withInterval:(int)interval{
	int opportunities = [self opportunitiesForInterval:interval];
	int occurencesP = [self occurenceEventCountForTrackNamed:trackName forCoderDoc:[agreementController primaryCoderDoc] withInterval:interval];
	int occurencesS = [self occurenceEventCountForTrackNamed:trackName forCoderDoc:[agreementController secondaryCoderDoc] withInterval:interval];
	int occurences = occurencesP*occurencesS;
	int nonoccurencesP = [self nonOccurenceEventCountForTrackNamed:trackName forCoderDoc:[agreementController primaryCoderDoc] withInterval:interval];
	int nonoccurencesS = [self nonOccurenceEventCountForTrackNamed:trackName forCoderDoc:[agreementController secondaryCoderDoc] withInterval:interval];
	int nonoccurences = nonoccurencesP*nonoccurencesS;
	float numerator = occurences+nonoccurences;
	float denominator = opportunities*opportunities;
	if(denominator){
		return numerator/denominator;
	}else{
		return 0;
	}
}
- (float)calculateKappaForTrackNamed:(NSString *)trackName withInterval:(int)interval{
	float pC= [self calculatePcForTrackNamed:trackName withInterval:interval];
	float pA= [self calculatePaForTrackNamed:trackName withInterval:interval];
	float numerator = pA-pC;
	float denominator = 1-pC;
	if(denominator)
		return numerator/denominator;
	else
		return 0;
	
}

#pragma mark - Helpers
- (void)validateIntervals{
	
	while([intervals count] < [[agreementController intersectingTrackNames] count]){
		[intervals addObject:[NSNumber numberWithInt:[[agreementController primaryCoderDoc] interval]]];
	}
	while([intervals count] < [[agreementController intersectingTrackNames] count]){
		[intervals removeLastObject];
	}
}

- (void)updateGUI{
	[self validateIntervals];
	[kappaTable reloadData];
	return;
}

#pragma mark - Accessors

- (NSMutableArray *)intervals{
	return intervals;
}
- (NSString*)exportDataToCSForTrackNamed:(NSString *)trackName  row:(int) rowIndex{
	
	int interval = [[intervals objectAtIndex:rowIndex] intValue];
	int opportunityCheck = [self opportunitiesForInterval:interval];
	
	if(opportunityCheck==0)
		return @"nan,nan,nan,nan,nan,nan,nan,nan,nan";
	else{
		int occurencesP = [self occurenceEventCountForTrackNamed:trackName forCoderDoc:[agreementController primaryCoderDoc] withInterval:interval];
		int occurencesS = [self occurenceEventCountForTrackNamed:trackName forCoderDoc:[agreementController secondaryCoderDoc] withInterval:interval];
		int nonoccurencesP = [self nonOccurenceEventCountForTrackNamed:trackName forCoderDoc:[agreementController primaryCoderDoc] withInterval:interval];
		int nonoccurencesS = [self nonOccurenceEventCountForTrackNamed:trackName forCoderDoc:[agreementController secondaryCoderDoc] withInterval:interval];
		int opportunities = [self opportunitiesForInterval:interval];
		int agreementsOfOccurencesAndNonOccurrences = [self numberOfAgreementsOfOccurencesAndNonOccurrencesForTrackNamed:trackName withInterval:interval];
		float pA = [self calculatePaForTrackNamed:trackName withInterval:interval];
		float pC= [self calculatePcForTrackNamed:trackName withInterval:interval];
		float kappaKappa = [self calculateKappaForTrackNamed:trackName withInterval:interval];
		NSString *exportData = [[NSString alloc] initWithFormat:@"%d,%d,%d,%d,%d,%d,%f,%f,%f",occurencesP,occurencesS,nonoccurencesP,nonoccurencesS,opportunities,agreementsOfOccurencesAndNonOccurrences,pA,pC,kappaKappa];
		
		return exportData; 
	}
	return @"";
}

#pragma mark - Table Glue Code
// just returns the item for the right row
- (id)tableView:(NSTableView *) aTableView objectValueForTableColumn:(NSTableColumn *) aTableColumn row:(int) rowIndex{ 
	
	
	//log or something to figure out which table column?
	NSString * thisTrackName = [[agreementController intersectingTrackNames]objectAtIndex:rowIndex];
	int interval = [[intervals objectAtIndex:rowIndex] intValue];
	int opportunityCheck = [self opportunitiesForInterval:interval];
	
	/* -------------------------------------------------------------------------------
	 * If there is not the original movie file, return N/A, else do the following....
	 ---------------------------------------------------------------------------------*/
	if(opportunityCheck == 0){
		if([[aTableColumn identifier] compare: @"trackName"]==NSOrderedSame){
			return thisTrackName;  
		}else if([[aTableColumn identifier] compare: @"kappaInterval"]==NSOrderedSame){
			return [intervals objectAtIndex:rowIndex]; 
		}else{
			return @"nan";
		}
		
	}else{
		if([[aTableColumn identifier] compare: @"trackName"]==NSOrderedSame){
			return thisTrackName;  
		}else if([[aTableColumn identifier] compare: @"kappaInterval"]==NSOrderedSame){
			return [intervals objectAtIndex:rowIndex]; 
		}else if([[aTableColumn identifier] compare: @"kappaOp"]==NSOrderedSame){
			int occurences = [self occurenceEventCountForTrackNamed:thisTrackName forCoderDoc:[agreementController primaryCoderDoc] withInterval:interval];
			return [NSNumber numberWithInt:occurences];  
		}else if([[aTableColumn identifier] compare: @"kappaOs"]==NSOrderedSame){
			int occurences = [self occurenceEventCountForTrackNamed:thisTrackName forCoderDoc:[agreementController secondaryCoderDoc] withInterval:interval];
			return [NSNumber numberWithInt:occurences];  
		}else if([[aTableColumn identifier] compare: @"kappaNp"]==NSOrderedSame){
			int nonoccurences = [self nonOccurenceEventCountForTrackNamed:thisTrackName forCoderDoc:[agreementController primaryCoderDoc] withInterval:interval];
			return [NSNumber numberWithInt:nonoccurences];  
		}else if([[aTableColumn identifier] compare: @"kappaNs"]==NSOrderedSame){
			int nonoccurences = [self nonOccurenceEventCountForTrackNamed:thisTrackName forCoderDoc:[agreementController secondaryCoderDoc] withInterval:interval];
			return [NSNumber numberWithInt:nonoccurences];  
		}else if([[aTableColumn identifier] compare: @"kappaU"]==NSOrderedSame){
			int opportunities = [self opportunitiesForInterval:interval];
			return [NSNumber numberWithInt:opportunities];  
		}else if([[aTableColumn identifier] compare: @"kappaA"]==NSOrderedSame){
			int agreementsOfOccurencesAndNonOccurrences = [self numberOfAgreementsOfOccurencesAndNonOccurrencesForTrackNamed:thisTrackName withInterval:interval];
			return [NSNumber numberWithInt:agreementsOfOccurencesAndNonOccurrences];  
		}else if([[aTableColumn identifier] compare: @"kappaPa"]==NSOrderedSame){
			float pA = [self calculatePaForTrackNamed:thisTrackName withInterval:interval];
			return [NSNumber numberWithFloat:pA];  
		}else if([[aTableColumn identifier] compare: @"kappaPc"]==NSOrderedSame){
			float pC= [self calculatePcForTrackNamed:thisTrackName withInterval:interval];
			return [NSNumber numberWithFloat:pC];  
		}else if([[aTableColumn identifier] compare: @"kappaKappa"]==NSOrderedSame){
			float kappaKappa = [self calculateKappaForTrackNamed:thisTrackName withInterval:interval];
			return [NSNumber numberWithFloat:kappaKappa];  
		}
	}
	return nil;
	
}

// just returns the number of items we have.
- (int)numberOfRowsInTableView:(NSTableView *)aTableView{
	
	return [[agreementController intersectingTrackNames] count];
}


- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
	
	if([[aTableColumn identifier] compare: @"kappaInterval"]==NSOrderedSame){
		//Set the local value for the interval to check in.
		//NSLog(@"%@",anObject);
		[intervals replaceObjectAtIndex:rowIndex withObject: anObject];
	}
	return;
}

@end
