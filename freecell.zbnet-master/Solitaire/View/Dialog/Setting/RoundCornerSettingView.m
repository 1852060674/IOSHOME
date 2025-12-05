//
//  RoundCornerSettingView.m
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "RoundCornerSettingView.h"
#import "ViewController.h"
#import "SettingCollectionViewCell.h"


//#define ViewController GameViewController

#define CON_ANIMATION

typedef enum : NSUInteger {
  SettingSep1,
  SettingStockPosition,
  SettingFreecellOnTop,
  SettingSound,
  SettingShowTime,
  SettingRotation,
  SettingTapAction,
#ifdef CON_ANIMATION
  SettingAnimation,
#endif
  SettingEnablingHint,
  SettingSep2,
  SettingHelp,
} SettingType;
@implementation RoundCornerSettingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
  [super awakeFromNib];
  self.titleLabel.text = LocalizedGameStr2(setting_title);
  [self.closeButton setTitle:LocalizedGameStr(ok) forState:(UIControlStateNormal)];
  [self.collectionView registerNib:[UINib nibWithNibName:@"SettingTableViewSwitchCell" bundle:nil] forCellWithReuseIdentifier:@"switch"];
  [self.collectionView registerNib:[UINib nibWithNibName:@"SettingTableViewDiscloseCell" bundle:nil] forCellWithReuseIdentifier:@"disclose"];
  [self.collectionView registerNib:[UINib nibWithNibName:@"SettingTableViewSegCell" bundle:nil] forCellWithReuseIdentifier:@"seg"];
  [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"def"];
}

- (ViewController *)gameVC {
  ViewController * vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
;
  if (![vc isKindOfClass:[ViewController class]]) {
    return nil;
  }
  return vc;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return SettingHelp+1;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath bounds:(CGRect)bounds isPortrait:(BOOL)portrait{
  if (portrait) {
    CGFloat scale = (IS_IPAD?1.5:1);
    if (indexPath.row == SettingSep1 || indexPath.row == SettingSep2) {
      return 6*scale;
    }
    return 36*scale;
  } else {
    CGFloat hh = (CGRectGetHeight(bounds)/5);
    if (indexPath.row == SettingSep1 || indexPath.row == SettingSep2) {
      return 0;
    } else {

    }
    return hh;
  }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  CGRect rect = self.contentView.bounds;
  CGFloat w = 0;
  CGFloat height = [self heightForItemAtIndexPath:indexPath bounds:rect isPortrait:self.isp];
  if (self.isp) {
    w = CGRectGetWidth(rect);
  } else {
    w = CGRectGetWidth(rect)/2;
  }
  return CGSizeMake(w, height);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

  SettingType type = indexPath.item;
  if (type == SettingSep1 || type == SettingSep2) {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"def" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
  }
  SettingCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:(type < (SettingSep2+1))?(@"switch"):(@"disclose") forIndexPath:indexPath];
  cell.clicker.onImage = [UIImage imageNamed:@"switch_on"];
  cell.clicker.offImage = [UIImage imageNamed:@"switch_off"];
  cell.nameL.textColor = [UIColor whiteColor];
  cell.clicker.userInteractionEnabled = YES;
  ViewController * vc = [self gameVC];
  switch (type) {

    case SettingStockPosition: {
      cell.nameL.text =  LocalizedGameStr(freecell_pos);
      [cell.clicker setOnImage:[UIImage imageNamed:@"99right.png"]];
      [cell.clicker setOffImage:[UIImage imageNamed:@"99left.png"]];
      cell.clicker.isOn = vc.gameView.stockOnRight;
      [cell.clicker addTarget:self action:@selector(switchstockOnRight:) forControlEvents:UIControlEventValueChanged];
    }
      break;

    case SettingFreecellOnTop: {
      cell.nameL.text =  LocalizedGameStr(freecell_on_top);
      if (self.isp) {
        cell.nameL.textColor = [UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1];
        cell.clicker.userInteractionEnabled = NO;
        cell.clicker.isOn = YES;
      } else {
        cell.clicker.isOn = vc.gameView.freecellOnTop;
      }
      [cell.clicker addTarget:self action:@selector(switchFreecellOnTop:) forControlEvents:UIControlEventValueChanged];
    }
      break;

    case SettingSound: {
      cell.nameL.text =  LocalizedGameStr2(setting_sound);
      cell.clicker.isOn = vc.gameView.sound;
      [cell.clicker addTarget:self action:@selector(switchSound:) forControlEvents:UIControlEventValueChanged];
    }
      break;

    case SettingShowTime: {
      cell.nameL.text = LocalizedGameStr2(setting_times);
      cell.clicker.isOn = !(vc.gameView.timeLabel.hidden);
      [cell.clicker addTarget:self action:@selector(switchTime:) forControlEvents:UIControlEventValueChanged];
    }
      break;

    case SettingRotation: {
      cell.nameL.text = LocalizedGameStr2(setting_orientation);
      cell.clicker.isOn = ![[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
      [cell.clicker addTarget:self action:@selector(switchOrientation:) forControlEvents:UIControlEventValueChanged];
    }
      break;

    case SettingEnablingHint: {
      cell.nameL.text = LocalizedGameStr2(setting_hints);
      cell.clicker.isOn = vc.autohintEnabled;
      [cell.clicker addTarget:self action:@selector(switchHints:) forControlEvents:UIControlEventValueChanged];
    }
      break;

    case SettingTapAction: {
      cell.nameL.text = LocalizedGameStr2(setting_tapmove);
      cell.clicker.isOn = vc.gameView.autoOn;
      [cell.clicker addTarget:self action:@selector(switchTapmove:) forControlEvents:UIControlEventValueChanged];
    }
      break;

#ifdef CON_ANIMATION

    case SettingAnimation: {
      cell.nameL.text = LocalizedGameStr2(congratulationsAnimation);
      cell.clicker.isOn = [[NSUserDefaults standardUserDefaults] boolForKey:win_animate_key];
      [cell.clicker addTarget:self action:@selector(switchAnimation:) forControlEvents:UIControlEventValueChanged];

    }
      break;

#endif
      
//    case SettingStat: {
//      cell.sep.hidden = NO;
//      cell.nameL.text = LocalizedGameStr(statistics);
//
//    }
//      break;

    case SettingHelp: {
      cell.sep.hidden = !self.isp;
      cell.nameL.text = LocalizedGameStr2(help_rules);
    }
      break;



    default:
      break;
  }
  return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  SettingType type = indexPath.row;
  if (type >= (SettingSep2+1)) {
    switch (type) {
//      case SettingStat: {
//        if ([self.delegate respondsToSelector:@selector(showStatView)]) {
//          [self.delegate showStatView];
//        }
//      }
//        break;

      case SettingHelp: {
        if ([self.delegate respondsToSelector:@selector(showRuleView)]) {
          [self.delegate showRuleView];
        }
      }
        break;

      default:
        break;
    }
  }

}




- (void)switchAnimation:(ZXSwitch *)sw {
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setBool:sw.isOn forKey:win_animate_key];
  [settings synchronize];
}

- (void) switchHints:(id)sender
{
  ViewController * vc = [self gameVC];

  ZXSwitch * sw = (ZXSwitch *)sender;

  vc.autohintEnabled = sw.isOn;
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setBool:sw.isOn forKey:@"hints"];
  [settings synchronize];
}

