//
//  XYView.h
//  XY Control
//
//  Created by Gary Newby on 11/03/2013.
//  Copyright (c) 2014 Gary Newby. All rights reserved.
//


#import "XYView.h"


@interface XYView ()

@property(nonatomic, strong) UIColor *foreColour;
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong) NSMutableParagraphStyle *paragraphStyle;
@property(nonatomic, strong) NSDictionary *fontAttributes;
@property(nonatomic, assign) BOOL touchIsDown;
@property(nonatomic, assign) CGFloat fsize;

@end


@implementation XYView


-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}

-(id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setUp];
    }
    return self;
}

-(void)setUp
{
    CGFloat hue, saturation, brightness, alpha;
    [self.backgroundColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    _foreColour = [UIColor colorWithHue:hue saturation:saturation brightness:brightness*0.2 alpha:alpha];
    _name = @"--";
    _fsize = CGRectGetHeight(self.frame) * 0.05;
    _font = [UIFont systemFontOfSize:12.0];
    _paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    _paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    _paragraphStyle.alignment = NSTextAlignmentLeft;
    _fontAttributes = @{NSFontAttributeName:_font, NSForegroundColorAttributeName:_foreColour, NSParagraphStyleAttributeName:_paragraphStyle};
    _xyPosition = CGPointMake(CGRectGetWidth(self.frame)*0.5, CGRectGetHeight(self.frame)*0.5);
    
    self.layer.cornerRadius = _fsize;
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchIsDown = YES;
    UITouch *touch = [touches anyObject];
    self.xyPosition = [touch locationInView:touch.view];
    [self updateXY];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent*)event;
{
    self.touchIsDown = YES;
    UITouch *touch = [touches anyObject];
    self.xyPosition = [touch locationInView:touch.view];
    [self updateXY];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.touchIsDown = NO;
    UITouch *touch = [touches anyObject];
    self.xyPosition = [touch locationInView:touch.view];
    [self updateXY];
}

- (void)updateXY
{
    [self.delegate controlValueChanged:[self xyRange] name:self.name];
    [self setNeedsDisplay];
}

- (CGPoint)xyRange
{
    return CGPointMake(self.xyPosition.x/CGRectGetWidth(self.bounds) , self.xyPosition.y/CGRectGetHeight(self.bounds));
}

- (void)layoutSubviews
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    
    [self.foreColour set];
    CGContextSetLineWidth(currentContext, 1);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, self.xyPosition.x, 0);
    CGContextAddLineToPoint(currentContext, self.xyPosition.x, rect.size.height);
    CGContextMoveToPoint(currentContext, 0, self.xyPosition.y);
    CGContextAddLineToPoint(currentContext, rect.size.width, self.xyPosition.y);
    CGContextStrokePath(currentContext);
    CGRect circleRect = CGRectOffset(CGRectMake(self.xyPosition.x, self.xyPosition.y, 40, 40), -20, -20);
    CGContextAddEllipseInRect(currentContext, circleRect);
    CGContextStrokePath(currentContext);
    CGPoint xy = [self xyRange];
    NSString *text = [NSString stringWithFormat:@"%@   x: %1.2f  y: %1.2f", self.name, xy.x, xy.y];
    CGSize size = [text sizeWithAttributes:self.fontAttributes];
    [text drawInRect:CGRectMake(self.fsize, self.fsize, size.width, size.height) withAttributes:self.fontAttributes];
    
    CGContextRestoreGState(currentContext);
    [super drawRect:rect];
    
}

@end



