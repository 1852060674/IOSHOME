//
//  CharView.h
//  WordSearch
//
//  Created by apple on 13-8-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CharView : UIView

@property (assign, nonatomic) int row;
@property (assign, nonatomic) int col;
@property (assign, nonatomic) char c;

- (id)initWithFrame:(CGRect)frame theChar:(char)theChar row:(int)row col:(int)col ;

- (void)bounce;

@end
