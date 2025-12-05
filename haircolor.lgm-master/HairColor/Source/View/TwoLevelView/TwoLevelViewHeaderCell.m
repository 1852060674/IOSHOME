//
//  TwoLevelViewHeaderCell.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/2.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "TwoLevelViewHeaderCell.h"
#import "Masonry.h"

@implementation TwoLevelViewHeaderCell
-(TwoLevelViewHeaderCell *)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _lockImageView = [[UIImageView alloc] init];
        _sepView = [[UIImageView alloc] init];

        [self addSubview:_imageView];
        [self addSubview:_lockImageView];
        [self addSubview:_sepView];
        
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;

        _lockImageView.contentMode = UIViewContentModeScaleAspectFill;
        _lockImageView.clipsToBounds = YES;

        _sepView.contentMode = UIViewContentModeScaleAspectFill;
        _sepView.clipsToBounds = YES;
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.height.equalTo(_imageView.mas_width);
            make.centerX.equalTo(self.mas_centerX);
            
            make.width.lessThanOrEqualTo(self.mas_width).priorityLow();
            make.height.lessThanOrEqualTo(self.mas_height).priorityLow();
        }];
        
        [_lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_imageView);
        }];
        
        [_sepView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self);
            make.height.equalTo(self).multipliedBy(0.65);
            make.width.equalTo(@1);
        }];
        _sepView.image = [UIImage imageNamed:@"cut_sep"];
    }
    return self;
}

@end
