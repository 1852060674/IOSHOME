//
//  MGTBArrowAspectView.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-18.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MGTBArrowAspectViewDelegate;

@interface MGTBArrowAspectView : UIView
@property (assign, nonatomic) NSInteger selectedBtnIdx;

@property (weak, nonatomic) id<MGTBArrowAspectViewDelegate> delegate;

- (void)hideSelf;
- (void)showSelf;

@end


@protocol MGTBArrowAspectViewDelegate <NSObject>

@required
- (void)mgTBArrowAspectViewSelectItemAt:(NSInteger)index;

@end