//
//  ViewController.m
//  why you lying
//
//  Created by awt on 15/10/25.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "ViewController.h"
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "Soubdutton.h"
#import "TheSound.h"
#import "Admob.h"
#import "CommonSet.h"
#import "Masonry/Masonry.h"
#import "ProtocolAlerView.h"
#include "ApplovinMaxWrapper.h"
#import <SafariServices/SafariServices.h>
#define REVIEW_SIGN (@"revie_sian")
@interface ViewController ()<SoundButtonDelegate,AdmobViewControllerDelegate>
{
    float waveHeight;
    float waveLongth;
    float waveSpeed;
    float waveFreaunte;
    int waveCounter;
    BOOL isShowRes;
    CGPoint waveStartPoint;
    CAShapeLayer *myLayer;
    AVAudioRecorder *recorder;
    CADisplayLink *myLink;
    BOOL isGreen;
}

@property (weak, nonatomic) IBOutlet UIView *waveBtn;
@property (strong,nonatomic) NSMutableArray *layerArray;
@property (strong,nonatomic) Soubdutton *imageButton;
@property (nonatomic) BOOL isBeyond13;
@property (strong,nonatomic) UIImageView *resImageView;
@property (weak, nonatomic) IBOutlet UIButton *microPhoneBtn;
@property (nonatomic , strong) UIImageView *topView;
@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) UIImageView *middleView;
@property (strong,nonatomic) UIButton *ageStateView;
@property (strong,nonatomic) UIImageView *animationView;
@property (strong,nonatomic) UIImageView *signView;
@property NSInteger continueTime ;
@property BOOL lastState;

@property (strong,nonatomic) UIView *adview;
@property (weak, nonatomic) IBOutlet UIView *AdView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *admobHeight;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    srandom(time(NULL));
    isShowRes = NO;
    [self layoutOutTopView];
    [self layoutScrolleView];
    [self layoutSoundBtn];
    [self layoutBtnView];
    [self showWave];
    [self setContinueTime:0];
    [self setLastState:NO];
    // Do any additional setup afterloading the view, typically from a nib.
    if(![[AdmobViewController shareAdmobVC] ifNeedShowNext:self]) {
        [[AdmobViewController shareAdmobVC] decideShowRT:self];
    }
    
//    [self addBannerAd];
    [AdmobViewController shareAdmobVC].delegate = self;
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    _admobHeight.constant=admobHeight1;
    [self.view addSubview:self.AdView];
    [[AdmobViewController shareAdmobVC] checkConfigUD];
}
// 2024.1.1 by zzx 在代码中添加adview 在非刘海屏的情况下，出现了admob高度不准确的情况，通过获取max+5解决，此外由于原因不知，采取storybraod中添加adview来适配。
- (void) addBannerAd {
    [AdmobViewController shareAdmobVC].delegate = self;
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    if ([[UIScreen mainScreen] bounds].size.height < 812) {
        admobHeight1=admobHeight1+5;
        }
    if(IS_IPHONE4) {
        self.adview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, admobHeight1)];
        [self.view addSubview:self.adview];
    } else {
        self.adview = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-admobHeight1, self.view.frame.size.width, admobHeight1)];
        self.adview.translatesAutoresizingMaskIntoConstraints = FALSE;
        [self.view addSubview:self.adview];
        

        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:self.adview
                                  attribute:NSLayoutAttributeBottom
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.bottomLayoutGuide
                                  attribute:NSLayoutAttributeTop
                                  multiplier:1
                                  constant:0]];
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:self.adview
                                  attribute:NSLayoutAttributeLeading
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeLeading
                                  multiplier:1
                                  constant:0]];
        [self.view addConstraint:[NSLayoutConstraint
                                  constraintWithItem:self.adview
                                  attribute:NSLayoutAttributeTrailing
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.view
                                  attribute:NSLayoutAttributeTrailing
                                  multiplier:1
                                  constant:0]];
        [self.adview addConstraint:[NSLayoutConstraint
                                    constraintWithItem:self.adview
                                    attribute:NSLayoutAttributeHeight
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                    attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1
                                    constant:admobHeight1]];
    }
    
    
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adview placeid:@"mainpage"];
}

