//
//  FaceLandmarker.h
//  Make_Me_Thin
//
//  Created by ZB_Mac on 16/4/12.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#define ENABLE_ZB
//#define ENABLE_LUXAND

typedef enum : NSUInteger {
    LandmarkMethodNone,
    LandmarkMethodFacepp,
    LandmarkMethodLuxand,
    LandmarkMethodCI,
    LandmarkMethodGuess,
    LandmarkMethodZB,
} LandmarkMethod;

@interface FaceLandmarker : NSObject
+(FaceLandmarker *) defaultLandmarker;

-(void)asynLandmarkImage:(UIImage *)image withMethodList:(NSArray *)methods andEndBlock:(void (^)(NSArray* landmarks))endBlock;
-(NSArray *)landmarkImage:(UIImage *)image withMethodList:(NSArray *)methods;

-(void)clear;
@end
