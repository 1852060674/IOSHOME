//
//  HomeViewController.m
//  VoiceChanger
//
//  Created by tangtaoyu on 15/5/25.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import "HomeViewController.h"
#import "MGDefine.h"
#import "VoiceViewController.h"
#import <UIKit/UIKit.h>
#import "AudioConvert.h"
#import "DotimeManage.h"
#import "Recorder.h"
#import "MGFile.h"
#import "MGVoice.h"
#import "MGData.h"
#import "MGVoiceDefine.h"
#import "AppDelegate.h"
#include "ApplovinMaxWrapper.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
@interface HomeViewController
()<DotimeManageDelegate,UIAlertViewDelegate>
{
   
    UIView *speakView;
    UILabel *timeLabel;
    UIButton *speakBtn;
    float pianyiy;
    DotimeManage *timeManager;
    AudioConvertOutputFormat outputFormat; //输出音频格式
    
    BOOL isInRecord;
    BOOL show_banner;
    
    NSInteger voiceTimeLength;
    
    JASidePanelController *jaPC;
}
@property (nonatomic, strong) UIView* adview;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[UIScreen mainScreen] bounds].size.height >= 812 ){
        if ([[UIScreen mainScreen] bounds].size.height+ [[UIScreen mainScreen] bounds].size.width <1500 ) {
            pianyiy=44;
            if ( @available(ios 14.5, *) )
            {
                pianyiy=50;
            }
        }else{
            // ipd kNavigationBarHeight in homeviewcontroller value 50
            pianyiy=6;
        }
        
    }
    NSLog(@"zzx %lf",pianyiy);
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    jaPC = app.jaSPC;
    
    isInRecord = NO;
    show_banner=NO;
    outputFormat = kVoiceOutputFormat;
    voiceTimeLength = 0;
    
    [self naviInit];
    [self widgetsInit];
    [self soundInit];
    
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];

    // 调用方法获取 AdMob 的高度
    CGFloat admobHeight = [applovinWrapper getAdmobHeight];
    
    self.adview = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight+pianyiy, kScreenWidth, 100)];
//    self.adview.backgroundColor=[UIColor redColor];
    NSLog(@"zzx221 %lf",admobHeight);
    [self.view addSubview:self.adview];
    NSLog(@"zzx2 %lf",kNavigationBarHeight);
    NSLog(@"zzx2 %lf",self.adview.center.y);
    if(![[AdmobViewController shareAdmobVC] ifNeedShowNext:self]) {
        [[AdmobViewController shareAdmobVC] decideShowRT:self];
    }
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
//    [self setNeedsStatusBarAppearanceUpdate];
//    [self preferredStatusBarStyle];//
//    [self firstProtocolAlter];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;//
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adview placeid:@"homepage"];
    
    self.navigationController.navigationBarHidden = NO;
    
    [self firstProtocolAlter];
}

