//
//  ZBFaceAligment.m
//  PhotoEditor
//
//  Created by ZB_Mac on 2017/2/22.
//  Copyright © 2017年 ZB_Mac. All rights reserved.
//

#import "ZBFaceAligment.h"
#import "LBFRegressor.hpp"
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
//#import "FaceppLocalDetector.h"
#import "UIImage+Data.h"
#import "CGRectCGPointUtility.h"
#include <sys/stat.h>

const NSInteger g_leftEye_left      = 0;
const NSInteger g_leftEye_right     = 1;
const NSInteger g_rightEye_left     = 2;
const NSInteger g_rightEye_right    = 3;
const NSInteger g_nose_bottom_left  = 4;
const NSInteger g_nose_bottom       = 5;
const NSInteger g_nose_bottom_right = 6;
const NSInteger g_mouth_left        = 7;
const NSInteger g_mouth_right       = 8;
const NSInteger g_mouth_top         = 9;
const NSInteger g_mouth_bottom      = 10;
const NSInteger g_contour_chin      = 11;
const NSInteger g_contour_left_1    = 12;
const NSInteger g_contour_left_2    = 13;
const NSInteger g_contour_right_1   = 14;
const NSInteger g_contour_right_2   = 15;

@implementation FaceLandmarks

@end

@interface ZBFaceAligment()
{
    LBF::LBFRegressor *_regressor;
}
@end


@implementation ZBFaceAligment

-(void)releaseAllResource {
    if (!_regressor) {
        delete _regressor;
        _regressor = NULL;
    }
}

-(void)initAllResource {
    if (!_regressor) {
        _regressor = new LBF::LBFRegressor;
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"lbf_model.bin" ofType:nil];
        FILE *fp = fopen([filePath UTF8String], "rb");
        
        struct stat statbuf;
        stat([filePath UTF8String],&statbuf);
        
        unsigned char *data = (unsigned char *)malloc(statbuf.st_size);
        unsigned char *buffer = data;
        fread(buffer, sizeof(unsigned char), statbuf.st_size, fp);
        fclose(fp);
        
        unsigned char **bufferPtr = &buffer;
        _regressor->read(bufferPtr);
        free(data);
    }
}

+(ZBFaceAligment *) defaultProcessor
{
    static dispatch_once_t once;
    static id warper = nil;
    dispatch_once(&once, ^{
        warper = [[self alloc] init];
    });
    return warper;
}

+(NSArray *)aligmentFaceImage:(UIImage *)image
{
//    NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@(NO), @(20), FaceppDetectorAccuracyHigh, nil] forKeys:[NSArray arrayWithObjects:FaceppDetectorTracking, FaceppDetectorMinFaceSize, FaceppDetectorAccuracyHigh, nil]];
//
//    FaceppLocalDetector *detector = [FaceppLocalDetector detectorOfOptions:dict andAPIKey:@"42f0a376b55174f1d4ce795c7fb5cb35"];
//    FaceppLocalResult *result;
//
//    result = [detector detectWithImage:image];
//
//    int width = image.size.width;
//    int height = image.size.height;
//    CGFloat ratio = 1.0;
//
//    CGRect fitArea = CGRectMake(0, 0, width, height);
//    CGPoint center = [CGRectCGPointUtility centerPointOfRect:fitArea];
//    CGRect drawArea = CGRectMake(0, 0, width, height);
//
//    if (result.faces.count <= 0)
//    {
//        width = 1280;
//        height = 1280;
//        ratio = 1.0;
//
//        fitArea = AVMakeRectWithAspectRatioInsideRect(image.size, CGRectMake(0, 0, width, height));
//        center = [CGRectCGPointUtility centerPointOfRect:fitArea];
//        drawArea = [CGRectCGPointUtility rectWithCenterPoint:center andSize:CGSizeMake(fitArea.size.width*ratio, fitArea.size.height*ratio)];
//
//        UIImage *newImage = [UIImage generateImageWithSize:CGSizeMake(width, height) withImage:image andDrawArea:drawArea];
//
//        result = [detector detectWithImage:newImage];
//
//        if (result.faces.count <= 0) {
//            width = 1024;
//            height = 1024;
//            ratio = 0.5;
//
//            fitArea = AVMakeRectWithAspectRatioInsideRect(image.size, CGRectMake(0, 0, width, height));
//            center = [CGRectCGPointUtility centerPointOfRect:fitArea];
//            drawArea = [CGRectCGPointUtility rectWithCenterPoint:center andSize:CGSizeMake(fitArea.size.width*ratio, fitArea.size.height*ratio)];
//
//            UIImage *newImage = [UIImage generateImageWithSize:CGSizeMake(width, height) withImage:image andDrawArea:drawArea];
//
//            result = [detector detectWithImage:newImage];
//        }
//    }
//
    NSMutableArray *facesLandmarks = [NSMutableArray array];
//    
//    for (int idx=0; idx<result.faces.count; ++idx) {
//        FaceppLocalFace *faceFeature = result.faces[idx];
//        CGRect bounds = faceFeature.bounds;
//
//        if (CGRectIntersectsRect(bounds, drawArea))
//        {
//            bounds.origin.x -= drawArea.origin.x;
//            bounds.origin.y -= drawArea.origin.y;
//
//            CGFloat scale = image.size.width/drawArea.size.width;
//            bounds.origin.x *= scale;
//            bounds.origin.y *= scale;
//            bounds.size.width *= scale;
//            bounds.size.height *= scale;
//
//            bounds = CGRectIntersection(CGRectMake(0, 0, image.size.width, image.size.height), bounds);
//
//            FaceLandmarks *faceLandmarks = [self aligmentFaceImage:image inFaceRect:bounds];
//
//            [facesLandmarks addObject:faceLandmarks];
//        }
//    }
//    
    return facesLandmarks;
}

