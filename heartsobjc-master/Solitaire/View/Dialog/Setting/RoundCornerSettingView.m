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
#import "zhconfig.h"
//#define ViewController GameViewController

#define CON_ANIMATION

typedef enum : NSUInteger {
  SettingSep1,
  SettingSound,
  SettingRotation,
  SettingSpeed,
  SettingSep2,
  SettingHelp,
  SettingToOldTheme,
  SettingShowTime,
  SettingTapAction,
#ifdef CON_ANIMATION
  SettingAnimation,
#endif
  SettingEnablingHint,
  SettingFreecellOnTop,
  SettingStockPosition,
} SettingType;


@interface RoundCornerSettingView ()
{
    ViewController* vc;
}
@end
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
  [self.closeButton setTitle:LocalizedGameStr2(ok) forState:(UIControlStateNormal)];
  [self.collectionView registerNib:[UINib nibWithNibName:@"SettingTableViewSwitchCell" bundle:nil] forCellWithReuseIdentifier:@"switch"];
  [self.collectionView registerNib:[UINib nibWithNibName:@"SettingTableViewDiscloseCell" bundle:nil] forCellWithReuseIdentifier:@"disclose"];
  [self.collectionView registerNib:[UINib nibWithNibName:@"SettingTableViewSegCell" bundle:nil] forCellWithReuseIdentifier:@"seg"];
  [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"def"];
}

- (ViewController *)gameVC {
//  ViewController * vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UINavigationController *navigationController = nil;

    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController *)rootViewController;
    } else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        navigationController = tabBarController.selectedViewController;
    }

    NSArray *viewControllers = navigationController.viewControllers;
    vc = (ViewController*)viewControllers[0];

  if (![vc isKindOfClass:[ViewController class]]) {
    return nil;
  }
  return vc;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return SettingHelp+2;
//  return SettingToOldTheme+1;
}

