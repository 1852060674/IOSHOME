//
//  RoundCornerSettingView.h
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "RoundCornerDialogView.h"

@interface RoundCornerSettingView : RoundCornerDialogView<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *sepVertical;
@end
