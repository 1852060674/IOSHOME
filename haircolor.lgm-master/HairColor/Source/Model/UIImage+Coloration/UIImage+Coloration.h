//
//  UIImage+Coloration.h
//  HairColor
//
//  Created by ZB_Mac on 15-4-28.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Coloration)
-(UIImage *)imageWithColoration:(UIColor *)color highlight:(BOOL)highlight mode:(NSInteger)mode;

// mode: 4 - overlay; 5 - softlight
-(UIImage *)imageColoredWithImage:(UIImage *)image inFrame:(CGRect)frame highlight:(BOOL)highlight mode:(NSInteger)mode;

@end
