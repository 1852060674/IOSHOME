//
//  ZBJoinCollageView.h
//  Collage
//
//  Created by shen on 13-6-26.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZBJoinCollageViewDelegte <NSObject>

@optional
- (void)changeSuperViewFrame:(float)height;

- (void)openAlbum:(NSUInteger)sourceType withRect:(CGRect)rect;

- (void)editCurrentSelectedImage:(UIImage*)image;

@end

@interface ZBJoinCollageView : UIView

//@property (nonatomic, strong)NSMutableDictionary *selectedImagesDic;
@property (nonatomic, assign)id<ZBJoinCollageViewDelegte> delegate;
@property (nonatomic, strong)UIImageView *photoFrameImageView;

- (id)initWithFrame:(CGRect)frame withSelectedImages:(NSArray *)imagesArray;

- (void)addAnNewImage:(UIImage*)image;

- (void)setBackgroundColorOrImage:(UIColor *)backgroundColor;

//- (void)setPhotoFrame:(UIImage*)photoFrame;
- (void)setCurrentSelectedImage:(UIImage*)image;

@end