- (CGFloat)heightForItemAtIndexPath:(NSIndexPath *)indexPath bounds:(CGRect)bounds isPortrait:(BOOL)portrait{
    int x=IS_IPAD? 28:10;
  if (portrait) {
    CGFloat scale = (IS_IPAD?1.5:1);
    if (indexPath.row == SettingSep1 || indexPath.row == SettingSep2) {
      return 6*scale-x;
    }
    return 36*scale-x;
  } else {
      int x=IS_IPAD? 30: [self isLandscape] ? 13 : 10;
    CGFloat hh = (CGRectGetHeight(bounds)/4);
    if (indexPath.row == SettingSep1 || indexPath.row == SettingSep2) {
      return 0;
    } else {

    }
      return  hh-x;
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
  CGFloat height = [self heightForItemAtIndexPath:indexPath bounds:rect isPortrait:NO];
  if (self.isp) {
    w = CGRectGetWidth(rect);
  } else {
    w = CGRectGetWidth(rect);
  }
    if (IS_IPAD) {
        if (indexPath.row == SettingSep1 || indexPath.row == SettingSep2) {
            return CGSizeMake(w, 0);
        } else {
            
            return CGSizeMake(w,self.viewHeig/5.0);  //5替换为实际的cell数量
        }
    }else{
        return CGSizeMake(w, height);
        
    }
}


- (NSString *)stringForSpeed:(NSInteger)sp {
  if (sp == 0) {
    return @"Slow";
  } else if (sp == 2) {
    return @"Fast";
  }
  return @"Normal";
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"zzx indexPath.row = %ld",indexPath.row);
    NSLog(@"zzx indexPath.section = %ld",indexPath.section);
  
  SettingType type = indexPath.item;
    if (indexPath.row == 7) {
        NSLog(@" zzx indexPath.row SettingType %lu",type);
    }
  if (type == SettingSep1 || type == SettingSep2) {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"def" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
  }
  NSString * reuseId = (type < (SettingSep2+1))?(@"switch"):(@"disclose");
  if (type == SettingSpeed) {
    reuseId = @"disclose";
  }
  SettingCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
  cell.clicker.onImage = [UIImage imageNamed:@"switch_on"];
  cell.clicker.offImage = [UIImage imageNamed:@"switch_off"];
  cell.nameL.textColor = [UIColor whiteColor];
  cell.clicker.userInteractionEnabled = YES;
  ViewController * vc = [self gameVC];
  switch (type) {

    case SettingStockPosition: {
//        if (IS_IPAD) {
//               /*cell.frame = CGRectOffset(cell.frame, 0, 40);*/ //向上偏移20个单位
//         }
      cell.nameL.text =  LocalizedGameStr(freecell_pos);
      [cell.clicker setOnImage:[UIImage imageNamed:@"99right.png"]];
      [cell.clicker setOffImage:[UIImage imageNamed:@"99left.png"]];
//      cell.clicker.isOn = vc.gameView.stockOnRight;
      [cell.clicker addTarget:self action:@selector(switchstockOnRight:) forControlEvents:UIControlEventValueChanged];
    }
      break;

    case SettingFreecellOnTop: {
//        if (IS_IPAD) {
////               cell.frame = CGRectOffset(cell.frame, 0, 40); //向上偏移20个单位
//         }
      cell.nameL.text =  LocalizedGameStr(freecell_on_top);
      if (self.isp) {
        cell.nameL.textColor = [UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1];
        cell.clicker.userInteractionEnabled = NO;
        cell.clicker.isOn = YES;
      } else {
//        cell.clicker.isOn = vc.gameView.freecellOnTop;
      }
      [cell.clicker addTarget:self action:@selector(switchFreecellOnTop:) forControlEvents:UIControlEventValueChanged];
    }
      break;

    case SettingSpeed: {
        if (IS_IPAD) {
////            cell.frame = CGRectOffset(cell.frame, 0, 40);
////            cell.transform = CGAffineTransformMakeTranslation(0, 40);//向上偏移20个单位
            cell.nameL.font = [UIFont systemFontOfSize:24.0];
//            cell.nameL.transform = CGAffineTransformMakeTranslation(40, 0);
            cell.valueL.font = [UIFont systemFontOfSize:24.0];
            
            // 禁用AutoresizingMask转换为约束
            cell.nameL.translatesAutoresizingMaskIntoConstraints = NO;

            // 移除原有的宽度约束
            for (NSLayoutConstraint *constraint in cell.nameL.constraints) {
                if (constraint.firstAttribute == NSLayoutAttributeWidth) {
                    [cell.nameL removeConstraint:constraint];
                    break;
                }
            }

            // 创建新的宽度约束并添加
            NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint constraintWithItem:cell.nameL attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:120];
            [cell.nameL addConstraint:newWidthConstraint];
         }
      cell.nameL.text =  LocalizedGameStr2(Speed);
      cell.sep.hidden = YES;
      cell.valueL.text = [self stringForSpeed:vc.gameView.speed];
    }
      break;

    case SettingSound: {
     if (IS_IPAD) {
//         cell.transform = CGAffineTransformMakeTranslation(0, 40);//向上偏移20个单位
         cell.nameL.font = [UIFont systemFontOfSize:24.0];
         // 禁用AutoresizingMask转换为约束
         cell.nameL.translatesAutoresizingMaskIntoConstraints = NO;

//         // 移除原有的宽度约束
//         for (NSLayoutConstraint *constraint in cell.nameL.constraints) {
//             if (constraint.firstAttribute == NSLayoutAttributeWidth) {
//                 [cell.nameL removeConstraint:constraint];
//                 break;
//             }
//         }

         // 创建新的宽度约束并添加
//         NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint constraintWithItem:cell.nameL attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
//         [cell.nameL addConstraint:newWidthConstraint];
         
//         cell.clicker.frame=CGRectMake(0,0, 78, 36);
         NSLog(@"rsawaedaw cell.clicker.frame.origin.x %lf",cell.clicker.frame.origin.x);
         NSLog(@"rsawaedaw cell.clicker.frame.origin.y %lf",cell.clicker.frame.origin.y);
         if (kScreenWidth >kScreenHeight) {
//             cell.clicker.transform = CGAffineTransformMakeTranslation(0, 0);
         }else{
//             cell.clicker.transform = CGAffineTransformMakeTranslation(-40, 0);
         }
         if (1) {
//             NSLog(@"rsawaedaw");
//             // 创建新的宽度约束并添加
//             NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint constraintWithItem:cell.nameL attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
//             [cell.nameL addConstraint:newWidthConstraint];
//           // 禁用AutoresizingMask转换为约束
//           cell.clicker.translatesAutoresizingMaskIntoConstraints = NO;
//
//           // 添加左侧约束，距离左边50单位
//           NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:cell.clicker attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeading multiplier:1.0 constant:370];
//             if ([self isLandscape] && kScreenWidth > kScreenHeight ) {
//                 leftConstraint = [NSLayoutConstraint constraintWithItem:cell.clicker attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeading multiplier:1.0 constant:200];
//             }
//
//           // 添加顶部约束，位于顶部
//           NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:cell.clicker attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:17];
//
//           // 添加宽度约束，宽度为原始宽度+20
//           NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:cell.clicker attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:78];
//
//           // 添加高度约束，高度为原始高度+20
//           NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:cell.clicker attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:36];

           // 将约束添加到相应的视图上
//           [cell addConstraint:leftConstraint];
//           [cell addConstraint:topConstraint];
//           [cell.clicker addConstraint:widthConstraint];
//           [cell.clicker addConstraint:heightConstraint];
         }
            
      }
      cell.nameL.text =  LocalizedGameStr2(setting_sound);
      cell.clicker.isOn = vc.gameView.sound;
      [cell.clicker addTarget:self action:@selector(switchSound:) forControlEvents:UIControlEventValueChanged];
    }
      break;

//    case SettingShowTime: {
//      cell.nameL.text = LocalizedGameStr2(setting_times);
//      cell.clicker.isOn = !(vc.gameView.timeLabel.hidden);
//      [cell.clicker addTarget:self action:@selector(switchTime:) forControlEvents:UIControlEventValueChanged];
//    }
//      break;

    case SettingRotation: {
        if(IS_IPAD){
            {
//                cell.transform = CGAffineTransformMakeTranslation(0, 40);//向上偏移20个单位
                cell.nameL.font = [UIFont systemFontOfSize:24.0];
                // 禁用AutoresizingMask转换为约束
                cell.nameL.translatesAutoresizingMaskIntoConstraints = NO;

                // 移除原有的宽度约束
//                for (NSLayoutConstraint *constraint in cell.nameL.constraints) {
//                    if (constraint.firstAttribute == NSLayoutAttributeWidth) {
//                        [cell.nameL removeConstraint:constraint];
//                        break;
//                    }
//                }

                // 创建新的宽度约束并添加
//                NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint constraintWithItem:cell.nameL attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
//                [cell.nameL addConstraint:newWidthConstraint];
//                
//       //         cell.clicker.frame=CGRectMake(0,0, 78, 36);
//                NSLog(@"rsawaedaw cell.clicker.frame.origin.x %lf",cell.clicker.frame.origin.x);
//                NSLog(@"rsawaedaw cell.clicker.frame.origin.y %lf",cell.clicker.frame.origin.y);
//                if (kScreenWidth >kScreenHeight) {
//                    cell.clicker.transform = CGAffineTransformMakeTranslation(0, 0);
//                }else{
//                    cell.clicker.transform = CGAffineTransformMakeTranslation(-40, 0);
//                }
//                if (1) {
//                    NSLog(@"rsawaedaw");
//                    // 创建新的宽度约束并添加
//                    NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint constraintWithItem:cell.nameL attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:200];
//                    [cell.nameL addConstraint:newWidthConstraint];
//                  // 禁用AutoresizingMask转换为约束
//                  cell.clicker.translatesAutoresizingMaskIntoConstraints = NO;
//
//                  // 添加左侧约束，距离左边50单位
//                  NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:cell.clicker attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeading multiplier:1.0 constant:370];
//                    if ([self isLandscape] && kScreenWidth > kScreenHeight ) {
//                        leftConstraint = [NSLayoutConstraint constraintWithItem:cell.clicker attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeLeading multiplier:1.0 constant:200];
//                    }
//
//                  // 添加顶部约束，位于顶部
//                  NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:cell.clicker attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell attribute:NSLayoutAttributeTop multiplier:1.0 constant:17];
//
//                  // 添加宽度约束，宽度为原始宽度+20
//                  NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:cell.clicker attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:78];
//
//                  // 添加高度约束，高度为原始高度+20
//                  NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:cell.clicker attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:36];

                  // 将约束添加到相应的视图上
       //           [cell addConstraint:leftConstraint];
       //           [cell addConstraint:topConstraint];
       //           [cell.clicker addConstraint:widthConstraint];
       //           [cell.clicker addConstraint:heightConstraint];
//                }
                   
             }
        }
      cell.nameL.text = LocalizedGameStr2(setting_orientation);
      cell.clicker.isOn = ![[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
      [cell.clicker addTarget:self action:@selector(switchOrientation:) forControlEvents:UIControlEventValueChanged];
    }
      break;

//    case SettingEnablingHint: {
//      cell.nameL.text = LocalizedGameStr2(setting_hints);
//      cell.clicker.isOn = vc.autohintEnabled;
//      [cell.clicker addTarget:self action:@selector(switchHints:) forControlEvents:UIControlEventValueChanged];
//    }
//      break;

    case SettingTapAction: {
        if (IS_IPAD) {
//               cell.frame = CGRectOffset(cell.frame, 0, 40); //向上偏移20个单位
         }
      cell.nameL.text = LocalizedGameStr2(setting_tapmove);
      cell.clicker.isOn = vc.gameView.autoOn;
      [cell.clicker addTarget:self action:@selector(switchTapmove:) forControlEvents:UIControlEventValueChanged];
    }
      break;

#ifdef CON_ANIMATION

    case SettingAnimation: {
        if (IS_IPAD) {
//               cell.frame = CGRectOffset(cell.frame, 0, 40); //向上偏移20个单位
         }
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
        if (IS_IPAD) {
//            
//            cell.transform = CGAffineTransformMakeTranslation(0, 40);
//            cell.frame = CGRectOffset(cell.frame, 0, 40); //向上偏移20个单位
            cell.nameL.font = [UIFont systemFontOfSize:24.0];
            // 禁用AutoresizingMask转换为约束
            cell.nameL.translatesAutoresizingMaskIntoConstraints = NO;

            // 移除原有的宽度约束
            for (NSLayoutConstraint *constraint in cell.nameL.constraints) {
                if (constraint.firstAttribute == NSLayoutAttributeWidth) {
                    [cell.nameL removeConstraint:constraint];
                    break;
                }
            }

            // 创建新的宽度约束并添加
            NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint constraintWithItem:cell.nameL attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:120];
            [cell.nameL addConstraint:newWidthConstraint];
         }
      cell.sep.hidden = YES;
      cell.nameL.text = LocalizedGameStr2(help_rules);
//      cell.nameL.text = LocalizedGameStr2(ToOldTheme);
    }
      break;
     
      case SettingToOldTheme: {
          if (IS_IPAD) {
//              cell.transform = CGAffineTransformMakeTranslation(0, 40);
//              cell.frame = CGRectOffset(cell.frame, 0, 40); //向上偏移20个单位
              cell.nameL.font = [UIFont systemFontOfSize:24.0];
              // 禁用AutoresizingMask转换为约束
              cell.nameL.translatesAutoresizingMaskIntoConstraints = NO;

              // 移除原有的宽度约束
              for (NSLayoutConstraint *constraint in cell.nameL.constraints) {
                  if (constraint.firstAttribute == NSLayoutAttributeWidth) {
                      [cell.nameL removeConstraint:constraint];
                      break;
                  }
              }

              // 创建新的宽度约束并添加
              NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint constraintWithItem:cell.nameL attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:120];
              [cell.nameL addConstraint:newWidthConstraint];
          }else{
              // 禁用AutoresizingMask转换为约束
              cell.nameL.translatesAutoresizingMaskIntoConstraints = NO;
              // 移除原有的宽度约束
              for (NSLayoutConstraint *constraint in cell.nameL.constraints) {
                  if (constraint.firstAttribute == NSLayoutAttributeWidth) {
                      [cell.nameL removeConstraint:constraint];
                      break;
                  }
              }

              // 创建新的宽度约束并添加
              NSLayoutConstraint *newWidthConstraint = [NSLayoutConstraint constraintWithItem:cell.nameL attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:120];
              [cell.nameL addConstraint:newWidthConstraint];
          }
        cell.sep.hidden = YES;
        cell.nameL.text = LocalizedGameStr2(ToOldTheme);
      }
        break;


    default:
      break;
  }
  return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  SettingType type = indexPath.row;
  if ( SettingSpeed == type) {
    int speed = ([self gameVC].gameView.speed+1)%3;
    [self gameVC].gameView.speed = speed;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setInteger:speed forKey:@"speed"];
    [settings synchronize];
    [collectionView reloadData];
    return;
  }
  if (type >= (SettingSep2+1)) {
    switch (type) {
//      case SettingStat: {
//        if ([self.delegate respondsToSelector:@selector(showStatView)]) {
//          [self.delegate showStatView];
//        }
//      }
//        break;

      case SettingHelp: {
//          [self performSegueWithIdentifier:@"rulesegue" sender:self];
        if ([self.delegate respondsToSelector:@selector(showRuleView)]) {
          [self.delegate showRuleView];
        }
      }
        break;
        case SettingToOldTheme: {
            [self ChangeToOldManSetting];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"background"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"cardback"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"cardfront"];
            [vc setBackImage];
            [vc.gameView IsOldman];
            [vc.gameView updateInfoList];
            [vc.gameView updateThemesButtonStatus];
            [self.superview removeFromSuperview];
        }
          break;

      default:
        break;
    }
  }

}






