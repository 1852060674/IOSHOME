//
//  LevelView.h
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum LEVEL_STATE {
    LEVEL_STATE_LOCKED = -1,
    LEVEL_STATE_OPEN = 0,
    LEVEL_STATE_PASSED = 1,
    LEVEL_STATE_PERFECT = 2
    };

@interface LevelView : UIView

@property (nonatomic, assign) int type;
@property (nonatomic, assign) int no;
@property (nonatomic, assign) int state;
@property (nonatomic, assign) int coloridx;

@property (nonatomic, strong) UIView* leftBorder;
@property (nonatomic, strong) UIView* rightBorder;
@property (nonatomic, strong) UIView* upBorder;
@property (nonatomic, strong) UIView* downBorder;
@property (nonatomic, strong) UIImageView* bkView;
@property (nonatomic, strong) UIImageView* perfectImage;
@property (nonatomic, strong) UIImageView* passedImage;
@property (nonatomic, strong) UIImageView* lockedImage;
@property (nonatomic, strong) UILabel* noLabel;

- (id)initWithFrame:(CGRect)frame theType:(int)theType theNo:(int)theNo theState:(int)theState color:(int)color;
- (void)updateDisplay;
- (void)tapEffect;

@end
