//
//  DataFileLog.h
//  VCode
//
//  Created by Joey Hagedorn on 10/18/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.
//Implements NSCoding protocol

//An interesting note about this datalog file format is that there Must be a data entry for each timestamp.
#import <Cocoa/Cocoa.h>

@interface DataFileLog : NSObject {
	NSString * path;
	NSString * rawFile;
	NSArray * volPoints;
	NSArray * timestamps;
	NSMutableDictionary * dataColumns;

	unsigned long long start;
	unsigned long long end;
	NSArray *defaultColors;

	
	
	//This stuff is hacked on at the end...
	NSMutableArray * orderedMetricKeys;
	NSMutableArray * orderedMetricColor;
	NSMutableArray * orderedMetricEnabled;
	NSMutableArray * orderedMetricStyle;
	
}

//this really inits from text file
- (id)initWithPath:(NSString *)inputPath;

- (unsigned long long) start;
- (unsigned long long) end;
- (unsigned long long) length;
- (int) pointCount;
- (float) maxVol;

//format is interlaced time, value NSNumbers of unsigned long long, float
//time, volume
- (NSArray *) volPoints;
- (NSString *) path;

- (NSArray *) orderedMetricKeys;
- (NSArray *) orderedMetricColor;
- (NSArray *) orderedMetricEnabled;
- (NSArray *) orderedMetricStyle;

- (NSString *) keyAtIndex:(int)index;
- (int) indexForKey:(NSString *) key;
- (NSColor *) colorForKey:(NSString *)key;
- (void)	setColorForKey:(NSString *)key to:(NSColor *)newColor;
- (NSNumber *) enabledForKey:(NSString *)key;
- (void)	setEnabledForKey:(NSString *)key to:(NSNumber *)newState;

- (NSString *) styleForKey:(NSString *)key;
- (void)	setStyleForKey:(NSString *)key to:(NSString *)newStyle;

- (void)moveMetricFromIndex:(int)beginIndex toIndex:(int)endIndex;



//this is the new API:
- (NSArray *) timestamps;//Array full of NSNumbers (unsigned long longs) of each timestamp
- (NSDictionary *) dataColumns;//A Dicitonary full of Arrays full of arrays full of NSNumbers. Key is column label;
- (NSArray *) dataColumnMaxes;//array full of NSNumbers maximum values of each metric

@end