- (void)widgetsInit
{
    UIImageView *bgIV = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgIV.image = [UIImage imageNamed:@"background.jpg"];
    [self.view addSubview:bgIV];
    
    float speakH = kDevice3(160., 180., 250.);
    float bottomH = kDevice3(40., 40., 60.);
    NSLog(@" zzx speakH =%lf",speakH);
//    NSLog(@" zzx showIheight2 =%lf",kNavigationBarHeight+kSmartAdHeight+(showIVH-showIVH0)/2+changeshowIVH0Y);
    float showIVH = (kScreenHeight - speakH - bottomH - kNavigationBarHeight - kSmartAdHeight);
    NSLog(@" zzx kScreenHeight =%lf",kScreenHeight);
    float showIVH0 = showIVH/1.5;
    float changeSpeakBtnY=0;
    float changeshowIVH0Y=0;
    if ([[UIScreen mainScreen] bounds].size.height >= 812 && [[UIScreen mainScreen] bounds].size.height+ [[UIScreen mainScreen] bounds].size.width <1500) {
        // iPhone 11 375x812
        showIVH0 = showIVH/1.5/1.5;
        changeSpeakBtnY=100.0-30;
        changeshowIVH0Y=30;
        
    }
    if ([[UIScreen mainScreen] bounds].size.height <812) {
        changeshowIVH0Y=44;
        changeSpeakBtnY=-30;
    }
    UIImageView *showIV = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-showIVH0)/2, kSmartAdHeight+(showIVH-showIVH0)/2+changeshowIVH0Y, showIVH0, showIVH0)];
    NSLog(@" zzx showIheight =%lf",kSmartAdHeight+(showIVH-showIVH0)/2+changeshowIVH0Y);
    showIV.image = [UIImage imageNamed:@"show_original"];
    [self.view addSubview:showIV];
    
    float ivH = speakH*0.4;
    float btnH = speakH*0.6;
    
    speakView = [[UIView alloc] init];
    speakView.frame = CGRectMake(0, kScreenHeight-kNavigationBarHeight-speakH-bottomH, kScreenWidth, speakH);
    [self.view addSubview:speakView];
    
    
    UIImageView *timeIV = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-ivH*1.25)/2, 0-changeSpeakBtnY, ivH*1.25, ivH)];
    timeIV.image = [UIImage imageNamed:@"jishiqi"];
    [speakView addSubview:timeIV];
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth-ivH*1.25)/2, 0-changeSpeakBtnY, ivH*1.25, ivH*0.9)];
    timeLabel.font = [UIFont systemFontOfSize:26.];
    timeLabel.textColor = [UIColor redColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [speakView addSubview:timeLabel];
    

    speakBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    speakBtn.frame = CGRectMake((kScreenWidth-btnH)/2, speakH-btnH-changeSpeakBtnY, btnH, btnH);
    [speakBtn setImage:[UIImage imageNamed:@"speak_normal"] forState:UIControlStateNormal];
    [speakBtn addTarget:self action:@selector(clickSpeakBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [speakView addSubview:speakBtn];
    
    timeManager = [DotimeManage DefaultManage];
    [timeManager setDelegate:self];
}

- (void)clickSpeakBtn
{
    if([MGData Instance].launchCount == 1){
        [MGVoice AccessToMicroPhone];
        [self performSelector:@selector(toSpeak) withObject:nil afterDelay:0.5];
        return;
    }

    [self toSpeak];
}

- (void)toSpeak
{
    if([MGVoice AccessToMicroPhone]){
        NSLog(@"Microphone is enabled..");
        [self clickAccessSpeakBtn];
        
    }else{
        NSLog(@"Microphone is disabled..");
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MG_ACCESS_TIPS", nil)
                                                                message:NSLocalizedString(@"MG_ACCESS_MICROPHONE", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"MG_ACCESS_OK", nil)
                                                      otherButtonTitles:nil];
            
            [alertView show];
        });
    }
}

- (void)clickAccessSpeakBtn
{
    speakBtn.enabled = NO;
    if(!isInRecord){
        isInRecord = YES;
        
        [speakBtn setImage:[UIImage imageNamed:@"speak_pause"] forState:UIControlStateNormal];

        [self playSound];
    }else{
        isInRecord = NO;

        [self voiceEnd];
        [speakBtn setImage:[UIImage imageNamed:@"speak_normal"] forState:UIControlStateNormal];
        [self playSound];
    }
}

- (void)recordThing
{
    [self voiceBegin];
}
//zzx
- (void)endRecordThing
{
    VoiceViewController *voiceVC = [[VoiceViewController alloc] init];
    voiceVC.outputFormat = outputFormat;
    voiceVC.voiceTimeLength = voiceTimeLength;
    voiceVC.fileName = [Recorder shareRecorder].filename;
    voiceVC.filePath = [Recorder shareRecorder].filePath;
    voiceVC.isPresent = NO;
    
    [MGData tryShowAdsInVC:self.navigationController];
    [self.navigationController pushViewController:voiceVC animated:YES];
    
    [voiceVC setBackBlock:^(){
        timeLabel.text = @"";
    }];
}

- (void)voiceBegin
{
    timeLabel.text = @"0";
    
    voiceTimeLength = 0;
    //录音
    [timeManager setTimeValue:30];
    [timeManager startTime];
    
    [[Recorder shareRecorder] startRecord];
}

- (void)voiceEnd
{
    [timeManager stopTimer];
    [[Recorder shareRecorder] stopRecord];
    
    NSInteger times;
    NSError *err = nil;
    AVAudioPlayer *aPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[Recorder shareRecorder].filename] error:&err];
    if(!err){
        times = aPlayer.duration;
    }else{
        times = (int)ceil(voiceTimeLength);
    }
    
    [MGFile pushVoiceOriWith:[Recorder shareRecorder].filename];
    [MGFile pushVoicePathWith:@{kVoiceNum:[NSString stringWithFormat:@"%i",(int)[MGFile Instance].voiceIndex],
                                kVoiceName:[Recorder shareRecorder].filename,
                                kVoiceCate:@"0",
                                kVoiceTime:[NSString stringWithFormat:@"%i", times],
                                kVoiceCustom:@"0,0",
                                kVoiceDate:[self createFilename]
                                }];
}

