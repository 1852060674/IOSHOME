//
//  SettingViewController.m
//  WordSearch
//
//  Created by apple on 13-8-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SettingViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "TheSound.h"
#import "Config.h"
#import "Admob.h"
#include "ApplovinMaxWrapper.h"
@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *admobHeight;

@end
BOOL show_banner;
@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    ///
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    _admobHeight.constant=admobHeight1;
    
    [self.notifSwitch addTarget:self action:@selector(switchNotify:) forControlEvents:UIControlEventValueChanged];
    [self.soundSwitch addTarget:self action:@selector(switchSound:) forControlEvents:UIControlEventValueChanged];
    ///
    self.notifSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"notify"];
    self.soundSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNotifSwitch:nil];
    [self setSoundSwitch:nil];
    [self setToHome:nil];
    [self setAdView:nil];
    [super viewDidUnload];
}

- (void)switchSound:(id)sender
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:self.soundSwitch.on forKey:@"sound"];
    [settings synchronize];
    [TheSound playTapSound];
}

- (void)switchNotify:(id)sender
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:self.notifSwitch.on forKey:@"notify"];
    [settings synchronize];
    [TheSound playTapSound];
}

- (IBAction)sendEmail:(id)sender {
//    if ([MFMailComposeViewController canSendMail]) {
//        MFMailComposeViewController* emailviewcontroller = [[MFMailComposeViewController alloc] init];
//        emailviewcontroller.mailComposeDelegate = self;
//        [emailviewcontroller setToRecipients:[NSArray arrayWithObjects:@"lotusapp@qq.com", nil]];
//        [emailviewcontroller setSubject:@"Need for help?"];
//        NSString *body = @"Qustion type to here";
//        [emailviewcontroller setMessageBody:body isHTML:NO];
//        //[emailviewcontroller addAttachmentData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img.china-code.net/newspic/201001/09/20100109093926359.jpg"]] mimeType:@"image/jpg" fileName:@"iamge.jpg"];
//        [self presentModalViewController:emailviewcontroller animated:YES];
//    }
//    else
//    {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"Sorry!There is no email account set up on this device!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }
    
    [[[AdmobViewController shareAdmobVC] rtService] doFeedback:self];
    [TheSound playTapSound];
}

- (IBAction)help:(id)sender {
    [TheSound playTapSound];
}

- (IBAction)restore:(id)sender {
    [TheSound playTapSound];
}
- (IBAction)home:(id)sender {
    [TheSound playTapSound];
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 视图布局完成后
    if (!show_banner) {
        [AdmobViewController shareAdmobVC].delegate=self;
        [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
        show_banner=YES;
    }
}
@end
