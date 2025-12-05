//
//  ComprehensiveCutoutDrawView.h
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/24.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ComprehensiveCutoutDrawView;

@protocol ComprehensiveCutoutDrawViewDelegate <NSObject>

-(void)comprehensiveCutoutDrawView:(ComprehensiveCutoutDrawView *)drawView didFinishDrawWithImage:(UIImage *)image;

@end

@interface ComprehensiveCutoutDrawView : UIView
-(ComprehensiveCutoutDrawView *)initWithFrame:(CGRect)frame andImageWidth:(NSInteger)imageWidth andImageHeight:(NSInteger)imageHeight;

@property (nonatomic, readwrite) BOOL forClosedArea;
@property (nonatomic, readwrite) BOOL forClosedAreaWithContour;

@property (nonatomic, readwrite) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, readwrite) NSInteger imageWidth;
@property (nonatomic, readwrite) NSInteger imageHeight;
@property (nonatomic, weak) id<ComprehensiveCutoutDrawViewDelegate> delegate;

-(void)privateTouchesBeganAtPoint:(CGPoint)point;
-(void)privateTouchesMovedToPoint:(CGPoint)point;
-(void)privateTouchesEndedAtPoint:(CGPoint)point;
-(void)privateTouchesCancelled;

-(void)updateContextSize;
@end
