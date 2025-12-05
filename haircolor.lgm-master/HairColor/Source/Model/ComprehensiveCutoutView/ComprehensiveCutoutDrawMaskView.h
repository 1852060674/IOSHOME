//
//  ComprehensiveCutoutMaskView.h
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/24.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComprehensiveCutoutDrawMaskView : UIView

-(ComprehensiveCutoutDrawMaskView *)initWithFrame:(CGRect)frame andImageWidth:(NSInteger)imageWidth andImageHeight:(NSInteger)imageHeight;

@property (nonatomic, readwrite) NSInteger imageWidth;
@property (nonatomic, readwrite) NSInteger imageHeight;

// for brush&eraser
@property (nonatomic, readwrite) NSInteger brushRadius;
@property (nonatomic, readwrite) CGFloat brushSmooth;
@property (nonatomic, readwrite) CGFloat brushAlpha;
@property (nonatomic, readwrite) BOOL eraseMode;

-(void)privateTouchesBeganAtPoint:(CGPoint)point;
-(void)privateTouchesMovedToPoint:(CGPoint)point;
-(void)privateTouchesEndedAtPoint:(CGPoint)point;
-(void)privateTouchesCancelled;

-(UIImage *)getMaskImage;

-(UIImage *)getFixMaskImage;
-(void)setFixMaskImage:(UIImage *)image;

-(void)updateContextSize;

@end
