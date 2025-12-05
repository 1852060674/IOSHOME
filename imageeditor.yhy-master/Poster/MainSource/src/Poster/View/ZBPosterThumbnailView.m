//
//  ZBPosterThumbnailView.m
//  Collage
//
//  Created by shen on 13-7-23.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBPosterThumbnailView.h"
#import "ImageUtil.h"
#import "ZBCommonDefine.h"
#import "ZBCommonMethod.h"
#import "AdUtility.h"
#import "GlobalSettingManger.h"

@interface ZBPosterThumbnailView()<UIGestureRecognizerDelegate>
{
    
}


@property (nonatomic, strong) UIImageView *checkmarkImageView;


@end
@implementation ZBPosterThumbnailView
@synthesize imageView = _imageView;
//@synthesize delegate;
@synthesize isSelected = _isSelected;
@synthesize thumbnailIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isSelected = NO;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.imageView setUserInteractionEnabled:YES];
        [self addSubview:self.imageView];
        
        UITapGestureRecognizer *_singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAPoster:)];
        [self.imageView addGestureRecognizer:_singleTap];
        
        float _x = 0;
        float _y = 0;
        _x = frame.size.width-35;
        _y = frame.size.height-35;
        
        self.checkmarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_x, _y, 35, 35)];
        self.checkmarkImageView.image = [ImageUtil loadResourceImage:@"overlay"];
        self.checkmarkImageView.hidden = YES;
		[self addSubview:self.checkmarkImageView];
    }
    return self;
}

- (void)selectAPoster:(UITapGestureRecognizer *)sender
{
    if (!_isSelected) {

        _isSelected = YES;
        self.checkmarkImageView.hidden = NO;
        NSUInteger _lastThumbnailIndex = [ZBCommonMethod getCurrentPosterType];
        [ZBCommonMethod setCurrentPosterType:self.thumbnailIndex];
        if (sender.numberOfTapsRequired == 1) {
            
            NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInteger:self.thumbnailIndex] ,@"PosterChangeType",
                                          [NSNumber numberWithInteger:_lastThumbnailIndex] ,@"LastPosterChangeType",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPosterChangeType object:_postInfoDic];
            
//            //回调
//            if (self.delegate && [self.delegate respondsToSelector:@selector(selectAPoster:)] ) {
//                [self.delegate selectAPoster:_lastThumbnailIndex];
//            }
        }
    }
}

- (void)clearSelectedStatus
{
    self.checkmarkImageView.hidden = YES;
    self.isSelected = NO;
}

- (void)setSelectedStatus
{
    self.checkmarkImageView.hidden = NO;
    self.isSelected = YES;
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
