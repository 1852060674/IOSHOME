//
//  ZBIrregularCollageScrollView.h
//  Collage
//
//  Created by shen on 13-7-7.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

//@protocol ZBIrregularCollageScrollViewDelegate <NSObject>
//
//@optional
//
//- (void)openAlbum:(NSUInteger)sourceType withRect:(CGRect)rect;
//
//- (void)editCurrentSelectedImage:(UIImage*)image;
//
//@end

@interface ZBIrregularCollageScrollView : UIScrollView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *originImage;
@property (nonatomic, assign) BOOL isSelected;
//@property (nonatomic, assign) id<ZBIrregularCollageScrollViewDelegate> delegate;

- (void)adjustImageViewFrame:(CGRect)rect;

@end
