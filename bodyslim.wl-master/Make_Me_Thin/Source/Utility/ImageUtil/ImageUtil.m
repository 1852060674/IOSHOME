//
//  ImageUtil.m
//  ImageProcessing
//
//  Created by Evangel on 10-11-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageUtil.h"
#import <QuartzCore/QuartzCore.h>

#include <sys/time.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#import "sys/utsname.h"
#import "UIImage-Extensions.h"

@implementation ImageUtil

+ (UIImage *)loadResourceImage:(NSString*)imageName
{
    UIImage *image = nil;
    if([imageName length] > 0)
    {
        NSString *newName = imageName;
        if([imageName hasSuffix:@".png"] || [imageName hasSuffix:@".PNG"])
        {
            newName = [imageName stringByReplacingOccurrencesOfString:@".png" withString:@""];
        }
        else if ([imageName hasSuffix:@".jpg"] || [imageName hasSuffix:@".JPG"]) {
            newName = [imageName stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
        }
		NSString *path = [[NSBundle mainBundle] pathForResource:newName ofType:@"png"];
        if([path length] > 0)
        {
            image = [UIImage imageWithContentsOfFile:path];
        }
        else
        {
            path = [[NSBundle mainBundle] pathForResource:newName ofType:@"PNG"];
            if([path length] > 0)
            {
                image = [UIImage imageWithContentsOfFile:path];
            }
            else
            {
                path = [[NSBundle mainBundle] pathForResource:newName ofType:@"jpg"];
                if([path length] > 0)
                {
                    image = [UIImage imageWithContentsOfFile:path];
                }
                else
                {
                    path = [[NSBundle mainBundle] pathForResource:newName ofType:@"JPG"];
                    if([path length] > 0)
                    {
                        image = [UIImage imageWithContentsOfFile:path];
                    }
                }
            }
            
        }
    }
    return image;
}

+ (CGSize) fitSize: (CGSize)thisSize inSize: (CGSize) aSize
{
	CGFloat scale;
	CGSize newsize;
	
	if(thisSize.width<aSize.width && thisSize.height < aSize.height)
	{
		newsize = thisSize;
	}
	else 
	{
        if(thisSize.width >= aSize.width)
		{
			scale = aSize.width/thisSize.width;
			newsize.width = aSize.width;
			newsize.height = thisSize.height*scale;
		}
        else
		{
			scale = aSize.height/thisSize.height;
			newsize.height = aSize.height;
			newsize.width = thisSize.width*scale;
		}
	}
    
	return newsize;
}

// Proportionately resize, completely fit in view, no cropping
+ (UIImage *) image: (UIImage *) image fitInSize: (CGSize) viewsize
{
	// calculate the fitted size
	CGSize size = [ImageUtil fitSize:image.size inSize:viewsize];
	
	UIGraphicsBeginImageContext(size);

	CGRect rect = CGRectMake(0, 0, size.width, size.height);
	[image drawInRect:rect];
	
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();  
	
	return newimg;  
}

+(UIImage *)imageFromText:(NSString *)text width:(float)width height:(float)height
{
    // set the font type and size
    //UIFont *font = [UIFont systemFontOfSize:12.0f];  
    CGSize size  = CGSizeMake(width, height);// [text sizeWithFont:font];
    
    // check if UIGraphicsBeginImageContextWithOptions is available (iOS is 4.0+)
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(size,NO,0.0);
    else
        // iOS is < 4.0 
        UIGraphicsBeginImageContext(size);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger 
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //CGContextClearRect(ctx, CGRectMake(0,0,width,height));
    //CGContextBeginPath(ctx);
    
    //CGContextSetFillColor(ctx, CGColorGetComponents( [[UIColor yellowColor] CGColor]));        
    //CGContextFillRect(ctx, CGRectMake(0,0,width,height));
    
    // set font color
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor); 
    
    //CGContextSetRGBStrokeColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor blueColor] CGColor]);    
    //CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor blueColor] CGColor]);
    
    // draw in context, you can use  drawInRect/drawAtPoint:withFont:
    //[text drawAtPoint:CGPointMake(0.0, 0.0) withFont:font];
    [text drawInRect:CGRectMake(20, 20, width, height) withFont:[UIFont systemFontOfSize:20.0]];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //[image retain];
    UIGraphicsEndImageContext();    
    
    //CGContextClosePath(ctx); 
    
    return image;
}

