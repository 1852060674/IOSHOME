//
//  YouWinTableViewCell.m
//  Solitaire
//
//  Created by jerry on 2017/8/16.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "YouWinTableViewCell.h"

@implementation YouWinTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
  self.backgroundColor = [UIColor clearColor];
  self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
