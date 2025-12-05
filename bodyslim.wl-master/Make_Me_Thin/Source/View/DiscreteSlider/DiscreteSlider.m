//
//  DiscreteSlider.m
//  ThinBooth
//
//  Created by ZB_Mac on 14-9-19.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import "DiscreteSlider.h"

@interface DiscreteSlider ()
{
    NSArray *_flagPoints;
}

@property (strong, nonatomic) UIColor *normalColor;
@property (strong, nonatomic) UIColor *highlightColor;

@property (strong, nonatomic) UIImageView *pointerView;

@property (readwrite, nonatomic) CGFloat sliderCircleRadius;
@property (readwrite, nonatomic) CGFloat padding;

@property (copy, nonatomic) NSArray *thumbImages;
@end

@implementation DiscreteSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame andMinValue:(NSInteger)min andMaxValue:(NSInteger)max andNormalColor:(UIColor *)normalColor andHighlightColor:(UIColor *)highlightColor andPointerImages:(NSArray *)images

{
    NSAssert(images.count==max-min+1 && images.count>0, @"DiscreteSlider Error");
    self = [self initWithFrame:frame];
    if (self) {
        _maxValue = MAX(min, max);
        _minValue = MIN(min, max);
        self.normalColor = normalColor;
        self.highlightColor = highlightColor;
        self.thumbImages = images;
        
        self.sliderCircleRadius = frame.size.height*0.5;
        self.padding = self.sliderCircleRadius;
        
        self.backgroundColor = [UIColor clearColor];
    
        CGFloat circelCenterX = self.padding+self.sliderCircleRadius;
        CGFloat circelCenterY = frame.size.height/2.0;
        CGFloat centerDistance = (CGRectGetWidth(frame)-circelCenterX*2)/(self.maxValue-self.minValue);
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger idx=0; idx<self.maxValue-self.minValue+1; ++idx) {
            [array addObject:[NSValue valueWithCGPoint:CGPointMake(circelCenterX, circelCenterY)]];
            circelCenterX += centerDistance;
        }
        _flagPoints = [array copy];
        
        self.pointerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.sliderCircleRadius*2, self.sliderCircleRadius*2)];
        self.pointerView.image = images[0];
        self.pointerView.contentMode = UIViewContentModeScaleAspectFit;
        self.pointerView.userInteractionEnabled = YES;

        self.pointerView.center = [_flagPoints.firstObject CGPointValue];
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
    
    CGPoint lineBegin = [_flagPoints.firstObject CGPointValue];
    CGPoint lineEnd = [_flagPoints.lastObject CGPointValue];
    
    CGFloat trackWidth = self.sliderCircleRadius*0.5;

    CGContextSetFillColorWithColor(context, self.highlightColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.highlightColor.CGColor);
    CGContextSetLineWidth(context, 1.0);
    
    CGContextStrokeRect(context, CGRectMake(lineBegin.x-self.sliderCircleRadius, lineBegin.y-trackWidth/2.0, lineEnd.x-lineBegin.x+2*self.sliderCircleRadius, trackWidth));
    
    for (NSInteger idx=0; idx<_flagPoints.count; ++idx) {
        CGPoint flagPoint = [_flagPoints[idx] CGPointValue];
        CGContextFillEllipseInRect(context, CGRectMake(flagPoint.x-trackWidth*0.25, flagPoint.y-trackWidth*0.25, trackWidth*0.5, trackWidth*0.5));
    }
}

-(void)setSelectedValue:(NSInteger)selectedValue
{
    _selectedValue = MIN(MAX(self.minValue, selectedValue), self.maxValue);
    _pointerView.center = [_flagPoints[_selectedValue-self.minValue] CGPointValue];
    _pointerView.image = self.thumbImages[_selectedValue-self.minValue];
//    [self setNeedsDisplay];
}

-(void)pointerMove:(UIPanGestureRecognizer *)gesture
{
    CGPoint translation = [gesture translationInView:self];
    
    CGFloat leftest = [_flagPoints.firstObject CGPointValue].x;
    
    CGFloat rightest = [_flagPoints.lastObject CGPointValue].x;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStatePossible:
        {
            CGPoint center = gesture.view.center;
            center.x += translation.x;
            center.x = MIN(MAX(leftest, center.x), rightest);
            gesture.view.center = center;

//            [self setNeedsDisplay];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        {
            CGFloat minDistance = rightest-leftest;
            CGPoint center = gesture.view.center;
            NSInteger value = self.selectedValue;
            
            for (NSInteger idx=0; idx<self.maxValue-self.minValue+1; ++idx) {
                CGPoint flagPoint = [_flagPoints[idx] CGPointValue];
                CGFloat distance = fabs(flagPoint.x-center.x);
                if (distance<minDistance) {
                    value = idx;
                    minDistance = distance;
                }
            }
            
            // send event when the pan ends.
            self.selectedValue = value+self.minValue;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
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