-(void)ChangeToOldManSetting{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    // 20240328 切换用户前保存新用户主题
//    NSString* newBack = [settings objectForKey:@"Newbackground"];
//    NSString* Newcardback = [settings objectForKey:@"Newcardback"];
    NSString* newBack = newBack = [settings objectForKey:@"background"];
    NSString* Newcardback = [settings objectForKey:@"cardback"];
    if (newBack ==nil) {
        newBack = [settings objectForKey:@"background"];
    }
    if (Newcardback == nil) {
        Newcardback = [settings objectForKey:@"cardback"];
    }
    [settings setObject:newBack forKey:@"Newbackground"];
    [settings setObject:Newcardback forKey:@"Newcardback"];
    // 切换用户后  获取以前保存着老用户主题 如果为空则重新赋值
    NSString* OldBack = [settings objectForKey:@"Oldbackground"];
    NSString* OldCardback = [settings objectForKey:@"OldNewcardback"];
    // 如果有值赋值，无值给默认值
    if (OldBack) {
        [settings setObject:OldBack forKey:@"background"];
        NSLog(@"Old background is: %@", OldBack);
    } else {
        [settings setObject:@"RedFelt" forKey:@"background"];
        NSLog(@"Old background is not set for the given key.");
    }
    
    if (OldCardback) {
        [settings setObject:OldCardback forKey:@"cardback"];
        NSLog(@"Old background is: %@", OldCardback);
    } else {
        [settings setObject:@"CardBack-BlueGrid" forKey:@"cardback"];
        NSLog(@"Old background is not set for the given key.");
    }
    
    // 0401add cardface 恢复默认 是否需要保存
    
    /// default
    BOOL classicCard = CLASSIC_CARD;
    BOOL orientation = YES;//!(IPHONE_LANDSCAPE);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        classicCard = YES;
        orientation = YES;
    }
    //定义两套初始化皮肤number.1
    NSLog(@"test first1 coming");
    NSDictionary *defaultValue=nil;
    defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:@"CardBack-BlueGrid",@"cardback",
                    @"RedFelt",@"background",
                    [NSNumber numberWithInteger:0],@"level",
                    [NSNumber numberWithBool:YES],@"sound",
                    [NSNumber numberWithBool:YES],@"timemoves",
                    [NSNumber numberWithBool:orientation],@"orientation",
                    [NSNumber numberWithBool:YES],@"hints",
                    [NSNumber numberWithBool:TAP_MOVE],@"tapmove",
                    [NSNumber numberWithBool:NO],@"gamecenter",
                    [NSNumber numberWithBool:NO],@"holiday",
                    [NSNumber numberWithBool:NO],@"congra",
                    [NSNumber numberWithInt:1],@"speed",
                    [NSNumber numberWithInteger:orientation ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight],@"currentori",
                    [NSNumber numberWithBool:classicCard],@"classic",
                    [NSNumber numberWithInt:0],@"cnt",
                    [NSNumber numberWithBool:NO],@"rated",
                    [NSNumber numberWithInt:0],@"popratecnt",
                    nil];
    
   
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"changetoNewMan"];
    [settings registerDefaults:defaultValue];
    
