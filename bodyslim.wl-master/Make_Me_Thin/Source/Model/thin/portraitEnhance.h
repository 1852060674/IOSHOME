//
//  portraitEnhance.h
//  FaceMorph
//
//  Created by shen on 14-7-11.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kIWErrorNone,
    kIWErrorFaceDetectFail,
} IWErrorCode;

@class portraitEnhance;

@protocol portraitEnhanceDataSource <NSObject>

@required
- (BOOL) faceFeatureUsable:(UIImage *)image;
- (BOOL) accurateFaceFeatureUsable:(UIImage *)image;
@optional
- (CGPoint) leftEyeLeftForImage:(UIImage *)image;
- (CGPoint) leftEyeBottomForImage:(UIImage *)image;
- (CGPoint) leftEyeRightForImage:(UIImage *)image;
- (CGPoint) leftEyeTopForImage:(UIImage *)image;
- (CGPoint) leftEyeCenterForImage:(UIImage *)image;
- (CGFloat) leftEyeIrisRadiusForImage:(UIImage *)image;
- (CGRect) leftEyeRectForImage:(UIImage *)image;

- (CGPoint) rightEyeLeftForImage:(UIImage *)image;
- (CGPoint) rightEyeBottomForImage:(UIImage *)image;
- (CGPoint) rightEyeRightForImage:(UIImage *)image;
- (CGPoint) rightEyeTopForImage:(UIImage *)image;
- (CGPoint) rightEyeCenterForImage:(UIImage *)image;
- (CGFloat) rightEyeIrisRadiusForImage:(UIImage *)image;
- (CGRect) rightEyeRectForImage:(UIImage *)image;

- (CGPoint) noseTipForImage:(UIImage *)image;

- (CGPoint) faceContourLeft1ForImage:(UIImage *)image;
- (CGPoint) faceContourLeft2ForImage:(UIImage *)image;
- (CGPoint) faceContourLeft3ForImage:(UIImage *)image;
- (CGPoint) faceContourLeft4ForImage:(UIImage *)image;
- (CGPoint) faceContourLeft5ForImage:(UIImage *)image;
- (CGPoint) faceContourLeft6ForImage:(UIImage *)image;
- (CGPoint) faceContourLeft7ForImage:(UIImage *)image;
- (CGPoint) faceContourLeft8ForImage:(UIImage *)image;
- (CGPoint) faceContourLeft9ForImage:(UIImage *)image;

- (CGPoint) faceContourRight1ForImage:(UIImage *)image;
- (CGPoint) faceContourRight2ForImage:(UIImage *)image;
- (CGPoint) faceContourRight3ForImage:(UIImage *)image;
- (CGPoint) faceContourRight4ForImage:(UIImage *)image;
- (CGPoint) faceContourRight5ForImage:(UIImage *)image;
- (CGPoint) faceContourRight6ForImage:(UIImage *)image;
- (CGPoint) faceContourRight7ForImage:(UIImage *)image;
- (CGPoint) faceContourRight8ForImage:(UIImage *)image;
- (CGPoint) faceContourRight9ForImage:(UIImage *)image;

- (CGPoint) faceContourChinForImage:(UIImage *)image;

- (CGRect) faceRectForImage:(UIImage *)image;


@end

@interface portraitEnhance : NSObject
@property (nonatomic, weak) id<portraitEnhanceDataSource> dataSource;
@property (nonatomic, readonly) IWErrorCode errorCode;
-(void)reset;
@end
