//
//  DataFileLog.m
//  VCode
//
//  Created by Joey Hagedorn on 10/18/07.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "DataFileLog.h"
#include <stdio.h>

@implementation DataFileLog

- (id)init
{
    self = [super init];
    if (self) {
		start = 0;
		end = 0;
		path = nil;
		rawFile = nil;
		volPoints = nil;
		timestamps = nil;
		dataColumns = nil;
		orderedMetricKeys = nil;
		orderedMetricColor = nil;
		orderedMetricEnabled = nil;
	}
    return self;
}

- (id)initWithPath:(NSString *)inputPath{
	self = [super init];
	
	defaultColors = [[NSArray arrayWithObjects:
					  [NSColor colorWithCalibratedRed:0.74901960784313726 green:0.11372549019607843 blue:0.11372549019607843 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.45098039215686275 green:0.023529411764705882 blue:0.023529411764705882 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.45098039215686275 green:0.38823529411764707 blue:0.023529411764705882 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.16470588235294117 green:0.15686274509803921 blue:0.45098039215686275 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.078431372549019607 green:0.22745098039215686 blue:0.11764705882352941 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.39215686274509803 green:0.20392156862745098 blue:0.60784313725490191 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.27843137254901962 green:0.15294117647058825 blue:0.15294117647058825 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.58039215686274515 green:0.25882352941176473 blue:0.25882352941176473 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.24705882352941178 green:0.32941176470588235 blue:0.26666666666666666 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.73725490196078436 green:0.35686274509803922 blue:0.16470588235294117 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.18431372549019609 green:0.1803921568627451 blue:0.28235294117647058 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.0 green:0.46274509803921571 blue:0.46274509803921571 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:1.0 green:0.34901960784313724 blue:0.34901960784313724 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.32156862745098042 green:0.45098039215686275 blue:0.77647058823529413 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.16862745098039217 green:0.47843137254901963 blue:0.090196078431372548 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.10588235294117647 green:0.0 blue:0.38039215686274508 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.38039215686274508 green:0.14117647058823529 blue:0.0 alpha:(float)1.0],
					  [NSColor colorWithCalibratedRed:0.33725490196078434 green:0.058823529411764705 blue:0.36862745098039218 alpha:(float)1.0],
					  nil] retain];
	
	
    if ( self ) {
		path = [[NSString stringWithString:inputPath] retain];
		rawFile = [[NSString stringWithContentsOfFile:path] retain];
		dataColumns = [[NSMutableDictionary alloc] init];
		
		NSArray * lines = [rawFile componentsSeparatedByString:@"\n"];
		int linecount = [lines count];
		NSMutableArray * entries = [[[NSMutableArray alloc] initWithCapacity:((linecount-2)*2)] autorelease];
		NSMutableArray * timeAccumulator = [[[NSMutableArray alloc] initWithCapacity:(linecount)] autorelease];
		//int volumeindex = 9;
		int timeindex = 0;
		timeindex = [[[lines objectAtIndex:1] componentsSeparatedByString:@","] indexOfObject:@"Time"];

		NSMutableArray * columnLabels = [[[lines objectAtIndex:1] componentsSeparatedByString:@","] retain];//take time out of here...
		[columnLabels removeObjectAtIndex:timeindex];
		
		for(int i=0; i< [columnLabels count] ;i++){
			[dataColumns setValue:[[[NSMutableArray alloc] initWithCapacity:linecount] autorelease] forKey:[columnLabels objectAtIndex:i]];
		}

		for(int i=2; i<(linecount-3); i++){
			NSArray * line =  [[lines objectAtIndex:i] componentsSeparatedByString:@","];
			unsigned long long time;
			if(!sscanf([[line objectAtIndex:timeindex] cString],"%llu",&time)){
				return nil;
			}
			[timeAccumulator addObject:[NSNumber numberWithUnsignedLongLong:time]];

			for(int j = 0; j<[columnLabels count]; j++){
				NSNumber * metricValue = [NSNumber numberWithFloat: [[line objectAtIndex:j+1] floatValue]];
				[[dataColumns objectForKey:[columnLabels objectAtIndex:j]] addObject: metricValue];
			}
			
		}
		timestamps = [[NSArray arrayWithArray:timeAccumulator] retain];
		
		for(int i=0;i<[timestamps count];i++){
			[entries addObject:[timestamps objectAtIndex:i]];
			[entries addObject:[[dataColumns objectForKey:@"Volume"] objectAtIndex:i]];
		}

		volPoints = [[NSArray arrayWithArray:entries] retain];
		start = [[timestamps objectAtIndex:0] unsignedLongLongValue];
		end = [[timestamps objectAtIndex:([[dataColumns objectForKey:@"Volume"] count] - 1)] unsignedLongLongValue];
		
		
		orderedMetricKeys = [[NSMutableArray arrayWithArray:[dataColumns allKeys]] retain];
		orderedMetricColor = [[NSMutableArray arrayWithCapacity:[orderedMetricKeys count]] retain];
		orderedMetricStyle = [[NSMutableArray arrayWithCapacity:[orderedMetricKeys count]] retain];

		for(int i=0; i< [orderedMetricKeys count]; i++){
			[orderedMetricColor addObject:[defaultColors objectAtIndex:(i % [defaultColors count])]];
		}
		orderedMetricEnabled = [[NSMutableArray arrayWithCapacity:[orderedMetricKeys count]] retain];
		for(int i=0; i< [orderedMetricKeys count]; i++){
			[orderedMetricEnabled addObject:[NSNumber numberWithInt:NSOffState]];
		}
		//This is for migration from old stuff
		[self setEnabledForKey:@"Volume" to:[NSNumber numberWithInt:NSOnState]];

		//orderedMetricStyle
		for(int i=0; i< [orderedMetricKeys count]; i++){
			[orderedMetricStyle addObject:@"Bar"];
		}
		
    }
	
	
	//test here for valid initialization; if not, return nil
    return self;
}

