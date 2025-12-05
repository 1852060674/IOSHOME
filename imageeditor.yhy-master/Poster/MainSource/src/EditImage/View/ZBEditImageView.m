//
//  ZBEditImageView.m
//  Poster
//
//  Created by shen on 13-8-2.
//  Copyright (c) 2013年 ZBNetwork. All rights reserved.
//

#import "ZBEditImageView.h"
#import "ZBCommonDefine.h"

@implementation ZBEditImageView
{
    float _adHeight;
}

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _adHeight = 0;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.imageView setUserInteractionEnabled:YES];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setImageViewWithImage:(UIImage*)image
{
    CGSize _imageSize = image.size;
    CGRect _rect = self.frame;
    float _scale = 0;
    
    float _newWidth = _rect.size.width;
    float _newHeight = 0;
    
    _scale = _rect.size.width/_imageSize.width;
    if (_rect.size.height<_scale*_imageSize.height) {
        _scale = _rect.size.height/_imageSize.height;
        _newWidth = _imageSize.width*_scale;
        _newHeight = _imageSize.height*_scale;
    }
    else
    {
        _newHeight = _imageSize.height*_scale;
    }

    
    float _x = (self.frame.size.width-_newWidth)*0.5;
    float _y = (self.frame.size.height-_newHeight)*0.5;
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(_x, _y, _newWidth, _newHeight);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
