//
//  PickImagesView.h
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-17.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZBCommonDefine.h"

@protocol PickImagesViewDelegate <NSObject>
@optional

- (void)goToImagesStitch:(ALAssetsGroup*)assetGroup withType:(PickerImageFilterType)filterType;
- (void)gotoAlbumGroupAtIndex:(NSInteger)groupIndex;
@end

@interface PickImagesView : UIView
@property (nonatomic, assign)id<PickImagesViewDelegate> delegate;
@property (nonatomic, strong) UITableView *albumTableView;

- (void)getAssetsFromAlbum:(BOOL)isReload;

@end