- (void)TimerActionValueChange:(int)time; //时间改变
{
    timeLabel.text = [NSString stringWithFormat:@"%i", time];
    voiceTimeLength = time;
    
    if(time >= 60){
        [self clickAccessSpeakBtn];
    }
}

- (void)soundInit
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"notice" ofType:@"caf"];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
    
    NSString *string = [[NSBundle mainBundle] pathForResource:@"notice_mini" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:string];
    NSError *err = nil;
    if (audioPalyer) {
        [audioPalyer stop];
        audioPalyer = nil;
    }
    audioPalyer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    audioPalyer.delegate = self;
//    audioPalyer.volume = 0.3;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [audioPalyer stop];
    
    if(isInRecord){
        speakBtn.enabled = YES;
        [self recordThing];
    }else{
        [self endRecordThing];
        speakBtn.enabled = YES;
    }
}

- (void)naviInit
{
    NSShadow *shadow = [NSShadow new];
    UIColor *color = [UIColor colorWithRed:162/255.0 green:177/255.0 blue:180/255.0 alpha:1.0];
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],
                                 NSShadowAttributeName:color,
                                 NSFontAttributeName:[UIFont fontWithName:@"Arial-Bold" size:0.0]
                                 };
    
    [shadow setShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f]];
    [shadow setShadowOffset: CGSizeMake(0.0f, 1.0f)];
    //改变背景颜色
    appearance.backgroundColor=color;
    self.navigationController.navigationBar.standardAppearance=appearance;
    self.navigationController.navigationBar.scrollEdgeAppearance= appearance;
    if ( @available(ios 14.5, *) )
    {
        self.navigationController.navigationBar.compactScrollEdgeAppearance=appearance;
    }
//    self.navigationItem.title = NSLocalizedString(@"MG_RECORD", nil);
     
    UIImage *backgroundImage = [UIImage imageNamed:@"navibar"];
    [appearance setBackgroundImage:backgroundImage];
    [appearance setTitleTextAttributes:attributes];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
   // 改变按钮颜色
//    self.navigationController.navigationBar.barTintColor=color;
    
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
}

- (NSString *)createFilename
{
    NSDate *date_ = [NSDate date];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"yyyy.MM.dd_HH.mm.ss"];
    NSString *timeFileName = [dateformater stringFromDate:date_];
    return timeFileName;
}


- (void)playSound
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
//                   ^{
//                       AudioServicesPlaySystemSound(soundID);
//                   });
    
    [audioPalyer play];
}

// att
- (void) firstProtocolAlter {
    NSString * val = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"];
    if (!val) {
        
        //show alert
        
        ProtocolAlerView *alert = [ProtocolAlerView new];
        alert.homeViewController = self;
        alert.strContent = @"Thanks for using Voice Changer!\nIn this app, we need permission to access the microphone, take a recording of you voice, then process and make change on that voice. In this procedure, we do not collect or save any data getting from your device including processed data. By clicking 'Agree' you confirm that you have read and agree to our privacy policy.\nAt the same time, Ads may be displayed in this app. When requesting to 'track activity' in the next popup, please click 'Allow' to let us find more personalized ads. It's completely anonymous and only used for relevant ads.";
        
        [alert showAlert:self cancelAction:^(id  _Nullable object) {
            //不同意
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
            //                   [self exitApplication];
        } privateAction:^(id  _Nullable object) {
            //   输入项目的隐私政策的 URL
            SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://happyhollow.online/support/funnyphoto/voicechanger/policy.html"]];
//            sfVC.delegate = self;
            [self presentViewController:sfVC animated:YES completion:nil];
//                    [self pushWebController:[YSCommonWebUrl userAgreementsUrl] isLoadOutUrl:NO title:@"用户协议"];
        } delegateAction:^(id  _Nullable object) {
            NSLog(@"用户协议");
            //   输入项目的隐私政策的 URL
            SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://happyhollow.online/support/funnyphoto/voicechanger/policy.html"]];
//            sfVC.delegate = self;
            [self presentViewController:sfVC animated:YES completion:nil];
        }
        ];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 视图布局完成后
    if (!show_banner) {
        [[AdmobViewController shareAdmobVC] show_admob_banner:self.adview placeid:@"homepage"];
        
        show_banner=YES;
    }
}

- (BOOL)prefersStatusBarHidden
{
    if ([[UIScreen mainScreen] bounds].size.height >= 812 && [[UIScreen mainScreen] bounds].size.height+ [[UIScreen mainScreen] bounds].size.width <1500) {
        return NO;
    }
    return YES;
}

@end
