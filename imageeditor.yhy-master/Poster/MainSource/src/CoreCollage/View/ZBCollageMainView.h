//
//  ZBCollageMainView.h
//  Collage
//
//  Created by shen on 13-6-24.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBCommonDefine.h"
#import "BHPresentTemplateView.h"
#import "BHFreeCollageView.h"
#import "ZBJoinCollageView.h"
#import "ZBPosterCollageView.h"

@protocol ZBCollageMainViewDelegate <NSObject>

@optional
- (void)goToHomeView;

- (void)openAlbumAnLibrary:(NSUInteger)sourceType  withRect:(CGRect)rect;

- (void)editImage:(UIImage*)image;

- (void)changeCollageType:(CollageType)type;

- (BOOL)canChangeTemplate:(NSInteger)index;
- (BOOL)canChangeBackground:(NSInteger)index;
- (BOOL)canAddSticker:(NSInteger)index;

@end

@interface ZBCollageMainView : UIView

@property (nonatomic, assign) PicImageTemplateType templateType;
@property (nonatomic, assign) id<ZBCollageMainViewDelegate> delegate;
@property (nonatomic, strong) BHPresentTemplateView *presentView;
@property (nonatomic, strong) BHFreeCollageView *freecollageView;
@property (nonatomic, strong) UIScrollView *joinScrollView;
@property (nonatomic, strong) ZBJoinCollageView *joinCollageView;
@property (nonatomic, strong) ZBPosterCollageView *posterCollageView;
@property (nonatomic, assign) CollageType currentCollageType;
@property (nonatomic, strong) UIButton *upgradeButton;

- (id)initWithFrame:(CGRect)frame withSelectedImgesArray:(NSArray*)imagesArray;

- (id)initWithFrame:(CGRect)frame withSelectedImgesArray:(NSArray*)imagesArray andCollageType:(CollageType)type;

- (void)setSelectedImage:(UIImage*)selectedImage;

- (void)turnGridAndFreeCollageViewAnimation:(NSUInteger)selectedIndex;

- (void)adjustViewHeightForAd:(BOOL)flag;

@end
