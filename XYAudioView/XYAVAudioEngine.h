//
//  XYAudioEngine.h
//  XYViewTest
//
//  Created by Gary on 12/9/14.
//  Copyright (c) 2014 Mellowmuse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYAVAudioEngine : NSObject

- (void)playSoundFile:(NSString *)fileName;
- (void)stopSoundFile;
- (void)soundPan:(float)value;
- (void)soundVolume:(float)value;
- (void)reverbLevel:(float)value;
- (void)delayLevel:(float)value;
- (void)delayLength:(float)value;

@end
