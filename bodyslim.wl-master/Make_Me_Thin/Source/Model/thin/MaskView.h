//
//  maskView.h
//  eyeColorPlus
//
//  Created by shen on 14-7-16.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MaskView;

@protocol MaskViewDataSource <NSObject>

@required
-(CGFloat) viewScaleForMaskView:(MaskView *)maskView;
-(CGFloat) imageScaleForMaskView:(MaskView *)maskView;
-(CGSize) imageSizeForMaskView:(MaskView *)maskView;
-(CGFloat) stokeWidthForMaskView:(MaskView *)maskView;
-(UIImageView *)underneathImageView;
@end

@interface MaskView : UIView

-(id)initWithFrame:(CGRect)frame andDataSource:(id<MaskViewDataSource>) dataSource;

@property (nonatomic, weak) id<MaskViewDataSource> dataSource;

-(void)privateTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)privateTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)privateTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)privateTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
-(UIImage *)getMaskImage;
-(UIImage *)getViewImage;
@end
