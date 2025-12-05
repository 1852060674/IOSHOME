//
//  UIColor+Hex.h
//  MoviePhoto2
//
//  Created by ZB_Mac on 15-4-20.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)
+ (UIColor *) colorWithHexString: (NSString *) hexString;
+ (NSString *) hexFromUIColor: (UIColor*) color ;
@end
