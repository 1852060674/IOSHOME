//
//  ZBImageView.m
//  Collage
//
//  Created by shen on 13-7-18.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBImageView.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBImageView()

@property (nonatomic, assign) CGPoint previousTouchPoint;
@property (nonatomic, assign) BOOL previousTouchHitTestResponse;

@end

@implementation ZBImageView

@synthesize image;
@synthesize originImage;

@synthesize previousTouchPoint = _previousTouchPoint;
@synthesize previousTouchHitTestResponse = _previousTouchHitTestResponse;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kTransparentColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self.image drawInRect:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
}

- (void)showImageWidthPoints:(NSArray*)pointsArray
{
    self.image = [ImageUtil getSpecialImage:self.image withPoints:pointsArray];
    [self setNeedsDisplay];
}

#pragma mark handle alpha=0 iamge

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Return NO if even super returns NO (i.e., if point lies outside our bounds)
    NSLog(@"%d,%f,%f",self.tag,point.x,point.y);
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
    
    // We can't test the image's alpha channel if  no image. Fall back to super.
    BOOL response = NO;
    
    if (self.image == nil) {
        response = YES;
    }
    else {
        if ([self isAlphaVisibleAtPoint:point forImage:self.image]) {
            NSLog(@"YES %d,%f,%f",self.tag,point.x,point.y);
            response = YES;
        }
    }
    
    self.previousTouchHitTestResponse = response;
    
    return response;
}

- (BOOL)isAlphaVisibleAtPoint:(CGPoint)point forImage:(UIImage *)img
{
    CGColorRef pixelColor = [[self colorAtPixel:point withImage:img] CGColor];
    CGFloat alpha = CGColorGetAlpha(pixelColor);
    return alpha >= 0.1;
}

- (UIColor *)colorAtPixel:(CGPoint)point withImage:(UIImage*)img {
    // Cancel if point is outside img coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, img.size.width, img.size.height), point)) {
        return nil;
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = img.CGImage;
    NSUInteger width = img.size.width;
    NSUInteger height = img.size.height;
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

- (void)resetHitTestCache
{
    self.previousTouchPoint = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
    self.previousTouchHitTestResponse = NO;
}


#pragma mark -- touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