+(UIImage *)screenshot
{
	// Also checking for version directly for 3.2(.x) since UIGraphicsBeginImageContextWithOptions appears to exist
	// but can't be used.
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
	CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (systemVersion >= 4.0f)
	{
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
        
	} else {
		UIGraphicsBeginImageContext(imageSize);
	}
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    //NSInteger count = 0;
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            
            // Y-offset for the status bar (if it's showing)
            NSInteger yOffset = [UIApplication sharedApplication].statusBarHidden ? 0 : -20;
            
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y + yOffset);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIImage*)captureView:(CGRect)rect
{    
    /////////////////////////////////////////////////////////////////////////
    // 还原背景，真实截图
//    UIImage* scrImgWithBG = [self screenshot];
//    UIImage *tvImgWithBG = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(scrImgWithBG.CGImage, rect)];
    
    UIImage* scrImgWithBG = [self screenshot];
    CGImageRef faceImageRef= CGImageCreateWithImageInRect(scrImgWithBG.CGImage, rect);
    UIImage *tvImgWithBG = [UIImage imageWithCGImage:faceImageRef];
    CGImageRelease(faceImageRef);
    
    /*
    int realHeight = [self getMinHeight:tvImgWithBG];
    int realWidth = [self getMinWidth:tvImgWithBG];
    
    // 做最后的去边框裁剪工作
    UIImage *realImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(tvImgWithBG.CGImage, CGRectMake(0,0,realWidth,realHeight))];
    
    //NSLog(@"width=%f, height=%f, realHeight=%d", editViewWidth, editViewHeight*scale, realHeight);
    */
    return tvImgWithBG;
}

// 裁剪掉图片边缘多余的空白部分 
//+ (UIImage *) cutImageEdge: (UIImage *) inImage edgeMargin:(float)margin
//{
//    int realHeight = [self getMinHeight:inImage];
//    int realWidth = [self getMinWidth:inImage];
//
////    NSLog(@"width=%d, height=%d", realWidth, realHeight);
//    
//    // 做最后的去边框裁剪工作
//    return [UIImage imageWithCGImage:CGImageCreateWithImageInRect(inImage.CGImage, CGRectMake(0,0,realWidth,realHeight))];
//}

+ (UIImage*)changeImageColor:(UIImage*)inImage r1:(int)r1 g1:(int)g1 b1:(int)b1 r2:(int)r2 g2:(int)g2 b2:(int)b2
{
	unsigned char *imgPixel = [self RequestImagePixelData:inImage];
	CGImageRef inImageRef = [inImage CGImage];
	GLuint w = CGImageGetWidth(inImageRef);
	GLuint h = CGImageGetHeight(inImageRef);
	
	int wOff = 0;
	int pixOff = 0;
	
	for(GLuint y = 0;y< h;y++)
	{
		pixOff = wOff;
		
		for (GLuint x = 0; x<w; x++) 
		{
			int red = (unsigned char)imgPixel[pixOff];
			int green = (unsigned char)imgPixel[pixOff+1];
			int blue = (unsigned char)imgPixel[pixOff+2];
			
            if (red == r1 && green == g1 && blue == b1) 
            {
                imgPixel[pixOff] = r2;
                imgPixel[pixOff+1] = g2;
                imgPixel[pixOff+2] = b2;                
            }
			
			pixOff += 4;
		}
		wOff += w * 4;
	}
	
	NSInteger dataLength = w*h* 4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * w;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(w, h, 
                                        bitsPerComponent, 
                                        bitsPerPixel, 
                                        bytesPerRow, 
                                        colorSpaceRef, 
                                        bitmapInfo, 
                                        provider, 
                                        NULL, NO, renderingIntent);
	
	UIImage *my_Image = [UIImage imageWithCGImage:imageRef];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	return my_Image;
}