- (id)initWithCoder:(NSCoder *)coder{
	self = [super init];
    path = [[coder decodeObjectForKey:@"DFpath"] retain];
	rawFile = [[coder decodeObjectForKey:@"DFrawfile"] retain];
	start = [coder decodeInt64ForKey:@"DFstarttime"];
	end = [coder decodeInt64ForKey:@"DFendtime"];
	
	//for backwards compatibility with 1.0
	//If there are keys for Times and Metrics, use them
	//otherwise set Times an Metrics according to every other point in volPoints
	if([coder containsValueForKey:@"DF2timestamps"] && [coder containsValueForKey:@"DF2datacolumns"]){
		timestamps = [[coder decodeObjectForKey:@"DF2timestamps"] retain];
		dataColumns = [[coder decodeObjectForKey:@"DF2datacolumns"] retain];
		
		NSMutableArray * entries = [[[NSMutableArray alloc] initWithCapacity:[timestamps count] * 2] autorelease];
		for(int i=0;i<[timestamps count];i++){
			[entries addObject:[timestamps objectAtIndex:i]];
			[entries addObject:[dataColumns objectForKey:@"Volume"]];
		}
		volPoints = [[NSArray arrayWithArray:entries] retain];
		
		
		orderedMetricKeys = [[coder decodeObjectForKey:@"DF2metricorder"] retain];
		orderedMetricColor = [[coder decodeObjectForKey:@"DF2metriccolor"] retain];
		orderedMetricEnabled = [[coder decodeObjectForKey:@"DF2metricenabled"] retain];
		orderedMetricStyle = [[coder decodeObjectForKey:@"DF3metricstyle"] retain];


	}else{
		/*
		volPoints = [[coder decodeObjectForKey:@"DFvolpoints"] retain];
		timestamps = [[NSMutableArray alloc] initWithCapacity:([volPoints count]/2)];
		dataColumns = [[NSMutableDictionary alloc] initWithCapacity:1];
		[dataColumns setValue:[[NSMutableArray alloc] initWithCapacity:([volPoints count]/2)] forKey:@"Volume"];
		NSMutableArray * timeAccumulator = [[[NSMutableArray alloc] initWithCapacity:(1000)] autorelease];

		for(int i =0; i<[volPoints count]; i++){
			[timeAccumulator addObject:[volPoints objectAtIndex:i]];
			[[dataColumns objectForKey:@"Volume"] addObject:[volPoints objectAtIndex: ++i]];
		}
		timestamps = [[NSArray arrayWithArray:timeAccumulator] retain];
		orderedMetricKeys = [[NSMutableArray arrayWithObject:@"Volume"] retain];
		orderedMetricColor = [[NSMutableArray arrayWithObject:[NSColor blackColor]] retain];
		orderedMetricEnabled = [[NSMutableArray arrayWithObject:[NSNumber numberWithInt:NSOffState]] retain];
		*/
		return [self initWithPath:path];
		
	}
	
	//It'd be great if we got rid of volPoints in future versions
	
	return self;
}

