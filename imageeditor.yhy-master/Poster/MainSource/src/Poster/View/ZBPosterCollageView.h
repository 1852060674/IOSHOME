//
//  ZBPosterCollageView.h
//  Collage
//
//  Created by shen on 13-7-18.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBCommonDefine.h"

@interface ZBPosterCollageView : UIView

- (id)initWithFrame:(CGRect)frame andSelectedImages:(NSArray*)imagesArray;

- (BOOL)canChangeBackgroundImageWithPosterCollageChangeType:(PosterCollageChangeType)type;

- (void)changeBackgroundImageWithPosterCollageChangeType:(PosterCollageChangeType)type;

- (void)setSelectedImage:(UIImage*)image;

@end
