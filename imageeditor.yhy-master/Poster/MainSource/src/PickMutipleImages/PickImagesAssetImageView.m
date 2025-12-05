//
//  PickImagesAssetImageView.m
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-21.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import "PickImagesAssetImageView.h"
#import "ZBCommonDefine.h"

#define kImageViewTag   101
#define kOverlayImageViewTag 201

@interface PickImagesAssetImageView()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation PickImagesAssetImageView

@synthesize asset = _asset;
@synthesize imageView = _imageView;
@synthesize isSelected = _isSelected;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kAssetEdgeLength, kAssetEdgeLength)];
        _imageView.backgroundColor = [UIColor yellowColor];
        _imageView.tag = kImageViewTag;
        [self addSubview:_imageView];        
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uesrClicked:)];
        singleTap.numberOfTouchesRequired = 1; //手指数
        singleTap.numberOfTapsRequired = 1; //tap次数
        [_imageView addGestureRecognizer:singleTap];
        [_imageView setUserInteractionEnabled:YES];        
        
        _isSelected = NO;
    }
    return self;
}

- (void)dealloc
{

}

- (void)setImage
{
    _imageView.image = [UIImage imageWithCGImage:self.asset.thumbnail];
}

- (void)uesrClicked:(UITapGestureRecognizer *)sender
{
    if (sender.numberOfTapsRequired == 1) {
        
        //回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(returnASelectedAsset: withSelectedType:)] ) {
            [self.delegate returnASelectedAsset:self.asset withSelectedType:_isSelected];
        }
    }
}

@end
