//
//  ZXSwitch.m
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ZXSwitch.h"
@implementation ZXSwitch

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
    [self commonInit];
  }
  return self;
}

- (void)commonInit {
  [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchSwitch)]];
  self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
  [self addSubview:self.imageView];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
  self = [super initWithCoder:coder];
  if (self) {
    [self commonInit];
  }
  return self;
}


- (void)touchSwitch {
  self.isOn = !_isOn;
  [self sendActionsForControlEvents:(UIControlEventValueChanged)];
}



- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  self.imageView.frame = self.bounds;
}

- (void)setIsOn:(BOOL)isOn {
  _isOn = isOn;
  self.imageView.image = isOn?(self.onImage):(self.offImage);
}

- (void)setOnImage:(UIImage *)onImage {
  _onImage = onImage;
  if (self.isOn) {
    self.imageView.image = onImage;
  }
}


- (void)setOffImage:(UIImage *)offImage {
  _offImage = offImage;
  if (!self.isOn) {
    self.imageView.image = offImage;
  }
}

@end