//+(CGContextRef) CreateRGBABitmapContext: (CGImageRef)inImage 
//{
//	CGContextRef context = NULL; 
//	CGColorSpaceRef colorSpace; 
//	void *bitmapData; 
//	int bitmapByteCount; 
//	int bitmapBytesPerRow;
//	size_t pixelsWide = CGImageGetWidth(inImage); 
//	size_t pixelsHigh = CGImageGetHeight(inImage); 
//	bitmapBytesPerRow	= (pixelsWide * 4); 
//	bitmapByteCount	= (bitmapBytesPerRow * pixelsHigh); 
//	colorSpace = CGColorSpaceCreateDeviceRGB();
//	if (colorSpace == NULL) 
//	{
//		fprintf(stderr, "Error allocating color space\n"); return NULL;
//	}
//	// allocate the bitmap & create context 
//	bitmapData = malloc( bitmapByteCount ); 
//	if (bitmapData == NULL) 
//	{
//		fprintf (stderr, "Memory not allocated!"); 
//		CGColorSpaceRelease( colorSpace ); 
//		return NULL;
//	}
//	context = CGBitmapContextCreate (bitmapData, 
//                                     pixelsWide, 
//                                     pixelsHigh, 
//                                     8, 
//                                     bitmapBytesPerRow, 
//                                     colorSpace, 
//                                     kCGImageAlphaPremultipliedLast);
//	if (context == NULL) 
//	{
//		free (bitmapData); 
//		fprintf (stderr, "Context not created!");
//	} 
//	CGColorSpaceRelease( colorSpace ); 
//	return context;
//}

// Return Image Pixel data as an RGBA bitmap 
//+(unsigned char *)RequestImagePixelData:(UIImage *)inImage 
//{
//	CGImageRef img = [inImage CGImage]; 
//	CGSize size = [inImage size];
//	CGContextRef cgctx = [self CreateRGBABitmapContext:img]; 
//	
//	if (cgctx == NULL) 
//		return NULL;
//	
//	CGRect rect = {{0,0},{size.width, size.height}}; 
//	CGContextDrawImage(cgctx, rect, img); 
//	unsigned char *data = CGBitmapContextGetData (cgctx); 
//	CGContextRelease(cgctx);
//	return data;
//}

// 获得图片的宽度
+(int) getImageWidth:(UIImage*)inImage
{
    CGImageRef inImageRef = [inImage CGImage];
    return CGImageGetWidth(inImageRef);
}

// 获得图片的高度
+(int) getImageHeight:(UIImage*)inImage
{
    CGImageRef inImageRef = [inImage CGImage];
    return CGImageGetHeight(inImageRef);    
}

+(int) getMinHeight:(UIImage*)inImage
{
    unsigned char *imgPixel = [self RequestImagePixelData:inImage];
    CGImageRef inImageRef = [inImage CGImage];
    GLuint w = CGImageGetWidth(inImageRef);
    GLuint h = CGImageGetHeight(inImageRef);
    
//    NSLog(@"getMinHeight  width=%d, height=%d", w, h);
    
    int x,y;
    for(y=h-1;y>0;y--)
    {
        BOOL isSameLine = YES;
        for(x=0;x<w-1;x++)
        {
            int index=y*w+x;
            
            // note: 一个像素
            if((imgPixel[index*4] != imgPixel[(index+1)*4]) || (imgPixel[index*4+1] != imgPixel[(index+1)*4+1]) ||(imgPixel[index*4+2] != imgPixel[(index+1)*4+2]))
            {
                isSameLine = NO;
                if (y+20 < h)
                    return y+20;
                else if (y+10 < h)
                    return y+10;
                else
                    return y+1;
            }
        }
    }
    return y+1;
}

+(int) getMinWidth:(UIImage*)inImage
{
    unsigned char *imgPixel = [self RequestImagePixelData:inImage];
    CGImageRef inImageRef = [inImage CGImage];
    GLuint w = CGImageGetWidth(inImageRef);
    GLuint h = CGImageGetHeight(inImageRef);
    
    int x,y;
    for(x=w-1;x>0;x--)
    {
        BOOL isSameLine = YES;
        for(y=h-1;y>1;y--)
        {
            int index=y*w+x;
            
            // note: 一个像素
            if((imgPixel[index*4] != imgPixel[(index-w)*4]) || (imgPixel[index*4+1] != imgPixel[(index-w)*4+1]) ||(imgPixel[index*4+2] != imgPixel[(index-w)*4+2]))
            {
                isSameLine = NO;
                if (x+20 < w)
                    return x+20;
                else if (x+10 < w)
                    return x+10;
                else
                    return x+1;
            }
        }
    }
    return x+1;
}

