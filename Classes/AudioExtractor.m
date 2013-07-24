//
//  AudioExtractor.m
//  VCode
//
//  Created by Joey Hagedorn on 3/17/08.
//  Updated and modified by Joshua Hailpern & Zhongnan Du on 12/7/2011
//  Copyright 2008 University of Illinois & Joey Hagedorn. All rights reserved.
//	This software is licensed under a BSD license. Please refer to the included
//  license file for more details.

#import "AudioExtractor.h"


@implementation AudioExtractor

- (id)init
{
	return [self initWithSamplecount:1];
}

- (id)initWithSamplecount:(int)newSamplecount
{
    self = [super init];
    if (self) {
		samples = [[NSMutableArray alloc] init];
		samplecount = newSamplecount;
	}
	
    return self;
}

- (void)dealloc{
	[samples release];
	[super dealloc];
}


- (QTMovie *) movie {
	return movie;
}

- (void) setMovie:(QTMovie *)newMovie {
	if(movie != newMovie) {
		[movie release];
		movie = [newMovie retain];
		[self resampleMovie];
	}
}

- (int) samplecount {
	return samplecount;
}
- (void) setSamplecount:(int)newSamplecount {
	samplecount = newSamplecount;
}




//length in seconds
- (float) movieLength{
	QTTime length;
	if(movie != nil){
		length = [movie duration];
		return ((float)length.timeValue/(float)length.timeScale);
	}
	return 0;
}

//length in seconds
- (float) samplerate{
	return samplecount/[self movieLength];
}

- (void) resampleMovie{
	if(movie){
		
		//extract: http://developer.apple.com/quicktime/audioextraction.html
		
		//Step 1: Begin Extraction
		OSStatus                err                  = noErr;
		MovieAudioExtractionRef extractionSessionRef = nil;
		
		err = MovieAudioExtractionBegin([movie quickTimeMovie], 0, &extractionSessionRef); 
		
		//Step 2: Get/Set Audio Extraction Session Properties

		AudioChannelLayout *layout  = NULL;
		UInt32             size     = 0;
		
		// First get the size of the extraction output layout
		err = MovieAudioExtractionGetPropertyInfo(extractionSessionRef,
												  kQTPropertyClass_MovieAudioExtraction_Audio,
												  kQTMovieAudioExtractionAudioPropertyID_AudioChannelLayout,
												  NULL, &size, NULL);
		
		if (err == noErr)
		{
			// Allocate memory for the channel layout
			layout = (AudioChannelLayout *) calloc(1, size);
			if (layout == nil) 
			{
				err = memFullErr;
				return;
			}
			
			// Get the layout for the current extraction configuration.
			// This will have already been expanded into channel descriptions.
			err = MovieAudioExtractionGetProperty(extractionSessionRef,
												  kQTPropertyClass_MovieAudioExtraction_Audio,
												  kQTMovieAudioExtractionAudioPropertyID_AudioChannelLayout,
												  size, layout, nil);
			
		}
		
		
		
		
		AudioStreamBasicDescription asbd;
		
		// Get the default audio extraction ASBD
		err = MovieAudioExtractionGetProperty(extractionSessionRef,
											  kQTPropertyClass_MovieAudioExtraction_Audio,
											  kQTMovieAudioExtractionAudioPropertyID_AudioStreamBasicDescription,
											  sizeof (asbd), &asbd, nil);
		

	
		
		/*
		NSLog(@"   NATIVE");

		NSLog(@"   format flags   = %d",asbd.mFormatFlags);
		NSLog(@"   sample rate    = %f",asbd.mSampleRate);
		NSLog(@"   b/packet       = %d",asbd.mBytesPerPacket);
		NSLog(@"   f/packet       = %d",asbd.mFramesPerPacket);
		NSLog(@"   b/frame        = %d",asbd.mBytesPerFrame);
		NSLog(@"   channels/frame = %d",asbd.mChannelsPerFrame);
		NSLog(@"   b/channel      = %d",asbd.mBitsPerChannel);
		*/

		
		//asbd.mSampleRate = [self samplerate]; //This is calculated from size/length etc
		
		asbd.mFormatID = kAudioFormatLinearPCM;
		
		asbd.mFormatFlags = kAudioFormatFlagIsFloat|
							kAudioFormatFlagIsPacked |
							kAudioFormatFlagsNativeEndian; // NOT kAudioFormatFlagIsNonInterleaved!
		
		//			// Copy stuff to sample array

		
		//asbd.mChannelsPerFrame = 2;
		asbd.mBitsPerChannel = sizeof(float) * 8;
		asbd.mBytesPerFrame = sizeof(float) * asbd.mChannelsPerFrame;
		asbd.mBytesPerPacket = asbd.mBytesPerFrame;
		


		
		// Set the new audio extraction ASBD
		err = MovieAudioExtractionSetProperty(extractionSessionRef,
											  kQTPropertyClass_MovieAudioExtraction_Audio,
											  kQTMovieAudioExtractionAudioPropertyID_AudioStreamBasicDescription,
											  sizeof (asbd), &asbd);
	

		Boolean allChannelsDiscrete = false;
		
		// disable mixing of audio channels
		err = MovieAudioExtractionSetProperty(extractionSessionRef,
											  kQTPropertyClass_MovieAudioExtraction_Movie,
											  kQTMovieAudioExtractionMoviePropertyID_AllChannelsDiscrete,
											  sizeof (Boolean), &allChannelsDiscrete);
		
		
		
		
		
		//UInt32				numFrames				= (UInt32) samplecount;

		float				numFramesF = asbd.mSampleRate * ((float) GetMovieDuration([movie quickTimeMovie]) / (float) GetMovieTimeScale([movie quickTimeMovie]));
		UInt32				numFrames				= (UInt32) numFramesF;
		
		//alloocate BufferList here	
		AudioBufferList*	buffer					= calloc(sizeof(AudioBufferList), 1);
		float* samp;
		
		buffer->mNumberBuffers = 1;
		buffer->mBuffers[0].mNumberChannels = asbd.mChannelsPerFrame;
		buffer->mBuffers[0].mDataByteSize = (asbd.mBitsPerChannel/8) * buffer->mBuffers[0].mNumberChannels * numFrames;
		
		samp = calloc(buffer->mBuffers[0].mDataByteSize, 1);
		buffer->mBuffers[0].mData = samp;
		
		UInt32 flags = 0;
		
		err = MovieAudioExtractionFillBuffer(extractionSessionRef, &numFrames, buffer, &flags);
		if (flags & kQTMovieAudioExtractionComplete)
		{
			// extraction complete!
			//copy it to the NSMutableArray

			float * dataPointer;
			dataPointer = samp;

			//This is likely not the best way to get audio samples-- fix this up for better 
			int step = (((int)(float)numFrames/(float)samplecount)*asbd.mChannelsPerFrame);
			for(int i =0; i<samplecount; i++){
				[samples addObject:[NSNumber numberWithFloat:*dataPointer]];
				
				dataPointer += step;
			}
			
			
		}
		err = MovieAudioExtractionEnd(extractionSessionRef);


		
		
		free(samp);
		free(buffer);
		
		 

	}
		 
}

- (NSArray *) samples{
	if(samples)
		return [NSArray arrayWithArray:samples];
	else
		return nil;
}


@end
