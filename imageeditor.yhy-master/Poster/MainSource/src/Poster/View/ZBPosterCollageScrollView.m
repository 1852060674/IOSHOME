//
//  ZBPosterCollageScrollView.m
//  Collage
//
//  Created by shen on 13-7-18.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBPosterCollageScrollView.h"
#import <CoreGraphics/CoreGraphics.h>
#import "ZBCommonDefine.h"

@interface ZBPosterCollageScrollView ()<UIActionSheetDelegate>
{

}
@property (nonatomic, assign) CGPoint previousTouchPoint;
@property (nonatomic, assign) BOOL previousTouchHitTestResponse;

@end

@implementation ZBPosterCollageScrollView

@synthesize imageView;
@synthesize originImage;
@synthesize previousTouchPoint = _previousTouchPoint;
@synthesize previousTouchHitTestResponse = _previousTouchHitTestResponse;
@synthesize isSelected;
//@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.decelerationRate = 0;
        self.isSelected = NO;
        [self initImageView];
    }
    return self;
}

- (void)initImageView
{
    imageView = [[UIImageView alloc]init];
    
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    // Add gesture,double tap zoom imageView.
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                       action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [imageView addGestureRecognizer:doubleTapGesture];
    
    [self setMinimumZoomScale:1];
    [self setMaximumZoomScale:1.5];
    [self setZoomScale:1];
    
    [self resetHitTestCache];
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

- (void)adjustImageViewFrame:(CGRect)rect
{
    if (nil != self.imageView) {
        self.imageView.frame = rect;
    }
}

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
    
    // We can't test the image's alpha channel if  no image. Fall back to super.
    BOOL response = NO;
    
    if (self.imageView.image == nil) {
        response = YES;
    }
    else {
        if ([self isAlphaVisibleAtPoint:point forImage:self.imageView.image]) {
            response = YES;
        }
    }
    
    self.previousTouchHitTestResponse = response;
    
    return response;
}

- (BOOL)isAlphaVisibleAtPoint:(CGPoint)point forImage:(UIImage *)image
{
    CGColorRef pixelColor = [[self colorAtPixel:point withImage:image] CGColor];
    CGFloat alpha = CGColorGetAlpha(pixelColor);
    return alpha >= 0.1;
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

- (void)resetHitTestCache
{
    self.previousTouchPoint = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
    self.previousTouchHitTestResponse = NO;
}

- (void)handleDoubleTap:(UIGestureRecognizer*)recognizer
{
    UIActionSheet *aActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reselect photo" otherButtonTitles:@"Edit current photo", nil];
    [aActionSheet showInView:self];
}

#pragma mark -- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //打开相册
        self.isSelected = YES;
        NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObject:[NSValue valueWithCGRect:self.frame] forKey:@"IrregularChangeImage"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kIrregularChangeImage object:_postInfoDic];
        
    }else if (buttonIndex == 1) {
        //编辑当前选择的图片
        self.isSelected = YES;
        NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObject:self.originImage forKey:@"IrregularEditImage"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kIrregularEditImage object:_postInfoDic];
    }
}


#pragma mark - UIScrollViewDelegate

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return imageView;
//}
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//    if (scale<=1) {
//        return;
//    }
//    NSLog(@"scale %f",scale);
//    [scrollView setZoomScale:scale animated:NO];
//}


#pragma mark -- touches
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
//    CGPoint locationPoint = [[touches anyObject] locationInView:self];
    //    NSLog(@"touchesShouldBegin %f,%f",locationPoint.x,locationPoint.y);
    return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
//    CGPoint locationPoint = [[touches anyObject] locationInView:self];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