//等比率缩放
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize), NO, 0);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize), NO, 0.0);
//    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

//等比率缩放
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size
{
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    //    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize), NO, 0.0);
    //    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

//+ (UIImage*)captureViewWithCrop:(CGRect)rect
//{ 
//    /////////////////////////////////////////////////////////////////////////
//    // 计算出比例
//    float scale = 2.0;
//    struct utsname systemInfo;
//    uname(&systemInfo);
//    NSString* insideName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
//    if ([insideName hasPrefix:@"iPhone1"] || [insideName hasPrefix:@"iPhone2"]) 
//        scale = 1.0;
//    
//    rect.size.width *= scale;
//    rect.size.height *= scale;
//        
//    /////////////////////////////////////////////////////////////////////////
//    // 还原背景，真实截图
//    UIImage* scrImgWithBG = [ImageUtil screenshot];
////    NSLog(@"scrImgWithBG %f,%f",scrImgWithBG.size.width,scrImgWithBG.size.height);
//    UIImage *tvImgWithBG = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(scrImgWithBG.CGImage, rect)];
//    
//    int realHeight = [ImageUtil getMinHeight:tvImgWithBG];
//    int realWidth = [ImageUtil getMinWidth:tvImgWithBG];
//    
//    // 做最后的去边框裁剪工作
//    UIImage *realImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(tvImgWithBG.CGImage, CGRectMake(0,0,realWidth,realHeight))];
//    
//    //NSLog(@"width=%f, height=%f, realHeight=%d", editViewWidth, editViewHeight*scale, realHeight);
//    
//    return realImage;
//}

// 合并2个图像
+ (UIImage*) mergeImage:(UIImage*)bg front:(UIImage*) front size:(CGSize)size alpha:(float)alpha
{
    UIGraphicsBeginImageContext( size );
    
    // Use existing opacity as is
    [bg drawInRect:CGRectMake(0,0,size.width,size.height)];
    // Apply supplied opacity
    [front drawInRect:CGRectMake(0,0,size.width,size.height) blendMode:kCGBlendModeNormal alpha:alpha];
    /*    
     UIGraphicsBeginImageContext(size);
     
     CGPoint thumbPoint = CGPointMake(0,0);
     [bg drawAtPoint:thumbPoint];
     
     CGPoint starredPoint = CGPointMake(0, 0);
     [front drawAtPoint:starredPoint];
     */    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;    
}

+ (UIImage*) mergeImage:(UIImage*)bg front:(UIImage*) front size:(CGSize)size
{
    return [self mergeImage:bg front:front size:size alpha:1];
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image kMaxResolution:(int)kMaxResolution 
{
	//static int kMaxResolution = 640;
	
	CGImageRef imgRef = image.CGImage;
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		} else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
		case UIImageOrientationUp:
            NSLog(@"UIImageOrientationUp");
			transform = CGAffineTransformIdentity;
			break;
		case UIImageOrientationUpMirrored:
            NSLog(@"UIImageOrientationUpMirrored");            
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
		case UIImageOrientationDown:
            NSLog(@"UIImageOrientationDown");            
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
		case UIImageOrientationDownMirrored:
            NSLog(@"UIImageOrientationDownMirrored");                        
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
		case UIImageOrientationLeftMirrored:
            NSLog(@"UIImageOrientationDownMirrored");                                    
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
		case UIImageOrientationLeft:
            NSLog(@"UIImageOrientationLeft");                        
            
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
		case UIImageOrientationRightMirrored:
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
		case UIImageOrientationRight:
            NSLog(@"UIImageOrientationRight");                        
            
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
	
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) 
    {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	} 
    else 
    {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}


+(int) colorDiff:(int)r1 g1:(int)g1 b1:(int)b1 r2:(int)r2 g2:(int)g2 b2:(int)b2
{
    int dwBg_Y = (int)(r1*0.299 + g1*0.587 + b1*0.114);
    int dwFront_Y = (int)(r2*0.299 + g2*0.587 + b2*0.114);
    return abs(dwFront_Y - dwBg_Y);
}

+(int) getDarkLevel:(int)r g:(int)g b:(int)b
{
    return [self colorDiff:255 g1:255 b1:255 r2:r g2:g b2:b];
}

// 判断颜色是否够深
+(BOOL) isDarkBlack:(int)r g:(int)g b:(int)b
{
    int sim = [self colorDiff:255 g1:255 b1:255 r2:r g2:g b2:b];
    if (sim > 100)
        return YES;
    else
        return NO;
}

+(BOOL) isMiddleBlack:(int)r g:(int)g b:(int)b
{
    int sim = [self colorDiff:255 g1:255 b1:255 r2:r g2:g b2:b];
    if (sim > 50 && sim < 100)
        return YES;
    else
        return NO;
}

+(BOOL) isLightBlack:(int)r g:(int)g b:(int)b
{
    int sim = [self colorDiff:255 g1:255 b1:255 r2:r g2:g b2:b];
    if (sim > 25 && sim < 50)
        return YES;
    else
        return NO;    
}

+ (UIImage*)getSpecialImage:(UIImage*)image withPoints:(NSArray*)pointArray
{
    if (pointArray.count<=0) {
        return nil;
    }
    //    NSArray *points = [self getPoints];
    CGRect rect = CGRectZero;
    
    rect.size = image.size;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
    
    {
        [[UIColor blackColor] setFill];
        UIRectFill(rect);
        [[UIColor whiteColor] setFill];
        
        UIBezierPath *aPath = [UIBezierPath bezierPath];
        
        NSValue *_value = [pointArray objectAtIndex:0];
        // Set the starting point of the shape.
        [aPath moveToPoint:[_value CGPointValue]];
        
        for (uint i=1; i<pointArray.count; i++)
        {
            _value = [pointArray objectAtIndex:i];
            [aPath addLineToPoint:[_value CGPointValue]];
        }
        
        
        [aPath closePath];
        [aPath fill];
    }
    
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    {
        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
        [image drawAtPoint:CGPointZero];
    }
    
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return maskedImage;
}

+ (UIImage*)drawCircle:(UIImage*)image withCenter:(CGPoint)centerPoint radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clock
{
    CGRect rect = CGRectZero;
    
    rect.size = image.size;
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0.0);
    
    {
        [[UIColor blackColor] setFill];
        UIRectFill(rect);
        [[UIColor whiteColor] setFill];
        
        UIBezierPath* aPath = [UIBezierPath bezierPathWithArcCenter:centerPoint
                                                             radius:radius
                                                         startAngle:startAngle
                                                           endAngle:endAngle
                                                          clockwise:clock];
        
        [aPath closePath];
        [aPath fill];
    }
    
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    {
        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
        [image drawAtPoint:CGPointZero];
    }
    
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return maskedImage;
}

