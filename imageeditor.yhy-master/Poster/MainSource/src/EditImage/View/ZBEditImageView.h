//
//  ZBEditImageView.h
//  Poster
//
//  Created by shen on 13-8-2.
//  Copyright (c) 2013年 ZBNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZBEditImageView : UIView

@property (nonatomic, strong) UIImageView *imageView;

- (void)setImageViewWithImage:(UIImage*)image;
@end
