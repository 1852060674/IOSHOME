//
//  RoundCornerThemeView.h
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "RoundCornerDialogView.h"

@interface RoundCornerThemeView : RoundCornerDialogView<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *leftB;
@property (weak, nonatomic) IBOutlet UIButton *middleB;
@property (weak, nonatomic) IBOutlet UIButton *rightB;
@property (nonatomic, strong) NSMutableString * type;
@property (weak, nonatomic) IBOutlet UIButton *cancelB;
@property (nonatomic, assign) BOOL isRemovingCustom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endDeletionButtonTrailing;
@end
