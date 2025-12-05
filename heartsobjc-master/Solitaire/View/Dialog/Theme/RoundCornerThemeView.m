//
//  RoundCornerThemeView.m
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "RoundCornerThemeView.h"
#import "ThemeCollectionViewCell.h"
#import <AVFoundation/AVUtilities.h>
#import "cardview.h"
#define small_pic_suffix @"_small"

#define cardback_mask_alpha @"cardbackmaskalpha"
#define cardback_border @"cardbackborder"

#define custom_plus_name @"custom_bg"
#define custom_minus_name @"custom_bg1"
#define custom_minus_back_name @"custom_bgminus"


@implementation RoundCornerThemeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
  [super awakeFromNib];
  self.cancelB.hidden = YES;
  self.titleLabel.text = LocalizedGameStr2(theme);
  [self.closeButton setTitle:LocalizedGameStr2(dialog_close) forState:(UIControlStateNormal)];
  [self.leftB setTitle:LocalizedGameStr2(dialog_theme_card) forState:(UIControlStateNormal)];
  [self.middleB setTitle:LocalizedGameStr2(dialog_theme_cardback) forState:(UIControlStateNormal)];
  [self.rightB setTitle:LocalizedGameStr2(dialog_theme_gameback) forState:(UIControlStateNormal)];
  [self.cancelB setTitle:LocalizedGameStr2(done) forState:(UIControlStateNormal)];
  [self.collectionView registerNib:[UINib nibWithNibName:@"ThemeCollectionViewCellSmall" bundle:nil] forCellWithReuseIdentifier:@"small"];
  [self.collectionView registerNib:[UINib nibWithNibName:@"ThemeCollectionViewCellBig" bundle:nil] forCellWithReuseIdentifier:@"big"];
  self.type = [[NSMutableString alloc] init];
  UIView * view = [[UIView alloc] init];
  view.backgroundColor = [UIColor clearColor];
  self.collectionView.backgroundView = view;
//  [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelRemoving)]];
}




- (NSArray *)frontImageNames {
  return @[
           @"classic",
           @"bigcard",
           @"newcard3",
           @"newcard4",
           @"newcard5",
           @"newcard6",
           ];
}

