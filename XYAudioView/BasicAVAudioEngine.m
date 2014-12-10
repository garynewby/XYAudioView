//
//  XYAudioEngine.m
//  XYViewTest
//
//  Created by Gary Newby on 12/9/14.
//  Copyright (c) 2014 Gary Newby. All rights reserved.
//

#import "BasicAVAudioEngine.h"
#import <AVFoundation/AVFoundation.h>


@interface BasicAVAudioEngine ()

@property(nonatomic, strong) AVAudioEngine *engine;
@property(nonatomic, strong) AVAudioMixerNode *mainMixer;
@property(nonatomic, strong) AVAudioUnitReverb *reverb;
@property(nonatomic, strong) AVAudioUnitDelay *delay;
@property(nonatomic, strong) AVAudioPlayerNode *soundPlayer;
@property(nonatomic, strong) AVAudioFormat *fxFormat;
@property(nonatomic, strong) AVAudioFile *soundFile;
@property(nonatomic, strong) AVAudioInputNode *inputNode;
@property(nonatomic, assign) NSUInteger numOfChannels;
@property(nonatomic, assign) float SR;

@end


@implementation BasicAVAudioEngine


- (instancetype)init
{
    self = [super init];
    if (self) {

        NSError *error;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error]; // quiet otherwise
        
        // Engine
        _engine = [[AVAudioEngine alloc] init];
        
        self.inputNode = self.engine.inputNode;

        _mainMixer = [_engine mainMixerNode];
        _mainMixer.outputVolume = 1;
        _numOfChannels = _mainMixer.numberOfOutputs;
        _SR = [[_mainMixer outputFormatForBus:0] sampleRate];
        _fxFormat = [_mainMixer outputFormatForBus:0];
        
        // Reverb
        _reverb = [[AVAudioUnitReverb alloc] init];
        [_reverb loadFactoryPreset:AVAudioUnitReverbPresetMediumHall];
        _reverb.wetDryMix = 0.0;
        [_engine attachNode:_reverb];
        [_engine connect:_reverb to:_mainMixer format:_fxFormat];
        
        // Delay
        _delay = [[AVAudioUnitDelay alloc] init];
        _delay.wetDryMix = 40.0;
        _delay.delayTime = 0.20;
        _delay.feedback = 60.0;
        _delay.lowPassCutoff = 16000.0;
        [_engine attachNode:_delay];
        [_engine connect:_delay to:_reverb format:_fxFormat];
        
        // Sound player
        _soundPlayer = [[AVAudioPlayerNode alloc] init];
        [_engine attachNode:_soundPlayer];
        [_engine connect:_soundPlayer to:_delay format:_fxFormat];
        
        [_engine startAndReturnError:&error];
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
    [self.soundPlayer scheduleFile:self.soundFile atTime:0 completionHandler:nil];
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
