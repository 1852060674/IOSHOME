//
//  ZBSelectedThumbnailView.h
//  Collage
//
//  Created by shen on 13-6-27.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol ZBSelectedThumbnailViewDelegate <NSObject>

@optional

- (void)deleteImageViewFromSuperView:(id)sender;

@end

@interface ZBSelectedThumbnailView : UIView

@property (nonatomic, strong)UIImageView *imageView;
@property (nonatomic, assign)id<ZBSelectedThumbnailViewDelegate> delegate;
@property (nonatomic, strong)ALAsset *asset;
@property (nonatomic, strong)NSString *assetIdentifier;

@end
