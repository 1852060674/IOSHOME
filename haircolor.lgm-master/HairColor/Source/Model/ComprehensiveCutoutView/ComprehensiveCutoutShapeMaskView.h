//
//  ComprehensiveCutoutMaskView.h
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/24.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComprehensiveCutoutShapeMaskView : UIView

-(ComprehensiveCutoutShapeMaskView *)initWithFrame:(CGRect)frame andImageWidth:(NSInteger)imageWidth andImageHeight:(NSInteger)imageHeight;

@property (nonatomic, readwrite) NSInteger imageWidth;
@property (nonatomic, readwrite) NSInteger imageHeight;
@property (nonatomic, strong) UIImageView *shapeMaskImageView;

-(UIImage *)getMaskImage;

-(UIImage *)getShapeMaskImage;
-(void)setShapeMaskImage:(UIImage *)image;
-(void)resetShapeView;

-(void)updateContextSize;

-(void)zoomByScale:(CGFloat)scale;
-(void)rotateByAngle:(CGFloat)angle;
-(void)translateByOffset:(CGPoint)offset;
//
@end
