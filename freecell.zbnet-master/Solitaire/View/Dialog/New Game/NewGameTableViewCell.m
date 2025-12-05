//
//  NewGameTableViewCell.m
//  Solitaire
//
//  Created by jerry on 2017/8/16.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "NewGameTableViewCell.h"

@implementation NewGameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  self.backgroundColor = [UIColor clearColor];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
