//
//  OpViewController.m
//  WordSearch
//
//  Created by apple on 13-8-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "OpViewController.h"
#import "CAKeyframeAnimation+AHEasing.h"
#import "TheSound.h"
#import "Config.h"
#import "PlayViewController.h"
#import "TKAlertCenter.h"
#import "Config.h"
#import "Admob.h"
#include "ApplovinMaxWrapper.h"
@interface OpViewController ()
{
    __weak IBOutlet NSLayoutConstraint *admobHeight;
    BOOL show_banner;
}

@end

@implementation OpViewController
@synthesize opType;
@synthesize bestTime;

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
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    admobHeight.constant=admobHeight1;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pauseLabel.alpha = 0;
    if ([[UIScreen mainScreen] bounds].size.height >= 812) {
        self.pauseLabel.font=[UIFont systemFontOfSize:40 weight:UIFontWeightBold];
    }else{
        self.pauseLabel.font=[UIFont systemFontOfSize:35 weight:UIFontWeightBold];
    }
    self.timeLabel.alpha = 0;
    self.continueBtn.alpha = 0;
    self.nextBtn.alpha = 0;
    self.imageBottom.alpha = 0;
    self.imageStar1.alpha = 0;
    self.imageStar2.alpha = 0;
    self.imageStar3.alpha = 0;
    self.imageStar4.alpha = 0;
    self.imageStar5.alpha = 0;
    self.imageStar6.alpha = 0;
    self.imageStar7.alpha = 0;
    self.imageStar8.alpha = 0;
    self.imageStar9.alpha = 0;
    if (self.opType == OP_PAUSE) {
        self.continueBtn.alpha = 1;
        self.pauseLabel.text = @"GAME PAUSED";
    }
    else if(self.opType == OP_NEXT)
    {
        self.nextBtn.alpha = 1;
        self.timeLabel.alpha = 1;
        self.pauseLabel.text = @"GAME WIN";
        self.timeLabel.text = [NSString stringWithFormat:@"TIME COST: %02d:%02d",self.bestTime/60,self.bestTime%60];
        [self showStar];
    }
    ///
    /// admob
    /*
    GADBannerView* bannerView_;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                0.0,
                                                GAD_SIZE_728x90.width,
                                                GAD_SIZE_728x90.height)];
    }
    else
    {
        bannerView_ = [[GADBannerView alloc]
                       initWithFrame:CGRectMake(0.0,
                                                0.0,
                                                GAD_SIZE_320x50.width,
                                                GAD_SIZE_320x50.height)];
    }
    bannerView_.adUnitID = GOOGLE_BANNER_ID;
    bannerView_.rootViewController = self;
    [self.adView addSubview:bannerView_];
    [bannerView_ loadRequest:[GADRequest request]];
     */
}

- (void)setType:(NSInteger)type
{
    self.opType = type;
}

- (void)setTime:(NSInteger)time
{
    self.bestTime = time;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    CGPoint targetCenter = self.pauseLabel.center;
    self.pauseLabel.center = CGPointMake(targetCenter.x, 0);
    self.pauseLabel.alpha = 1;
    [UIView animateWithDuration:0.1 animations:^(void){
        ;
    }completion:^(BOOL finished){
        CALayer *layer= [self.pauseLabel layer];
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.750] forKey:kCATransactionAnimationDuration];
        CAAnimation *chase = [CAKeyframeAnimation animationWithKeyPath:@"position" function:BounceEaseOut fromPoint:self.pauseLabel.center toPoint:targetCenter];
        [chase setDelegate:self];
        [layer addAnimation:chase forKey:@"position"];
        [CATransaction commit];
        [self.pauseLabel setCenter:targetCenter];
        //
        if (self.opType == OP_NEXT)
        {
        }
    }];
    //
//    if (self.opType == OP_NEXT) {
//        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//        int timecnt = [[settings objectForKey:@"cnt"] integerValue];
//        if (timecnt % 3 == 0) {
//            [self showRate];
//        }
//    }
    [AdmobViewController shareAdmobVC].delegate=self;
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
    
}

- (void)viewDidUnload {
    [self setPauseLabel:nil];
    [self setTimeLabel:nil];
    [self setAdView:nil];
    [self setImageStar1:nil];
    [self setImageStar2:nil];
    [self setImageStar3:nil];
    [self setImageStar4:nil];
    [self setImageStar5:nil];
    [self setImageStar6:nil];
    [self setImageStar7:nil];
    [self setImageStar8:nil];
    [self setImageStar9:nil];
    [self setImageBottom:nil];
    [self setContinueBtn:nil];
    [self setNextBtn:nil];
    [super viewDidUnload];
}
- (IBAction)toHome:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
    UINavigationController* nav = (UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    PlayViewController* pvc = (PlayViewController*)[nav topViewController];
    [pvc removeNotification];
    [nav popViewControllerAnimated:YES];
    [TheSound playTapSound];
}

- (IBAction)nextGame:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"nextgame" object:@""];
    [TheSound playTapSound];
}

- (IBAction)continueGame:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
    [TheSound playTapSound];
}

- (void)showStar
{
    int time = self.bestTime;
    if (time > 0) {
        self.imageBottom.alpha = 1;
        self.imageStar1.alpha = 0;
        self.imageStar2.alpha = 0;
        self.imageStar3.alpha = 0;
        self.imageStar4.alpha = 0;
        self.imageStar5.alpha = 0;
        self.imageStar6.alpha = 0;
        self.imageStar7.alpha = 0;
        self.imageStar8.alpha = 0;
        self.imageStar9.alpha = 0;
        if (time < 25) {
            self.imageStar3.alpha = 1;
            self.imageStar6.alpha = 1;
            self.imageStar9.alpha = 1;
        }
        else if (time < 50)
        {
            self.imageStar3.alpha = 1;
            self.imageStar6.alpha = 1;
            self.imageStar8.alpha = 1;
        }
        else if (time < 75)
        {
            self.imageStar3.alpha = 1;
            self.imageStar6.alpha = 1;
            self.imageStar7.alpha = 1;
        }
        else if (time < 100)
        {
            self.imageStar3.alpha = 1;
            self.imageStar6.alpha = 1;
        }
        else if (time < 125)
        {
            self.imageStar3.alpha = 1;
            self.imageStar5.alpha = 1;
        }
        else if (time < 150)
        {
            self.imageStar3.alpha = 1;
            self.imageStar4.alpha = 1;
        }
        else if (time < 175)
        {
            self.imageStar3.alpha = 1;
        }
        else if (time < 200)
        {
            self.imageStar2.alpha = 1;
        }
        else if (time < 225)
        {
            self.imageStar1.alpha = 1;
        }
    }
    else
    {
        self.imageBottom.alpha = 0.6;
        self.imageStar1.alpha = 0;
        self.imageStar2.alpha = 0;
        self.imageStar3.alpha = 0;
        self.imageStar4.alpha = 0;
        self.imageStar5.alpha = 0;
        self.imageStar6.alpha = 0;
        self.imageStar7.alpha = 0;
        self.imageStar8.alpha = 0;
        self.imageStar9.alpha = 0;
    }
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
