//
//  ShareViewController.m
//  ErasePhoto_new
//
//  Created by ZB_Mac on 14-11-30.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import "ShareViewController.h"
#import "ShareView/ShareView.h"
#import <MessageUI/MessageUI.h>
#import <ShareSDK/ShareSDK.h>
#import "TwoStateButton.h"
#import "MBProgressHUD.h"
#import "ShareService.h"
#import "Admob.h"
#import "AdUtility.h"
#import "ShareCommon.h"
#import "SharePopupCommon.h"
#import <Masonry/Masonry.h>
@import AppLovinSDK;

@interface ShareViewController ()<ShareViewDelegate, MBProgressHUDDelegate, ShareServiceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *adContainer;
@property (weak, nonatomic) IBOutlet UIView *saveContainer;
@property (weak, nonatomic) IBOutlet UIView *shareContainer;
@property (weak, nonatomic) IBOutlet UIView *mainTopBar;

@property (strong, nonatomic) TwoStateButton *backBtn;
@property (strong, nonatomic) TwoStateButton *homeBtn;

@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) UILabel *saveResultTip;
@property (strong, nonatomic) UIDocumentInteractionController *documentController;

@property (strong, nonatomic) MBProgressHUD *progressHUD;

@end

@implementation ShareViewController

@synthesize progressHUD=_progressHUD;
-(MBProgressHUD *)progressHUD
{
    if (_progressHUD==nil) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [_progressHUD setCenter:self.view.center];
        [self.view addSubview:_progressHUD];
        _progressHUD.delegate = self;
        _progressHUD.labelText = NSLocalizedStringFromTable(@"SHARE_WATING", @"share", @"");
        _progressHUD.userInteractionEnabled = YES;
        _progressHUD.labelFont = [UIFont systemFontOfSize:15];
    }
    return _progressHUD;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
//    if(@available(iOS 11,*)) {
//        self.additionalSafeAreaInsets = UIEdgeInsetsMake(-kNavBarHeight, 0, 0, 0);
//    }
    
    ShareView *shareView = [[ShareView alloc] initWithFrame:self.shareContainer.bounds];
    [shareView setupSubView];
    [self.shareContainer addSubview:shareView];
    shareView.delegate = self;
    
    [self setupContent];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.saveContainer.frame.size.height, self.saveContainer.frame.size.height)];
    [saveButton setImage:[UIImage imageNamed:@"share_icon_save"] forState:UIControlStateNormal];
    [self.saveContainer addSubview:saveButton];
    [saveButton addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    saveButton.center = CGPointMake(self.saveContainer.frame.size.width/2.0, self.saveContainer.frame.size.height/2.0);
    self.saveButton = saveButton;
    
    UILabel *saveResult = [[UILabel alloc] initWithFrame:self.saveContainer.bounds];
    saveResult.textAlignment = NSTextAlignmentCenter;
    saveResult.text = NSLocalizedStringFromTable(@"SHARE_IMAGE_SAVED", @"share", @"");
    self.saveResultTip = saveResult;
    [self.saveContainer addSubview:saveResult];
    saveResult.hidden = YES;
    
    self.titleLabel.text = NSLocalizedStringFromTable(@"SHARE_VC_TITLE", @"share", @"");
    
    [[AdmobViewController shareAdmobVC] recordValidUseCount];
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        safeAreaInsets = window.safeAreaInsets;
    }
    CGFloat adheight = MAAdFormat.banner.adaptiveSize.height;
    [self.adContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.mas_equalTo(self.view).mas_offset(safeAreaInsets.top + kNavigationBarHeight);
        make.height.mas_equalTo(adheight);
        make.width.mas_equalTo(kScreenWidth);
    }];
    [[AdmobViewController shareAdmobVC] show_admob_interstitial:self.navigationController placeid:3];
}

-(void) setupContent
{
    NSInteger count;
    CGFloat containerWidth;
    CGFloat buttonSize;
    CGFloat xOffset;
    CGFloat xMargin;
    TwoStateButton *button;
    UIView *container;
    const CGFloat xPadding = 8;
    
    //1. mainTopBar
    count = 2;
    container = self.mainTopBar;
    containerWidth = container.frame.size.width;
    buttonSize = container.frame.size.height;
    xOffset = xPadding;
    xMargin = (containerWidth-buttonSize*count-xOffset*2)/(count-1);
    
    button = [[TwoStateButton alloc] initWithFrame:CGRectMake(xOffset, 0, buttonSize, buttonSize)
                                    andState0Image:[UIImage imageNamed:@"back"]
                                    andState1Image:[UIImage imageNamed:@"back"]];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    self.backBtn = button;
    
    xOffset += buttonSize + xMargin;
    button = [[TwoStateButton alloc] initWithFrame:CGRectMake(xOffset, 0, buttonSize, buttonSize)
                                    andState0Image:[UIImage imageNamed:@"btn_home"]
                                    andState1Image:[UIImage imageNamed:@"btn_home"]];
    [button addTarget:self action:@selector(home:) forControlEvents:UIControlEventTouchUpInside];
//    [container addSubview:button];
//    self.homeBtn = button;
}

