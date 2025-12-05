//
//  MailLevelView.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/8/26.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainLevelView_1 : UIView

// banner
@property (nonatomic, readwrite) CGFloat adHeight;
@property (nonatomic, strong) UIView *adContainerView;
-(void)showBanner:(BOOL)show animated:(BOOL)animated completionAction:(void (^)(BOOL))completion;

// main
@property (nonatomic, strong) UIView *contentView;

// top
@property (nonatomic, readwrite) CGFloat topHeight;
@property (nonatomic, strong) UIView *shellTopBarView;

// bottom
@property (nonatomic, readwrite) CGFloat bottomHeight;
@property (nonatomic, strong) UIView *shellBottomBarView;

// pop
@property (nonatomic, readwrite) CGFloat popHeight_1;
@property (nonatomic, strong) UIView *popView_1;

@property (nonatomic, readwrite) CGFloat popHeight_2;
@property (nonatomic, strong) UIView *popView_2;

@property (nonatomic, readwrite) CGFloat popHeight_3;
@property (nonatomic, strong) UIView *popView_3;

-(NSInteger)currentPopViewType;
-(void)showPopView:(NSInteger)type animated:(BOOL)animated completionAction:(void (^)(BOOL))completion;

@end
