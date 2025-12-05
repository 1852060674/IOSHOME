//
//  DermabrasionDevice.m
//  Meitu
//
//  Created by ZB_Mac on 15-1-23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "DermabrasionDevice.h"
//#import "BEEPS.h"
#import "SkinDetect.h"
//#import <sketchLib2.0_iOS/SkinDetect.h>

#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgproc.hpp>
#import "UIImage+mat.h"
#import "GPUImageSufaceSmoothFilter.h"
#define MAX_SPATIAL_DECAY 0.02
#define MIN_SPATIAL_DECAY 0.02

#define MAX_METRICS_DEVIATION 20.0
#define MIN_METRICS_DEVIATION 8.0

#define CLAMP(l,x,u)   ((x)<(l)?(l):((x)>(u)?(u):(x)))
#define CLAMP0255(x)   CLAMP(0, x, 255)


// control points: (0.0, 1.0), (160/255.0, 0.5), (1.0, 0.0)
static CGFloat alphaMap[256] = {
    1.000000, 0.997546, 0.995091, 0.992637, 0.990181, 0.987726, 0.985269, 0.982812, 0.980353, 0.977893,
    0.975432, 0.972969, 0.970504, 0.968038, 0.965569, 0.963099, 0.960625, 0.958150, 0.955671, 0.953190,
    0.950706, 0.948219, 0.945728, 0.943234, 0.940737, 0.938235, 0.935730, 0.933221, 0.930707, 0.928189,
    0.925666, 0.923139, 0.920607, 0.918070, 0.915527, 0.912979, 0.910426, 0.907867, 0.905302, 0.902732,
    0.900155, 0.897572, 0.894982, 0.892386, 0.889783, 0.887173, 0.884556, 0.881932, 0.879300, 0.876661,
    0.874014, 0.871360, 0.868697, 0.866026, 0.863347, 0.860659, 0.857963, 0.855258, 0.852544, 0.849820,
    0.847088, 0.844346, 0.841594, 0.838833, 0.836062, 0.833281, 0.830489, 0.827687, 0.824875, 0.822052,
    0.819218, 0.816373, 0.813517, 0.810650, 0.807771, 0.804880, 0.801978, 0.799064, 0.796137, 0.793199,
    0.790248, 0.787284, 0.784308, 0.781318, 0.778316, 0.775301, 0.772272, 0.769229, 0.766173, 0.763103,
    0.760020, 0.756922, 0.753809, 0.750682, 0.747541, 0.744385, 0.741214, 0.738027, 0.734826, 0.731609,
    0.728377, 0.725128, 0.721864, 0.718584, 0.715288, 0.711975, 0.708646, 0.705300, 0.701938, 0.698558,
    0.695161, 0.691747, 0.688316, 0.684867, 0.681400, 0.677915, 0.674412, 0.670891, 0.667352, 0.663793,
    0.660217, 0.656621, 0.653006, 0.649373, 0.645719, 0.642047, 0.638354, 0.634642, 0.630910, 0.627158,
    0.623386, 0.619593, 0.615779, 0.611945, 0.608090, 0.604213, 0.600316, 0.596397, 0.592457, 0.588494,
    0.584510, 0.580504, 0.576476, 0.572426, 0.568353, 0.564257, 0.560139, 0.555998, 0.551833, 0.547645,
    0.543434, 0.539200, 0.534941, 0.530659, 0.526352, 0.522022, 0.517667, 0.513287, 0.508883, 0.504454,
    0.500000, 0.495521, 0.491017, 0.486488, 0.481935, 0.477358, 0.472757, 0.468133, 0.463485, 0.458814,
    0.454121, 0.449404, 0.444666, 0.439906, 0.435124, 0.430320, 0.425496, 0.420650, 0.415784, 0.410897,
    0.405990, 0.401064, 0.396117, 0.391152, 0.386167, 0.381164, 0.376142, 0.371102, 0.366044, 0.360968,
    0.355874, 0.350764, 0.345636, 0.340492, 0.335331, 0.330154, 0.324961, 0.319753, 0.314529, 0.309291,
    0.304037, 0.298769, 0.293486, 0.288190, 0.282880, 0.277556, 0.272219, 0.266869, 0.261506, 0.256131,
    0.250743, 0.245344, 0.239933, 0.234511, 0.229078, 0.223633, 0.218178, 0.212713, 0.207238, 0.201753,
    0.196258, 0.190754, 0.185242, 0.179720, 0.174190, 0.168652, 0.163106, 0.157552, 0.151990, 0.146422,
    0.140847, 0.135265, 0.129676, 0.124082, 0.118482, 0.112876, 0.107265, 0.101649, 0.096028, 0.090402,
    0.084773, 0.079139, 0.073502, 0.067861, 0.062217, 0.056570, 0.050921, 0.045269, 0.039615, 0.033959,
    0.028302, 0.022643, 0.016983, 0.011323, 0.005661, 0.000000,
};

