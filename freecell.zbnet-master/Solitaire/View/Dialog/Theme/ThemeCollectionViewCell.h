//
//  ThemeCollectionViewCell.h
//  Solitaire
//
//  Created by jerry on 2017/8/16.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconIV;
@property (weak, nonatomic) IBOutlet UIImageView *tickIV;
@property (weak, nonatomic) IBOutlet UIButton *deleteB;
@property (weak, nonatomic) IBOutlet UIView *dimView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconSpacing;

@end
