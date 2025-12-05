//
//  SettingTableViewCell.m
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "SettingCollectionViewCell.h"
#import "ConfirmDialog.h"
#import "DismissibleView.h"
#import "Masonry.h"
#import "Config.h"
@implementation SettingCollectionViewCell

- (void)awakeFromNib {
  [super awakeFromNib];

  self.backgroundColor = [UIColor clearColor];
  self.clicker.onImage = [UIImage imageNamed:@"switch_on"];
  self.clicker.offImage = [UIImage imageNamed:@"switch_off"];


  NSUserDefaults *usr = [NSUserDefaults standardUserDefaults];
  NSInteger n = [[usr objectForKey:@"spider_level"]integerValue] +100;
  self.segLeftB.selected = (n == _segLeftB.tag);
  self.segMiddleB.selected = (n == _segMiddleB.tag);
  self.segRightB.selected = (n == _segRightB.tag);

  [self.segLeftB setTitle:LocalizedGameStr2(pref_level_titles1) forState:(UIControlStateNormal)];
  [self.segMiddleB setTitle:LocalizedGameStr2(pref_level_titles2) forState:(UIControlStateNormal)];
  [self.segRightB setTitle:LocalizedGameStr2(pref_level_titles3) forState:(UIControlStateNormal)];


    // Initialization code
}

- (void)prepareForReuse {
  [super prepareForReuse];
  self.valueL.text = nil;
}


- (void)unselectAll {
  self.segLeftB.selected = NO;
  self.segMiddleB.selected = NO;
  self.segRightB.selected = NO;
}




- (IBAction)changeSuit:(UIButton *)sender {
  [self unselectAll];
  sender.selected = YES;

  UIButton *btn = (UIButton *)sender;
  int level = (int)btn.tag;
  NSUserDefaults *usr = [NSUserDefaults standardUserDefaults];
  int n = (int)[[usr objectForKey:@"spider_level"]integerValue] +100;
  if(n == level)
  {
    return;
  }else
  {

    
  }
  [usr setInteger:level-100 forKey:@"spider_level"];
  [usr synchronize];
  [self addConfirmDialog];
}


- (void)addConfirmDialog {
  ConfirmDialog * d = [[NSBundle mainBundle] loadNibNamed:@"ConfirmDialog" owner:nil options:nil].firstObject;
  d.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds)*0.94, 100);
  d.confirmStr = LocalizedGameStr2(ok);
  d.titleStr = LocalizedGameStr2(mode_message);
  d.titleL.text = d.titleStr;
  d.confirmL.text = d.confirmStr;
  DismissibleView * v = [[DismissibleView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  [self.window.rootViewController.view addSubview:v];
  [v mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];
  v.useAutoL = YES;
  [v addContentView:d];
  __weak typeof(v) weakDismiss = v;

  [d mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(0);
    make.centerY.mas_equalTo(0);
    make.width.mas_equalTo(weakDismiss.mas_width).multipliedBy(0.94);
    make.height.mas_equalTo(100);
  }];
  
}
@end
