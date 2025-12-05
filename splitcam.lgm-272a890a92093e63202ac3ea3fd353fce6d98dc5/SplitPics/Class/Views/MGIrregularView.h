//
//  MGIrregularView.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-10.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TestScrollView.h"
typedef NS_ENUM(NSInteger, ShapeType) {
    BezierShaper,
    ImageShaper,
    RectShaper
};



@protocol MGIrregularViewDelegate;
@protocol MGIrregularViewDataSource;

@interface MGIrregularView : UIView<UIScrollViewDelegate>

@property (strong, nonatomic) UIView *mainView;

@property (strong, nonatomic) TestScrollView *contentView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIBezierPath *bezierArea;
@property (strong, nonatomic) CAShapeLayer *borderLayer;
@property (strong, nonatomic) UIColor *borderColor;

@property (assign, nonatomic) float borderWidth;
@property (assign, nonatomic) float blurWidth;
@property (assign, nonatomic) CGRect viewRect;
@property (assign, nonatomic) CGRect blur0Rect;

@property (assign, nonatomic) BlurDirection blurDirection;
@property (assign, nonatomic) NSInteger sublayoutIndex;
@property (assign, nonatomic) LayoutPattern layoutIndex;
@property (assign, nonatomic) BOOL isInEdit;

@property (assign, nonatomic) ShapeType shapeType;

@property (weak, nonatomic) id<MGIrregularViewDelegate> delegate;
@property (weak, nonatomic) id<MGIrregularViewDataSource> dataSource;

- (void)setMaskLayer0;
- (void)setMaskLayer;
- (void)setBorderWithAutoHide:(BOOL)isHide;
- (void)setRectShapeTypeLayer;
- (void)setIrregularTypeLayer;

- (void)changeEdgeBlurWidth:(CGFloat)blurWidth;

- (void)showBorder;
- (void)hiddenBorder;

- (void)setImageViewData:(UIImage*)image;
- (void)setResfresh;
- (void)setResfreshWithBlur:(CGFloat)blurRadius;

@end

@protocol MGIrregularViewDelegate <NSObject>
@optional

- (void)tapViewAtIndex:(NSInteger)index;
- (void)tapFocusInPoint:(CGPoint)point WithIndex:(NSInteger)index;

@end;

@protocol MGIrregularViewDataSource <NSObject>

@optional
- (BOOL)isTakeOverAtMGIrregularView:(MGIrregularView*)view;
@end
