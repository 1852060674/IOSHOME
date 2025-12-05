//
//  CutoutTopView.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/8/26.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "CutoutTopView.h"
//#import "ZB_IMGCommonConfig.h"

@implementation CutoutTopView

-(void)awakeFromNib
{
    [super awakeFromNib];
    UIButton *button = self.topToolBtns[0];
    [button setTitle:NSLocalizedString(@"TOP_BACK", @"") forState:UIControlStateNormal];
//    [button setTitleColor:CUT_HIGHLIGHT_COLOR forState:UIControlStateNormal];
    
    button = self.topToolBtns[1];
    [button setTitle:NSLocalizedString(@"TOP_OK", @"") forState:UIControlStateNormal];
//    [button setTitleColor:CUT_HIGHLIGHT_COLOR forState:UIControlStateNormal];
    
    self.textLabel.text = NSLocalizedString(@"CUT_HAIR_TITLE", @"");
//    self.backgroundColor = BACKGROUND_COLOR;
}

- (IBAction)onBtnClick:(UIButton *)sender
{
    if (_actions) {
        _actions([self.topToolBtns indexOfObject:sender]);
    }
}

@end
