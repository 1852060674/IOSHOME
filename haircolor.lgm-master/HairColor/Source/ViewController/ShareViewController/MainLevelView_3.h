//
//  MainLevelView_3.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/8.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainLevelView_3 : UIView
-(MainLevelView_3 *)initWithFrame:(CGRect)frame andHasAD:(BOOL)hasAD;

// main
@property (nonatomic, strong) UIView *mainAreaView;
// top
@property (nonatomic, strong) UIView *shellTopBarView;
@property (nonatomic, readwrite) CGFloat topHeight;

// bottom
@property (nonatomic, strong) UIView *shellBottomBarView;
@property (nonatomic, readwrite) CGFloat bottomHeight_1;
@property (nonatomic, readwrite) CGFloat bottomHeight_2;

-(void)showBottomType:(NSInteger)type animated:(BOOL)animated;

@end