+ (UIImage*)getScaleImage:(UIImage*)image withWidth:(float)width andHeight:(float)height
{
    float _scale = 0;
//    if ((width<image.size.width && width*2>image.size.width) || (height<image.size.height && height*2>image.size.height))
//    {
//        return image;
//    }
    width = width*1.15;
    height = height*1.15;
    UIImage *_newImage;
    if (image.size.width/width<=image.size.height/height) {
        _scale = width/image.size.width;
    }
    else
    {
        _scale = height/image.size.height;
    }
    _newImage = [ImageUtil scaleImage:image toScale:_scale];
    return _newImage;
}

+ (UIImage*)getImageWithMarkImage:(UIImage*)markImage andOriginImage:(UIImage*)originImage andCGSize:(CGSize)size
{
//    NSLog(@"markImage before %f,%f",markImage.size.width,markImage.size.height);
    
    markImage = [ImageUtil scaleImage:markImage toSize:originImage.size];//toScale:size.width/markImage.size.width
    
    UIImage *maskedImage = [ImageUtil maskImage:originImage withMask:markImage];
    
//    NSLog(@"originImage %f,%f",originImage.size.width,originImage.size.height);
//    NSLog(@"markImage after %f,%f",markImage.size.width,markImage.size.height);
    
    UIGraphicsEndImageContext();
    return maskedImage;
}

