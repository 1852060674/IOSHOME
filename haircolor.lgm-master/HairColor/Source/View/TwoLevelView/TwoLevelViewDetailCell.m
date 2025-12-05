//
//  TwoLevelViewDetailCell.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/2.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "TwoLevelViewDetailCell.h"
#import "Masonry.h"

@interface TwoLevelViewDetailCell ()

@end

@implementation TwoLevelViewDetailCell
-(TwoLevelViewDetailCell *)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _labelView = [[UILabel alloc] init];
        _imageView = [[UIImageView alloc] init];
        _lockImageView = [[UIImageView alloc] init];
        
        [self addSubview:_labelView];
        [self addSubview:_imageView];
        [self addSubview:_lockImageView];
        
        _labelView.textAlignment = NSTextAlignmentCenter;
        _labelView.textColor = [UIColor whiteColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _lockImageView.contentMode = UIViewContentModeScaleAspectFill;
        _lockImageView.clipsToBounds = YES;
        
        [_labelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.bottom.equalTo(self);
            make.height.equalTo(self.mas_height).multipliedBy(_titleRatio);
        }];
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.bottom.equalTo(_labelView.mas_top);
            make.height.equalTo(_imageView.mas_width);
            make.centerX.equalTo(self.mas_centerX);
            
            make.width.lessThanOrEqualTo(self.mas_width).priorityLow();
        }];
        
        [_lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@12.0);
            make.top.equalTo(self).offset(2.0);
            make.right.equalTo(self).offset(-2.0);
        }];
    }
    return self;
}

-(void)setTitleRatio:(CGFloat)titleRatio
{
    _titleRatio = titleRatio;
    
    [_labelView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.equalTo(self);
        make.height.equalTo(self.mas_height).multipliedBy(_titleRatio);
    }];
    
    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.bottom.equalTo(_labelView.mas_top);
        make.height.equalTo(_imageView.mas_width);
        make.centerX.equalTo(self.mas_centerX);
        
        make.width.lessThanOrEqualTo(self.mas_width).priorityLow();
    }];
    
    [self setNeedsLayout];
}

-(void)setSelected:(BOOL)selected
{
    if (selected) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_bg_h"]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundView = imageView;
    }
    else
    {
        self.backgroundView = nil;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _labelView.font = [UIFont systemFontOfSize:CGRectGetHeight(_labelView.bounds)*0.8];
}
@end
