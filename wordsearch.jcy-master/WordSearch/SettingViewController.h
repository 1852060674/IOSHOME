//
//  SettingViewController.h
//  WordSearch
//
//  Created by apple on 13-8-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<MessageUI/MFMailComposeViewController.h>

@interface SettingViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *notifSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
- (IBAction)sendEmail:(id)sender;
- (IBAction)help:(id)sender;
- (IBAction)restore:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *toHome;
- (IBAction)home:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *adView;

- (void)switchSound:(id)sender;
- (void)switchNotify:(id)sender;

@end
