//
//  UIImage+Coloration.m
//  HairColor
//
//  Created by ZB_Mac on 15-4-28.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "UIImage+Coloration.h"
#import "UIImage+Mat.h"
#import "UIImage+Blend.h"

#import <opencv2/core/mat.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/imgproc/types_c.h>

@implementation UIImage (Coloration)
-(UIImage *)imageWithColoration:(UIColor *)color highlight:(BOOL)highlight mode:(NSInteger)mode
{
    UIImage *image = self;
    
    cv::Mat srcMat; //UIImageToMat(self, srcMat);
    srcMat = [UIImage mat8UC3WithImage:image];
    
    int rows = srcMat.rows;
    int cols = srcMat.cols;
    
    switch (mode) {
        case 0:
        {
            // get lab version of tint color
            const CGFloat* colors = CGColorGetComponents(color.CGColor);
            cv::Mat rgbColorMat(1, 1, CV_8UC4, cv::Vec4b(colors[0]*255, colors[1]*255, colors[2]*255, colors[3]*255));
            cv::Mat labColorMat;
            cv::cvtColor(rgbColorMat, labColorMat, CV_RGB2Lab);
            cv::Vec3b labColor = labColorMat.at<cv::Vec3b>(0, 0);
            
            // get lab version of srcImage
            cv::Mat labMat;
            cv::cvtColor(srcMat, labMat, CV_RGB2Lab);
            cv::Vec3b *labPtr;

            // get transform curve of A&B Channel
            NSArray *ctlPoints = @[
                                   [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(0.5, labColor[1]/255.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                                   ];
            NSArray *mapPoints = [self getPreparedSplineCurve:ctlPoints];
            CGFloat ACurveMap[256];
            for (int i=0; i<256; ++i) {
                CGFloat value = [mapPoints[i] floatValue];
                ACurveMap[i] = (value+i)/255.0;
            }
            
            ctlPoints = @[
                          [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                          [NSValue valueWithCGPoint:CGPointMake(0.5, labColor[2]/255.0)],
                          [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                          ];
            mapPoints = [self getPreparedSplineCurve:ctlPoints];
            CGFloat BCurveMap[256];
            for (int i=0; i<256; ++i) {
                CGFloat value = [mapPoints[i] floatValue];
                BCurveMap[i] = (value+i)/255.0;
            }
            
            if (highlight) {
                // get transform curve of L Channel if highlight is required
                ctlPoints = @[
                              [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                              [NSValue valueWithCGPoint:CGPointMake(0.35, 0.5)],
                              [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                              ];
                mapPoints = [self getPreparedSplineCurve:ctlPoints];
                CGFloat LCurveMap[256];
                for (int i=0; i<256; ++i) {
                    CGFloat value = [mapPoints[i] floatValue];
                    LCurveMap[i] = (value+i)/255.0;
                }
                
                for (int y=0; y<rows; ++y) {
                    labPtr = labMat.ptr<cv::Vec3b>(y);
                    for (int x=0; x<cols; ++x) {
                        (*labPtr)[1] = ACurveMap[(*labPtr)[1]]*255;
                        (*labPtr)[2] = BCurveMap[(*labPtr)[2]]*255;
                        (*labPtr)[0] = LCurveMap[(*labPtr)[0]]*255;
                        
                        ++labPtr;
                    }
                }
            }
            else
            {
                for (int y=0; y<rows; ++y) {
                    labPtr = labMat.ptr<cv::Vec3b>(y);
                    for (int x=0; x<cols; ++x) {
                        (*labPtr)[1] = ACurveMap[(*labPtr)[1]]*255;
                        (*labPtr)[2] = BCurveMap[(*labPtr)[2]]*255;
                        ++labPtr;
                    }
                }
            }
            
            cv::cvtColor(labMat, srcMat, CV_Lab2RGB);

            break;
        }
        case 1:
        {
            const CGFloat* colors = CGColorGetComponents(color.CGColor);
            cv::Mat rgbColorMat(1, 1, CV_8UC4, cv::Vec4b(colors[0]*255, colors[1]*255, colors[2]*255, colors[3]*255));
            cv::Mat labColorMat;
            cv::cvtColor(rgbColorMat, labColorMat, CV_RGB2Lab);
            cv::Vec3b labColor = labColorMat.at<cv::Vec3b>(0, 0);
            
            cv::Mat labMat;
            cv::cvtColor(srcMat, labMat, CV_RGB2Lab);
            cv::Vec3b *labPtr;
            
            if (highlight) {
                NSArray *ctlPoints = @[
                              [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                              [NSValue valueWithCGPoint:CGPointMake(0.35, 0.5)],
                              [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                              ];
                NSArray *mapPoints = [self getPreparedSplineCurve:ctlPoints];
                CGFloat LCurveMap[256];
                for (int i=0; i<256; ++i) {
                    CGFloat value = [mapPoints[i] floatValue];
                    LCurveMap[i] = (value+i)/255.0;
                }
                
                for (int y=0; y<rows; ++y) {
                    labPtr = labMat.ptr<cv::Vec3b>(y);
                    for (int x=0; x<cols; ++x) {
                        (*labPtr)[1] = labColor[1];
                        (*labPtr)[2] = labColor[2];
                        (*labPtr)[0] = LCurveMap[(*labPtr)[0]]*255;

                        ++labPtr;
                    }
                }
            }
            else
            {
                for (int y=0; y<rows; ++y) {
                    labPtr = labMat.ptr<cv::Vec3b>(y);
                    for (int x=0; x<cols; ++x) {
                        (*labPtr)[1] = labColor[1];
                        (*labPtr)[2] = labColor[2];
//                        (*labPtr)[0] = ((*labPtr)[0] + labColor[0])/2.0;
                        ++labPtr;
                    }
                }
            }
            
            cv::cvtColor(labMat, srcMat, CV_Lab2RGB);

            break;
        }
        case 2:
        {
            const CGFloat* colors = CGColorGetComponents(color.CGColor);
            cv::Mat grayMat;
            cv::cvtColor(srcMat, grayMat, CV_RGB2GRAY);
            
            cv::Vec3b *srcPtr;
            uchar *grayPtr;
            
            if (highlight) {
                for (int y=0; y<rows; ++y) {
                    srcPtr = srcMat.ptr<cv::Vec3b>(y);
                    grayPtr = grayMat.ptr<uchar>(y);
                    
                    for (int x=0; x<cols; ++x) {
                        if ((*grayPtr) < 128)
                        {
                            (*srcPtr)[0] = MAX(MIN(255, (*grayPtr)*colors[0]*2), 0);
                            (*srcPtr)[1] = MAX(MIN(255, (*grayPtr)*colors[1]*2), 0);
                            (*srcPtr)[2] = MAX(MIN(255, (*grayPtr)*colors[2]*2), 0);
                        }
                        else
                        {
                            (*srcPtr)[0] = MAX(MIN(255, 255-(255-(*grayPtr))*(1.0-colors[0])*2), 0);
                            (*srcPtr)[1] = MAX(MIN(255, 255-(255-(*grayPtr))*(1.0-colors[1])*2), 0);
                            (*srcPtr)[2] = MAX(MIN(255, 255-(255-(*grayPtr))*(1.0-colors[2])*2), 0);
                        }
                        
                        ++grayPtr;
                        ++srcPtr;
                    }
                }
            }
            else
            {
                for (int y=0; y<rows; ++y) {
                    srcPtr = srcMat.ptr<cv::Vec3b>(y);
                    grayPtr = grayMat.ptr<uchar>(y);
                    
                    for (int x=0; x<cols; ++x) {
                        if (colors[0] < 0.5)
                        {
                            (*srcPtr)[0] = MAX(MIN(255, (*grayPtr)*colors[0]*2 + (*grayPtr)*(*grayPtr)*(1.0-2*colors[0])/256), 0);
                        }
                        else
                        {
                            (*srcPtr)[0] = MAX(MIN(255, (*grayPtr)*(1.0-colors[0])*2 + sqrt(*grayPtr)*(2*colors[0]-1.0)*16), 0);
                        }
                        
                        if (colors[1] < 0.5)
                        {
                            (*srcPtr)[1] = MAX(MIN(255, (*grayPtr)*colors[1]*2 + (*grayPtr)*(*grayPtr)*(1.0-2*colors[1])/256), 0);
                        }
                        else
                        {
                            (*srcPtr)[1] = MAX(MIN(255, (*grayPtr)*(1.0-colors[1])*2 + sqrt(*grayPtr)*(2*colors[1]-1.0)*16), 0);
                        }
                        
                        if (colors[2] < 0.5)
                        {
                            (*srcPtr)[2] = MAX(MIN(255, (*grayPtr)*colors[2]*2 + (*grayPtr)*(*grayPtr)*(1.0-2*colors[2])/256), 0);
                        }
                        else
                        {
                            (*srcPtr)[2] = MAX(MIN(255, (*grayPtr)*(1.0-colors[2])*2 + sqrt(*grayPtr)*(2*colors[2]-1.0)*16), 0);
                        }
                        
                        ++grayPtr;
                        ++srcPtr;
                    }
                }
            }
            break;
        }
        case 3:
        {
            const CGFloat* colors = CGColorGetComponents(color.CGColor);
            
            NSArray *ctlPoints = @[
                                   [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                   [NSValue valueWithCGPoint:CGPointMake(0.5, (0.5+colors[0])*0.5)],
                                   [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                                   ];
            NSArray *mapPoints = [self getPreparedSplineCurve:ctlPoints];
            CGFloat RCurveMap[256];
            for (int i=0; i<256; ++i) {
                CGFloat value = [mapPoints[i] floatValue];
                RCurveMap[i] = (value+i)/255.0;
            }
            
            ctlPoints = @[
                          [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                          [NSValue valueWithCGPoint:CGPointMake(0.5, (0.5+colors[1])*0.5)],
                          [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                          ];
            mapPoints = [self getPreparedSplineCurve:ctlPoints];
            CGFloat GCurveMap[256];
            for (int i=0; i<256; ++i) {
                CGFloat value = [mapPoints[i] floatValue];
                GCurveMap[i] = (value+i)/255.0;
            }

            ctlPoints = @[
                          [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                          [NSValue valueWithCGPoint:CGPointMake(0.5, (0.5+colors[2])*0.5)],
                          [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                          ];
            mapPoints = [self getPreparedSplineCurve:ctlPoints];
            CGFloat BCurveMap[256];
            for (int i=0; i<256; ++i) {
                CGFloat value = [mapPoints[i] floatValue];
                BCurveMap[i] = (value+i)/255.0;
            }
            
            cv::Mat grayMat;
            cv::cvtColor(srcMat, grayMat, CV_RGB2GRAY);
            cv::Vec3b *srcPtr;
            uchar *grayPtr;
            
            if (highlight)
            {
                ctlPoints = @[
                              [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                              [NSValue valueWithCGPoint:CGPointMake(0.5, 0.7)],
                              [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                              ];
                mapPoints = [self getPreparedSplineCurve:ctlPoints];
                CGFloat RGBCurveMap[256];
                for (int i=0; i<256; ++i) {
                    CGFloat value = [mapPoints[i] floatValue];
                    RGBCurveMap[i] = (value+i)/255.0;
                }
                
                for (int y=0; y<rows; ++y) {
                    srcPtr = srcMat.ptr<cv::Vec3b>(y);
                    grayPtr = grayMat.ptr<uchar>(y);
                    
                    for (int x=0; x<cols; ++x) {
                        
                        (*grayPtr) = RGBCurveMap[(*grayPtr)]*255;
                        
                        (*srcPtr)[0] = RCurveMap[(*grayPtr)]*255;
                        (*srcPtr)[1] = GCurveMap[(*grayPtr)]*255;
                        (*srcPtr)[2] = BCurveMap[(*grayPtr)]*255;
                        
                        ++grayPtr;
                        ++srcPtr;
                    }
                }
            }
            else
            {
                for (int y=0; y<rows; ++y) {
                    srcPtr = srcMat.ptr<cv::Vec3b>(y);
                    grayPtr = grayMat.ptr<uchar>(y);
                    
                    for (int x=0; x<cols; ++x) {
                        
                        (*srcPtr)[0] = RCurveMap[(*grayPtr)]*255;
                        (*srcPtr)[1] = GCurveMap[(*grayPtr)]*255;
                        (*srcPtr)[2] = BCurveMap[(*grayPtr)]*255;
                        
                        ++grayPtr;
                        ++srcPtr;
                    }
                }
            }
            
            break;
        }
        default:
            break;
    }

    image = MatToUIImage(srcMat);
    
    return image;
}

// mode: 4 - overlay; 5 - softlight
-(UIImage *)imageColoredWithImage:(UIImage *)image inFrame:(CGRect)frame highlight:(BOOL)highlight mode:(NSInteger)mode
{
    cv::Mat rgbMat = [UIImage mat8UC3WithImage:self];
    cv::Mat grayMat;
    cv::cvtColor(rgbMat, grayMat, CV_RGB2GRAY);
    UIImage *grayImage = [UIImage imageWith8UC1Mat:grayMat];
    
    NSArray *blendModes = @[@(kCGBlendModeOverlay), @(kCGBlendModeSoftLight)];
    CGBlendMode blendMode = (CGBlendMode)[blendModes[mode-4] integerValue];
    
    frame.origin.y = self.size.height-frame.size.height-frame.origin.y;
    UIImage *coloredImage = [grayImage imageBlendedWithImage:image inFrame:frame blendMode:blendMode alpha:0.75];
    
    if (highlight) {
        NSArray *ctlPoints = @[
                      [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                      [NSValue valueWithCGPoint:CGPointMake(0.5, 0.6)],
                      [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)]
                      ];
        NSArray *mapPoints = [self getPreparedSplineCurve:ctlPoints];
        CGFloat RGBCurveMap[256];
        for (int i=0; i<256; ++i) {
            CGFloat value = [mapPoints[i] floatValue];
            RGBCurveMap[i] = (value+i)/255.0;
        }
        
        cv::Mat rgbMat = [UIImage mat8UC3WithImage:coloredImage];

        int rows = rgbMat.rows;
        int cols = rgbMat.rows;
        cv::Vec3b *srcPtr;

        for (int y=0; y<rows; ++y) {
            srcPtr = rgbMat.ptr<cv::Vec3b>(y);
            
            for (int x=0; x<cols; ++x) {
                
                (*srcPtr)[0] = RGBCurveMap[(*srcPtr)[0]]*255;
                (*srcPtr)[1] = RGBCurveMap[(*srcPtr)[1]]*255;
                (*srcPtr)[2] = RGBCurveMap[(*srcPtr)[2]]*255;
                
                ++srcPtr;
            }
        }
        
        coloredImage = [UIImage imageWith8UC3Mat:rgbMat];
    }
    return coloredImage;
}

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
