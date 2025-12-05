//
//  PickImagesAssetCell.m
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-18.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import "PickImagesAssetCell.h"
#import "PickImagesAssetImageView.h"

#define kImageViewTagStart   101
#define kOverlayImageViewTagStart 201

@interface PickImagesAssetCell()<PickImagesAssetImageViewDelegate>



@end

@implementation PickImagesAssetCell
@synthesize margin = _margin;
@synthesize assets = _assets;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        for (NSInteger i=0; i<kCountOfImagesPerLine; i++)
        {
            PickImagesAssetImageView *_assetImageView = [[PickImagesAssetImageView alloc] initWithFrame:CGRectMake(kMargin*(i+1)+kAssetEdgeLength*i, 2, kAssetEdgeLength, kAssetEdgeLength)];
            _assetImageView.tag = kImageViewTagStart+i;
            _assetImageView.hidden = YES;
            _assetImageView.delegate = self;
            [self addSubview:_assetImageView];
        }
    }
    return self;
}

- (void)refreshCellView
{
//    if (nil != self.assets) {
//        for (NSInteger i=0; i<kCountOfImagesPerLine; i++)
//        {
//            UIImageView *assetView = (UIImageView *)[self viewWithTag:(kImageViewTagStart + i)];
//            UIImageView *overlayImageView = (UIImageView *)[self viewWithTag:(kOverlayImageViewTagStart + i)];
//            
//            if(i < self.assets.count) {
//                assetView.hidden = NO;
//                overlayImageView.hidden = NO;
//                //设置图片
////                assetView.asset = [self.assets objectAtIndex:i];
//                ALAsset *_anAsset = (ALAsset*)[self.assets objectAtIndex:i];
//                assetView.image = [UIImage imageWithCGImage:_anAsset.thumbnail];
//            } else {
//                assetView.hidden = YES;
//                overlayImageView.hidden = YES;
//            }
//        }
//    }
    if (nil != self.assets) {
        for (NSInteger i=0; i<kCountOfImagesPerLine; i++)
        {
            PickImagesAssetImageView *assetView = (PickImagesAssetImageView *)[self viewWithTag:(kImageViewTagStart + i)];
            
            if(i < self.assets.count) {
                assetView.hidden = NO;
                //设置图片
                ALAsset *_anAsset = (ALAsset*)[self.assets objectAtIndex:i];
                assetView.asset = _anAsset;
                [assetView setImage];
            } else {
                assetView.hidden = YES;
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -- PickImagesAssetImageViewDelegate
- (void)returnASelectedAsset:(ALAsset *)asset withSelectedType:(BOOL)isSeleted
{
    if (nil != asset) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(handleAnAssetSeletedType:withSelectedType:)])
        {
            [self.delegate handleAnAssetSeletedType:asset withSelectedType:isSeleted];
        }
    }
}

@end
