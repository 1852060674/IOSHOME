//
//  BHPresentTemplateView.h
//  PicFrame
//
//  Created by shen Lv on 13-6-3.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBCommonDefine.h"

@protocol BHPresentTemplateViewDelegate <NSObject>

@optional
- (void)openAlbum:(NSUInteger)sourceType withRect:(CGRect)rect;

- (void)editCurrentSelectedImage:(UIImage*)image;

- (BOOL)canChangeBackground:(NSInteger) index;

@end

@interface BHPresentTemplateView : UIView

@property (nonatomic, assign)id<BHPresentTemplateViewDelegate> delegate;
@property (nonatomic, strong)UIImage *selectedImage;
@property (nonatomic, strong)UIImageView *photoFrame;
@property (nonatomic, strong)NSMutableDictionary *selectedImagesDic;

- (id)initWithFrame:(CGRect)frame withSelectedImages:(NSArray*)imagesArray;

- (void)setSelectedImage:(UIImage *)selectedImage;

//根据选择的ascpect，调整模板里面的布局
- (void)adjustFrameSize:(float)widthScale withHeight:(float)heightScale;

//根据每张图片的位置，展现模板
- (void)presentTemplate;

//把历史选择的图片在新选择的模板里面重新展现
- (void)presentSelectedImages;

- (void)changedBorderOrCornerValue:(float)value withChangedType:(SliderChangeType)type;

- (void)setBackgroundImage:(NSString*)imageName;

//用户重新选择模板后，调整图片显示
- (void)adjustTemplate:(NSUInteger)templateIndex;

- (void)showIrregularTemplate:(NSUInteger)templateIndex;

- (void)setTemplateBackgroundColor:(UIColor*)color;

@end
