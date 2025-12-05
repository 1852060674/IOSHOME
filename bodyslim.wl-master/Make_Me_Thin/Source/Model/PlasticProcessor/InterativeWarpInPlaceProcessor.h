//
//  InterativeWarpProcessor.h
//  Plastic Surgeon
//
//  Created by ZB_Mac on 15/6/9.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface InterativeWarpProcessorInPlace : NSObject
@property (readwrite, nonatomic) CGFloat strenght;

-(void)clean;
-(void)reset;

-(void)setSrcImage:(UIImage *)image;

-(UIImage *)enlargeAtCenterPoint:(CGPoint)center withRadius:(CGFloat)radius andWait:(BOOL)wait andStrenght:(CGFloat)strenght andSpeedFirst:(BOOL)speedFirst;
-(UIImage *)shrinkAtCenterPoint:(CGPoint)center withRadius:(CGFloat)radius andWait:(BOOL)wait andStrenght:(CGFloat)strenght andSpeedFirst:(BOOL)speedFirst;
-(UIImage *)translateFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint withRadius:(CGFloat)radius andWait:(BOOL)wait andStrenght:(CGFloat)strenght andSpeedFirst:(BOOL)speedFirst andDepressRadialWarp:(BOOL)depressRadialWarp;
-(UIImage *)translateFromStartPoint1:(CGPoint)startPoint1 toEndPoint1:(CGPoint)endPoint1 withRadius1:(CGFloat)radius1 andFromStartPoint2:(CGPoint)startPoint2 toEndPoint2:(CGPoint)endPoint2 withRadius2:(CGFloat)radius2 andWait:(BOOL)wait andStrenght:(CGFloat)strenght andSpeedFirst:(BOOL)speedFirst andDepressRadialWarp:(BOOL)depressRadialWarp;

-(void)makeCurrentMapKeyFrame;

-(NSArray *)applyPoints:(NSArray *)points;

@end