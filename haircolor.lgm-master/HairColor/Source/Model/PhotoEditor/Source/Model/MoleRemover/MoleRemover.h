//
//  MoleRemover.h
//  Meitu
//
//  Created by ZB_Mac on 15-1-23.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MoleRemover : NSObject
+(instancetype) defaultProcessor;
-(UIImage *)removeMole:(UIImage *)image andCenter:(CGPoint)center andRadius:(CGFloat)radius;
-(UIImage *)autoRemoveMole:(UIImage *)image inFaceRect:(CGRect)faceRect;
@end
