//
//  ViewController.m
//  XYViewTest
//
//  Created by Gary Newby on 12/9/14.
//  Copyright (c) 2014 Gary Newby. All rights reserved.
//

#import "XYViewController.h"
#import "XYView.h"
#import "XYAVAudioEngine.h"


static NSString * const kXYPANVOL = @"Pan & Volume";
static NSString * const kXYREVERB = @"Reverb";
static NSString * const kXYDELAY  = @"Delay";


@interface XYViewController () <XYViewDelegate>

@property (weak, nonatomic) IBOutlet XYView *xyViewA;
@property (weak, nonatomic) IBOutlet XYView *xyViewB;
@property (weak, nonatomic) IBOutlet XYView *xyViewC;


@property (nonatomic, strong) XYAVAudioEngine *audioEngine;

@end


@implementation XYViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.audioEngine = [[XYAVAudioEngine alloc] init];
    [self.audioEngine playSoundFile:@"test"];
    
    // XY View
    self.xyViewA.delegate = self;
    self.xyViewA.name = kXYPANVOL;
    self.xyViewB.delegate = self;
    self.xyViewB.name = kXYREVERB;
    self.xyViewC.delegate = self;
    self.xyViewC.name = kXYDELAY;
    
    // XY View Constraints
    NSDictionary *views =  @{@"xyViewA":_xyViewA, @"xyViewB":_xyViewB, @"xyViewC":_xyViewC};
    CGFloat xyHeight = [self getXYHeight:CGRectGetHeight([UIScreen mainScreen].bounds)];
    NSDictionary *metrics = @{@"xyHeight":@(xyHeight), @"pad":@10};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[xyViewA(xyHeight)]-pad-[xyViewB(==xyViewA)]-pad-[xyViewC(==xyViewA)]"
                                                                      options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[xyViewA]-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[xyViewB]-|" options:0 metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[xyViewC]-|" options:0 metrics:metrics views:views]];

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLayoutConstraint *constraint = self.view.constraints[5];
    
    // xyViewA height constraint
    constraint.constant = [self getXYHeight:size.height];
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
