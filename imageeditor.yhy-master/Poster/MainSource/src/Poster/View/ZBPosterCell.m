//
//  ZBPosterCell.m
//  Collage
//
//  Created by shen on 13-7-22.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBPosterCell.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBPosterThumbnailView.h"
#import "ZBCommonMethod.h"

@interface ZBPosterCell()
{
    float _x;
    float _y;
    float _w;
    float _h;
}

@property (nonatomic, assign)NSUInteger offset;

@end

@implementation ZBPosterCell

@synthesize imageView;
@synthesize offset;
//@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.offset = 0;
        
        if (IS_IPAD) {
            _y = 5;
            _w = 143;
            _h = 111*1.5;
        }
        else
        {
            _y = 5;
            _w = 82;
            _h = 111;
        }
        float _gap = 10;
        
        for (NSUInteger i=0; i<kImageViewCountsInPerLine; i++)
        {
            _x = _gap*(i+1)+_w*i;
            ZBPosterThumbnailView *_posterThumbnailView = [[ZBPosterThumbnailView alloc] initWithFrame:CGRectMake(_x, _y, _w, _h)];
            _posterThumbnailView.tag = kPosterThumbnailStartTag+i;
            _posterThumbnailView.hidden = YES;
            [self addSubview:_posterThumbnailView];
            
//            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uesrClicked:)];
//            singleTap.numberOfTouchesRequired = 1; //手指数
//            singleTap.numberOfTapsRequired = 1; //tap次数
//            [self.imageView addGestureRecognizer:singleTap];
//            [self.imageView setUserInteractionEnabled:YES];
        }
        
    }
    return self;
}

- (void)refreshCell:(NSDictionary *)imagesNameDic
{
    if (nil != imagesNameDic && imagesNameDic.count>0)
    {
        NSArray *_imagesArray = [imagesNameDic valueForKey:@"imagesArray"];
        self.offset = [[imagesNameDic valueForKey:@"offset"] integerValue];
        if (nil != _imagesArray && _imagesArray.count>0)
        {
            for (NSUInteger i=0; i<_imagesArray.count; i++)
            {
                ZBPosterThumbnailView *_posterThumbnailView = (ZBPosterThumbnailView*)[self viewWithTag:kPosterThumbnailStartTag+i];
                _posterThumbnailView.imageView.image = [ImageUtil loadResourceImage:[_imagesArray objectAtIndex:i]];
                _posterThumbnailView.hidden = NO;
                if ([ZBCommonMethod getCurrentPosterType] == self.offset+i) {
                    NSLog(@"%d",self.offset+i);
                    [_posterThumbnailView setSelectedStatus];
                }
                else
                {
                    [_posterThumbnailView clearSelectedStatus];
                }
                _posterThumbnailView.thumbnailIndex = offset+i;
            }
        }
        if (_imagesArray.count<kImageViewCountsInPerLine) {
            for (NSUInteger i=kImageViewCountsInPerLine-1; i>=kImageViewCountsInPerLine-_imagesArray.count; i--) {
                ZBPosterThumbnailView *_posterThumbnailView = (ZBPosterThumbnailView*)[self viewWithTag:kPosterThumbnailStartTag+i];
                _posterThumbnailView.hidden = YES;
            }
        }
    }
}

//#pragma mark ZBPosterThumbnailViewDelegate
//- (void)selectAPoster:(NSUInteger)lastPosterType
//{
//    //回调
//    if (self.delegate && [self.delegate respondsToSelector:@selector(selectAPoster:)] ) {
//        [self.delegate selectAPoster:lastPosterType];
//    }
//}

//- (void)uesrClicked:(UITapGestureRecognizer *)sender
//{
//    UIImageView *_imageView = (UIImageView*)[sender view];
//    if (sender.numberOfTapsRequired == 1) {
//        
//        //回调
////        if (self.delegate && [self.delegate respondsToSelector:@selector(returnASelectedAsset: withSelectedType:)] ) {
////            [self.delegate returnASelectedAsset:self.asset withSelectedType:_isSelected];
////        }
//        NSDictionary *_postInfoDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:_imageView.tag + self.offset- kPosterThumbnailStartTag] forKey:@"PosterChangeType"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kPosterChangeType object:_postInfoDic];
//
//    }
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
