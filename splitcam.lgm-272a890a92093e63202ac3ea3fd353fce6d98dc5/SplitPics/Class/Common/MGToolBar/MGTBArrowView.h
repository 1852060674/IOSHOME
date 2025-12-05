//
//  MGTBArrowView.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-12.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGAdjustView.h"

@protocol MGTBArrowViewDelegate;

@interface MGTBArrowView : UIView

@property (assign, nonatomic) NSInteger selectedPictureIdx;
@property (assign, nonatomic) NSInteger selectedBtnIdx;
@property (strong, nonatomic) MGAdjustView *adjustView;
@property (weak, nonatomic) id<MGTBArrowViewDelegate> delegate;

- (void)hideSelf;
- (void)showSelf;
- (void)setDefaultDataWith:(NSInteger)nums;

@end


@protocol MGTBArrowViewDelegate <NSObject>

@required
- (void)mgTBAVAdjustAtIndex:(NSInteger)index WithValue:(float)value;
- (void)mgTBAVHide;
@end
