//
//  InterativeWarpProcessor.m
//  Plastic Surgeon
//
//  Created by ZB_Mac on 15/6/9.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "InterativeWarpInPlaceProcessor.h"
#import <opencv2/imgcodecs/ios.h>
#import "InternalInterativeWarpInPlaceProcessor.h"
#import "CGPointUtility.h"
#import "UIImage+mat.h"

/**************************************************************************************************************/
/**************************************************************************************************************/

/*************************************** InterativeWarpProcessorInPlace ***************************************/

/**************************************************************************************************************/
/**************************************************************************************************************/

@interface InterativeWarpProcessorInPlace ()
{
    InterativeWarpInPlaceProcessor_ *_processor;
    
    cv::Mat _srcMat;
    
    CGSize _size;
}

@property (atomic, readwrite) NSLock *processingLock;

@property (readwrite, nonatomic) BOOL speedFirst;

@property (readwrite, nonatomic) BOOL depressRadialWarp;
@end

@implementation InterativeWarpProcessorInPlace

-(InterativeWarpProcessorInPlace *)init
{
    self = [super init];
    
    if (self) {
        _processor = new InterativeWarpInPlaceProcessor_();
        _processor->setOverlayWarps(false);
        
        self.processingLock = [[NSLock alloc] init];
    }
    return self;
}

-(void)makeCurrentMapKeyFrame
{
    _processor->fillMapWithProcessingMap();
}

-(void)setStrenght:(CGFloat)strenght
{
    _strenght = MAX(MIN(strenght, 1.0), 0.0);
    _processor->setStrenght(_strenght);
}

-(void)setSpeedFirst:(BOOL)speedFirst
{
    _speedFirst = speedFirst;
    _processor->setSpeedFirst(_speedFirst);
}

-(void)setDepressRadialWarp:(BOOL)depressRadialWarp
{
    _depressRadialWarp = depressRadialWarp;
    _processor->setDepressRadialWarp(_depressRadialWarp);
}

-(void)setSrcImage:(UIImage *)image
{
    //    UIImageToMat(image, _srcMat);
    _srcMat = [UIImage mat8UC3WithImage:image];
    _processor->setSize(_srcMat.cols, _srcMat.rows);
    _size = image.size;
}

-(NSArray *)applyPoints:(NSArray *)points
{
    NSMutableArray *newPoints = [NSMutableArray array];
    
    for (NSInteger idx=0; idx<points.count; ++idx) {
        CGPoint srcPoint = [points[idx] CGPointValue];
        cv::Point2f _srcPoint = cv::Point2f(srcPoint.x, srcPoint.y);
        
        cv::Point2f _dstPoint;
        if (!(_srcPoint.x >=0 && _srcPoint.x <= _size.width  && _srcPoint.y >= 0 && _srcPoint.y <= _size.height)) {
            return nil;
        }
        int ret = _processor->applyPoint(_srcPoint, _dstPoint);
        
        if (ret==0) {
            [newPoints addObject:[NSValue valueWithCGPoint:CGPointMake(_dstPoint.x, _dstPoint.y)]];
        }
        else
        {
            return nil;
        }
    }
    
    return [newPoints copy];
}

-(UIImage *)getResultImage
{
    UIImage *image;

    cv::Mat dstMat;
    int ret = _processor->applyMat(_srcMat, dstMat);
    
    if (ret==0) {
        image = MatToUIImage(dstMat);
    }
    
    return image;

}

-(UIImage *)enlargeAtCenterPoint:(CGPoint)center withRadius:(CGFloat)radius andWait:(BOOL)wait andStrenght:(CGFloat)strenght andSpeedFirst:(BOOL)speedFirst
{
    UIImage* ret;
    if (wait) {
        [self.processingLock lock];
        self.strenght = strenght;
        self.speedFirst = speedFirst;
        ret = [self doEnlargeAtCenterPoint:center withRadius:radius];
        [self.processingLock unlock];
    }
    else
    {
        if ([self.processingLock tryLock]) {
            self.strenght = strenght;
            self.speedFirst = speedFirst;
            ret = [self doEnlargeAtCenterPoint:center withRadius:radius];
            [self.processingLock unlock];
        }
    }
    
    return ret;
}

-(UIImage *)doEnlargeAtCenterPoint:(CGPoint)center withRadius:(CGFloat)radius
{
    center = [CGPointUtility clipPoint:center inFrame:CGRectMake(0, 0, _size.width, _size.height)];
    
    int ret = _processor->enlarge(cv::Point2f(center.x, center.y), radius);
    
    UIImage *image;

    if (ret==0) {
        cv::Mat dstMat;
        ret = _processor->applyMat(_srcMat, dstMat);
        
        if (ret==0) {
            image = MatToUIImage(dstMat);
        }
    }

    return image;
}

-(UIImage *)shrinkAtCenterPoint:(CGPoint)center withRadius:(CGFloat)radius andWait:(BOOL)wait andStrenght:(CGFloat)strenght andSpeedFirst:(BOOL)speedFirst
{
    UIImage* ret;
    if (wait) {
        [self.processingLock lock];
        self.strenght = strenght;
        self.speedFirst = speedFirst;
        ret = [self doShrinkAtCenterPoint:center withRadius:radius];
        [self.processingLock unlock];
    }
    else
    {
        if ([self.processingLock tryLock]) {
            self.strenght = strenght;
            self.speedFirst = speedFirst;
            ret = [self doShrinkAtCenterPoint:center withRadius:radius];
            [self.processingLock unlock];
        }
    }
    
    return ret;
}