+ (UIImage*)getImageWithMarkImage:(UIImage*)markImage andOriginImage:(UIImage*)originImage andCGSize:(CGSize)markSize andOriginSize:(CGSize)originSize
{
    CGRect faceRect = CGRectMake((markSize.width-originSize.width)*0.5, (markSize.height-originSize.height)*0.5, originSize.width, originSize.height);
    CGImageRef imgrefout = CGImageCreateWithImageInRect([markImage CGImage], faceRect);
    markImage = [UIImage imageWithCGImage:imgrefout];
    CGImageRelease(imgrefout);
    
    UIImage *maskedImage = [ImageUtil maskImage:originImage withMask:markImage];
    
    UIGraphicsEndImageContext();
    return maskedImage;
}


+(CGImageRef) CopyImageAndAddAlphaChannel :(CGImageRef) sourceImage
{
    CGImageRef retVal = NULL;
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef offscreenContext = CGBitmapContextCreate(NULL, width, height,
                                                          8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    if (offscreenContext != NULL) {
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, width, height), sourceImage);
        
        retVal = CGBitmapContextCreateImage(offscreenContext);
        CGContextRelease(offscreenContext);
    }
    
    CGColorSpaceRelease(colorSpace);
    return retVal;
}

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
    CGImageRef maskRef = maskImage.CGImage;
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
    CGImageRef sourceImage = [image CGImage];
    CGImageRef imageWithAlpha = sourceImage;
    //add alpha channel for images that don’t have one (ie GIF, JPEG, etc…)
    //this however has a computational cost
    if (CGImageGetAlphaInfo(sourceImage) == kCGImageAlphaNone) {
        imageWithAlpha = [ImageUtil CopyImageAndAddAlphaChannel :sourceImage];
    }
    
    CGImageRef masked = CGImageCreateWithMask(imageWithAlpha, mask);
    CGImageRelease(mask);
    
    //release imageWithAlpha if it was created by CopyImageAndAddAlphaChannel
    if (sourceImage != imageWithAlpha) {
        CGImageRelease(imageWithAlpha);
    }
    
    UIImage* retImage = [UIImage imageWithCGImage:masked];
    CGImageRelease(masked);
    return retImage;
}

+ (UIImage*)getMarkImage:(UIImage*)originMarkImage andSize:(CGSize)size andRadians:(float)radians
{
    if (originMarkImage == nil) {
        return nil;
    }

    originMarkImage = [ImageUtil getStretchImage:originMarkImage andSize:size];
    UIImage *_test = [originMarkImage imageRotatedByRadians:radians];
	return _test;
}

+ (UIImage*)getStretchImage:(UIImage*)orginImage andSize:(CGSize)size
{
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, 0);
    else
        // iOS is < 4.0
        UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    //    UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize), NO, 0.0);
    //    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [orginImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

// 合并2个图像
+ (UIImage*) mergeImage:(UIImage*)bg front:(UIImage*) front size:(CGSize)size alpha:(float)alpha andOriginOffset:(CGSize)originOffset andSizeOffset:(CGSize)sizeOffset
{
    UIGraphicsBeginImageContext( size );
    
    // Use existing opacity as is
    [bg drawInRect:CGRectMake(0,0,size.width,size.height)];
    // Apply supplied opacity
    [front drawInRect:CGRectMake(originOffset.width,originOffset.height,size.width-originOffset.width-sizeOffset.width,size.height-originOffset.height-sizeOffset.height) blendMode:kCGBlendModeNormal alpha:alpha];
    /*
     UIGraphicsBeginImageContext(size);
     
     CGPoint thumbPoint = CGPointMake(0,0);
     [bg drawAtPoint:thumbPoint];
     
     CGPoint starredPoint = CGPointMake(0, 0);
     [front drawAtPoint:starredPoint];
     */
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}


@end
