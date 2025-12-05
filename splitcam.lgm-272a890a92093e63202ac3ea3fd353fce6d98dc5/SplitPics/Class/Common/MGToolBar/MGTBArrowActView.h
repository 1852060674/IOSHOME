//
//  MGTBArrowActView.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-17.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MGTBArrowActViewDelegate;

@interface MGTBArrowActView : UIView

@property (assign, nonatomic) NSInteger selectedPictureIdx;
@property (assign, nonatomic) NSInteger selectedBtnIdx;
@property (weak, nonatomic) id<MGTBArrowActViewDelegate> delegate;

- (void)hideSelf;
- (void)showSelf;


@end


@protocol MGTBArrowActViewDelegate <NSObject>

@required

- (void)mgTBArrowActViewSelectItemAt:(NSInteger)index;
- (void)mgTBArrowActViewHide;
@end
