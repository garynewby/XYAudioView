//
//  ViewController.m
//  XYViewTest
//
//  Created by Gary Newby on 12/9/14.
//  Copyright (c) 2014 Gary Newby. All rights reserved.
//

#import "ViewController.h"
#import "XYView.h"
#import "BasicAVAudioEngine.h"


static NSString * const kXYPANVOL = @"Pan & Volume";
static NSString * const kXYREVERB = @"Reverb";
static NSString * const kXYDELAY  = @"Delay";


@interface ViewController () <XYViewDelegate>

@property (weak, nonatomic) IBOutlet XYView *xyViewA;
@property (weak, nonatomic) IBOutlet XYView *xyViewB;
@property (weak, nonatomic) IBOutlet XYView *xyViewC;


@property (nonatomic, strong) BasicAVAudioEngine *audioEngine;

@end


@implementation ViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.audioEngine = [[BasicAVAudioEngine alloc] init];
    [self.audioEngine playSoundFile:@"test"];
    
    // XY View
    self.xyViewA.delegate = self;
    self.xyViewA.name = kXYPANVOL;
    self.xyViewB.delegate = self;
    self.xyViewB.name = kXYREVERB;
    self.xyViewC.delegate = self;
    self.xyViewC.name = kXYDELAY;
    
}

- (CGFloat)getXYHeight:(CGFloat)height
{
    return (height - 20.0 - 60.0) / 3.0;
}

- (void)controlValueChanged:(CGPoint)point name:(NSString *)name
{
    if ([name isEqualToString:kXYPANVOL]) {
        [self.audioEngine soundPan:point.x];
        [self.audioEngine soundVolume:point.y];
    } else if ([name isEqualToString:kXYREVERB]) {
        [self.audioEngine reverbLevel:point.y];
    } else if ([name isEqualToString:kXYDELAY]) {
        [self.audioEngine delayLength:point.x];
        [self.audioEngine delayLevel:point.y];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}


@end
