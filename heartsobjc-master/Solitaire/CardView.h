//
//  CardView.h
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"

#define ASPECT_RATIO_X 0.71591
#define ASPECT_RATIO_Y 1.396825

@class Card;

@interface CardView : UIView

@property (strong, nonatomic) UIImage *cardImage;
@property (strong, nonatomic) Card *card;
@property (assign, nonatomic) CGAffineTransform oriTtansform;
@property (assign, nonatomic) BOOL rotatedFlag;

- (id)initWithFrame:(CGRect)frame andCard:(Card *)card;
- (id)initWithFrame:(CGRect)frame specialCard:(NSInteger)type;

- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;

+ (UIImage *)backImage;
+ (UIImage *)emptyImage;
+ (UIImage *)stockImage;
+ (UIImage *)foundationImage;
+ (UIImage *)hintImage;
+ (void)setBackImage:(NSString*)imageName;
+ (void)setEmptyImage:(NSString*)imageName;
+ (void)setStockImage:(NSString*)imageName;
+ (void)setFoundationImage:(NSString*)imageName;
+ (CGFloat)hintWidth;

- (void)setNewCard:(Card*)card;
- (void)updateClassic:(Card*)card;

- (void)rotateAngle:(CGFloat)angle animation:(BOOL)animation;
- (void)scaleRate:(CGFloat)rate;
- (void)rotateScale:(CGFloat)angle animation:(BOOL)animation rate:(CGFloat)rate;

@end
