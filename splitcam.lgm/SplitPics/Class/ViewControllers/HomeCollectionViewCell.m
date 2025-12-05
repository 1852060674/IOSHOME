//
//  HomeCollectionViewCell.m
//  SplitPics
//
//  Created by spring on 2016/10/17.
//  Copyright © 2016年 ZBNetWork. All rights reserved.
//

#import "HomeCollectionViewCell.h"

@implementation HomeCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
  self.lockImageView.image = [UIImage imageNamed:@"lock"];
  self.lockImageView.hidden = YES;
    // Initialization code
}

@end
