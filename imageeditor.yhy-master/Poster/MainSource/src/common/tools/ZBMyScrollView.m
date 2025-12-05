//
//  ZBMyScrollView.m
//  Collage
//
//  Created by shen on 13-7-5.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBMyScrollView.h"
#import <CoreGraphics/CoreGraphics.h>

@interface ZBMyScrollView()

@property (nonatomic, assign) CGPoint previousTouchPoint;
@property (nonatomic, assign) BOOL previousTouchHitTestResponse;

@end

@implementation ZBMyScrollView

@synthesize previousTouchPoint = _previousTouchPoint;
@synthesize previousTouchHitTestResponse = _previousTouchHitTestResponse;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self resetHitTestCache];
    }
    return self;
}

- (void)resetHitTestCache
{
    self.previousTouchPoint = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
    self.previousTouchHitTestResponse = NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Return NO if even super returns NO (i.e., if point lies outside our bounds)
    BOOL superResult = [super pointInside:point withEvent:event];
    if (!superResult) {
        return superResult;
    }
    
    // Don't check again if we just queried the same point
    // (because pointInside:withEvent: gets often called multiple times)
    if (CGPointEqualToPoint(point, self.previousTouchPoint)) {
        return self.previousTouchHitTestResponse;
    } else {
        self.previousTouchPoint = point;
    }
    
    // We can't test the image's alpha channel if the button has no image. Fall back to super.
//    UIImage *buttonImage = [self imageForState:UIControlStateNormal];
//    UIImage *buttonBackground = [self backgroundImageForState:UIControlStateNormal];
    
    BOOL response = NO;
//
//    if (buttonImage == nil && buttonBackground == nil) {
//        response = YES;
//    }
//    else if (buttonImage != nil && buttonBackground == nil) {
//        response = [self isAlphaVisibleAtPoint:point forImage:buttonImage];
//    }
//    else if (buttonImage == nil && buttonBackground != nil) {
//        response = [self isAlphaVisibleAtPoint:point forImage:buttonBackground];
//    }
//    else {
//        if ([self isAlphaVisibleAtPoint:point forImage:buttonImage]) {
//            response = YES;
//        } else {
//            response = [self isAlphaVisibleAtPoint:point forImage:buttonBackground];
//        }
//    }
    
    self.previousTouchHitTestResponse = response;
    return response;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    CGPoint _touchPoint = [[touches anyObject] locationInView:self];

}

- (BOOL)isAlphaVisibleAtPoint:(CGPoint)point forImage:(UIImage *)image
{
    // Correct point to take into account that the image does not have to be the same size
    // as the button. See https://github.com/ole/OBShapedButton/issues/1
    CGSize iSize = image.size;
    CGSize bSize = self.bounds.size;
    point.x *= (bSize.width != 0) ? (iSize.width / bSize.width) : 1;
    point.y *= (bSize.height != 0) ? (iSize.height / bSize.height) : 1;
    
    CGColorRef pixelColor = [[self colorAtPixel:point withImage:image] CGColor];
    CGFloat alpha = CGColorGetAlpha(pixelColor);
    return alpha >= 0.05;
}

- (UIColor *)colorAtPixel:(CGPoint)point withImage:(UIImage*)image {
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
