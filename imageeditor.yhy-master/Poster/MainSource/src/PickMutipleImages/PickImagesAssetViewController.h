//
//  PickImagesAssetViewController.h
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-18.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZBCommonDefine.h"

@interface PickImagesAssetViewController : UIViewController
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

- (id)initWithAssetLibray:(ALAssetsGroup*)assetsGroup withType:(PickerImageFilterType)filterType;
@end
