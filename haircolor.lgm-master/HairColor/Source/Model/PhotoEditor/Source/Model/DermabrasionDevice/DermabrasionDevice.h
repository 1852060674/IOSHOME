//
//  DermabrasionDevice.h
//  Meitu
//
//  Created by ZB_Mac on 15-1-23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DermabrasionDevice : NSObject
+(instancetype) defaultProcessor;

-(UIImage *)channelSmoothImage:(UIImage *)image byStrenght:(CGFloat)strenght;
-(UIImage *)surfaceSmoothImage:(UIImage *)image byStrenght:(CGFloat)strenght;
-(UIImage *)shadowLighten:(UIImage *)image byStrenght:(CGFloat)strenght;

@end