- (NSArray *)builtInCardBackImageNames {
  return [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cardbackNew" ofType:@"plist"]];
}

- (NSArray *)builtInDeskBackImageNames {
  return [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backgroundNew" ofType:@"plist"]];
}

#pragma mark - custom bg

- (BOOL)hasCustomCardBg {
  return [self allCustomCardBg].count > 0;
}

- (NSArray *)allCustomCardBg {
  return [[NSUserDefaults standardUserDefaults] objectForKey:customCardBgListKey];
}


- (NSArray *)allCustomDeskBg {
  return [[NSUserDefaults standardUserDefaults] objectForKey:customDeskBgListKey];
}


- (BOOL)hasCustomDeskBg {
  return [self allCustomDeskBg].count > 0;
}



- (void)addCustomBg:(NSString *)name {
  BOOL isCardBg = _middleB.selected;
  NSArray * bgs = (isCardBg?[self allCustomCardBg]:[self allCustomDeskBg]);
  NSMutableArray * bgsM = [bgs mutableCopy];
  [bgsM addObject:name];
  NSString * key = isCardBg?customCardBgListKey:customDeskBgListKey;
  [[NSUserDefaults standardUserDefaults] setObject:bgsM forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [_collectionView reloadData];
}

- (void)removeCustomBg:(NSString *)name {
  BOOL isCardBg = _middleB.selected;
  NSArray * bgs = (isCardBg?[self allCustomCardBg]:[self allCustomDeskBg]);
  NSMutableArray * bgsM = [bgs mutableCopy];
  [bgsM removeObject:name];
  NSString * listKey = isCardBg?customCardBgListKey:customDeskBgListKey;
  NSString * currentKey = isCardBg?@"cardback":@"background";
  NSString * currentPic = [[NSUserDefaults standardUserDefaults] objectForKey:currentKey];
  NSString * defaultName = isCardBg?@"cardback37.png":@"bg0";
  if (bgsM.count == 0) {
    NSString * flag = (isCardBg?@"userdefined-backcard":@"userdefined-background");
    [[NSUserDefaults standardUserDefaults] setObject:defaultName forKey:currentKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:flag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:_type];
  } else if ([currentPic isEqualToString:name]) {
    NSString * flag = (isCardBg?@"userdefined-backcard":@"userdefined-background");
    [[NSUserDefaults standardUserDefaults] setObject:defaultName forKey:currentKey];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:flag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:_type];
  }
  [[NSUserDefaults standardUserDefaults] setObject:bgsM forKey:listKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
  [_collectionView reloadData];
}

#pragma mark - misc

- (UIImage *)makeCardBgImg:(UIImage *)image {
  CGSize size = CGSizeMake(146, 198);
  CGRect rect = CGRectZero;
  rect.size = size;
  UIGraphicsBeginImageContext(size);
  UIImage * maskImg = [UIImage imageNamed:cardback_mask_alpha];
  UIImage * border = [UIImage imageNamed:cardback_border];
  [maskImg drawInRect:rect];
  [image drawInRect:rect blendMode:kCGBlendModeSourceIn alpha:1];
  [border drawInRect:rect];
  UIImage * val = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return val;
}
- (NSString *)pathWithLastComponent:(NSString *)lastpc {
  NSString* path = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(), lastpc];
  return path;
}


- (void)setPrefObj:(id)obj forKey:(NSString *)key {
  [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize {

  CGRect rect1 = CGRectMake(0, 0, reSize.width, reSize.height);
  CGRect rect = AVMakeRectWithAspectRatioInsideRect(image.size, rect1);
  CGFloat scale = MAX(CGRectGetWidth(rect1)/CGRectGetWidth(rect), CGRectGetHeight(rect1)/CGRectGetHeight(rect));
  CGRect rect0 = CGRectZero;
  rect0.size.width = CGRectGetWidth(rect)*scale;
  rect0.size.height = CGRectGetHeight(rect)*scale;
  rect0.origin.x = CGRectGetMidX(rect1)-rect0.size.width/2;
  rect0.origin.y = CGRectGetMidY(rect1)-rect0.size.height/2;
  rect0 = CGRectIntegral(rect0);
  rect1 = CGRectIntegral(rect1);
  UIGraphicsBeginImageContext(rect1.size);
  [image drawInRect:rect0];
  UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return reSizeImage;
}
#pragma mark - picker
- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
  [picker dismissViewControllerAnimated:YES completion:nil];
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
  if (_leftB.selected) {
    return;
  }
  ///
  [picker dismissViewControllerAnimated:YES completion:nil];
  [[UIApplication sharedApplication] setStatusBarHidden:YES];
  ///
  UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
  UIImage* scaleImage = (_middleB.selected?[self makeCardBgImg:[self reSizeImage:image toSize:CGSizeMake(146, 198)]]:[self reSizeImage:image toSize:[UIScreen mainScreen].bounds.size]);
  NSString * aname = [NSString stringWithFormat:@"userdefined%@%.0f", (_middleB.selected?@"cardbg":@"deskbg"),[[NSDate date] timeIntervalSince1970]];
  NSString* path = [self pathWithLastComponent:aname];
    if (!_middleB.selected) {
        float scale = [[UIScreen mainScreen] scale];
        NSString *retinaStr = @"";
        if (scale == 2.0)
            retinaStr = @"@2x";
         path = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(),aname, retinaStr];
    }
  [UIImagePNGRepresentation(scaleImage) writeToFile:path atomically:YES];
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    if (_middleB.selected) {
        CGFloat sizeWidth=_middleB.selected ?146 :[UIScreen mainScreen].bounds.size.width;
        CGFloat sizeHeight=_middleB.selected ?198 :[UIScreen mainScreen].bounds.size.height;
        
        CGSize size1 =  CGSizeMake(sizeWidth, sizeHeight);
        
        UIGraphicsBeginImageContextWithOptions(size1, NO, [UIScreen mainScreen].scale);
        
        [image drawInRect:CGRectMake(0, 0, sizeWidth, sizeHeight)];
        
        UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        [UIImagePNGRepresentation(scaledImage) writeToFile:path atomically:YES];
    }
    UIGraphicsEndImageContext();
//        return scaledImage;   //返回的就是已经改变的图片
  if (_rightB.selected) {
    UIImage * small = [self reSizeImage:scaleImage toSize:CGSizeMake(150/2, 200/2)];
    [UIImagePNGRepresentation(small) writeToFile:[self pathWithLastComponent:[aname stringByAppendingString:small_pic_suffix]] atomically:YES];
  }
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setObject:aname forKey:(_middleB.selected?@"cardback":@"background")];
  [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:(_middleB.selected?@"userdefined-backcard":@"userdefined-background")];
  [userDefaults synchronize];
  [self addCustomBg:aname];
}

#pragma mark - collection datasource

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  if (_leftB.selected) {
    return UIEdgeInsetsMake(10, 0, 0, 0);
  }
  return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  return 0;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//  return self.isRemovingCustom?UIEdgeInsetsMake(0, 0, 50, 0):UIEdgeInsetsZero;
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

  CGRect rect = self.contentView.bounds;


  if (CGRectGetWidth(rect) > CGRectGetHeight(rect)) {
    CGFloat scale = IS_IPAD?2:1;
    if (_leftB.selected) {
      return CGSizeMake(CGRectGetWidth(rect)/3, 80*scale);
    } else {
      //desk bg
      return CGSizeMake(CGRectGetWidth(rect)/5, 100*scale);
    }
  } else {

    CGFloat scale = IS_IPAD?2:1;
    if (_leftB.selected) {
      return CGSizeMake(CGRectGetWidth(rect)/2, 80*scale);
    } else {
      //desk bg
      return CGSizeMake(CGRectGetWidth(rect)/3, 90*scale);
    }

  }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  if (_leftB.selected) {
    return [self frontImageNames].count;
  } else if (_middleB.selected){
    //card bg
    return [self builtInCardBackImageNames].count + [self allCustomCardBg].count +(([self hasCustomCardBg])?(self.isRemovingCustom?0:2):1);
  } else {
    //desk bg
    return [self builtInDeskBackImageNames].count + [self allCustomDeskBg].count + (([self hasCustomDeskBg])?(self.isRemovingCustom?0:2):1);
  }
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

  CGRect rect = self.contentView.bounds;


  BOOL isp = (CGRectGetWidth(rect) < CGRectGetHeight(rect));

  ThemeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:_leftB.selected?@"small":@"big" forIndexPath:indexPath];
  cell.iconSpacing.constant = isp?-15:(IS_IPAD?-25:-18);
  cell.deleteB.hidden = YES;
  cell.dimView.hidden = YES;
  if (_leftB.selected) {
    NSString * name = [self frontImageNames][indexPath.item];
    cell.iconIV.image = [UIImage imageNamed:name];
      if (IS_IPAD ) {
          [cell.iconIV setTranslatesAutoresizingMaskIntoConstraints:NO];
          NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:cell.iconIV attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:10];
          NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.iconIV attribute:NSLayoutAttributeTrailing multiplier:1 constant:10];
          NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:cell.iconIV attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:10];
          NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:cell.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cell.iconIV attribute:NSLayoutAttributeBottom multiplier:1 constant:10];

          [NSLayoutConstraint activateConstraints:@[leading, trailing, top, bottom]];
      }