#pragma mark - HUD show&hide

- (void)showTipStatus
{
    [self.progressHUD.superview bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];
}

- (void)hideTipStatus
{
    [self.progressHUD hide:YES];
}

-(NSString *)getShareTitle
{
    return NSLocalizedStringFromTable(@"SHARE_APP_NAME", @"share", @"");
}

-(NSString *)getShareContent
{
    return [NSString stringWithFormat:@"#%@#%@", NSLocalizedStringFromTable(@"SHARE_APP_NAME", @"share", @""), APP_URL];
}

-(UIImage *)getShareImage
{
    return self.originalImage;
}

-(NSString *)getResultTipMessageWithShareType:(ZBShareType)shareType andResult:(ShareServiceResult)result
{
    NSString *message = nil;

    NSString *shareName = nil;
    switch (shareType) {
        case ZBShareTypeInstagram:
            shareName = NSLocalizedStringFromTable(@"SHARE_INSTAGRAM", @"share", @"instagram for locale");
            break;
        case ZBShareTypeSMS:
            shareName = NSLocalizedStringFromTable(@"SHARE_SMS", @"share", @"sms for locale");
            break;
        case ZBShareTypeFlickr:
            shareName = NSLocalizedStringFromTable(@"SHARE_FLICKR", @"share", @"flickr for locale");
            break;
        case ZBShareTypeWhatsApp:
            shareName = NSLocalizedStringFromTable(@"SHARE_WHATSAPP", @"share", @"whatsapp for locale");
            break;
        case ZBShareTypeMail:
            shareName = NSLocalizedStringFromTable(@"SHARE_MAIL", @"share", @"mail for locale");
            break;
        case ZBShareTypeDropbox:
            shareName = NSLocalizedStringFromTable(@"SHARE_DROPBOX", @"share", @"dropbox for locale");
            break;
        case ZBShareTypeFacebook:
            shareName = NSLocalizedStringFromTable(@"SHARE_FACEBOOK", @"share", @"facebook for locale");
            break;
        case ZBShareTypeTencentWeibo:
            shareName = NSLocalizedStringFromTable(@"SHARE_TC_WEIBO", @"share", @"tc weibo for locale");
            break;
        case ZBShareTypeWeixiSession:
            shareName = NSLocalizedStringFromTable(@"SHARE_WECHAT", @"share", @"wechat for locale");
            break;
        case ZBShareTypeSinaWeibo:
            shareName = NSLocalizedStringFromTable(@"SHARE_SINA_WEIBO", @"share", @"sina weibo for locale");
            break;
        case ZBShareTypeLinkedIn:
            shareName = NSLocalizedStringFromTable(@"SHARE_LINKEDIN", @"share", @"linkedin for locale");
            break;
        case ZBShareTypeTumblr:
            shareName = NSLocalizedStringFromTable(@"SHARE_TUMBLR", @"share", @"tumblr for locale");
            break;
        case ZBShareTypeVKontakte:
            shareName = NSLocalizedStringFromTable(@"SHARE_VKONTAKTE", @"share", @"vkontakte for locale");
            break;
        case ZBShareTypeTwitter:
            shareName = NSLocalizedStringFromTable(@"SHARE_TWITTER", @"share", @"twitter for locale");
            break;
        case ZBShareTypeAirPrint:
            shareName = NSLocalizedStringFromTable(@"SHARE_AIRPRINT", @"share", @"airprint for locale");
            break;
        case ZBShareTypeCopy:
            shareName = NSLocalizedStringFromTable(@"SHARE_COPY", @"share", @"copy for locale");
            break;
        default:
            break;
    }
    
    switch (result) {
        case kShareServiceDeviceNotSupport:
        {
            if (shareType == ZBShareTypeInstagram) {
                message = [NSString stringWithFormat:@"%@%@%@%@", NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_SUFFIX", @"share", @""),  NSLocalizedStringFromTable(@"SHARE_INSTAGRAM_NOT_INSTALLED", @"share", @"")];
            }
            else if (shareType == ZBShareTypeWhatsApp)
            {
                message = [NSString stringWithFormat:@"%@%@%@%@", NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_SUFFIX", @"share", @""), NSLocalizedStringFromTable(@"SHARE_WHATSAPP_NOT_INSTALLED", @"share", @"")];
            }
            else if (shareType == ZBShareTypeWeixiSession)
            {
                message = [NSString stringWithFormat:@"%@%@%@%@", NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_SUFFIX", @"share", @""), NSLocalizedStringFromTable(@"SHARE_WECHAT_NOT_INSTALLED", @"share", @"")];

            }
            else
            {
                message = [NSString stringWithFormat:@"%@%@%@", NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_SUFFIX", @"share", @"")];
            }
            break;
        }
        case kShareServiceFail:
        {
            message = [NSString stringWithFormat:@"%@%@%@", NSLocalizedStringFromTable(@"SHARE_FAIL_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_FAIL_SUFFIX", @"share", @"")];
            break;
        }
        default:
            break;
    }
    
    return message;
}

#pragma mark - actions

- (void)back:(TwoStateButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)home:(TwoStateButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)saveImage
{
    if([ShareCommon needPopup:self pagetype:Collection_Save item:0]) {
        return;
    }
    
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] saveToAlbumn:self.originalImage];
}

#pragma mark - shareView delegate
-(void)shareView:(ShareView *)shareView shareImageToPlatform:(ZBShareType)shareType
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:shareType inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)SMSShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeSMS inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)FacebookShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeFacebook inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)TwitterShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeTwitter inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)GooglePlusShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeGooglePlus inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)TumblrShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeTumblr inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)MailShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeMail inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)InstagramShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeInstagram inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)WhatsAppShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeWhatsApp inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)WechatShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeWeixiSession inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}
-(void)DropBoxShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeDropbox inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)FlickrShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeFlickr inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)VKontakteShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeVKontakte inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)LinkdinShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeLinkedIn inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)TencentWeiboShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeTencentWeibo inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)SinaWeiboShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeSinaWeibo inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)PinterestShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypePinterest inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)AirPrintShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeAirPrint inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)copyShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeCopy inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

