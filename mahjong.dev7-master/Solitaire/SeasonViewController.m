//
//  SeasonViewController.m
//  Mahjong
//
//  Created by yysdsyl on 14-11-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SeasonViewController.h"
#import "TheSound.h"
#import "Solitaire.h"
#import "Admob.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
Solitaire* game;
#define FREE_HINTS_SETTING_KEY @"freehints" // 只用来判断是否为老用户
@interface SeasonViewController ()

@end

@implementation SeasonViewController
int freehintsTop;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /// game.dat
    NSString* path = [NSString stringWithFormat:@"%@/Documents/game.dat",NSHomeDirectory()];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        game = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        game = [[Solitaire alloc] init:nil];
        //[game freshGame:nil];
    }
    game.unlockone = -1;
    //
    [[AdmobViewController shareAdmobVC] decideShowRT:self];
    CGFloat _sc_width= [UIScreen mainScreen].bounds.size.width;   // 获取屏幕的宽度
    CGFloat _sc_height= [UIScreen mainScreen].bounds.size.height;  // 获取屏幕的高度
    NSLog(@"opencount left");
    [self preSetFreeHints];
    [self firstProtocolAlter];
//    if (_sc_width +_sc_height > 1500) {
//        [lazyking firstProtocolAlter];
//    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)onSpring:(id)sender {
    [TheSound playTapSound];
    game.groupId = 0;
    [self performSegueWithIdentifier:@"levelSegue" sender:self];
}

- (IBAction)onSummer:(id)sender {
    [TheSound playTapSound];
    game.groupId = 1;
    [self performSegueWithIdentifier:@"levelSegue" sender:self];
}

- (IBAction)onAutumn:(id)sender {
    [TheSound playTapSound];
    game.groupId = 2;
    [self performSegueWithIdentifier:@"levelSegue" sender:self];
}

- (IBAction)onWinter:(id)sender {
    [TheSound playTapSound];
    game.groupId = 3;
    [self performSegueWithIdentifier:@"levelSegue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[AdmobViewController shareAdmobVC] checkConfigUD];
}
//- (void)viewDidAppear:(BOOL)animated{
//    // load att
//    UtilByZh *lazyking = [[UtilByZh alloc] init];
//    [lazyking firstProtocolAlter];
//}

- (void) firstProtocolAlter {
    NSString * val = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"];
    if (!val) {
        
        //show alert
        
        ProtocolAlerView *alert = [ProtocolAlerView new];
        alert.viewController = self;
        alert.strContent = @"Thanks for using Mahjong!\nIn this app, we need some permission to access the photo library, and camera to choose or take a photo of you. In this process, We do not collect or save any data getting from your device including processed data. By clicking 'Agree' you confirm that you have read and agree to our privacy policy.\nAt the same time, Ads may be displayed in this app. When requesting to 'track activity' in the next popup, please click 'Allow' to let us find more personalized ads. It's completely anonymous and only used for relevant ads.";
        
        [alert showAlert:self cancelAction:^(id  _Nullable object) {
            //不同意
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
            //                   [self exitApplication];
        } privateAction:^(id  _Nullable object) {
            //   输入项目的隐私政策的 URL
            SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://www.shoreline.site/support/quarkltd/spadessolitaire/policy.html"]];
            //sfVC.delegate = self;
            [self presentViewController:sfVC animated:YES completion:nil];
           //         [self pushWebController:[YSCommonWebUrl userAgreementsUrl] isLoadOutUrl:NO title:@"用户协议"];
        } delegateAction:^(id  _Nullable object) {
            NSLog(@"用户协议");
            //   输入项目的隐私政策的 URL
            SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://www.shoreline.site/support/quarkltd/spadessolitaire/policy.html"]];
            //sfVC.delegate = self;
//            [self presentViewController:sfVC animated:YES completion:nil];
        }
        ];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
    }
}

-(void) preSetFreeHints {
    NSUserDefaults* settingss = [NSUserDefaults standardUserDefaults];id obj = [settingss objectForKey:FREE_HINTS_SETTING_KEY];
    if(obj == nil) {
        freehintsTop = 3;
        long opencount = [[[AdmobViewController shareAdmobVC] getAppUseStats] getAppOpenCountTotal];
        if(opencount > 3) {
            freehintsTop = 10000;
        }
        NSLog(@"opencount =%ld",opencount);
        [settingss setObject:[NSNumber numberWithInt:opencount] forKey:FREE_HINTS_SETTING_KEY];
        [settingss synchronize];
    }
}
@end
