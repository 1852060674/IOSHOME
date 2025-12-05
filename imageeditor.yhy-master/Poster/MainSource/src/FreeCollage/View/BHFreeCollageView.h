//
//  BHFreeCollageView.h
//  PicFrame
//
//  Created by shen on 13-6-24.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHPresentTemplateView.h"
#import "ZBCommonDefine.h"

@protocol BHFreeCollageViewDelegate <NSObject>

@optional

- (void)openAlbum:(NSUInteger)sourceType withRect:(CGRect)rect;

- (void)editCurrentSelectedImage:(UIImage*)image;

@end

@interface BHFreeCollageView : UIView

@property (nonatomic, strong)NSMutableDictionary *selectedImagesDic;
@property (nonatomic, assign) id<BHFreeCollageViewDelegate> delegate;
//@property (nonatomic, strong)UIImageView *currentSelectedImageView;

- (id)initWithFrame:(CGRect)frame withSelectedImages:(NSArray *)imagesArray;

- (void)createCanvas:(NSArray*)imagesArray;

//- (void)addAnNewImage:(UIImage*)image;

- (void)setBackgroundColorOrImage:(UIColor *)backgroundColor;

- (void)setBackgroundImage:(NSString*)imageName;

- (void)changedCornerValue:(float)value;

- (void)setCurrentSelectedImage:(UIImage*)image;

- (void)adjustTemplateType:(NSUInteger)imageCount withFreeCollageChangeType:(FreeCollageChangeType)type;

-(BOOL)canAdjustTemplateType:(NSUInteger)imageCount  withFreeCollageChangeType:(FreeCollageChangeType)type;
@end
