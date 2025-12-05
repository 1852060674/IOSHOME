//
//  UIApplication+Size.h
//  Pyramid
//
//  Created by apple on 13-9-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIApplication (AppDimensions)
+(CGSize) currentSize;
+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation;
@end

@implementation UIApplication (AppDimensions)

+(CGSize) currentSize
{
    return [UIApplication sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

+(CGSize) sizeInOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    return size;
}

@end