- (void) layoutOutTopView
{
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.view.frame];
    [bgView setImage:[UIImage imageNamed:@"bg"]];
    [self.view addSubview:bgView];
    
    
    
    float neededWidth = WIDTH*0.8;
    if (IS_IPHONE4) {
        neededWidth *= 0.9;
    }
    else if (IS_IPAD)
    {
        neededWidth *= 0.8;
    }
    CGRect frame =  CGRectMake(0, 0, neededWidth, neededWidth*454/1171);
    if (IS_IPAD) {
        frame.origin.y = 100;
    }
    else  if(IS_IPHONE4){
        frame.origin.y = 55;
    }
    else {
        frame.origin.y = 70;
    }
    frame.origin.x =  (WIDTH - neededWidth)*0.5;
    
    UIImageView *topView = [[UIImageView alloc] initWithFrame:frame];
    [topView setImage:[UIImage imageNamed:@"trueView"]];
    [self.view addSubview:topView];
    [self setTopView:topView];
    
    
}

- (void) layoutScrolleView
{
    
    float neededWidth = WIDTH*0.6;
    if (IS_IPHONE4) {
        neededWidth *= 0.9;
    }
    else if (IS_IPAD)
    {
        neededWidth *= 0.8;
    }
    CGRect frame = CGRectMake(0, 0,neededWidth, neededWidth*0.3);
    frame.origin.x = (WIDTH- neededWidth)*0.5;
    frame.origin.y = self.topView.frame.origin.y + neededWidth*0.13;
    UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:frame];
    [scrollview setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:scrollview];
    CGRect frame1= frame;
    frame1.size.height = frame.size.width*155/1055;
    UIImageView *signView = [[UIImageView alloc] initWithFrame:frame1];
    [signView setCenter:scrollview.center];
    [signView setImage:[UIImage imageNamed:@"sign"]];
    [self.view addSubview:signView];
    [self setSignView:signView];
    [self.view bringSubviewToFront:self.topView];
    [scrollview  setShowsHorizontalScrollIndicator:NO];
    [scrollview setShowsVerticalScrollIndicator:YES];
    frame.origin = CGPointZero;
    frame.origin.y =frame.size.height*0.15;
    frame.size.height *= 0.7;
    frame.size.width = frame.size.height *1301/155;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:[UIImage imageNamed:@"true"]];
    [scrollview addSubview:imageView];
    
    [self setScrollView:scrollview];
    [self setResImageView:imageView];
    [self.resImageView setHidden:YES];
}

- (void) layoutSoundBtn
{
    
    float neededWidth = WIDTH *0.65;
    if (IS_IPHONE4) {
        neededWidth *= 0.9;
    }
    else if (IS_IPAD)
    {
        neededWidth *= 0.8;
    }
    CGRect frame = CGRectMake(0, 0, neededWidth, neededWidth*1060/849);
    frame.origin.x = (WIDTH - neededWidth)*0.5;
    frame.origin.y = self.topView.frame.origin.y+self.topView.frame.size.height*0.9;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:[UIImage imageNamed:@"fingerOutline"]];
    [self.view addSubview:imageView];
    [self setMiddleView:imageView];
    [imageView setUserInteractionEnabled:YES];
    [self setImageButton:[[Soubdutton alloc] initWithFrame:CGRectMake(neededWidth*0.234, neededWidth*0.2, neededWidth*0.6, neededWidth*0.6*732/491)]];
    [imageView addSubview:self.imageButton];
    [self.imageButton setSoundDelegate:self];
    

    
        //
    frame.origin = CGPointZero;
    frame.size.width *=2.5;
