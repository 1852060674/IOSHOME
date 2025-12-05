//
//  CardView.h 
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ASPECT_RATIO_X (142.0f/215.0f)
#define ASPECT_RATIO_Y (215.0f/142.0f)

@class Card; 

@interface CardView : UIView

@property (strong, nonatomic) UIImage *cardImage;
@property (strong, nonatomic) Card *card;

- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;

- (id)initWithFrame:(CGRect)frame andCard:(Card *)card;
- (id)initWithFrame:(CGRect)frame specialCard:(NSInteger)type;

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

+ (void)setNewBackImage:(int)idx filepath:(NSString *)path;
+ (void)setNewBackImage:(int)idx image:(UIImage *)fileimage;

- (void)setNewCard:(Card*)card;
- (void)updateClassic:(Card*)card;
- (void)filpCard:(BOOL)show delay:(CGFloat)delay  duration:(CGFloat)duration leftToRight:(BOOL)leftToRight  ;
@end