@implementation DermabrasionDevice

+(instancetype) defaultProcessor
{
    static dispatch_once_t once;
    static id warper = nil;
    dispatch_once(&once, ^{
        warper = [[self alloc] init];
    });
    return warper;
}

-(UIImage *)channelSmoothImage:(UIImage *)image byStrenght:(CGFloat)strenght
{
    strenght *= 0.7;
    NSArray *ctlPoints = @[
                           [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                           [NSValue valueWithCGPoint:CGPointMake(0.5, (0.65-0.5)*strenght+0.5)],
                           [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                           ];
    NSArray *mapPoints = [self getPreparedSplineCurve:ctlPoints];
    
    CGFloat curveMap[256];
    
    for (int i=0; i<256; ++i) {
        CGFloat value = [mapPoints[i] floatValue];
        curveMap[i] = (value+i)/255.0;
    }
    
//    cv::Mat srcMat; UIImageToMat(image, srcMat);
    cv::Mat srcMat; srcMat = [UIImage mat8UC3WithImage:image];
    cv::Mat dstMat; dstMat.create(srcMat.rows, srcMat.cols, CV_8UC4);
    int imageWidth = srcMat.cols;
    int imageHeight = srcMat.rows;
    
    uchar *skinPtr;
    cv::Vec3b *srcPtr;
    cv::Mat skinMat(imageHeight, imageWidth, CV_8UC1);
    for (int y=0; y<imageHeight; ++y) {
        skinPtr = skinMat.ptr<uchar>(y);
        srcPtr = srcMat.ptr<cv::Vec3b>(y);
        
        for (int  x=0; x<imageWidth; ++x) {
            if (isSkinRGB(srcPtr[0][0], srcPtr[0][1], srcPtr[0][2]))
            {
                skinPtr[0] = 1.0*255;
            }
            else
            {
                skinPtr[0] = 0.2*255;
            }
            ++srcPtr;
            ++skinPtr;
        }
    }
    cv::Mat maskMat;
    cv::blur(skinMat, maskMat, cv::Size(15, 15));
    
    
    std::vector<cv::Mat> singleChannels(srcMat.channels());
    cv::split(srcMat, singleChannels);
    
    cv::Mat blueChannel = singleChannels[2];
    cv::Mat gaussianBlue, gaussianBlue2, gaussianBlue3, gaussianBlue4;
    int highPassRadius = 7;
    cv::boxFilter(blueChannel, gaussianBlue, blueChannel.depth(), cv::Size(highPassRadius*2+1, highPassRadius*2+1));
    highPassRadius = 7;
    cv::boxFilter(gaussianBlue, gaussianBlue2, blueChannel.depth(), cv::Size(highPassRadius*2+1, highPassRadius*2+1));
    highPassRadius = 6;
    cv::boxFilter(gaussianBlue2, gaussianBlue3, blueChannel.depth(), cv::Size(highPassRadius*2+1, highPassRadius*2+1));
    
    highPassRadius = 7;
    cv::boxFilter(gaussianBlue3, gaussianBlue, blueChannel.depth(), cv::Size(highPassRadius*2+1, highPassRadius*2+1));
    highPassRadius = 7;
    cv::boxFilter(gaussianBlue, gaussianBlue4, blueChannel.depth(), cv::Size(highPassRadius*2+1, highPassRadius*2+1));
    highPassRadius = 6;
    cv::boxFilter(gaussianBlue4, gaussianBlue, blueChannel.depth(), cv::Size(highPassRadius*2+1, highPassRadius*2+1));
//    blueChannel = blueChannel - gaussianBlue2 + 128;
    
//    UIImage *dstImage = MatToUIImage(blueChannel);
    
//    return dstImage;
    
    cv::Mat srcLab;
    cv::cvtColor(srcMat, srcLab, CV_RGB2Lab);
    
    uchar *bluePtr;
    uchar *gaussianBluePtr, *gaussianBluePtr2;
    cv::Vec3b *labPtr;
    
    for (int y=0; y<imageHeight; ++y) {
        bluePtr = blueChannel.ptr<uchar>(y);
        gaussianBluePtr = gaussianBlue3.ptr<uchar>(y);
        gaussianBluePtr2 = gaussianBlue.ptr<uchar>(y);
        labPtr = srcLab.ptr<cv::Vec3b>(y);
        skinPtr = maskMat.ptr<uchar>(y);
        for (int x=0; x<imageWidth; ++x) {
            int highPass = *bluePtr-*gaussianBluePtr+128;
            highPass = CLAMP0255(highPass);
            float blue = highPass/255.0;
            
            if (blue<0.5) {
                blue = 2*blue*blue;
            }
            else
            {
                blue = 1.0-(1.0-blue)*(1.0-blue)*2;
            }
            
            if (blue<0.5) {
                blue = 2*blue*blue;
            }
            else
            {
                blue = 1.0-(1.0-blue)*(1.0-blue)*2;
            }
            
            if (blue<0.5) {
                blue = 2*blue*blue;
            }
            else
            {
                blue = 1.0-(1.0-blue)*(1.0-blue)*2;
            }
            
            if (blue<0.5) {
                blue = 2*blue*blue;
            }
            else
            {
                blue = 1.0-(1.0-blue)*(1.0-blue)*2;
            }
            
            uchar blue_ = CLAMP0255(blue*255+0.5);

            highPass = *gaussianBluePtr-*gaussianBluePtr2+128;
            highPass = CLAMP0255(highPass);
            blue = highPass/255.0;
            
            if (blue<0.5) {
                blue = 2*blue*blue;
            }
            else
            {
                blue = 1.0-(1.0-blue)*(1.0-blue)*2;
            }
            
            if (blue<0.5) {
                blue = 2*blue*blue;
            }
            else
            {
                blue = 1.0-(1.0-blue)*(1.0-blue)*2;
            }
            
            if (blue<0.5) {
                blue = 2*blue*blue;
            }
            else
            {
                blue = 1.0-(1.0-blue)*(1.0-blue)*2;
            }
            
//            if (blue<0.5) {
//                blue = 2*blue*blue;
//            }
//            else
//            {
//                blue = 1.0-(1.0-blue)*(1.0-blue)*2;
//            }
//            uchar blue__ = CLAMP0255(blue*255+0.5);
            
            uchar L = labPtr[0][0];
            float alpha = 2*(1.0-blue_/255.0)-alphaMap[blue_];
//            float alpha = alphaMap[blue_];
            alpha *= (*skinPtr)/255.0;
            alpha *= -4*(blue*blue)+4*blue;
            L = curveMap[L]*255*alpha + L*(1-alpha);
            labPtr[0][0] = CLAMP0255(L);
            
//            *bluePtr = CLAMP0255(alpha*255);
            
            ++labPtr;
            ++skinPtr;
            ++bluePtr;
            ++gaussianBluePtr;
            ++gaussianBluePtr2;
        }
    }

    cv::cvtColor(srcLab, dstMat, CV_Lab2RGB);

    UIImage *dstImage = MatToUIImage(dstMat);
    
    return dstImage;
}

-(UIImage *)shadowLighten:(UIImage *)image byStrenght:(CGFloat)strenght
{
    //    strenght *= 0.7;
    NSArray *ctlPoints = @[
                           [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                           [NSValue valueWithCGPoint:CGPointMake(0.5, 0.2+0.5)],
                           [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                           ];
    NSArray *mapPoints = [self getPreparedSplineCurve:ctlPoints];
    
    CGFloat curveMap[256];
    
    for (int i=0; i<256; ++i) {
        CGFloat value = [mapPoints[i] floatValue];
        curveMap[i] = (value+i);
    }
    
    ctlPoints = @[
                  [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                  [NSValue valueWithCGPoint:CGPointMake(25.0/256.0, 18.0/256.0)],
                  [NSValue valueWithCGPoint:CGPointMake(40.0/256.0, 40.0/256.0)],
                  [NSValue valueWithCGPoint:CGPointMake(64.0/256.0, 64.0/256.0)],
                  [NSValue valueWithCGPoint:CGPointMake(96.0/256.0, 96.0/256.0)],
                  [NSValue valueWithCGPoint:CGPointMake(128.0/256.0, 128.0/256.0)],
                  [NSValue valueWithCGPoint:CGPointMake(192.0/256.0, 192.0/256.0)],
                  [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                  ];
    mapPoints = [self getPreparedSplineCurve:ctlPoints];
    CGFloat curveMapContrast[256];
    
    for (int i=0; i<256; ++i) {
        CGFloat value = [mapPoints[i] floatValue];
        curveMapContrast[i] = (value+i);
    }
    
    // red
    ctlPoints = @[
                  [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                  [NSValue valueWithCGPoint:CGPointMake(128.0/256.0, 145.0/256.0)],
                  [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                  ];
    mapPoints = [self getPreparedSplineCurve:ctlPoints];
    CGFloat curveMapRed[256];
    
    for (int i=0; i<256; ++i) {
        CGFloat value = [mapPoints[i] floatValue];
        curveMapRed[i] = (value+i);
    }
    
    // green
    ctlPoints = @[
                  [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                  [NSValue valueWithCGPoint:CGPointMake(128.0/256.0, 145.0/256.0)],
                  [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                  ];
    mapPoints = [self getPreparedSplineCurve:ctlPoints];
    CGFloat curveMapGreen[256];
    
    for (int i=0; i<256; ++i) {
        CGFloat value = [mapPoints[i] floatValue];
        curveMapGreen[i] = (value+i);
    }
    
    // blue
    ctlPoints = @[
                  [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                  [NSValue valueWithCGPoint:CGPointMake(128.0/256.0, 150.0/256.0)],
                  [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                  ];
    mapPoints = [self getPreparedSplineCurve:ctlPoints];
    CGFloat curveMapBlue[256];
    
    for (int i=0; i<256; ++i) {
        CGFloat value = [mapPoints[i] floatValue];
        curveMapBlue[i] = (value+i);
    }
    
//    cv::Mat srcMat; UIImageToMat(image, srcMat);
    cv::Mat srcMat; srcMat = [UIImage mat8UC3WithImage:image];
    cv::Mat dstMat; dstMat.create(srcMat.rows, srcMat.cols, CV_8UC4);
    int imageWidth = srcMat.cols;
    int imageHeight = srcMat.rows;
    
    cv::Vec4b *dstPtr;
    cv::Vec3b *srcPtr;
    uchar R, G, B;
    int shadow;
    
    for (int y=0; y<imageHeight; ++y) {
        srcPtr = srcMat.ptr<cv::Vec3b>(y);
        dstPtr = dstMat.ptr<cv::Vec4b>(y);
        
        for (int x=0; x<imageWidth; ++x) {
            
            R = (*srcPtr)[0];
            G = (*srcPtr)[1];
            B = (*srcPtr)[2];
            shadow = (255-(R+G+B)/3)*R/255;
            //            R = curveMap[R]*(1.0-alphaMap[shadow])+R*alphaMap[shadow];
            //            G = curveMap[G]*(1.0-alphaMap[shadow])+G*alphaMap[shadow];
            //            B = curveMap[B]*(1.0-alphaMap[shadow])+B*alphaMap[shadow];
            //            R = (255-(255-R)*(255-R)/255)*0.75 + R*0.25;
            //            G = (255-(255-G)*(255-G)/255)*0.75 + G*0.25;
            //            B = (255-(255-B)*(255-B)/255)*0.75 + B*0.25;
            
            R = curveMapRed[R];
            G = curveMapRed[G];
            B = curveMapBlue[B];
            
            //            (*dstPtr)[0] = R;
            //            (*dstPtr)[1] = G;
            //            (*dstPtr)[2] = B;
            
            R = curveMapContrast[R];
            G = curveMapContrast[G];
            B = curveMapContrast[B];
            
            (*dstPtr)[0] = R*strenght+(*srcPtr)[0]*(1.0-strenght);
            (*dstPtr)[1] = G*strenght+(*srcPtr)[1]*(1.0-strenght);
            (*dstPtr)[2] = B*strenght+(*srcPtr)[2]*(1.0-strenght);
            (*dstPtr)[3] = 255;
            
            ++dstPtr;
            ++srcPtr;
        }
    }
    
    UIImage *dstImage = MatToUIImage(dstMat);
    
    return dstImage;
}

-(UIImage *)surfaceSmoothImage:(UIImage *)image byStrenght:(CGFloat)strenght
{
    GPUImageSufaceSmoothFilter *filter = [[GPUImageSufaceSmoothFilter alloc] init];
    filter.strenght = strenght;
    filter.xOffset = 3.0/image.size.width;
    filter.yOffset = 3.0/image.size.height;
    
    UIImage* smoothed = [filter imageByFilteringImage:image];
    
    return smoothed;
}

//-(UIImage *)surfaceSmoothImage:(UIImage *)image byStrenght:(CGFloat)strenght
//{
//    cv::Mat srcMat; UIImageToMat(image, srcMat);
//    cv::Mat dstMat; dstMat.create(srcMat.rows, srcMat.cols, CV_8UC4);
//    int imageWidth = srcMat.cols;
//    int imageHeight = srcMat.rows;
//    
//    int radius = 7;
//    int threshold = 20*20;
//    int alpha = 1;
//    
//    cv::Vec4b *srcPtr;
//    cv::Vec4b *dstPtr;
//    cv::Vec4b *currentPtr;
//    
//    int R1, G1, B1, R2, G2, B2;
//    
//    for (int y=0; y<imageHeight; ++y) {
//        srcPtr = srcMat.ptr<cv::Vec4b>(y);
//        dstPtr = dstMat.ptr<cv::Vec4b>(y);
//        
//        NSLog(@"processing row %d", y);
//        for (int x=0; x<imageWidth; ++x) {
//            
//            R1 = srcPtr[0][0];
//            G1 = srcPtr[0][1];
//            B1 = srcPtr[0][2];
//            
//            for (int dy=-radius; dy<=radius; ++dy) {
//                int yy = y+dy;
//                if (yy>=0 && yy<imageHeight) {
//                    currentPtr = srcMat.ptr<cv::Vec4b>(yy);
//                    
//                    for (int dx=-radius; dx<radius; ++dx) {
//                        int xx = x+dx;
//                        if (xx>=0 && xx<imageWidth && !(dx==0 && dy==0)) {
//                            R2 = currentPtr[xx][0];
//                            G2 = currentPtr[xx][1];
//                            B2 = currentPtr[xx][2];
//                            
//                            int distance = MAX(abs(dx), abs(dy));
//                            int rd = abs(R1 - R2);
//                            int gd = abs(G1 - G2);
//                            int bd = abs(B1 - B2);
//                            
//                            if (rd*rd + gd*gd + bd*bd < threshold) {
//                                R1 = (R1 * distance + R2 * alpha) / (distance + alpha);
//                                G1 = (G1 * distance + G2 * alpha) / (distance + alpha);
//                                B1 = (B1 * distance + B2 * alpha) / (distance + alpha);
//                            }
//                        }
//                    }
//                }
//            }
//            dstPtr[0][0] = R1;
//            dstPtr[0][1] = G1;
//            dstPtr[0][2] = B1;
//            dstPtr[0][3] = 255;
//            ++srcPtr;
//            ++dstPtr;
//        }
//    }
//    
//    UIImage *dstImage = MatToUIImage(dstMat);
//    return dstImage;
//}

#pragma mark -
#pragma mark Curve calculation

- (NSArray *)getPreparedSplineCurve:(NSArray *)points
{
    if (points && [points count] > 0)
    {
        // Sort the array.
        NSArray *sortedPoints = [points sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            float x1 = [(NSValue *)a CGPointValue].x;
            float x2 = [(NSValue *)b CGPointValue].x;
#else
            float x1 = [(NSValue *)a pointValue].x;
            float x2 = [(NSValue *)b pointValue].x;
#endif
            return x1 > x2?NSOrderedDescending:NSOrderedAscending;
        }];
        
        // Convert from (0, 1) to (0, 255).
        NSMutableArray *convertedPoints = [NSMutableArray arrayWithCapacity:[sortedPoints count]];
        for (int i=0; i<[points count]; i++){
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            CGPoint point = [[sortedPoints objectAtIndex:i] CGPointValue];
#else
            NSPoint point = [[sortedPoints objectAtIndex:i] pointValue];
#endif
            point.x = point.x * 255;
            point.y = point.y * 255;
            
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            [convertedPoints addObject:[NSValue valueWithCGPoint:point]];
#else
            [convertedPoints addObject:[NSValue valueWithPoint:point]];
#endif
        }
        
        
        NSMutableArray *splinePoints = [self splineCurve:convertedPoints];
        
        // If we have a first point like (0.3, 0) we'll be missing some points at the beginning
        // that should be 0.
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CGPoint firstSplinePoint = [[splinePoints objectAtIndex:0] CGPointValue];
#else
        NSPoint firstSplinePoint = [[splinePoints objectAtIndex:0] pointValue];
#endif
        
        if (firstSplinePoint.x > 0) {
            for (int i=firstSplinePoint.x; i >= 0; i--) {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
                CGPoint newCGPoint = CGPointMake(i, 0);
                [splinePoints insertObject:[NSValue valueWithCGPoint:newCGPoint] atIndex:0];
#else
                NSPoint newNSPoint = NSMakePoint(i, 0);
                [splinePoints insertObject:[NSValue valueWithPoint:newNSPoint] atIndex:0];
#endif
            }
        }
        
        // Insert points similarly at the end, if necessary.
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CGPoint lastSplinePoint = [[splinePoints lastObject] CGPointValue];
        
        if (lastSplinePoint.x < 255) {
            for (int i = lastSplinePoint.x + 1; i <= 255; i++) {
                CGPoint newCGPoint = CGPointMake(i, 255);
                [splinePoints addObject:[NSValue valueWithCGPoint:newCGPoint]];
            }
        }
#else
        NSPoint lastSplinePoint = [[splinePoints lastObject] pointValue];
        
        if (lastSplinePoint.x < 255) {
            for (int i = lastSplinePoint.x + 1; i <= 255; i++) {
                NSPoint newNSPoint = NSMakePoint(i, 255);
                [splinePoints addObject:[NSValue valueWithPoint:newNSPoint]];
            }
        }
#endif
        
        // Prepare the spline points.
        NSMutableArray *preparedSplinePoints = [NSMutableArray arrayWithCapacity:[splinePoints count]];
        for (int i=0; i<[splinePoints count]; i++)
        {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            CGPoint newPoint = [[splinePoints objectAtIndex:i] CGPointValue];
#else
            NSPoint newPoint = [[splinePoints objectAtIndex:i] pointValue];
#endif
            CGPoint origPoint = CGPointMake(newPoint.x, newPoint.x);
            
            float distance = sqrt(pow((origPoint.x - newPoint.x), 2.0) + pow((origPoint.y - newPoint.y), 2.0));
            
            if (origPoint.y > newPoint.y)
            {
                distance = -distance;
            }
            
            [preparedSplinePoints addObject:[NSNumber numberWithFloat:distance]];
        }
        
        return preparedSplinePoints;
    }
    
    return nil;
}


- (NSMutableArray *)splineCurve:(NSArray *)points
{
    NSMutableArray *sdA = [self secondDerivative:points];
    
    // [points count] is equal to [sdA count]
    NSInteger n = [sdA count];
    if (n < 1)
    {
        return nil;
    }
    double sd[n];
    
    // From NSMutableArray to sd[n];
    for (int i=0; i<n; i++)
    {
        sd[i] = [[sdA objectAtIndex:i] doubleValue];
    }
    
    
    NSMutableArray *output = [NSMutableArray arrayWithCapacity:(n+1)];
    
    for(int i=0; i<n-1 ; i++)
    {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CGPoint cur = [[points objectAtIndex:i] CGPointValue];
        CGPoint next = [[points objectAtIndex:(i+1)] CGPointValue];
#else
        NSPoint cur = [[points objectAtIndex:i] pointValue];
        NSPoint next = [[points objectAtIndex:(i+1)] pointValue];
#endif
        
        for(int x=cur.x;x<(int)next.x;x++)
        {
            double t = (double)(x-cur.x)/(next.x-cur.x);
            
            double a = 1-t;
            double b = t;
            double h = next.x-cur.x;
            
            double y= a*cur.y + b*next.y + (h*h/6)*( (a*a*a-a)*sd[i]+ (b*b*b-b)*sd[i+1] );
            
            if (y > 255.0)
            {
                y = 255.0;
            }
            else if (y < 0.0)
            {
                y = 0.0;
            }
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
            [output addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
#else
            [output addObject:[NSValue valueWithPoint:NSMakePoint(x, y)]];
#endif
        }
    }
    
    // The above always misses the last point because the last point is the last next, so we approach but don't equal it.
    [output addObject:[points lastObject]];
    return output;
}

- (NSMutableArray *)secondDerivative:(NSArray *)points
{
    const NSInteger n = [points count];
    if ((n <= 0) || (n == 1))
    {
        return nil;
    }
    
    double matrix[n][3];
    double result[n];
    matrix[0][1]=1;
    // What about matrix[0][1] and matrix[0][0]? Assuming 0 for now (Brad L.)
    matrix[0][0]=0;
    matrix[0][2]=0;
    
    for(int i=1;i<n-1;i++)
    {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        CGPoint P1 = [[points objectAtIndex:(i-1)] CGPointValue];
        CGPoint P2 = [[points objectAtIndex:i] CGPointValue];
        CGPoint P3 = [[points objectAtIndex:(i+1)] CGPointValue];
#else
        NSPoint P1 = [[points objectAtIndex:(i-1)] pointValue];
        NSPoint P2 = [[points objectAtIndex:i] pointValue];
        NSPoint P3 = [[points objectAtIndex:(i+1)] pointValue];
#endif
        
        matrix[i][0]=(double)(P2.x-P1.x)/6;
        matrix[i][1]=(double)(P3.x-P1.x)/3;
        matrix[i][2]=(double)(P3.x-P2.x)/6;
        result[i]=(double)(P3.y-P2.y)/(P3.x-P2.x) - (double)(P2.y-P1.y)/(P2.x-P1.x);
    }
    
    // What about result[0] and result[n-1]? Assuming 0 for now (Brad L.)
    result[0] = 0;
    result[n-1] = 0;
    
    matrix[n-1][1]=1;
    // What about matrix[n-1][0] and matrix[n-1][2]? For now, assuming they are 0 (Brad L.)
    matrix[n-1][0]=0;
    matrix[n-1][2]=0;
    
    // solving pass1 (up->down)
    for(int i=1;i<n;i++)
    {
        double k = matrix[i][0]/matrix[i-1][1];
        matrix[i][1] -= k*matrix[i-1][2];
        matrix[i][0] = 0;
        result[i] -= k*result[i-1];
    }
    // solving pass2 (down->up)
    for(NSInteger i=n-2;i>=0;i--)
    {
        double k = matrix[i][2]/matrix[i+1][1];
        matrix[i][1] -= k*matrix[i+1][0];
        matrix[i][2] = 0;
        result[i] -= k*result[i+1];
    }
    
    double y2[n];
    for(int i=0;i<n;i++) y2[i]=result[i]/matrix[i][1];
    
    NSMutableArray *output = [NSMutableArray arrayWithCapacity:n];
    for (int i=0;i<n;i++)
    {
        [output addObject:[NSNumber numberWithDouble:y2[i]]];
    }
    
    return output;
}

@end
//