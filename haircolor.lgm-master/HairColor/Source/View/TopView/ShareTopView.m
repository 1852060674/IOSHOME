//
//  EditTopView.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/7.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ShareTopView.h"

@implementation ShareTopView

-(void)awakeFromNib
{
    [super awakeFromNib];
    UIButton *button = self.topBtns[0];
    [button setTitle:NSLocalizedString(@"SHARE_TOP_BACK", @"") forState:UIControlStateNormal];
    
    button = self.topBtns[1];
    [button setTitle:NSLocalizedString(@"SHARE_TOP_OK", @"") forState:UIControlStateNormal];
    
    self.titleLabel.text = NSLocalizedString(@"SHARE_EDIT_TITLE", @"");
    
}

- (IBAction)onBtnClick:(UIButton *)sender
{
    if (_actions) {
        _actions([self.topBtns indexOfObject:sender]);
    }
}

@end
