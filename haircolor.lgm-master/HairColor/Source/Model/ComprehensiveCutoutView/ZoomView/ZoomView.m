//
//  ZoomView.m
//  eyeColorPlus
//
//  Created by shen on 14-7-21.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "ZoomView.h"

@interface ZoomView ()
{
    
}
@end

@implementation ZoomView

#define LINE_WIDTH 2
#define MIN_SIZE 50

-(id)initWithFrame:(CGRect)frame andCircleRadius:(CGFloat)radius
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        _circleRadius = radius;
        _crossLineWidth = _circleLineWidth = LINE_WIDTH;
        _circleColor = [UIColor whiteColor];
        _innerColor = [UIColor colorWithWhite:0.5 alpha:0.3];
        _hasCross = YES;
        _crossColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    }
    return self;
}

- (id)initWithCircleRadius:(CGFloat)radius
{
    CGRect frame = CGRectMake(0, 0, radius*3, radius*3);
    
    return [self initWithFrame:frame andCircleRadius:radius];
}

-(void)drawRect:(CGRect)rect
{
    CGRect frame = CGRectMake((self.frame.size.width)/2.0-self.circleRadius, (self.frame.size.height)/2.0-self.circleRadius, self.circleRadius*2, self.circleRadius*2);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.innerColor setFill];
    CGContextFillEllipseInRect(context, frame);
    
    [self.circleColor setStroke];
    if (self.circleLineDashed) {
        const static CGFloat dashPatten[2] = {5, 5};
        CGContextSetLineDash(context, 0, dashPatten, 2);
    }
    CGContextSetLineWidth(context, self.circleLineWidth);
    CGContextStrokeEllipseInRect(context, frame);
    
    if (self.hasCross) {
        [self.crossColor setStroke];
        CGContextSetLineWidth(context, self.crossLineWidth);
        CGPoint left = CGPointMake(frame.size.width/3.0+frame.origin.x, frame.size.height/2.0+frame.origin.y);
        CGPoint right = CGPointMake(frame.size.width*2.0/3.0+frame.origin.x, frame.size.height/2.0+frame.origin.y);
        CGContextMoveToPoint(context, left.x, left.y);
        CGContextAddLineToPoint(context, right.x, right.y);
        CGContextStrokePath(context);
     
        CGPoint top = CGPointMake(frame.size.width/2.0+frame.origin.x, frame.size.height/3.0+frame.origin.y);
        CGPoint bottom = CGPointMake(frame.size.width/2.0+frame.origin.x, frame.size.height*2.0/3.0+frame.origin.y);
        CGContextMoveToPoint(context, top.x, top.y);
        CGContextAddLineToPoint(context, bottom.x, bottom.y);
        CGContextStrokePath(context);
    }
}
-(void)setCircleRadius:(CGFloat)circleRadius
{
    if (_circleRadius!=circleRadius) {
        _circleRadius=circleRadius;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, circleRadius*3.0, circleRadius*3.0);
        [self setNeedsDisplay];
    }
}
-(void)setInnerColor:(UIColor *)innerColor
{
    _innerColor = innerColor;
    [self setNeedsDisplay];
}
-(void)setCircleLineWidth:(CGFloat)circleLineWidth
{
    if (_circleLineWidth != circleLineWidth) {
        _circleLineWidth = circleLineWidth;
        [self setNeedsDisplay];
    }
}
-(void)setCircleColor:(UIColor *)circleColor
{
    _circleColor = circleColor;
    [self setNeedsDisplay];
}
-(void)setHasCross:(BOOL)hasCross
{
    if (hasCross != _hasCross) {
        _hasCross = hasCross;
        [self setNeedsDisplay];
    }
}
-(void)setCrossColor:(UIColor *)crossColor
{
    _crossColor = crossColor;
    [self setNeedsDisplay];
}
-(void)setCrossLineWidth:(CGFloat)crossLineWidth
{
    if (_crossLineWidth != crossLineWidth) {
        _crossLineWidth = crossLineWidth;
        [self setNeedsDisplay];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
