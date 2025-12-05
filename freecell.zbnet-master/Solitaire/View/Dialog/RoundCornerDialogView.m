//
//  RoundCornerDialogView.m
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "RoundCornerDialogView.h"

@implementation RoundCornerDialogView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)close:(id)sender {
  [self.superview removeFromSuperview];
}

- (void)dealloc {
  self.delegate = nil;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  self.bgImageView.image = [[UIImage imageNamed:@"appearence@2x"] resizableImageWithCapInsets:(UIEdgeInsetsMake(50, 8, 50, 8)) resizingMode:UIImageResizingModeStretch];
}


@end
