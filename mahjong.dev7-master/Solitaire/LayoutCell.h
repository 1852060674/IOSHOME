//
//  LayoutCell.h
//  Mahjong
//
//  Created by yysdsyl on 14-11-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LayoutCell : UIView

@property (assign, nonatomic) BOOL locked;
@property (assign, nonatomic) int stars;
@property (assign, nonatomic) int layoutid;

- (id)initWithFrame:(CGRect)frame lock:(BOOL)lk stars:(int)st layoutid:(int)idx;
- (void)updateState;
- (void)unlockAnim;

@end