//      [cell.iconIV setTranslatesAutoresizingMaskIntoConstraints:NO];
//
//      [[cell.iconIV.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor] setActive:YES];
//      [[cell.iconIV.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor] setActive:YES];
//      [[cell.iconIV.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor] setActive:YES];
//      [[cell.iconIV.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor] setActive:YES];

    cell.tickIV.hidden = !([[self cardfrontprefix][indexPath.item] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"cardfront"]]);
  } else if (_middleB.selected) {
    //card bg
    
    NSString * savedName = [[NSUserDefaults standardUserDefaults] objectForKey:@"cardback"];
    cell.tickIV.hidden = YES;
    NSArray * bgs = [self builtInCardBackImageNames];
    if (indexPath.item < bgs.count) {
      if (self.isRemovingCustom) {
        cell.dimView.hidden = NO;
      }
      NSString * imgname = bgs[indexPath.item];
      cell.tickIV.hidden = !([imgname isEqualToString:savedName]);
      UIImage * iii = [UIImage imageNamed:imgname];
      cell.iconIV.image = iii;
    } else if ([self hasCustomCardBg]) {
      NSArray * cbgs = [self allCustomCardBg];
      if (indexPath.item - bgs.count < cbgs.count) {
        NSString * ipath = cbgs[indexPath.item - bgs.count];
        if (self.isRemovingCustom) {
          cell.deleteB.hidden = NO;
          [cell.deleteB addTarget:self action:@selector(tryToRemoveBg:) forControlEvents:(UIControlEventTouchUpInside)];
          cell.tickIV.hidden = YES;
        } else {
          cell.tickIV.hidden = !([ipath isEqualToString:savedName]);
        }
        cell.iconIV.image = [UIImage imageWithContentsOfFile:[self pathWithLastComponent:ipath]];
      } else if (indexPath.item - bgs.count == cbgs.count) {
        cell.iconIV.image = [UIImage imageNamed:custom_plus_name];
      } else {
        cell.iconIV.image = [UIImage imageNamed:self.isRemovingCustom? custom_minus_back_name:custom_minus_name];
      }
    } else {
      [self enableRemoving:NO];
      cell.iconIV.image = [UIImage imageNamed:custom_plus_name];
    }
  } else {
    //desk bg
    NSString * savedName = [[NSUserDefaults standardUserDefaults] objectForKey:@"background"];
    cell.tickIV.hidden = YES;
    NSArray * bgs = [self builtInDeskBackImageNames];
    if (indexPath.item < bgs.count) {
      if (self.isRemovingCustom) {
        cell.dimView.hidden = NO;
      }

      NSString * imgname = bgs[indexPath.item];
      cell.tickIV.hidden = !([imgname isEqualToString:savedName]);
      cell.iconIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_small.jpg", imgname]];
    } else if ([self hasCustomDeskBg]) {
      NSArray * cbgs = [self allCustomDeskBg];
      if (indexPath.item - bgs.count < cbgs.count) {
        NSString * ipath = cbgs[indexPath.item - bgs.count];
        if (self.isRemovingCustom) {
          cell.deleteB.hidden = NO;
          [cell.deleteB addTarget:self action:@selector(tryToRemoveBg:) forControlEvents:(UIControlEventTouchUpInside)];
          cell.tickIV.hidden = YES;
        } else {
          cell.tickIV.hidden = !([ipath isEqualToString:savedName]);
        }
        cell.iconIV.image = [UIImage imageWithContentsOfFile:[self pathWithLastComponent:[ipath stringByAppendingString:small_pic_suffix]]];
      } else if (indexPath.item - bgs.count == cbgs.count) {
        cell.iconIV.image = [UIImage imageNamed:custom_plus_name];
      } else {
        cell.iconIV.image = [UIImage imageNamed:self.isRemovingCustom? custom_minus_back_name:custom_minus_name];
      }
    } else {
      [self enableRemoving:NO];
      cell.iconIV.image = [UIImage imageNamed:custom_plus_name];
    }
  }
  return cell;
}


