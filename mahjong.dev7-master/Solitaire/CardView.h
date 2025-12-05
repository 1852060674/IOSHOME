//
//  CardView.h 
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ASPECT_RATIO_X 0.814
#define ASPECT_RATIO_Y 1.228
#define NUM_TILE 42

@class Card; 

@interface CardView : UIView

@property (strong, nonatomic) UIImage *cardImage;
@property (strong, nonatomic) Card *card;
@property (assign, nonatomic) BOOL flyflag;

- (id)initWithFrame:(CGRect)frame andCard:(Card *)card;
- (UIImage*)getImageFromTileset:(Card*)card;

- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;

+ (void)setTilesetImage:(NSString*)imageName;
+ (void)initRes:(int)themeid;

- (void)setNewCard:(Card*)card;
- (void)updateTheme:(Card*)card;
- (void)pauseChange;

- (void)bounce;
- (void)leftright;

@end
