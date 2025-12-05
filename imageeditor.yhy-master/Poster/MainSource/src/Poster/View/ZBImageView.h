//
//  ZBImageView.h
//  Collage
//
//  Created by shen on 13-7-18.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZBImageView : UIView


@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *originImage;

- (void)showImageWidthPoints:(NSArray*)pointsArray;

@end
