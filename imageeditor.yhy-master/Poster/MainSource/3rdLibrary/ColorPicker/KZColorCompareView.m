//
//  KZColorCompareView.m
//
//  Created by Alex Restrepo on 5/11/11.
//  Copyright 2011 KZLabs http://kzlabs.me
//  All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KZColorCompareView.h"

@interface KZColorCompareView ()
@property (nonatomic, strong) CAShapeLayer *touchDownLayer;
@property (nonatomic, strong) UIColor *checkerboardColor;
+ (CGPathRef)newRoundRectPathForBoundingRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
@end

@implementation KZColorCompareView
#pragma mark - Properties
@synthesize currentColor = _currentColor;
@synthesize touchDownLayer = _touchDownLayer;
@synthesize checkerboardColor = _checkerboardColor;

#pragma mark - Init/Dealloc
- (void)dealloc 
{
//    [_currentColor release];
//    [_checkerboardColor release];
//    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (!self) 
        return nil;
    
    self.opaque = YES;
    self.backgroundColor = [UIColor clearColor];
    self.currentColor = [[UIColor grayColor] colorWithAlphaComponent:0.8];//[UIColor whiteColor];//
    
    self.touchDownLayer = [CAShapeLayer layer];
    self.touchDownLayer.opacity = 0.0f;
    [self.layer addSublayer:self.touchDownLayer];
            
    return self;
}

#pragma mark - Custom Properties

- (void) setCurrentColor:(UIColor *)color
{
//    [color retain];
//    [_currentColor release];
    _currentColor = color;
    
    [self setNeedsDisplay];
}

- (UIColor *)checkerboardColor
{
    if(!_checkerboardColor)
    {
        self.checkerboardColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"checkerboard.png"]];
    }
    
    return _checkerboardColor;
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{   
    const CGFloat cornerRadius = 6.0f;
    const CGFloat borderWidth = 2.0f;
    CGContextRef context = UIGraphicsGetCurrentContext();                    
    
    // does color have alpha???
    if(CGColorGetAlpha(self.currentColor.CGColor))
    {
        CGPathRef checkerPath = [[self class] newRoundRectPathForBoundingRect:CGRectInset(self.bounds, borderWidth, borderWidth) cornerRadius:cornerRadius - 1.0f];
        CGContextAddPath(context, checkerPath);    
        [self.checkerboardColor setFill];    
        CGContextFillPath(context);
        CGPathRelease(checkerPath);
    }
//
    CGPathRef fillPath = [[self class] newRoundRectPathForBoundingRect:CGRectMake(0, 0, self.bounds.size.width  + 1.0f, self.bounds.size.height) cornerRadius:cornerRadius + 1.0f];
    CGContextAddPath(context, fillPath);
    [self.currentColor setFill];    
    CGContextFillPath(context);
    CGPathRelease(fillPath);
    
    CGContextSetLineWidth(context, borderWidth);
    CGPathRef borderPath = [[self class] newRoundRectPathForBoundingRect:CGRectInset(self.bounds, borderWidth * 0.5, borderWidth * 0.5) cornerRadius:cornerRadius];
    [[UIColor whiteColor] setStroke];    
    CGContextAddPath(context, borderPath);
    CGContextStrokePath(context);            
    CGPathRelease(borderPath);    
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    CGPathRef path = [[self class] newRoundRectPathForBoundingRect:CGRectMake(0, 0, self.bounds.size.width * 0.5 + 1.0f, self.bounds.size.height) cornerRadius:7.0];
    self.touchDownLayer.path = path;
    CGPathRelease(path);            
}

#pragma mark - Touch Handling

+ (CGPathRef)newRoundRectPathForBoundingRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
    // Drawing code in parts from http://stackoverflow.com/questions/400965/how-to-customize-the-background-border-colors-of-a-grouped-table-view
    // rect = CGRectInset(rect, 0.5, 0.5);
    const NSUInteger inset = 1.0f;
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat minx = CGRectGetMinX(rect) , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
    CGFloat miny = CGRectGetMinY(rect) , midy = CGRectGetMidY(rect) , maxy = CGRectGetMaxY(rect) ;
    minx = minx + inset;
    miny = miny + inset;
    
    maxx = maxx - inset;
    maxy = maxy - inset;
    
    CGPathMoveToPoint(path, NULL, minx, midy);
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, cornerRadius);
    CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, cornerRadius);
    CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, cornerRadius);
    CGPathCloseSubpath(path);
    return path;
}
@end
