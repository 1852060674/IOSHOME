//
//  DyeTopView.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/1.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "AutoDyeTopView.h"

@implementation AutoDyeTopView

-(void)awakeFromNib
{
    [super awakeFromNib];

    UIButton *button;
    
//    button = self.topToolBtns[0];
//    [button setTitle:NSLocalizedString(@"TOP_BACK", @"") forState:UIControlStateNormal];
    
    button = self.topToolBtns[1];
    [button setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    
    button = self.topToolBtns[2];
    [button setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    
//    button = self.topToolBtns[3];
//    [button setTitle:NSLocalizedString(@"TOP_OK", @"") forState:UIControlStateNormal];
}

- (IBAction)onBtnClick:(UIButton *)sender
{
    if (_actions) {
        _actions([self.topToolBtns indexOfObject:sender]);
    }
}

@end
