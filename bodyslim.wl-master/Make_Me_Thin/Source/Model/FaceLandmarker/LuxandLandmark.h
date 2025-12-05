//
//  LuxandLandmark.h
//  ChildLook4
//
//  Created by ZB_Mac on 15/9/6.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LandmarkSourceNone,
    LandmarkSourceFacePP,
    LandmarkSourceLuxand,
    LandmarkSourceCI,
    LandmarkSourceGuess,
    LandmarkSourceZB,
} LandmarkSource;

@interface LuxandLandmark : NSObject<NSCopying>
@property (nonatomic, readwrite) BOOL resultValid;

// 1:FacePP; 2:Luxand; 3:CI; 4:Guess; 5:ZB
@property (nonatomic, readwrite) LandmarkSource resultSource;

@property (nonatomic, readwrite) int imageWidth;
@property (nonatomic, readwrite) int imageHeight;

// 原始图片中眉毛轮廓点
@property (nonatomic, readwrite) CGPoint leftEyeBrowLeft;
@property (nonatomic, readwrite) CGPoint leftEyeBrowLeftQuater;
@property (nonatomic, readwrite) CGPoint leftEyeBrowMiddle;
@property (nonatomic, readwrite) CGPoint leftEyeBrowRightQuater;
@property (nonatomic, readwrite) CGPoint leftEyeBrowRight;

@property (nonatomic, readwrite) CGPoint rightEyeBrowLeft;
@property (nonatomic, readwrite) CGPoint rightEyeBrowLeftQuater;
@property (nonatomic, readwrite) CGPoint rightEyeBrowMiddle;
@property (nonatomic, readwrite) CGPoint rightEyeBrowRightQuater;
@property (nonatomic, readwrite) CGPoint rightEyeBrowRight;

// 原始图片中眼睛轮廓点
@property (nonatomic, readwrite) CGPoint leftEyeLeft;
@property (nonatomic, readwrite) CGPoint leftEyeBottom;
@property (nonatomic, readwrite) CGPoint leftEyeRight;
@property (nonatomic, readwrite) CGPoint leftEyeTop;
@property (nonatomic, readwrite) CGPoint leftEyeCenter;
@property (nonatomic, readwrite) CGPoint leftEyeLowerLeftQuarter;
@property (nonatomic, readwrite) CGPoint leftEyeLowerRightQuarter;
@property (nonatomic, readwrite) CGPoint leftEyeUpperLeftQuarter;
@property (nonatomic, readwrite) CGPoint leftEyeUpperRightQuarter;
@property (nonatomic, readwrite) CGPoint leftEyePupilLeft;
@property (nonatomic, readwrite) CGPoint leftEyePupilRight;

@property (nonatomic, readwrite) CGPoint rightEyeLeft;
@property (nonatomic, readwrite) CGPoint rightEyeBottom;
@property (nonatomic, readwrite) CGPoint rightEyeRight;
@property (nonatomic, readwrite) CGPoint rightEyeTop;
@property (nonatomic, readwrite) CGPoint rightEyeCenter;
@property (nonatomic, readwrite) CGPoint rightEyeLowerLeftQuarter;
@property (nonatomic, readwrite) CGPoint rightEyeLowerRightQuarter;
@property (nonatomic, readwrite) CGPoint rightEyeUpperLeftQuarter;
@property (nonatomic, readwrite) CGPoint rightEyeUpperRightQuarter;
@property (nonatomic, readwrite) CGPoint rightEyePupilLeft;
@property (nonatomic, readwrite) CGPoint rightEyePupilRight;

// 原始图片中鼻子轮廓点
@property (nonatomic, readwrite) CGPoint noseTop;
@property (nonatomic, readwrite) CGPoint noseTip;
@property (nonatomic, readwrite) CGPoint noseLowerMiddleContour;
@property (nonatomic, readwrite) CGPoint noseLeft;
@property (nonatomic, readwrite) CGPoint noseLeftContour2;
@property (nonatomic, readwrite) CGPoint noseLeftContour3;
@property (nonatomic, readwrite) CGPoint noseRight;
@property (nonatomic, readwrite) CGPoint noseRightContour2;
@property (nonatomic, readwrite) CGPoint noseRightContour3;

// 原始图片中嘴巴轮廓点
@property (nonatomic, readwrite) CGPoint mouthLeft;
@property (nonatomic, readwrite) CGPoint mouthRight;

@property (nonatomic, readwrite) CGPoint mouthLowerLipBottom;
@property (nonatomic, readwrite) CGPoint mouthLowerLipLeftContour1;
@property (nonatomic, readwrite) CGPoint mouthLowerLipLeftContour3;
@property (nonatomic, readwrite) CGPoint mouthLowerLipRightContour1;
@property (nonatomic, readwrite) CGPoint mouthLowerLipRightContour3;
@property (nonatomic, readwrite) CGPoint mouthLowerLipTop;

@property (nonatomic, readwrite) CGPoint mouthUpperLipBottom;
@property (nonatomic, readwrite) CGPoint mouthUpperLipLeftContour2;
@property (nonatomic, readwrite) CGPoint mouthUpperLipLeftContour3;
@property (nonatomic, readwrite) CGPoint mouthUpperLipRightContour2;
@property (nonatomic, readwrite) CGPoint mouthUpperLipRightContour3;
@property (nonatomic, readwrite) CGPoint mouthUpperLipTop;

// 原始图像中脸部轮廓点
@property (nonatomic, readwrite) CGPoint contourLeft1;
@property (nonatomic, readwrite) CGPoint contourLeft2;
@property (nonatomic, readwrite) CGPoint contourLeft3;
@property (nonatomic, readwrite) CGPoint contourLeft4;
@property (nonatomic, readwrite) CGPoint contourLeft5;
@property (nonatomic, readwrite) CGPoint contourLeft6;
@property (nonatomic, readwrite) CGPoint contourLeft7;
@property (nonatomic, readwrite) CGPoint contourLeft8;
@property (nonatomic, readwrite) CGPoint contourLeft9;

@property (nonatomic, readwrite) CGPoint contourRight1;
@property (nonatomic, readwrite) CGPoint contourRight2;
@property (nonatomic, readwrite) CGPoint contourRight3;
@property (nonatomic, readwrite) CGPoint contourRight4;
@property (nonatomic, readwrite) CGPoint contourRight5;
@property (nonatomic, readwrite) CGPoint contourRight6;
@property (nonatomic, readwrite) CGPoint contourRight7;
@property (nonatomic, readwrite) CGPoint contourRight8;
@property (nonatomic, readwrite) CGPoint contourRight9;

@property (nonatomic, readwrite) CGPoint contourChin;

@property (nonatomic, readwrite) CGPoint contourForeHead;

// 脸颊边界, luxand only
@property (nonatomic, readwrite) CGPoint cheekLeft1;
@property (nonatomic, readwrite) CGPoint cheekLeft2;
@property (nonatomic, readwrite) CGPoint cheekRight1;
@property (nonatomic, readwrite) CGPoint cheekRight2;

-(CGRect)getFaceRect;
-(CGFloat)faceContourRadius;
-(CGPoint)faceContourCentroid;

-(void)scaleLandmarkByRatio:(CGFloat)scale;
-(void)translateLandmarkByOffset:(CGPoint)offset;
-(NSArray *)usedLandmarks;
-(void)setUsedLandmarks:(NSArray *)array;

@end
