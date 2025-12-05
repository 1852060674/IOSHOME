//
//  ZBIrregularView.h
//  Collage
//
//  Created by shen on 13-7-8.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZBIrregularView : UIView

@property (nonatomic, assign) NSUInteger selectedIndex;

- (id)initWithFrame:(CGRect)frame withImagesArray:(NSArray*)imagesArray;

- (void)setSelectedImage:(UIImage*)image;

@end
