//
//  ColorCell.m
//  VCode
//
// see:
// http://www.cocoabuilder.com/archive/message/cocoa/2002/9/23/56158
//  Created by John Harte on Sat Sep 14 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "ColorCell.h"

@implementation ColorCell

- (void) drawWithFrame: (NSRect) cellFrame inView: (NSView*) 
	controlView {
	NSRect sqare = NSInsetRect (cellFrame, 0.5, 0.5);
	
	sqare.size.width = sqare.size.height * 2.0;
	sqare.origin.x = sqare.origin.x + (cellFrame.size.width - 
									   sqare.size.width) / 2.0;

	
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect: sqare];
	
	[(NSColor*) [self objectValue] drawSwatchInRect:NSInsetRect (sqare, 2.0, 2.0)];
	//[(NSColor*) [self objectValue] set];    
	//[NSBezierPath fillRect: NSInsetRect (sqare, 2.0, 2.0)];
}

@end