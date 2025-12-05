//
//  ZBPosterImageView.m
//  Collage
//
//  Created by shen on 13-7-18.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBPosterImageView.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBPosterImageView()<UIActionSheetDelegate>
{
    CGPoint _startPoint;
    CGPoint _offsetPoint;
    CGPoint netTranslation;//平衡 
}

@property (nonatomic, assign) CGPoint previousTouchPoint;
@property (nonatomic, assign) BOOL previousTouchHitTestResponse;
@property (nonatomic, strong) NSArray *pointsArray;

@end

@implementation ZBPosterImageView

@synthesize imageView;
@synthesize originImage;
@synthesize isSelected;

@synthesize previousTouchPoint = _previousTouchPoint;
@synthesize previousTouchHitTestResponse = _previousTouchHitTestResponse;

@synthesize pointsArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kTransparentColor;
        self.isSelected = NO;
        _offsetPoint = CGPointZero;
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
    
    //4、拖手势
    UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    [imageView addGestureRecognizer:panGesture];
    
    [self resetHitTestCache];
}


- (void)showImageWidthPoints:(NSArray*)pointsArray_
{
    NSMutableArray *_pointArray = [[NSMutableArray alloc] initWithCapacity:2];
    for (NSUInteger i=0; i<pointsArray_.count; i++)
    {
        NSValue *_valuePoint = [pointsArray_ objectAtIndex:i];
        CGPoint _point = [_valuePoint CGPointValue];
        _point.x = _point.x + netTranslation.x;
        _point.y = _point.y - netTranslation.y;
        [_pointArray addObject:[NSValue valueWithCGPoint:_point]];
    }
    self.imageView.image = [ImageUtil getSpecialImage:self.originImage withPoints:_pointArray];
    self.imageView.frame = CGRectMake(netTranslation.x, netTranslation.y, self.imageView.frame.size.width, self.imageView.frame.size.height);
    NSLog(@"%@",self.imageView);
    self.pointsArray = pointsArray_;
//    [self setNeedsDisplay];
}

- (void)handleDoubleTap:(UIGestureRecognizer*)recognizer
{
    UIActionSheet *aActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reselect photo" otherButtonTitles:@"Edit current photo", nil];
    [aActionSheet showInView:self];
}

//拖手势
-(void)handlePanGesture:(UIGestureRecognizer*)sender{
    //得到拖的过程中的xy坐标
    CGPoint translation=[(UIPanGestureRecognizer*)sender translationInView:imageView];
    //平移图片CGAffineTransformMakeTranslation
    sender.view.transform=CGAffineTransformMakeTranslation(netTranslation.x+translation.x, netTranslation.y+translation.y);
    //状态结束，保存数据
    if(sender.state==UIGestureRecognizerStateEnded){
        netTranslation.x+=translation.x;
        netTranslation.y+=translation.y;
    }
    [self showImageWidthPoints:self.pointsArray];
    
}
#pragma mark -- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        //打开相册
        self.isSelected = YES;
//        NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObject:[NSValue valueWithCGRect:self.frame] forKey:@"IrregularChangeImage"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kIrregularChangeImage object:_postInfoDic];
        
    }else if (buttonIndex == 1) {
        //编辑当前选择的图片
        self.isSelected = YES;
//        NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObject:self.originImage forKey:@"IrregularEditImage"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kIrregularEditImage object:_postInfoDic];
    }
}


#pragma mark handle alpha=0 iamge

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // Return NO if even super returns NO (i.e., if point lies outside our bounds)
//    NSLog(@"%d,%f,%f",self.tag,point.x,point.y);
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
//    [super touchesBegan:touches withEvent:event];
    _startPoint = [[touches anyObject] locationInView:self];
    NSLog(@"start point %f,%f",_startPoint.x,_startPoint.y);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    NSArray * touchesArr=[[event allTouches] allObjects];
//	
//    if ([touchesArr count]==1)
//    {
//        CGPoint pt = [[touches anyObject] locationInView:self];
//        _offsetPoint.x = pt.x - _startPoint.x;
//        _offsetPoint.y = pt.y - _startPoint.y;
//        NSLog(@"move point %f,%f",pt.x,pt.y);
////        [self showImageWidthPoints:self.pointsArray];
//    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


@end
