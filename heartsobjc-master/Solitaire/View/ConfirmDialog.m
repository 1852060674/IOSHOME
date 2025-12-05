//
//  ConfirmDialog.m
//  Solitaire
//
//  Created by jerry on 2017/9/1.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ConfirmDialog.h"

@implementation ConfirmDialog

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
  [super awakeFromNib];
  self.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1];
  self.layer.borderWidth = 1;
  self.layer.borderColor = [UIColor colorWithRed:0.7 green:0.4 blue:0.1 alpha:1].CGColor;
  self.layer.cornerRadius = 3;
  self.titleL.text = self.titleStr;
  self.confirmL.text = self.confirmStr;
}
- (IBAction)confirm:(id)sender {
  [self.superview removeFromSuperview];
}

@end