-(UIImage *)doShrinkAtCenterPoint:(CGPoint)center withRadius:(CGFloat)radius
{
    center = [CGPointUtility clipPoint:center inFrame:CGRectMake(0, 0, _size.width, _size.height)];
    
    int ret = _processor->shrink(cv::Point2f(center.x, center.y), radius);
    
    UIImage *image;
    
    if (ret==0) {
        cv::Mat dstMat;
        ret = _processor->applyMat(_srcMat, dstMat);
        
        if (ret==0) {
            image = MatToUIImage(dstMat);
        }
    }
    
    return image;
}

-(UIImage *)translateFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint withRadius:(CGFloat)radius andWait:(BOOL)wait andStrenght:(CGFloat)strenght andSpeedFirst:(BOOL)speedFirst andDepressRadialWarp:(BOOL)depressRadialWarp
{
    UIImage *ret;
    if (wait) {
        [self.processingLock lock];
        self.strenght = strenght;
        self.speedFirst = speedFirst;
        self.depressRadialWarp = depressRadialWarp;
        ret = [self doTranslateFromStartPoint:startPoint toEndPoint:endPoint withRadius:radius];
        [self.processingLock unlock];
    }
    else
    {
        if ([self.processingLock tryLock]) {
            self.strenght = strenght;
            self.speedFirst = speedFirst;
            self.depressRadialWarp = depressRadialWarp;
            ret = [self doTranslateFromStartPoint:startPoint toEndPoint:endPoint withRadius:radius];
            [self.processingLock unlock];
        }
    }
    
    return ret;
}

-(UIImage *)doTranslateFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint withRadius:(CGFloat)radius
{
//    startPoint = [CGPointUtility clipPoint:startPoint inFrame:CGRectMake(0, 0, _size.width, _size.height)];
//    endPoint = [CGPointUtility clipPoint:endPoint inFrame:CGRectMake(0, 0, _size.width, _size.height)];
//    radius = MAX(radius, [CGPointUtility distanceBetweenPoint:startPoint andPoint:endPoint]);
    
    int ret = _processor->translate(cv::Point2f(startPoint.x, startPoint.y), cv::Point2f(endPoint.x, endPoint.y), radius);
    
    UIImage *image;
    
    if (ret==0) {
        cv::Mat dstMat;
        ret = _processor->applyMat(_srcMat, dstMat);
        
        if (ret==0) {
            image = MatToUIImage(dstMat);
        }
    }
    
    return image;
}

-(UIImage *)translateFromStartPoint1:(CGPoint)startPoint1 toEndPoint1:(CGPoint)endPoint1 withRadius1:(CGFloat)radius1 andFromStartPoint2:(CGPoint)startPoint2 toEndPoint2:(CGPoint)endPoint2 withRadius2:(CGFloat)radius2 andWait:(BOOL)wait andStrenght:(CGFloat)strenght andSpeedFirst:(BOOL)speedFirst andDepressRadialWarp:(BOOL)depressRadialWarp
{
    UIImage *ret;
    if (wait) {
        [self.processingLock lock];
        self.strenght = strenght;
        self.speedFirst = speedFirst;
        self.depressRadialWarp = depressRadialWarp;
        ret = [self doTranslateFromStartPoint1:startPoint1 toEndPoint1:endPoint1 withRadius1:radius1 andFromStartPoint2:startPoint2 toEndPoint2:endPoint2 withRadius2:radius2];
        [self.processingLock unlock];
    }
    else
    {
        if ([self.processingLock tryLock]) {
            self.strenght = strenght;
            self.speedFirst = speedFirst;
            self.depressRadialWarp = depressRadialWarp;
            ret = [self doTranslateFromStartPoint1:startPoint1 toEndPoint1:endPoint1 withRadius1:radius1 andFromStartPoint2:startPoint2 toEndPoint2:endPoint2 withRadius2:radius2];
            [self.processingLock unlock];
        }
    }
    
    return ret;
}

-(UIImage *)doTranslateFromStartPoint1:(CGPoint)startPoint1 toEndPoint1:(CGPoint)endPoint1 withRadius1:(CGFloat)radius1 andFromStartPoint2:(CGPoint)startPoint2 toEndPoint2:(CGPoint)endPoint2 withRadius2:(CGFloat)radius2
{
//    startPoint1 = [CGPointUtility clipPoint:startPoint1 inFrame:CGRectMake(0, 0, _size.width, _size.height)];
//    endPoint1 = [CGPointUtility clipPoint:endPoint1 inFrame:CGRectMake(0, 0, _size.width, _size.height)];
//    radius1 = MAX(radius1, [CGPointUtility distanceBetweenPoint:startPoint1 andPoint:endPoint1]);

//    startPoint2 = [CGPointUtility clipPoint:startPoint2 inFrame:CGRectMake(0, 0, _size.width, _size.height)];
//    endPoint2 = [CGPointUtility clipPoint:endPoint2 inFrame:CGRectMake(0, 0, _size.width, _size.height)];
//    radius2 = MAX(radius1, [CGPointUtility distanceBetweenPoint:startPoint2 andPoint:endPoint2]);
    
    int ret = _processor->translate(cv::Point2f(startPoint1.x, startPoint1.y), cv::Point2f(endPoint1.x, endPoint1.y), radius1, cv::Point2f(startPoint2.x, startPoint2.y), cv::Point2f(endPoint2.x, endPoint2.y), radius2);
    
    UIImage *image;
    
    if (ret==0) {
        cv::Mat dstMat;
        ret = _processor->applyMat(_srcMat, dstMat);
        
        if (ret==0) {
            image = MatToUIImage(dstMat);
        }
    }
    
    return image;
}

-(void)reset
{
    _processor->setSize(_size.width, _size.height);
}

-(void)clean
{
    _srcMat.release();
    _processor->clean();
}

-(void)dealloc
{
    _srcMat.release();
    delete _processor;
}

@end
