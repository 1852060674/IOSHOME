//
//  PickImagesAssetView.h
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-18.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBCommonDefine.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface PickImagesAssetView : UIView
@property (nonatomic, assign) PickerImageFilterType filterType;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) UIScrollView *bottomScrollView;

- (id)initWithAssetsGroup:(ALAssetsGroup*)assetsGroup frame:(CGRect)rect;

- (void)addSelectedAssetsOnScrollview;
@end
