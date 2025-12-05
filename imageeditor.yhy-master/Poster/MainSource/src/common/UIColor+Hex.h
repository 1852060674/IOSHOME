//
//  UIColor+Hex.h
//  BaiduNews
//
//  Created by JHorn on 11-8-1.
//  Copyright 2011 Baidu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (Hex)

+ (UIColor *) colorWithHex:(uint) hex;
+ (void)colorWithHex:(uint)hex red:(int *)red green:(int *)green blue:(int *)blue alpha:(int *)alpha;

@end
