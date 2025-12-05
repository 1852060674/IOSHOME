//
//  ZBPosterCollageScrollView.h
//  Collage
//
//  Created by shen on 13-7-18.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZBPosterCollageScrollView : UIScrollView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, assign) BOOL isSelected;

@end