//    [settings setObject:@"RedFelt" forKey:@"background"];
//    [settings synchronize];
    
    [settings synchronize];
    
    // 测试切换主题后赋值是否成功
//    NSString* newBack = [self getRealBackImgName:[[NSUserDefaults standardUserDefaults] objectForKey:@"background"]];
//    NSString* newBack = [settings objectForKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"background"]];
    NSLog(@"0328 zzx newback %@",newBack);
    
//    [settings objectForKey:@"cardback"];
    
}
- (BOOL)isLandscape {
    // 横屏
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(orientation);
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

//  vc.autohintEnabled = sw.isOn;
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
//  vc.gameView.timeLabel.hidden = !sw.isOn;
//  vc.gameView.movesLabel.hidden = !sw.isOn;
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
  self.sepVertical.hidden = YES;
//  ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).scrollDirection = isp?UICollectionViewScrollDirectionVertical:UICollectionViewScrollDirectionHorizontal;
//  self.closeButtonCenterX.constant = isp?0:(CGRectGetWidth(self.bounds)/2 - (CGRectGetWidth(self.closeButton.bounds)/2+ 8+8));
  [self.collectionView reloadData];
}

- (void)switchstockOnRight:(id)sender {
  ViewController * vc = [self gameVC];

  ZXSwitch * sw = (ZXSwitch *)sender;
//  vc.gameView.stockOnRight = sw.isOn;
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
//  vc.gameView.freecellOnTop = sw.isOn;
  [UIView performWithoutAnimation:^{
    [vc.gameView computeBottomCardLayout];
    [vc.gameView computeCardLayout:0 destPos:-1 destIdx:-1];
  }];
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  [settings setBool:sw.isOn forKey:freecellOnTop_key];
  [settings synchronize];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"zzx rse");
    [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView reloadData];
}




@end
