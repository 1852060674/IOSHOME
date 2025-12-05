//
//  FakeLanchWindow.m
//  HairColor
//
//  Created by ZB_Mac on 16/3/7.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "FakeLanchWindow.h"
#import "Admob.h"

@interface NonStatusBarVC : UIViewController

@end

@implementation NonStatusBarVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

@interface FakeLanchWindow ()<AdmobViewControllerDelegate>
{
    BOOL _showingPop;
}
@property (nonatomic, strong) NonStatusBarVC *controller;
@end

@implementation FakeLanchWindow
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        _controller = [[NonStatusBarVC alloc] init];
        self.rootViewController = _controller;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
//        NSString *name = [[NSBundle mainBundle] pathForResource:@"Lanch_6" ofType:@"png"];
        UIImage *image = [UIImage imageNamed:@"LaunchImage"];
        imageView.image = image;
        
        _controller.view.backgroundColor = [UIColor clearColor];
        [_controller.view addSubview:imageView];
    }
    return self;
}

-(void)becomeKeyWindow
{
    
    [AdmobViewController shareAdmobVC].delegate = self;
    BOOL shown = NO;
#ifdef ENABLE_AD
    shown = [[AdmobViewController shareAdmobVC] try_show_admob_interstitial:_controller placeid:1 ignoreTimeInterval:NO];
#endif
    if (!shown) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!_showingPop) {
                [self dismiss];
            }
        });
    }

    _showingPop = shown;
}

-(void)dismiss
{
    for (UIView*view in _controller.view.subviews) {
        [view removeFromSuperview];
    }
    
    self.rootViewController = nil;
    _controller = nil;
    
    if ([AdmobViewController shareAdmobVC].delegate == self) {
        [AdmobViewController shareAdmobVC].delegate = nil;
    }
    
    if ([self isKeyWindow]) {
        NSArray *windows = [UIApplication sharedApplication].windows;
        
        for (UIWindow *window in windows) {
            if (window != self && ![window isHidden]) {
                [window makeKeyAndVisible];
                break;
            }
        }
    }
    
    HomeViewController *uiController = self.preController;
    uiController.fakeLanchWindow = nil;
}

#pragma mark - AdmobViewControllerDelegate
#pragma mark - AdmobViewControllerDelegate
-(void)adMobVCDidReceiveInterstitialAd:(AdmobViewController *)adMobVC
{
#ifdef ENABLE_AD
    if(!_showingPop) {
        _showingPop = [[AdmobViewController shareAdmobVC] try_show_admob_interstitial:_controller placeid:1 ignoreTimeInterval:NO];
    }
#endif
}

-(void)adMobVCDidCloseInterstitialAd:(AdmobViewController *)adMobVC
{
    _showingPop = NO;
    [self dismiss];
}

-(void)adMobVCWillCloseInterstitialAd:(AdmobViewController *)adMobVC
{
    _controller.view.hidden = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
