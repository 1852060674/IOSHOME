//
//  HomeViewController.h
//  Mahjong
//
//  Created by yysdsyl on 14-11-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIScrollView *levelsScrollView;
@property (weak, nonatomic) IBOutlet UIButton *soundBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgView;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UIView *shadowVIew;

- (IBAction)onBack:(id)sender;
- (IBAction)onSound:(id)sender;

@end