- (NSArray *)cardfrontprefix {
  return @[
           @"1",
           @"0",
           @"2",
           @"3",
           @"4",
           @"5",
           ];
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (_leftB.selected) {
    [_type appendString:@"cardfront"];
    NSString * name = [self cardfrontprefix][indexPath.item];
    [self setPrefObj:name forKey:@"cardfront"];
  } else if (_middleB.selected){
    //card bg
    [_type appendString:@"cardback"];
    NSArray * bgs = [self builtInCardBackImageNames];
    if (indexPath.item < bgs.count) {
      if (self.isRemovingCustom) {

      } else {
      NSString * imgname = bgs[indexPath.item];
      [self setPrefObj:@(NO) forKey:@"userdefined-backcard"];
        [self setPrefObj:imgname forKey:@"cardback"];

      }
    } else if ([self hasCustomCardBg]) {
      NSArray * cbgs = [self allCustomCardBg];
      if (indexPath.item - bgs.count < cbgs.count) {
        NSString * ipath = cbgs[indexPath.item - bgs.count];
        if (self.isRemovingCustom) {

        } else {
          [self setPrefObj:@(YES) forKey:@"userdefined-backcard"];
          [self setPrefObj:ipath forKey:@"cardback"];
        }
      } else if (indexPath.item - bgs.count == cbgs.count) {
        [self pick:nil];
      } else {
        [self enableRemoving:YES];
      }
      [collectionView reloadData];
    } else {
      [self pick:nil];
    }

  } else {
    //desk bg
    [_type appendString:@"background"];
    NSArray * bgs = [self builtInDeskBackImageNames];
    if (indexPath.item < bgs.count) {

      if (self.isRemovingCustom) {

      } else {
        NSString * imgname = bgs[indexPath.item];
        [self setPrefObj:imgname forKey:@"background"];
      }
    } else if ([self hasCustomDeskBg]) {

      NSArray * cbgs = [self allCustomDeskBg];
      if (indexPath.item - bgs.count < cbgs.count) {
        NSString * ipath = cbgs[indexPath.item - bgs.count];
        if (self.isRemovingCustom) {

        } else {
          [self setPrefObj:@(YES) forKey:@"userdefined-backcard"];
          [self setPrefObj:ipath forKey:@"background"];
        }

      } else if (indexPath.item - bgs.count == cbgs.count) {
        [self pick:nil];
      } else {
        [self enableRemoving:YES];
      }
      [collectionView reloadData];
    } else {
      [self pick:nil];
    }
  }
  [collectionView reloadData];
}