//    
//    [self setResLable:[[UILabel alloc] initWithFrame:frame]];
//    [self.resLable setTextColor:[UIColor whiteColor]];
//    [self.view addSubview:self.resLable];
//   // [self.resLable setBackgroundColor:[UIColor whiteColor]];
//    [self.resLable setHidden:YES];
//    [self.resLable.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
//    [self.resLable setTextAlignment:NSTextAlignmentCenter];
//    [self.scrollView addSubview:self.resLable];
}
- (void) layoutBtnView
{
    
    float neededWidth = WIDTH * 0.85;
    if (IS_IPHONE4) {
        neededWidth *= 0.9;
    }
    else if (IS_IPAD)
    {
        neededWidth *= 0.8;
    }
    CGRect frame = self.middleView.frame;
    frame.origin.y += frame.size.height;
    frame.origin.x -= neededWidth*0.06;
    frame.size.width = neededWidth;
    frame.size.height = neededWidth * 321 /959;
    
    UIImageView  *imageView = [[UIImageView alloc] initWithFrame:frame];
    [imageView setImage:[UIImage imageNamed:@"button"]];
    [self.view addSubview:imageView];
    [imageView setUserInteractionEnabled:YES];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(neededWidth*0.05, neededWidth*0.08, neededWidth*0.55, neededWidth*0.55*259/564)];
    
 
    [imageView addSubview:btn];
    [btn addTarget:self action:@selector(changeAgeState:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *stateView = [[UIButton alloc]initWithFrame:CGRectMake(neededWidth*0.65, neededWidth*0.15, neededWidth*0.2, neededWidth*0.2*97/192)];
    
    [stateView setUserInteractionEnabled:NO];
    [imageView addSubview:stateView];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_13]) {
        [btn setImage:[UIImage imageNamed:@"belowNormle"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"belowPess"] forState:UIControlStateHighlighted];
        [stateView  setBackgroundImage:[UIImage imageNamed:@"over"] forState:UIControlStateNormal];
    }
    else {
        [btn setImage:[UIImage imageNamed:@"overNormle"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"overPress"] forState:UIControlStateHighlighted];
        [stateView  setBackgroundImage:[UIImage imageNamed:@"below"] forState:UIControlStateNormal];
    }
    [self setAgeStateView:stateView];
    
    [imageView setHidden:TRUE];
    [btn setHidden:TRUE];
    [stateView setHidden:TRUE];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void) beginAnimation
{
    [myLink setPaused:NO];
    [self.signView  setHidden:YES];
}

- (void) adMobVCDidCloseInterstitialAd:(AdmobViewController *)adMobVC
{
    if (isShowRes) {
        [self stopAnimationWithResult:YES];
        isShowRes = NO;
    }
}

- (void) stopAnimationWithResult:(BOOL)isTrueOrFalse
{
    [myLink setPaused:YES];
    [self.animationView setCenter:CGPointMake(self.animationView.center.x , self.topView.frame.size.height*0.8)];
    if ([[AdmobViewController shareAdmobVC] try_show_admob_interstitial:self ignoreTimeInterval:NO]) {
        isShowRes = YES;
        [AdmobViewController shareAdmobVC].delegate = self;
        return;
    }
    //
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
    [self.resImageView setHidden:NO];
    CGRect frame = self.resImageView.frame;
    
    int res = random() %2;
    if (res == 0) {
        isTrueOrFalse = YES;
    }
    else {
        isTrueOrFalse = NO;
    }
    if (self.lastState == isTrueOrFalse) {
        self.continueTime++;
    }
    else {
        [self setLastState:isTrueOrFalse];
        [self setContinueTime:1];
    }
    if (self.continueTime == 4) {
        [self setLastState:!isTrueOrFalse];
        [self setContinueTime:1];
    }
    if (isTrueOrFalse) {

        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_13]) {
            [TheSound playFalseAdultSound];
        }
        else {
            [TheSound playFalseAdultSound];
        }
        frame.size.width = frame.size.height*1385/155;
        [self.resImageView setFrame:frame];
        [self.resImageView setImage:[UIImage imageNamed:@"false"]];
        [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
            [self.scrollView.layer setBackgroundColor:[[UIColor redColor] CGColor]];
            

        } completion:^(BOOL finished) {
        }];
        
    }
    else {
        frame.size.width = frame.size.height*1301/155;
        [self.resImageView setFrame:frame];
        [self.resImageView setImage:[UIImage imageNamed:@"true"]];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_13]) {
            [TheSound playTrueAdultSound];
        }
        else {
            [TheSound playTrueChildSound];
        }
        [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
          //  [UIView setAnimationRepeatCount:10];
            [self.scrollView.layer setBackgroundColor:[[UIColor blueColor] CGColor]];
                    } completion:^(BOOL finished) {
     
                    }];
        
    }

    NSTimeInterval duration ;
    if (isTrueOrFalse) {
        duration = 4;
    }
    else {
        duration = 4;
    }
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        [self.resImageView setCenter:CGPointMake(-self.resImageView.frame.size.width*0.5, self.resImageView.center.y)];
    } completion:^(BOOL finished) {
        [self.resImageView setFrame:frame];
        [self.resImageView setHidden:YES];
        [self.scrollView.layer removeAllAnimations];
        [self.scrollView.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
        [self.imageButton setUserInteractionEnabled:YES];
         [self.signView setHidden:NO];
    }];
}



