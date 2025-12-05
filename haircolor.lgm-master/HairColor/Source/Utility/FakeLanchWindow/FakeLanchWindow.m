//
//  FakeLanchWindow.m
//  HairColor
//
//  Created by ZB_Mac on 16/3/7.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "FakeLanchWindow.h"
#import "AdUtility.h"
#import "CfgCenter.h"

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

@interface FakeLanchWindow ()
{
    BOOL _showingPop;
    UIViewController* parentVC;
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
        NSString *name = [[NSBundle mainBundle] pathForResource:@"Lanch_6" ofType:@"png"];
        UIImage *image = [UIImage imageWithContentsOfFile:name];
        imageView.image = image;
        
        _controller.view.backgroundColor = [UIColor clearColor];
        [_controller.view addSubview:imageView];
    }
    return self;
}

- (void) setParentViewController:(UIViewController *)pVC {
    parentVC = pVC;
}

-(void)becomeKeyWindow
{
    [AdmobViewController shareAdmobVC].delegate = self;

    BOOL shown = [AdUtility tryShowInterstitialInVC:_controller ignoreTimeInterval:NO];
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
    if (_action) {
        _action(_showingPop);
    }
    for (UIView*view in _controller.view.subviews) {
        [view removeFromSuperview];
    }
    
    SEL releaseRef = NSSelectorFromString(@"releaseFakeLaunchRef");
    if(parentVC != nil && [parentVC respondsToSelector:releaseRef]) {
        [parentVC performSelector:releaseRef];
        parentVC = nil;
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
}

-(void)interstitialAction:(NSNotification *)notice
{
    NSString *name = notice.name;
    NSDictionary *user_info = notice.userInfo;
    
    if ([name isEqualToString:kInterstitialNotification])
    {
        NSString *action = [user_info objectForKey:@"action"];
        if ([action isEqualToString:@"received"])
        {
            _showingPop = [AdUtility tryShowInterstitialInVC:_controller ignoreTimeInterval:NO];
        }
        else if ([action isEqualToString:@"willdismiss"])
        {
            _controller.view.hidden = YES;
        }
        else if ([action isEqualToString:@"diddismiss"])
        {
            _controller.view.hidden = YES;
        }
    }
}

#pragma mark - AdmobViewControllerDelegate
-(void)adMobVCDidReceiveInterstitialAd:(AdmobViewController *)adMobVC
{
    if(!_showingPop) {
        _showingPop = [AdUtility tryShowInterstitialInVC:_controller ignoreTimeInterval:NO];
    }
}

-(void)adMobVCDidCloseInterstitialAd:(AdmobViewController *)adMobVC
{
    _controller.view.hidden = YES;
    [self dismiss];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
