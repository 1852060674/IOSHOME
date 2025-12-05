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
#import "Common.h"
#import "Admob.h"
#include "ApplovinMaxWrapper.h"
@interface SettingViewController ()
{
    __weak IBOutlet NSLayoutConstraint *admobHeightIpd;
    __weak IBOutlet NSLayoutConstraint *admobHeight;
}
@end

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
    /// admob
    //[Common addAds:self.adView rootVc:self];
    ///
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"])
        [self.soundBtn setBackgroundImage:[UIImage imageNamed:@"sound on"] forState:UIControlStateNormal];
    else
        [self.soundBtn setBackgroundImage:[UIImage imageNamed:@"sound off"] forState:UIControlStateNormal];
}
- (void)viewDidAppear:(BOOL)animated
{
    [self admobHeightUpdate];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self admobHeightUpdate];
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAdView:nil];
    [super viewDidUnload];
}

- (IBAction)back:(id)sender {
    [TheSound playTapSound];
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)switchSound:(id)sender {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL on = [settings boolForKey:@"sound"];
    on = !on;
    [settings setBool:on forKey:@"sound"];
    [settings synchronize];
    if (on)
        [self.soundBtn setBackgroundImage:[UIImage imageNamed:@"sound on"] forState:UIControlStateNormal];
    else
        [self.soundBtn setBackgroundImage:[UIImage imageNamed:@"sound off"] forState:UIControlStateNormal];
    [TheSound playTapSound];
}
- (void) admobHeightUpdate {
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    admobHeight.constant=admobHeight1;
    admobHeightIpd.constant =admobHeight1;
}
@end
