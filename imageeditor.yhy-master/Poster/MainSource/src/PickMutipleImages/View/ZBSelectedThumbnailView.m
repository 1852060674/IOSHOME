//
//  ZBSelectedThumbnailView.m
//  Collage
//
//  Created by shen on 13-6-27.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBSelectedThumbnailView.h"
#import "ImageUtil.h"
#import "ZBCommonDefine.h"

@interface ZBSelectedThumbnailView()<UIGestureRecognizerDelegate>
{
    UIButton *_deleteButton;
}

@end

@implementation ZBSelectedThumbnailView

@synthesize imageView = _imageView;
@synthesize delegate;
@synthesize asset;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-5, self.frame.size.height-5)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.imageView setUserInteractionEnabled:YES];
        [self addSubview:self.imageView];
        
        UITapGestureRecognizer *_singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteSelectedImage:)];
        [self.imageView addGestureRecognizer:_singleTap];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (IS_IPAD) {
            _deleteButton.frame = CGRectMake(-15, -15, 30, 30);
        }
        else
            _deleteButton.frame = CGRectMake(-5, -5, 20, 20);
        [_deleteButton setImage:[ImageUtil loadResourceImage:@"close-iphone"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteSelectedImage:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
    }
    return self;
}

- (void)deleteSelectedImage:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteImageViewFromSuperView:)]) {
        [self.delegate deleteImageViewFromSuperView:self];
    }
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
