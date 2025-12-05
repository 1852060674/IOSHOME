//
//  PickImagesAssetCell.h
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-18.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBCommonDefine.h"
#import <AssetsLibrary/AssetsLibrary.h>

@protocol PickImagesAssetCellDelegate <NSObject>

@optional
- (void)handleAnAssetSeletedType:(ALAsset*)asset withSelectedType:(BOOL)isSeleted;

@end

@interface PickImagesAssetCell : UITableViewCell
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, assign)id<PickImagesAssetCellDelegate> delegate;

//- (id)initWithAsset:(NSArray*)assets;
- (void)refreshCellView;
@end
