//
//  HomeViewController.h
//  SplitPics
//
//  Created by tangtaoyu on 15-3-4.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FakeLanchWindow;

@interface HomeViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView * collectionView;
@property FakeLanchWindow *fakeLanchWindow;

@end
