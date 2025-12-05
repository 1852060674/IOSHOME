//
//  MGImageUtil.m
//  newFace
//
//  Created by tangtaoyu on 15-2-10.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGImageUtil.h"
#import "MGGPUUtil.h"


static void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v)
{
    float min, max, delta;
    min = MIN( r, MIN( g, b ));
    max = MAX( r, MAX( g, b ));
    *v = max;               // v
    delta = max - min;
    if( max != 0 )
        *s = delta / max;       // s
    else {
        // r = g = b = 0        // s = 0, v is undefined
        *s = 0;
        *h = -1;
        return;
    }
    
    if(delta == 0)
        delta = 1;
    
    if( r == max )
        *h = ( g - b ) / delta;     // between yellow & magenta
    else if( g == max )
        *h = 2 + ( b - r ) / delta; // between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta; // between magenta & cyan
    *h *= 60;               // degrees
    if( *h < 0 )
        *h += 360;
    if( *h >360)
        *h = 360;
}

@implementation MGImageUtil

+ (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)scaleSize
{
    UIGraphicsBeginImageContext(scaleSize);  //scaleSize 为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage*)cutImage:(UIImage*)image WithRect:(CGRect)rect
{
    UIImage *outImage;
    CGImageRef cgimg = CGImageCreateWithImageInRect([image CGImage], rect);
    outImage = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    return outImage;
}

+ (UIImage *)getImageFromView:(UIView *)view
{
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    [view drawViewHierarchyInRect:CGRectMake(0, 0, size.width, size.height) afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)getImageFromView:(UIView *)view WithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 2.0, 2.0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)drawImage:(UIImage*)image WithRect:(CGRect)rect InRect:(CGRect)aRect
{
    UIGraphicsBeginImageContextWithOptions(aRect.size, NO, 0.0);
    [image drawInRect:rect];
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    return output;
}

+ (UIImage*)bezierPath:(UIBezierPath*)path inRect:(CGRect)rect WithWidth:(float)width
{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    path.lineWidth = width;
    [[UIColor whiteColor] setStroke];
    [path stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)bezierPath:(UIBezierPath*)path inRect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    [[UIColor whiteColor] setFill];
    [path fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSArray*)getHSV:(UIImage*)image
{
    CGImageRef inImage = image.CGImage;
    CGImageRetain(inImage);
    CFDataRef bitmapData = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    CFMutableDataRef m_DataRef = CFDataCreateMutableCopy(0, 0, bitmapData);
    UInt8 *data = (UInt8*)CFDataGetMutableBytePtr(m_DataRef);
    
    int length = (int)CFDataGetLength(m_DataRef);
    
    float hsv_h, hsv_s, hsv_v;
    double hsv_ah = 0.0;
    float hsv_as = 0.0, hsv_av = 0.0;
    int nums = 0;
    
    for (int i = 0; i < length; i+=4)
    {
        UInt8 r_pixel = data[i];
        UInt8 g_pixel = data[i+1];
        UInt8 b_pixel = data[i+2];
        UInt8 a_pixel = data[i+3];
        
        if(a_pixel==255){
            RGBtoHSV((float)r_pixel/255.0, (float)g_pixel/255.0, (float)b_pixel/255.0, &hsv_h, &hsv_s, &hsv_v);
            
            hsv_ah += hsv_h;
            hsv_as += hsv_s;
            hsv_av += hsv_v;
            
            nums++;
        }
    }
    
    hsv_ah = hsv_ah/nums;
    hsv_as = hsv_as/nums;
    hsv_av = hsv_av/nums;
    
    NSArray *arr = [[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:hsv_ah],
                                                    [NSNumber numberWithFloat:hsv_as],
                                                    [NSNumber numberWithFloat:hsv_av],nil];
    CFRelease(bitmapData);
    CFRelease(m_DataRef);
    CGImageRelease(inImage);
    return arr;
}

@end