+(FaceLandmarks *)aligmentFaceImage:(UIImage *)image inFaceRect:(CGRect)faceArea;
{
    LBF::LBFRegressor regressor;
    
//    NSLog(@"%@", @"before reading");
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"lbf_model.bin" ofType:nil];
    FILE *fp = fopen([filePath UTF8String], "rb");
//    regressor.read(fp);
    
    struct stat statbuf;
    stat([filePath UTF8String],&statbuf);
    
    unsigned char *data = (unsigned char *)malloc(statbuf.st_size);
    unsigned char *buffer = data;
    fread(buffer, sizeof(unsigned char), statbuf.st_size, fp);
    fclose(fp);
    
    unsigned char **bufferPtr = &buffer;
    regressor.read(bufferPtr);
    free(data);
    
    IMAGE_MAT mat;
    cv::Mat srcMat;
    UIImageToMat(image, srcMat);
    cv::cvtColor(srcMat, mat, cv::COLOR_RGB2GRAY);
    
//    NSLog(@"channel: %d", mat.channels());
    
    LBF::BBox bounding_box;
    bounding_box.x = faceArea.origin.x;
    bounding_box.y = faceArea.origin.y;
    bounding_box.width = faceArea.size.width;
    bounding_box.height = faceArea.size.height;
    bounding_box.x_center = bounding_box.x + bounding_box.width/2.0;
    bounding_box.y_center = bounding_box.y + bounding_box.height/2.0;
    
    
    SHAPE_MAT shape;
    
    regressor.test(mat, bounding_box, shape);
    
    NSMutableArray *landmarks = [NSMutableArray array];
    
//    5, 7, 9, 11, 13, // contour 0
//    32, 34, 36, // nose 5
//    37, 40, // left eye 8
//    43, 46, // right eye 10
//    49, 52, 55, 58, // outer mouth 12

    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(8, 0)), (CGFloat)(shape(8, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(9, 0)), (CGFloat)(shape(9, 1)))]];

    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(10, 0)), (CGFloat)(shape(10, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(11, 0)), (CGFloat)(shape(11, 1)))]];

    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(5, 0)), (CGFloat)(shape(5, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(6, 0)), (CGFloat)(shape(6, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(7, 0)), (CGFloat)(shape(7, 1)))]];

    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(12, 0)), (CGFloat)(shape(12, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(14, 0)), (CGFloat)(shape(14, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(13, 0)), (CGFloat)(shape(13, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(15, 0)), (CGFloat)(shape(15, 1)))]];

    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(2, 0)), (CGFloat)(shape(2, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(0, 0)), (CGFloat)(shape(0, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(1, 0)), (CGFloat)(shape(1, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(4, 0)), (CGFloat)(shape(4, 1)))]];
    [landmarks addObject:[NSValue valueWithCGPoint:CGPointMake((CGFloat)(shape(3, 0)), (CGFloat)(shape(3, 1)))]];

    FaceLandmarks *faceLandmarks = [FaceLandmarks new];
    faceLandmarks.landmarks = [landmarks copy];
    faceLandmarks.faceArea = faceArea;
    
    NSLog(@"%@", @"testing done");
    
    return faceLandmarks;
}
@end
