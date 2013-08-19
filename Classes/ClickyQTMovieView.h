//
//  ClickyQTMovieView.h
//  MovieViewTest
//
//  Created by Joey Hagedorn on 3/3/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


@interface ClickyQTMovieView : QTMovieView {
    NSArray*    rateSteps;
    NSUInteger  rateIndex;
    NSUInteger  rateIndexForPause;
}

@end