- (void) dealloc{
	if(path != nil){
		[path release];
	}
	if(rawFile != nil){
		[rawFile release];
	}
	if(volPoints != nil){
		[volPoints release];
	}
	if(timestamps != nil){
		[timestamps release];
	}
	if(dataColumns != nil){
		[dataColumns release];
	}
	if(orderedMetricKeys != nil){
		[orderedMetricKeys release];
	}
	if(orderedMetricColor != nil){
		[orderedMetricColor release];
	}
	if(orderedMetricEnabled != nil){
		[orderedMetricEnabled release];
	}
	if(orderedMetricStyle != nil){
		[orderedMetricStyle release];
	}

	[super dealloc];

}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt64:start forKey:@"DFstarttime"];
    [coder encodeInt64:end forKey:@"DFendtime"];
    [coder encodeObject:path forKey:@"DFpath"];
	[coder encodeObject:rawFile forKey:@"DFrawfile"];
    [coder encodeObject:volPoints forKey:@"DFvolpoints"];
	[coder encodeObject:timestamps forKey:@"DF2timestamps"];		
    [coder encodeObject:dataColumns forKey:@"DF2datacolumns"];		
    [coder encodeObject:orderedMetricKeys forKey:@"DF2metricorder"];		
    [coder encodeObject:orderedMetricColor forKey:@"DF2metriccolor"];		
    [coder encodeObject:orderedMetricEnabled forKey:@"DF2metricenabled"];		
    [coder encodeObject:orderedMetricStyle forKey:@"DF3metricstyle"];		

    return;
}

- (unsigned long long) start{
	return start;
}

- (unsigned long long) end{
	return end;
}

- (unsigned long long) length{
	return (end-start);	
}
- (int) pointCount{
	if(volPoints){
		return ([volPoints count])/2;
	}else{
		return 0;
	}
}

- (float) maxVol{
	float maxVol = 0;
	float thisVol = 0;
	for(int i = 1; i<[volPoints count]; i = i+2){
		thisVol = [[volPoints objectAtIndex:i] floatValue];
		if(thisVol > maxVol){
			maxVol = thisVol;
		}
	}
	return maxVol;
}

- (NSArray *) volPoints{
	//actually reimplement this to build it out of timestamps and metric for Volume
	if(volPoints){
		return [NSArray arrayWithArray:volPoints];
	}else{
		return nil;
	}
}

- (NSString *) path{
	if(path){
		return [NSString stringWithString:path];
	}else{
		return nil;
	}
}

