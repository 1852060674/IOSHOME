//
//  ZBDeleteButton.m
//  Collage
//
//  Created by shen on 13-7-1.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBDeleteButton.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@implementation ZBDeleteButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kTransparentColor;
        UIImage *_closeImage = [ImageUtil loadResourceImage:@"close-iphone.png"];
        
        UIImageView *_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _closeImage.size.width, _closeImage.size.height)];
        _imageView.image = _closeImage;
        [self addSubview:_imageView];
        _imageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    }
    return self;
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
