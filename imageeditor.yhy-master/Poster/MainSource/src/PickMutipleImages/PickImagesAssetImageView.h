//
//  PickImagesAssetImageView.h
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-21.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol PickImagesAssetImageViewDelegate <NSObject>

@optional
- (void)returnASelectedAsset:(ALAsset*)asset withSelectedType:(BOOL)isSeleted;

@end

@interface PickImagesAssetImageView : UIView

@property (nonatomic,strong)ALAsset *asset;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic,assign)id<PickImagesAssetImageViewDelegate> delegate;

- (void)setImage;

@end