- (NSArray *) timestamps{
	if(timestamps){
		return [NSArray arrayWithArray:timestamps];
	}else{
		return nil;
	}
}
- (NSDictionary *) dataColumns{
	if(dataColumns){
		return [NSDictionary dictionaryWithDictionary:dataColumns];
	}
	return nil;
}
- (NSArray *) dataColumnMaxes{
	NSMutableArray * maxes = [NSMutableArray arrayWithCapacity:[dataColumns count]];
	for(id metric in orderedMetricKeys){
		NSArray * sortedMetric = [[dataColumns objectForKey:metric] sortedArrayUsingSelector:@selector(compare:)];
		[maxes addObject:[sortedMetric lastObject]];
	}
	return [NSArray arrayWithArray:maxes];
}

- (NSArray *) orderedMetricKeys{
	if(orderedMetricKeys){
		return [NSArray arrayWithArray:orderedMetricKeys];
	}
	return nil;
}
- (NSArray *) orderedMetricColor{
	if(orderedMetricColor){
		return [NSArray arrayWithArray:orderedMetricColor];
	}
	return nil;
}
- (NSArray *) orderedMetricEnabled{
	if(orderedMetricEnabled){
		return [NSArray arrayWithArray:orderedMetricEnabled];
	}
	return nil;
}

- (NSArray *) orderedMetricStyle{
	if(orderedMetricStyle){
		return [NSArray arrayWithArray:orderedMetricStyle];
	}
	return nil;
}


- (NSString *) keyAtIndex:(int)index{
	return [orderedMetricKeys objectAtIndex:index];
}
- (int) indexForKey:(NSString *) key{
	return [orderedMetricKeys indexOfObject:key];
}
- (NSColor *) colorForKey:(NSString *)key{
	return [orderedMetricColor objectAtIndex:[self indexForKey:key]];
}
- (void)	setColorForKey:(NSString *)key to:(NSColor *)newColor{
	[orderedMetricColor replaceObjectAtIndex:[self indexForKey:key] withObject:newColor];
}
- (NSNumber *) enabledForKey:(NSString *)key{
	return [orderedMetricEnabled objectAtIndex:[self indexForKey:key]];
	
}
- (void)	setEnabledForKey:(NSString *)key to:(NSNumber *)newState{
	[orderedMetricEnabled replaceObjectAtIndex:[self indexForKey:key] withObject:newState];
}

- (NSString *) styleForKey:(NSString *)key{
	return [orderedMetricStyle objectAtIndex:[self indexForKey:key]];
}
- (void)	setStyleForKey:(NSString *)key to:(NSString *)newStyle{
	[orderedMetricStyle replaceObjectAtIndex:[self indexForKey:key] withObject:newStyle];
}

- (void)moveMetricFromIndex:(int)beginIndex toIndex:(int)endIndex{
	if(beginIndex>-1 && beginIndex<[orderedMetricKeys count] &&
	   endIndex>-1 && endIndex<[orderedMetricKeys count] ){
		
		if(beginIndex != endIndex){
			id movedObject;
			movedObject = [orderedMetricKeys objectAtIndex:beginIndex];
			[orderedMetricKeys removeObjectAtIndex:beginIndex];
			[orderedMetricKeys insertObject:movedObject atIndex:endIndex];
			movedObject = [orderedMetricColor objectAtIndex:beginIndex];
			[orderedMetricColor removeObjectAtIndex:beginIndex];
			[orderedMetricColor insertObject:movedObject atIndex:endIndex];
			movedObject = [orderedMetricEnabled objectAtIndex:beginIndex];
			[orderedMetricEnabled removeObjectAtIndex:beginIndex];
			[orderedMetricEnabled insertObject:movedObject atIndex:endIndex];
			movedObject = [orderedMetricStyle objectAtIndex:beginIndex];
			[orderedMetricStyle removeObjectAtIndex:beginIndex];
			[orderedMetricStyle insertObject:movedObject atIndex:endIndex];
		}//else do nothing
	}
	return;
}


@end