- (void)switchTapmove:(id)sender
{
  ViewController * vc = [self gameVC];

  ZXSwitch * sw = (ZXSwitch *)sender;
  vc.gameView.autoOn = sw.isOn;
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setBool:sw.isOn forKey:@"tapmove"];
  [settings synchronize];
}



- (void) switchTime:(id)sender
{
  ViewController * vc = [self gameVC];

  ZXSwitch * sw = (ZXSwitch *)sender;
  vc.gameView.timeLabel.hidden = !sw.isOn;
  vc.gameView.movesLabel.hidden = !sw.isOn;
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setBool:sw.isOn forKey:@"tandm"];
  [settings synchronize];
}

- (void) switchSound:(id)sender
{
  ViewController * vc = [self gameVC];
  ZXSwitch * sc = (ZXSwitch *)sender;
  vc.gameView.sound = sc.isOn;
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setBool:sc.isOn forKey:@"sound"];
  [settings synchronize];
}

- (void)switchOrientation:(id)sender
{
  ZXSwitch * sw = (ZXSwitch *)sender;
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setBool:!sw.isOn forKey:@"orientation"];
  int ori2 = [[UIApplication sharedApplication] statusBarOrientation];
  if (sw.isOn) [settings setInteger:ori2 forKey:@"currentori"];
  [settings synchronize];
}


- (void)prepareForPortrait:(NSNumber *)ispV {
  BOOL isp = [ispV boolValue];
  self.isp = isp;
  self.sepVertical.hidden = isp;
  ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).scrollDirection = isp?UICollectionViewScrollDirectionVertical:UICollectionViewScrollDirectionHorizontal;
  self.closeButtonCenterX.constant = isp?0:(CGRectGetWidth(self.bounds)/2 - (CGRectGetWidth(self.closeButton.bounds)/2+ 8+8));
  [self.collectionView reloadData];
}

- (void)switchstockOnRight:(id)sender {
  ViewController * vc = [self gameVC];

  ZXSwitch * sw = (ZXSwitch *)sender;
  vc.gameView.stockOnRight = sw.isOn;
  [UIView performWithoutAnimation:^{
    [vc.gameView computeBottomCardLayout];
    [vc.gameView computeCardLayout:0 destPos:-1 destIdx:-1];
  }];
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setBool:sw.isOn forKey:stockOnRight_key];
  [settings synchronize];
}

- (void)switchFreecellOnTop:(id)sender {
  ViewController * vc = [self gameVC];

  ZXSwitch * sw = (ZXSwitch *)sender;
  vc.gameView.freecellOnTop = sw.isOn;
  [UIView performWithoutAnimation:^{
    [vc.gameView computeBottomCardLayout];
    [vc.gameView computeCardLayout:0 destPos:-1 destIdx:-1];
  }];
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setBool:sw.isOn forKey:freecellOnTop_key];
  [settings synchronize];
}



@end
