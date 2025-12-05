//
//  ContinousSlider.m
//  ThinBooth
//
//  Created by ZB_Mac on 14-9-19.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import "ContinousSlider.h"

#define SLIDER_PADDINGX (6)

@interface ContinousSlider ()
{
    CGPoint lineBegin;
    CGPoint lineEnd;
}

@property (strong, nonatomic) UIColor *normalColor;
@property (strong, nonatomic) UIColor *highlightColor;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *pointerView;

@property (readwrite, nonatomic) CGFloat titleWidth;
@property (readwrite, nonatomic) CGFloat circleRadius;
@property (readwrite, nonatomic) CGFloat padding;
@end

@implementation ContinousSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andTitle:(NSString *)title andMinValue:(CGFloat)min andMaxValue:(CGFloat)max andNormalColor:(UIColor *)normalColor andHighlightColor:(UIColor *)highlightColor andPointerImage:(UIImage *)image
{
    self = [self initWithFrame:frame];
    if (self) {
        self.maxValue = MAX(min, max);
        self.minValue = MIN(min, max);
        self.normalColor = normalColor;
        self.highlightColor = highlightColor;
        self.titleWidth = title?frame.size.width*1.0/5.0:0;
        self.circleRadius = CGRectGetHeight(frame)/4.0;
        self.padding = SLIDER_PADDINGX;
        
        self.backgroundColor = [UIColor clearColor];
        
        if (title) {
            self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.circleRadius, 0, self.titleWidth, frame.size.height)];
            self.titleLabel.text = title;
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.font = [UIFont systemFontOfSize:self.titleWidth/4.75];
            self.titleLabel.textColor = self.highlightColor;
            self.titleLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:self.titleLabel];
        }
        
        CGFloat sliderStartX = self.titleLabel.frame.origin.x+self.titleLabel.frame.size.width+self.circleRadius;
        CGFloat remainWidth = frame.size.width-sliderStartX-self.padding*2.0-self.circleRadius;
        
        CGFloat circelCenterX = sliderStartX+self.padding;
        CGFloat circelCenterY = frame.size.height/2.0;
        
        lineBegin = CGPointMake(circelCenterX, circelCenterY);
        lineEnd = CGPointMake(circelCenterX+remainWidth, circelCenterY);
        
        CGFloat pointerSize = MIN(frame.size.width, frame.size.height);
        self.pointerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pointerSize, pointerSize)];
        self.pointerView.backgroundColor = [UIColor clearColor];
        CGFloat pointerInnerSize = self.circleRadius*4;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((pointerSize-pointerInnerSize)/2.0, (pointerSize-pointerInnerSize)/2.0,  pointerInnerSize,  pointerInnerSize)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
//        imageView.layer.cornerRadius = pointerInnerSize/2.0;
//        imageView.backgroundColor = highlightColor;
        [self.pointerView addSubview:imageView];
        self.pointerView.center = lineBegin;
