//
//  MGCell.h
//  FunFace
//
//  Created by tangtaoyu on 15-2-5.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *indexlabel;
@property (nonatomic, assign) NSInteger index;

- (void)selectedBorder:(BOOL)isSelected;

@end
