//
//  HelpViewController.m
//  WordSearch
//
//  Created by apple on 13-8-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HelpViewController.h"
#import "TheSound.h"
#import "Admob.h"
#include "ApplovinMaxWrapper.h"
@interface HelpViewController ()
{
    __weak IBOutlet NSLayoutConstraint *admobHeightIpd;
    __weak IBOutlet NSLayoutConstraint *admobHeight;
}
@end

@implementation HelpViewController

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
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.helpImage.frame.size.height);
}

-(void) viewWillAppear:(BOOL)animated {
    [self admobHeightUpdate];
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
- (void)viewDidAppear:(BOOL)animated
{
    [self admobHeightUpdate];
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
    [TheSound playTapSound];
}
- (void) admobHeightUpdate {
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    admobHeight.constant=admobHeight1;
    admobHeightIpd.constant =admobHeight1;
}
@end