//        self.pointerView.backgroundColor = [UIColor redColor];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pointerMove:)];
        [self.pointerView addGestureRecognizer:panGesture];
        
        [self addSubview:self.pointerView];
        
        self.selectedValue = self.minValue;
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andTitle:(NSString *)title andMinValue:(CGFloat)min andMaxValue:(CGFloat)max andNormalColor:(UIColor *)normalColor andHighlightColor:(UIColor *)highlightColor andPointerColor:(UIColor *)pointerColor
{
    self = [self initWithFrame:frame];
    if (self) {
        self.maxValue = MAX(min, max);
        self.minValue = MIN(min, max);
        self.normalColor = normalColor;
        self.highlightColor = highlightColor;
//        self.titleWidth = frame.size.width*1.0/5.0;
//        self.circleRadius = frame.size.height*1.0/4.0;
//        self.padding = self.circleRadius;
        self.titleWidth = 0.0;
        self.circleRadius = CGRectGetHeight(frame)/4.0;
        self.padding = SLIDER_PADDINGX;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.titleWidth, frame.size.height)];
        self.titleLabel.text = title;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:self.titleWidth/4.75];
        self.titleLabel.textColor = self.highlightColor;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
        CGFloat sliderStartX = self.titleLabel.frame.origin.x+self.titleLabel.frame.size.width;
        CGFloat remainWidth = frame.size.width-sliderStartX-self.padding*2.0;
        
        CGFloat circelCenterX = sliderStartX+self.padding;
        CGFloat circelCenterY = frame.size.height/2.0;
        
        lineBegin = CGPointMake(circelCenterX, circelCenterY);
        lineEnd = CGPointMake(circelCenterX+remainWidth, circelCenterY);
        
        CGFloat pointerSize = MIN(frame.size.width, frame.size.height);
        self.pointerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pointerSize, pointerSize)];
        self.pointerView.backgroundColor = [UIColor clearColor];
        CGFloat pointerInnerSize = self.circleRadius*2.5;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((pointerSize-pointerInnerSize)/2.0, (pointerSize-pointerInnerSize)/2.0,  pointerInnerSize,  pointerInnerSize)];
        imageView.backgroundColor = pointerColor;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = pointerInnerSize/2.0;
        [self.pointerView addSubview:imageView];
        self.pointerView.center = lineBegin;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pointerMove:)];
        [self.pointerView addGestureRecognizer:panGesture];
        
        [self addSubview:self.pointerView];
        
        self.selectedValue = self.minValue;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat trackWidth = self.circleRadius*0.8;

    CGContextSetStrokeColorWithColor(context, self.highlightColor.CGColor);
    CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, lineBegin.x, lineBegin.y-trackWidth/2.0);
    CGContextAddLineToPoint(context, lineEnd.x, lineBegin.y-trackWidth/2.0);
    CGContextAddArc(context, lineEnd.x, lineEnd.y, trackWidth/2.0, -M_PI_2, M_PI_2, 0);
    CGContextAddLineToPoint(context, lineBegin.x, lineBegin.y+trackWidth/2.0);
    CGContextAddArc(context, lineBegin.x, lineBegin.y, trackWidth/2.0, M_PI_2, -M_PI_2, 0);
    CGContextStrokePath(context);
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, trackWidth);
    CGContextMoveToPoint(context, lineBegin.x, lineBegin.y);
    CGContextAddLineToPoint(context, self.pointerView.center.x, self.pointerView.center.y);
    CGContextStrokePath(context);
    
    CGContextSetStrokeColorWithColor(context, self.normalColor.CGColor);
    CGContextMoveToPoint(context, self.pointerView.center.x, self.pointerView.center.y);
    CGContextAddLineToPoint(context, lineEnd.x, lineEnd.y);
    CGContextStrokePath(context);
}

-(void)setSelectedValue:(CGFloat)selectedValue
{
    _selectedValue = MAX(MIN(selectedValue, self.maxValue), self.minValue);
    if (self.maxValue != self.minValue) {
        CGFloat rate = (_selectedValue-self.minValue)/(self.maxValue-self.minValue);
        CGPoint center = self.pointerView.center;
        center.x = (lineEnd.x-lineBegin.x)*rate+lineBegin.x;
        self.pointerView.center = center;
        [self setNeedsDisplay];
        
//        [UIView animateWithDuration:0.3 animations:^{
//            self.pointerView.center = center;
//        } completion:^(BOOL finished) {
//            [self setNeedsDisplay];
//        }];
    }
}

-(void)pointerMove:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:self];
    
    CGFloat leftest = lineBegin.x;
    CGFloat rightest = lineEnd.x;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStatePossible:
        {
            CGPoint center = gesture.view.center;
            center.x += translation.x;
            center.x = MIN(MAX(leftest, center.x), rightest);
            gesture.view.center = center;
            [self setNeedsDisplay];

            if (self.instanceValueChanged) {
                CGFloat rate = (center.x-leftest)/(rightest-leftest);
                _selectedValue = self.minValue+(self.maxValue-self.minValue)*rate;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }

            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            CGPoint center = gesture.view.center;
            CGFloat rate = (center.x-leftest)/(rightest-leftest);
            _selectedValue = self.minValue+(self.maxValue-self.minValue)*rate;
            // send event when the pan ends.
            [self sendActionsForControlEvents:UIControlEventTouchUpInside];
            [self setNeedsDisplay];

            break;
        }
        default:
            break;
    }
    [gesture setTranslation:CGPointZero inView:self];
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