#pragma mark - action

- (void)close:(id)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:_type];
  [super close:sender];
}


- (void)tryToRemoveBg:(UIButton *)button {
  BOOL isCardBg = _middleB.selected && [self hasCustomCardBg];
  BOOL isDeskBg = _rightB.selected && [self hasCustomDeskBg];
  NSArray * bgs = nil;
  NSArray * cbgs = nil;
  if (isCardBg) {
    bgs = [self builtInCardBackImageNames];
    cbgs = [self allCustomCardBg];
  } else if (isDeskBg) {
    bgs = [self builtInDeskBackImageNames];
    cbgs = [self allCustomDeskBg];
  }
  if (cbgs) {
    UICollectionViewCell * cell = (UICollectionViewCell *)button.superview.superview;
    if ([cell isKindOfClass:[UICollectionViewCell class]]) {
      NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
      if (indexPath) {
        if (indexPath.item - bgs.count < cbgs.count) {
          NSString * ipath = cbgs[indexPath.item - bgs.count];
          [self removeCustomBg:ipath];
        }
      }
    }
  }
}

- (void)enableRemoving:(BOOL)enable {
  self.isRemovingCustom = enable;
  self.cancelB.hidden = !enable;
}


- (IBAction)pick:(id)sender {
  ///
  [self enableRemoving:NO];

  UIImagePickerController *pc = [[UIImagePickerController alloc] init];
  pc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
  //pc.allowsEditing = YES;
  pc.delegate = self;
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pc animated:YES completion:nil];
}


- (IBAction)clickButton:(UIButton *)sender {
  [self unselectAll];
  sender.selected = YES;
  [self enableRemoving:NO];
  [_collectionView reloadData];
}

- (void)cancelRemoving {
  NSLog(@"cancel");
  [self enableRemoving:NO];
  [self.collectionView reloadData];
}

- (void)unselectAll {
  self.leftB.selected = NO;
  self.middleB.selected = NO;
  self.rightB.selected = NO;
}

- (IBAction)cancelDeleting:(id)sender {
  [self cancelRemoving];
}



- (void)prepareForPortrait:(NSNumber *)ispV {
  BOOL isp = [ispV boolValue];

//  self.closeButtonCenterX.constant = isp?0:(CGRectGetWidth(self.bounds)/2 - (CGRectGetWidth(self.closeButton.bounds)/2+ 8+8));
  self.closeButtonCenterX.constant = isp?0:0;
  self.endDeletionButtonTrailing.constant = isp?10:(8+CGRectGetWidth(self.closeButton.bounds)-CGRectGetWidth(self.cancelB.bounds));
  [self.collectionView reloadData];


}





@end
