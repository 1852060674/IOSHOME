//
//  DismissibleView.m
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "DismissibleView.h"
@interface DismissibleView()
@property (nonatomic, strong) UIButton * button;
@end

@implementation DismissibleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    self.button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.button.frame = self.bounds;
    [self addSubview:self.button];
    [self.button addTarget:self action:@selector(dismiss) forControlEvents:(UIControlEventTouchUpInside)];
  }
  return self;
}

- (void)dismiss {
  if (!_disableTapToDismiss) {
    [self removeFromSuperview];
  }
}


- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  self.contentSize = self.contentSize;
  self.button.frame = self.bounds;
}



- (void)setContentSize:(CGSize)contentSize {
  _contentSize = contentSize;
  if (!_useAutoL) {
    self.contentView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    self.contentView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  }
}

- (void)addContentView:(UIView *)view {
  [self addSubview:view];
  _contentView = view;
  self.contentSize = self.contentSize;
}


@end
