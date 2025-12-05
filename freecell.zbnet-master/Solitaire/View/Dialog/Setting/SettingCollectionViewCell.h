//
//  SettingTableViewCell.h
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXSwitch.h"
@interface SettingCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet ZXSwitch *clicker;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIImageView *sep;
@property (weak, nonatomic) IBOutlet UIButton *segLeftB;
@property (weak, nonatomic) IBOutlet UIButton *segMiddleB;
@property (weak, nonatomic) IBOutlet UIButton *segRightB;

@end
