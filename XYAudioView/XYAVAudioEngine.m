//
//  XYAudioEngine.m
//  XYViewTest
//
//  Created by Gary Newby on 12/9/14.
//  Copyright (c) 2014 Gary Newby. All rights reserved.
//

#import "XYAVAudioEngine.h"
#import <AVFoundation/AVFoundation.h>


@interface XYAVAudioEngine ()

@property(nonatomic, strong) AVAudioEngine *engine;
@property(nonatomic, strong) AVAudioMixerNode *mainMixer;
@property(nonatomic, strong) AVAudioUnitReverb *reverb;
@property(nonatomic, strong) AVAudioUnitDelay *delay;
@property(nonatomic, strong) AVAudioPlayerNode *soundPlayer;
@property(nonatomic, strong) AVAudioFormat *fxFormat;
@property(nonatomic, strong) AVAudioFile *soundFile;
@property(nonatomic, assign) NSUInteger numOfChannels;
@property(nonatomic, assign) float SR;

@end


@implementation XYAVAudioEngine


- (instancetype)init
{
    self = [super init];
    if (self) {

        NSError *error;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        // Engine
        self.engine = [[AVAudioEngine alloc] init];
        self.mainMixer = [self.engine mainMixerNode];
        self.mainMixer.outputVolume = 1;
        self.numOfChannels = self.mainMixer.numberOfOutputs;
        self.SR = [[self.mainMixer outputFormatForBus:0] sampleRate];
        self.fxFormat = [self.mainMixer outputFormatForBus:0];
        
        // Reverb
        self.reverb = [[AVAudioUnitReverb alloc] init];
        [self.reverb loadFactoryPreset:AVAudioUnitReverbPresetMediumHall];
        self.reverb.wetDryMix = 0.0;
        [self.engine attachNode:self.reverb];
        [self.engine connect:self.reverb to:self.mainMixer format:self.fxFormat];
        
        // Delay
        self.delay = [[AVAudioUnitDelay alloc] init];
        self.delay.wetDryMix = 40.0;
        self.delay.delayTime = 0.20;
        self.delay.feedback = 60.0;
        self.delay.lowPassCutoff = 16000.0;
        [self.engine attachNode:self.delay];
        [self.engine connect:self.delay to:self.reverb format:self.fxFormat];
        
        // Sound player
        self.soundPlayer = [[AVAudioPlayerNode alloc] init];
        [self.engine attachNode:self.soundPlayer];
        [self.engine connect:self.soundPlayer to:self.delay format:self.fxFormat];
    
        [self.engine startAndReturnError:&error];
        
        if (error) {
            NSLog(@"Error starting engine: %@", [error localizedDescription]);
        } else {
            NSLog(@"Engine start successful");
        }
    }
    
    return self;
}

- (void)playSoundFile:(NSString *)fileName
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"wav"];
    NSError *error;
    self.soundFile = [[AVAudioFile alloc] initForReading:fileURL error:&error];
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    [self.soundPlayer play];
    [self.soundPlayer scheduleFile:self.soundFile atTime:0 completionHandler:^ {
        //
    }];
}

- (void)soundPan:(float)value
{
    self.soundPlayer.pan = value;
}

- (void)soundVolume:(float)value
{
    self.soundPlayer.volume = value;
}

- (void)reverbLevel:(float)value
{
    self.reverb.wetDryMix = value * 100;

}

- (void)delayLevel:(float)value
{
    self.delay.wetDryMix = value * 100;
}

- (void)delayLength:(float)value
{
    self.delay.delayTime = value * 100;
}

- (void)stopSoundFile
{
    [self.soundPlayer stop];
}



@end
