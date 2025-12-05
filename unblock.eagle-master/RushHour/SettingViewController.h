//
//  SettingViewController.h
//  WordSearch
//
//  Created by apple on 13-8-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<MessageUI/MFMailComposeViewController.h>

@interface SettingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *adView;
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *soundBtn;
- (IBAction)switchSound:(id)sender;

@end