- (void) showWave
{

    CGRect frame = self.topView.frame;
    frame.origin.x = 0 ;
     frame.origin.y = frame.size.height*0.8;
    frame.size.height = frame.size.width*82/1171;
   
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 1; i < 6; i++) {
        [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d",i]]];
    }
    [imageView setAnimationImages:array];
    [imageView setAnimationDuration:0.5];
    [imageView startAnimating];
    [imageView setImage:[UIImage imageNamed:@"1"]];
    [self.topView addSubview:imageView];
    [self setAnimationView:imageView];
    myLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(theMAve:)];
    [myLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [myLink setPaused:YES];
   
     //[myLayer setDelegate:self];
    
}

- (void) openMacPhone
{

}

- (void)viewWillAppear:(BOOL)animated
{
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.AdView placeid:@"mainpage"];
    [self firstProtocolAlter];
}
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
}

- (void) theMAve : (CADisplayLink  *)disPlayLink
{
   double volume =  [self.imageButton getCerrentVolume];
    
    UIColor *green;
    
    if (volume > 0.1) {
        green = [[UIColor greenColor] colorWithAlphaComponent:0.2+0.8*volume];
        volume = 0.4 + 0.6*volume;
        
    }
    else {
        green = [[UIColor greenColor] colorWithAlphaComponent:0.2+volume];
        volume = 0.2+volume;
    }
    [self.scrollView setBackgroundColor:green];
    CGPoint  center = self.animationView.center;
    center.y = self.topView.frame.size.height*0.8-self.topView.frame.size.height*0.5*volume;
//    if (isGreen) {
//        [self.scrollView setBackgroundColor:[UIColor greenColor]];
//        isGreen = NO;
//    }
//    else {
//        [self.scrollView setBackgroundColor:[UIColor clearColor]];
//        isGreen = YES;
//    }
    [self.animationView setCenter:center];
    
}

- (IBAction)changeAgeState:(UIButton *)sender
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:IS_13]) {
        [sender setImage:[UIImage imageNamed:@"belowNormle"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"belowPess"] forState:UIControlStateHighlighted];
        [self.ageStateView  setBackgroundImage:[UIImage imageNamed:@"over"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_13];
    }
    else {
        [sender setImage:[UIImage imageNamed:@"overNormle"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"overPress"] forState:UIControlStateHighlighted];
        [self.ageStateView  setBackgroundImage:[UIImage imageNamed:@"below"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_13];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}
// att
- (void) firstProtocolAlter {
    NSString * val = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"];
    if (!val) {
        
        //show alert
        
        ProtocolAlerView *alert = [ProtocolAlerView new];
        alert.viewController = self;
        alert.strContent = @"Thanks for using WhyYouLying!\nBy clicking 'Agree' you confirm that you have read and agree to our privacy policy.\nAt the same time, Ads may be displayed in this app. When requesting to 'track activity' in the next popup, please click 'Allow' to let us find more personalized ads. It's completely anonymous and only used for relevant ads.";
        
        [alert showAlert:self cancelAction:^(id  _Nullable object) {
            //不同意
            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
            //                   [self exitApplication];
        } privateAction:^(id  _Nullable object) {
            //   输入项目的隐私政策的 URL
            SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://www.shoreline.site/support/quarkltd/spadessolitaire/policy.html"]];
            //sfVC.delegate = self;
//            [self presentViewController:sfVC animated:YES completion:nil];
            //        [self pushWebController:[YSCommonWebUrl userAgreementsUrl] isLoadOutUrl:NO title:@"用户协议"];
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
@end
