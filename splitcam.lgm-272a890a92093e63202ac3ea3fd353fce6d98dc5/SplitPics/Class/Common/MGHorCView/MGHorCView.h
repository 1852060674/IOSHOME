//
//  MGHorCView.h
//  FunFace
//
//  Created by tangtaoyu on 15-2-5.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MGHorCViewDelegate;
@protocol MGHorCViewDataSource;

@interface MGHorCView : UIView<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *myCollection;
@property (nonatomic, weak) id<MGHorCViewDelegate> delegate;
@property (nonatomic, weak) id<MGHorCViewDataSource> dataSource;

@property (nonatomic, assign) NSInteger selectedPictureIdx;
@property (nonatomic, assign) NSInteger selectedEffectIdx;

@property (nonatomic, assign) BOOL isPaid;

@property (assign,nonatomic) NSInteger nums;
- (void)cellReload;
- (void)hideSelf;
- (void)showSelf;
- (void)unlockLocks;

- (void)setDefaultDataWith:(NSInteger)nums;
@end


@protocol MGHorCViewDelegate <NSObject>
@optional

- (void)mgHorCViewdidSelectItemAtIndex:(NSInteger)index;
- (BOOL)selectUpgrade:(NSInteger)type;
- (void)mghorCViewHide;
@end

@protocol MGHorCViewDataSource

@required

- (NSInteger)numberOfItemsInMGHorCVIew:(MGHorCView *)view;
- (UIImage*)imageInMGHorCView:(MGHorCView*)view AtIndex:(NSInteger)index;
@end;