-(void)LineShareView:(ShareView *)shareView
{
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:ZBShareTypeLine inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:[self getShareImage]];
}

#pragma mark - share service delegate
-(void)shareServiceDidEndShare:(ShareService *)shareService shareType:(ZBShareType)shareType result:(ShareServiceResult)resultCode
{
    if (resultCode == kShareServiceSuccess) {
        if ([self hasAd]) {
#ifdef ENABLE_AD
//            [AdUtility tryShowInterstitialInVC:self];
#endif
        }
    }
    NSString *message = [[ShareService defaultService] getResultTipMessageWithShareType:shareType andResult:resultCode];

    if (message != nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"SHARE_CANCEL_WORD", @"share", @"share for locale") otherButtonTitles:nil];
        [alertView show];
    }
    [self.navigationController.navigationBar setHidden:NO];
    
    NSLog(@"%s", __FUNCTION__);
}

-(void) shareServiceBeforeShare:(ShareService *)shareService
{
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)shareServiceDidEndSave:(ShareService *)shareService result:(ShareServiceResult)resultCode
{
    if (resultCode == kShareServiceSuccess) {
        if ([self hasAd]) {
#ifdef ENABLE_AD
//            [AdUtility tryShowInterstitialInVC:self];
#endif
        }
        
        self.saveButton.enabled = NO;
        [self.saveButton setImage:[UIImage imageNamed:@"btn_save_success"] forState:UIControlStateNormal];
    }
    //    NSLog(@"%s", __FUNCTION__);
}

#pragma mark -
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self adjustUI];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStylePlain target:self action:@selector(home:)];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.autoSave) {
        [self saveImage];
    }
    
    if (self.adContainer.superview && [self hasAd]) {
        [AdUtility tryShowBannerInView:self.adContainer placeid:@"sharepage"];
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - for ad

- (void)adjustUI
{
    NSLog(@"%s", __FUNCTION__);
    
    // needs update
    if ([self hasAd] == NO && self.adContainer.superview != nil) {

        [self.adContainer removeFromSuperview];
    }
}

-(BOOL) hasAd
{
    return [AdUtility hasAd];
}

@end
