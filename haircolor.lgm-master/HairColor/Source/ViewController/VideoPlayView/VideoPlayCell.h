//
//  VideoPlayCell.h
//  CutMeIn
//
//  Created by ZB_Mac on 16/8/8.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerView;

@interface VideoPlayCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@end
