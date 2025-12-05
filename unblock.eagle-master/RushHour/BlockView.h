//
//  BlockView.h
//  UnblockMe
//
//  Created by yysdsyl on 13-10-18.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockView : UIView

@property (assign, nonatomic) int seq;
@property (assign, nonatomic) int x;
@property (assign, nonatomic) int y;
@property (assign, nonatomic) BOOL hor;
@property (assign, nonatomic) int len;
@property (assign, nonatomic) BOOL type;

- (id)initWithFrame:(CGRect)frame seq:(int)SEQ x:(int)X y:(int)Y hor:(BOOL)HOR len:(int)LEN type:(BOOL)TYPE;

- (void)moveTopLeft:(int)flag;

@end
