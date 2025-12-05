//
//  SimpleImageCollectionViewCell.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/6/23.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "SimpleImageCollectionViewCell.h"
#import "Masonry.h"

@interface SimpleImageCollectionViewCell ()
@end

@implementation SimpleImageCollectionViewCell
{
    BOOL _viewSetup;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    return self;
}

-(void)setupViews
{
    if (!_viewSetup)
    {
        _titleLabel = [[UILabel alloc] init];
        _imageView = [[UIImageView alloc] init];
        _overlayImageView = [[UIImageView alloc] init];
        
        [self addSubview:_titleLabel];
        [self addSubview:_imageView];
        [self addSubview:_overlayImageView];
        
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
        
        _overlayImageView.contentMode = UIViewContentModeScaleAspectFit;
        _overlayImageView.clipsToBounds = YES;
        _overlayImageView.hidden = YES;
        
        _viewSetup = YES;
        
        if (_layoutMode==0) {
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.and.bottom.equalTo(self);
                make.height.equalTo(self.mas_height).multipliedBy(_titleRatio);
            }];
            
            UIEdgeInsets imageViewInset = [self.additionalDataSource imageViewEdgeInsetsForCell:self];
            
            [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).mas_offset(imageViewInset.top);
                make.bottom.equalTo(_titleLabel.mas_top).mas_offset(-imageViewInset.bottom);
                make.height.equalTo(_imageView.mas_width);
                make.centerX.equalTo(self.mas_centerX);
                
                make.width.lessThanOrEqualTo(self.mas_width).priorityLow();
            }];
            
            [_overlayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.top.equalTo(_imageView);
            }];
        }
        else if (_layoutMode == 1)
        {
            [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self);
                make.height.equalTo(_imageView.mas_width);
                make.left.right.equalTo(self);
            }];
            
            [_overlayImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.bottom.top.equalTo(_imageView);
            }];
            
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.and.bottom.equalTo(self);
                make.top.equalTo(_imageView.mas_bottom);
            }];
        }
        
        _RTImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _RTImageView.contentMode = UIViewContentModeScaleAspectFit;
//        _RTImageView.backgroundColor = [UIColor colorWithHexString:@"8f58cc"];
        _RTImageView.image = [UIImage imageNamed:@"lock_dot"];
        [self addSubview:_RTImageView];
        [_RTImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@12.0);
            make.top.equalTo(self).offset(2.0);
            make.right.equalTo(self).offset(-2.0);
        }];
        _RTImageView.hidden = YES;
    }
//    else
//    {
//        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.and.bottom.equalTo(self);
//            make.height.equalTo(self.mas_height).multipliedBy(_titleRatio);
//        }];
//    }
}

-(void)setShowRTView:(BOOL)showRTView
{
    _showRTView = showRTView;
    _RTImageView.hidden = !_showRTView;
}

-(void)setShowSelectedMode:(NSInteger)showSelectedMode
{
    _showSelectedMode = showSelectedMode;
    
    self.selected = self.selected;
}

-(void)setSelected:(BOOL)selected
{
    switch (_showSelectedMode) {
        case 0:
            self.overlayImageView.hidden = YES;
            break;
        case 1:
            self.overlayImageView.hidden = !selected;
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
        {
            self.imageView.image = [self.additionalDataSource iconForCell:self selected:selected];
            self.titleLabel.textColor = [self.additionalDataSource titleColorForCell:self selected:selected];
            break;
        }
        case 5:
        {
            UIColor *color = [self.additionalDataSource titleColorForCell:self selected:selected];
            self.titleLabel.textColor = color;
            self.imageView.tintColor = color;
            break;
        }
        case 6:
        {
            self.overlayImageView.hidden = !selected;
            self.titleLabel.textColor = [self.additionalDataSource titleColorForCell:self selected:selected];
            break;
        }
        default:
            break;
    }
    
    [super setSelected:selected];
}

@end
