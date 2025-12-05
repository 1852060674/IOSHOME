//
//  ShareViewController.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/8.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "ShareViewController.h"
#import "MainLevelView_3.h"
#import "Masonry.h"
#import "ShareView.h"
#import "AdUtility.h"
#import "ShareTopView.h"
#import "MBProgressHUD.h"
#import "UserSettingManger.h"
#import "UIImage+Rotation.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface ShareViewController ()<ShareViewDelegate, ShareServiceDelegate>
{
    BOOL _hideStatusBar;
    
    BOOL _receivedNativedAd;

    BOOL _everAutoSave;
    __weak IBOutlet UIView *contentView;
}
@property (nonatomic, strong) MainLevelView_3 *mainLevelView;

@property (nonatomic, strong) UIView *nativeAdView;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ShareViewController

-(void)loadView
{
    [super loadView];
    self.mainLevelView = [[MainLevelView_3 alloc] initWithFrame:[UIScreen mainScreen].bounds andHasAD:[AdUtility hasAd]];
    self.mainLevelView.clipsToBounds = YES;
    self.mainLevelView.opaque = YES;
    
    //self.view = self.mainLevelView;
    [contentView addSubview:self.mainLevelView];
    [self.mainLevelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(contentView);
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    __weak ShareViewController *_wSelf = self;
    /// top
    NSArray  *apparray= [[NSBundle mainBundle] loadNibNamed:@"ShareTopView" owner:nil options:nil];
    ShareTopView *topView = (ShareTopView *)[apparray firstObject];
    [topView setActions:^(NSInteger index) {
        switch (index)
        {
            case 0:
            {
                [_wSelf back];
                break;
            }
            case 1:
            {
                [_wSelf share];
                break;
            }
            default:
                break;
        }
    }];
    [_mainLevelView.shellTopBarView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_mainLevelView.shellTopBarView);
    }];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [_mainLevelView.mainAreaView addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = self.originalImage;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(imageView.mas_height).multipliedBy(self.originalImage.size.width/self.originalImage.size.height);
        
        make.width.height.lessThanOrEqualTo(_mainLevelView.mainAreaView);
        make.width.height.equalTo(_mainLevelView.mainAreaView).with.priorityLow();
        
        make.center.equalTo(_mainLevelView.mainAreaView);
    }];
    _imageView = imageView;
    
    ShareView *shareView = [[ShareView alloc] initWithFrame:_mainLevelView.shellBottomBarView.bounds];
    shareView.backgroundColor = [UIColor clearColor];
    [_mainLevelView.shellBottomBarView addSubview:shareView];
    shareView.delegate = self;
    [shareView setupSubView];
    
    [shareView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(_mainLevelView.shellBottomBarView);
        make.height.equalTo(shareView.mas_width).multipliedBy(0.55);
    }];
    
    [self loadNativeAd];
    
//    [_mainLevelView.shellBottomBarView addSubview:_nativeAdView];
//    [_nativeAdView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.bottom.equalTo(_mainLevelView.shellBottomBarView);
//        
//        make.top.equalTo(shareView.mas_bottom).offset(8);
////        make.height.equalTo(@(200));
//    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _hideStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.view layoutIfNeeded];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_everAutoSave && [[UserSettingManger defaultManger] autoSave]) {
        _everAutoSave = YES;
        
        //[[ShareService defaultService] setDelegate:self];
        [[ShareService defaultService] showShareToPlatForm:ZBShareTypeSave inVC:self fromView:nil title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
    }
}

-(BOOL)prefersStatusBarHidden
{
    //return _hideStatusBar;
    return NO;
}

#pragma mark -
-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)share
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark -
- (void)loadNativeAd{
//    if ([AdUtility hasAd])
//    {
//        GADNativeExpressAdView *nativeExpressAdView = [[GADNativeExpressAdView alloc] initWithAdSize:kGADAdSizeMediumRectangle];
//        nativeExpressAdView.delegate = self;
//        nativeExpressAdView.adUnitID = kNativeMediumID;
//        nativeExpressAdView.rootViewController = self;
//        _nativeAdView = nativeExpressAdView;
//
//        GADRequest *request = [GADRequest request];
//        [nativeExpressAdView loadRequest:request];
//
//        _receivedNativedAd = NO;
//    }
}

//#pragma mark GADNativeExpressAdViewDelegate implementation
//-(void)nativeExpressAdViewDidReceiveAd:(GADNativeExpressAdView *)nativeExpressAdView
//{
//    _receivedNativedAd = YES;
//    _nativeAdView = nativeExpressAdView;
//
//    NSLog(@"%s", __FUNCTION__);
//}
//
//-(void)nativeExpressAdView:(GADNativeExpressAdView *)nativeExpressAdView didFailToReceiveAdWithError:(GADRequestError *)error
//{
//    _receivedNativedAd = NO;
//    NSLog(@"%s: %@", __FUNCTION__, [error description]);
//}

#pragma mark - ShareViewDelegate
-(void)shareView:(ShareView *)shareView shareImageToPlatform:(ZBShareType)shareType
{
    if (shareType==ZBShareTypeSMS && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _hideStatusBar = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ShareService defaultService] setDelegate:self];
            [[ShareService defaultService] showShareToPlatForm:shareType inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
        });
    }
    else
    {
        //[[ShareService defaultService] setDelegate:self];
        [[ShareService defaultService] showShareToPlatForm:shareType inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
    }
}

#pragma mark - ShareServiceDelegate
-(void)shareServiceDidEndShare:(ShareService *)shareService shareType:(ZBShareType)shareType result:(ShareServiceResult)resultCode
{
    _hideStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (shareType == ZBShareTypeSave)
    {
        if (resultCode == kShareServiceSuccess)
        {
            UIImageView *customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
            [MBProgressHUD showSharedHUDInView:self.view withCustomView:customView andTitle:NSLocalizedStringFromTable(@"SHARE_SAVED_SUCCEED", @"share", @"") andDuration:1.0];
        }
    }
    else
    {
        NSString *message = [[ShareService defaultService] getResultTipMessageWithShareType:shareType andResult:resultCode];
        
        if (message != nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"SHARE_CANCEL_WORD", @"share", @"share for locale") otherButtonTitles:nil];
            [alertView show];
        }
        
        NSLog(@"%s", __FUNCTION__);
    }
}

#pragma mark -
-(UIImage *)getShareImage
{
    return [self.originalImage rotateAndScaleWithMaxSize:[[UserSettingManger defaultManger] getRealResolution]];
}

-(UIView *)getContentView
{
    return _imageView;
}

#pragma mark -

-(void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
