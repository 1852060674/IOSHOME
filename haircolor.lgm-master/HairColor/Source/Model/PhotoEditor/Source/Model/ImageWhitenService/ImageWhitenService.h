//
//  ImageWhitenService.h
//  Meitu
//
//  Created by ZB_Mac on 15-1-23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageWhitenService : NSObject
+(instancetype) defaultProcessor;
-(UIImage *)whitenImage:(UIImage *)image byStrenght:(CGFloat)strenght;
@end
