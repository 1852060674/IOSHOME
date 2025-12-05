//
//  ShareDemoView.m
//  CutMeIn
//
//  Created by ZB_Mac on 16/7/20.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ShareDemoView.h"
#import "Masonry.h"
#import "UIColor+Hex.h"

@interface ShareDemoView ()
@end

@implementation ShareDemoView

-(ShareDemoView *)initWithFrame:(CGRect)frame andImage:(UIImage *)image;
{
    self = [super initWithFrame:frame];
    
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(self);
        }];
        
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.layer.borderColor = [UIColor colorWithHexString:@"8c58cc"].CGColor;
        _imageView.layer.borderWidth = 1.0;
        _imageView.image = image;
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.layer.cornerRadius = CGRectGetHeight(_imageView.frame)*0.5;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
