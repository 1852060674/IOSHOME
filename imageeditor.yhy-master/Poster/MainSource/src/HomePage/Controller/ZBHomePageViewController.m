//
//  ZBHomePageViewController.m
//  Poster
//
//  Created by shen on 13-8-2.
//  Copyright (c) 2013年 ZBNetwork. All rights reserved.
//

#import "ZBHomePageViewController.h"
#import "ZBHomePageView.h"
#import "ZBCommonDefine.h"
#import "ZBCommonMethod.h"
#import <QuartzCore/QuartzCore.h>
#import <Photos/Photos.h>
#import "ImageUtil.h"
#import "ZBEditImageViewController.h"
#import "PickImagesViewController.h"
#import <AviarySDK/AviarySDK.h>
//#import "GADBannerViewDelegate.h"

#import "ZBAppDelegate.h"
#import "AdUtility.h"
#import "Admob.h"
#import "GlobalSettingManger.h"
#import "ShareService.h"
#import "Toast+UIView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "FakeLanchWindow.h"
#import "AssetHelper.h"
#import "ShareViewController.h"
#import "SharePopupCommon.h"
#import <Masonry/Masonry.h>
//@import Flurry_iOS_SDK;
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
@import AppLovinSDK;

@interface ZBHomePageViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,AFPhotoEditorControllerDelegate,UIPopoverControllerDelegate,ZBHomePageViewDelegate>
{
    ZBHomePageView *_homePageView;
    UIPopoverController *_popover;
}

@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) UIPopoverController * popover;
@property (nonatomic, strong) UIView * adView;
@property (nonatomic, readwrite) NSInteger appearTimesAfterLoad;
@property (nonatomic)UIEdgeInsets safeAreaInsets;

@end

@implementation ZBHomePageViewController
@synthesize assetLibrary;
@synthesize popover;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        self.safeAreaInsets = window.safeAreaInsets;
    }
    
    if (self) {
        // Custom initialization
        
        //self.view.backgroundColor = [UIColor whiteColor];
#if 0
        if (kSystemVersion>=7.0) {
            _homePageView = [[ZBHomePageView alloc] initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth, kScreenHeight)];
        }
        else
        {
            _homePageView = [[ZBHomePageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        }
#endif
        _homePageView = [[ZBHomePageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _homePageView.backgroundColor = [UIColor whiteColor];
        _homePageView.delegate = self;
        [self.view addSubview:_homePageView];
        
        CGFloat adheight = MAAdFormat.banner.adaptiveSize.height;
        
        self.adView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - adheight - _safeAreaInsets.bottom, kScreenWidth, kAdHeight)];
        [self.view addSubview:self.adView];
        [self.adView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.mas_equalTo(self.view).mas_offset(-1 * _safeAreaInsets.bottom);
            make.height.mas_equalTo(adheight);
            make.width.mas_equalTo(kScreenWidth);
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    
    _fakeLanchWindow = [[FakeLanchWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [_fakeLanchWindow setPreController:self];
    if ([AdUtility hasAd]) {
        [_fakeLanchWindow makeKeyAndVisible];
    }
    
    
	// Do any additional setup after loading the view.
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // dev1 -> lele
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [ZBCommonMethod setUserSelectedAssets:nil];

    
    if (![AdUtility hasAd])
    {
        _homePageView.upgradeButton.hidden = YES;
        [[AdmobViewController shareAdmobVC] remove_banner:_homePageView];
    }
    
    // Delete IAP entrance
    _homePageView.upgradeButton.hidden = YES;

    _homePageView.feedbackButton.hidden = YES;
    
    _homePageView.moreButton.hidden = YES;

//    else
//    {
//        if ( ![_adViewController admob_interstial_ready]) {
//            _homePageView.moreButton.hidden = YES;
//        } else {
//            _homePageView.moreButton.hidden = NO;
//        }
//    }
    
    [AdUtility tryShowBannerInView:_adView placeid:@"homepage"];
    
    [self firstProtocolAlter];
    
    [self setNeedsStatusBarAppearanceUpdate];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//退出程序
- (void)exitApplication {
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [UIView animateWithDuration:0.2f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
    //exit(0);
}

- (void) firstProtocolAlter {
    
    NSString * val = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunch"];
    if (!val) {

        //show alert
        
        ProtocolAlerView *alert = [ProtocolAlerView new];
        alert.homeViewController = self;
                 alert.strContent = @"Thanks for using Image Editor!\nIn this app, we need some permission to access the photo library, and camera to choose or take a photo of you. In this process, We do not collect or save any data getting from your device including processed data. By clicking \"Agree\" you confirm that you have read and agree to our privacy policy.\nAt the same time, Ads may be displayed in this app. When requesting to \"track activity\" in the next popup, please click \"Allow\" to let us find more personalized ads. It's completely anonymous and only used for relevant ads.";
               
               [alert showAlert:self cancelAction:^(id  _Nullable object) {
                   //不同意
                   [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
                   [self exitApplication];
               } privateAction:^(id  _Nullable object) {
                       //   输入项目的隐私政策的 URL
                       SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://seaworldgame.online/support/yhyllc/imageeditor/policy.html"]];
                       //sfVC.delegate = self;
                       [self presentViewController:sfVC animated:YES completion:nil];
    //        [self pushWebController:[YSCommonWebUrl userAgreementsUrl] isLoadOutUrl:NO title:@"用户协议"];
               } delegateAction:^(id  _Nullable object) {
                   NSLog(@"用户协议");
                       //   输入项目的隐私政策的 URL
                       SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://seaworldgame.online/support/yhyllc/imageeditor/policy.html"]];
                       //sfVC.delegate = self;
                       [self presentViewController:sfVC animated:YES completion:nil];
               }
               ];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
#pragma mark -
#pragma mark ZBHomePageViewDelegate
- (void)editImage
{
//    [Flurry logEvent:@"EditorPage"];
    if([ShareCommon needPopup:self])
        return;
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.allowsEditing = NO;
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.allowsEditing = NO;
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];

    [[AdmobViewController shareAdmobVC] checkConfigUD];
/*    if([ASSETHELPER canAccessLibrary]){
        dispatch_async(dispatch_get_main_queue(), ^{

        });
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PHOTO_LIBRARY_ACCESS_DENIED", @"") message:NSLocalizedString(@"ENABLE_ACCESS_TO_PHOTO_MSG", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SETTINGS", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
                [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALBUMN_ACCESSMENT_ERROR_CANCEL", @"") style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:settingsAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }*/

}

- (void)collage
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if(status == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//            if (status == PHAuthorizationStatusAuthorized) {
//                
//            }else if(status == PHAuthorizationStatusDenied) {
//            }
            [self collage];
        }];
        return;
    }
    if([ASSETHELPER canAccessLibrary]){
        dispatch_async(dispatch_get_main_queue(), ^{
//            [Flurry logEvent:@"CollagePage"];
            
//            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//            if (status == PHAuthorizationStatusDenied) {
//                if ([ZBCommonMethod systemVersion]>=8.0) {
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALBUMN_ACCESSMENT_ERROR_TITLE", @"") message:NSLocalizedString(@"ALBUMN_ACCESSMENT_ERROR_MSG_V8_UPPER", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ALBUMN_ACCESSMENT_ERROR_CANCEL", @"") otherButtonTitles:nil];
//                    [alertView show];
//                }
//                else
//                {
//                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ALBUMN_ACCESSMENT_ERROR_TITLE", @"") message:NSLocalizedString(@"ALBUMN_ACCESSMENT_ERROR_MSG", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ALBUMN_ACCESSMENT_ERROR_CANCEL", @"") otherButtonTitles:nil];
//                    [alertView show];
//                }
//                return;
//            }
            
            UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
            if (@available(iOS 11.0, *)) {
                UIWindow *window = UIApplication.sharedApplication.keyWindow;
                safeAreaInsets = window.safeAreaInsets;
            }
            
            PickImagesViewController *_pickImageViewController = [[PickImagesViewController alloc] init];
            [self.navigationController pushViewController:_pickImageViewController animated:YES];
        });
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"PHOTO_LIBRARY_ACCESS_DENIED", @"") message:NSLocalizedString(@"ENABLE_ACCESS_TO_PHOTO_MSG", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SETTINGS", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
                [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ALBUMN_ACCESSMENT_ERROR_CANCEL", @"") style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:settingsAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)more_app
{
   // [adsController showFreeAds];
    // ad wall
    //adViewController = [[AdWallViewController alloc] init];
    //[self.view addSubview:adViewController.view];
    //[_adViewController adWall:self];
    [[AdmobViewController shareAdmobVC] show_admob_interstitial:self placeid:6];
    _homePageView.moreButton.hidden = YES;
}

- (void)update_pro
{
    //NSUserDefaults *readUserDefault = [NSUserDefaults standardUserDefaults];
    //NSString* strUrl = [readUserDefault objectForKey:@"pro_url"];
    
    //NSLog(@"update : %@\n", strUrl);
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
#ifdef ENABLE_IAP
    [[AdmobViewController shareAdmobVC] doUpgradeInApp:self product:kRemoveAd];
#endif
}

#pragma mark - Popover Methods

- (void) presentViewControllerInPopover:(UIViewController *)controller withRect:(CGRect)rect
{
    CGRect popoverRect = rect;
    _popover = nil;
    if (_popover == nil)
    {
        _popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [_popover setDelegate:self];
    }
    
    [_popover presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) dismissPopoverWithCompletion:(void(^)(void))completion
{
    [_popover dismissPopoverAnimated:YES];
    _popover = nil;
    
    NSTimeInterval delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            completion();
    });
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)info
{
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    void(^completion)(void)  = ^(void){
        
        if (nil == assetURL) {
            UIImage *_image = [info objectForKey:UIImagePickerControllerOriginalImage];
            
//            [self launchPhotoEditorWithImage:image highResolutionImage:_image];
            [self displayEditorForImage:image];
            
            [[AdmobViewController shareAdmobVC] ifNeedShowNext:self];
        }
        else
        {
            [[self assetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                if (asset){
                    [self launchEditorWithAsset:asset];
                }
            } failureBlock:^(NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable access to your device's photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        }
    };
    
#if 0
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:completion];
    }
    else{
        [self dismissPopoverWithCompletion:completion];
    }
#endif
    [self dismissViewControllerAnimated:YES completion:completion];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions
{
    // Set Tool Order
//    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFCrop, kAFSharpness, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFFrames, kAFStickers, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFWhiten, kAFBlemish, kAFMeme];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
    
    // Set Supported Orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray * supportedOrientations = @[@(UIInterfaceOrientationPortrait), @(UIInterfaceOrientationPortraitUpsideDown), @(UIInterfaceOrientationLandscapeLeft), @(UIInterfaceOrientationLandscapeRight)];
        [AFPhotoEditorCustomization setSupportedIpadOrientations:supportedOrientations];
    }
}


//#pragma mark - Photo Editor Creation and Presentation
//- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
//{
//     [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
//    // Initialize the photo editor and set its delegate
//    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
//    [photoEditor setDelegate:self];
//
//   
//    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self setPhotoEditorCustomizationOptions];
//    });
//    
//    // If a high res image is passed, create the high res context with the image and the photo editor.
//    if (highResImage) {
//        //        [self setupHighResContextForPhotoEditor:photoEditor withImage:highResImage];
//    }
//    
//   // [_adViewController show_admob_banner:0 width:0 view:self.view];
//   // [self.view addSubview:photoEditor.view];
//    
//    // Present the photo editor.
////#if 0
//    [self presentViewController:photoEditor animated:YES completion:^{
//     //   [_adViewController show_admob_banner:kNavBarHeight + kStatusBarHeight width:0 view:photoEditor.view];
//    }];
////#endif
//}
//

- (void)displayEditorForImage:(UIImage *)imageToEdit
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AFPhotoEditorController setAPIKey:@"196f65722f84db4e" secret:@"1419ea4a000f38d7"];
    });
    
    AFPhotoEditorController *editorController = [[AFPhotoEditorController alloc] initWithImage:imageToEdit];
    [AFPhotoEditorCustomization setToolOrder:@[
                                               kAFOrientation,
                                               kAFCrop,
                                               kAFEffects,
                                               kAFEnhance,
                                               kAFFrames,
                                               kAFText,
                                               kAFAdjustments,
                                               kAFSharpness,
                                               kAFFocus,
                                               kAFDraw,
                                               kAFSplash,
                                               kAFBlemish,
                                               kAFBlur,
                                               kAFMeme,
                                               kAFStickers,
                                               kAFWhiten,
                                               kAFRedeye,
                                               ]];
    [editorController setDelegate:self];
    [self presentViewController:editorController animated:YES completion:nil];
}



#pragma mark - Photo Editor Launch Methods

- (UIImage *)editingResImageForAsset:(ALAsset*)asset
{
    CGImageRef image = [[asset defaultRepresentation] fullScreenImage];
    
    return [UIImage imageWithCGImage:image scale:1.0 orientation:UIImageOrientationUp];
}

- (UIImage *)highResImageForAsset:(ALAsset*)asset
{
    ALAssetRepresentation * representation = [asset defaultRepresentation];
    
    CGImageRef image = [representation fullResolutionImage];
    UIImageOrientation orientation = (UIImageOrientation)[representation orientation];
    CGFloat scale = [representation scale];
    
    return [UIImage imageWithCGImage:image scale:scale orientation:orientation];
}

- (void) launchEditorWithAsset:(ALAsset *)asset
{
    UIImage * editingResImage = [self editingResImageForAsset:asset];
    UIImage * highResImage = [self highResImageForAsset:asset];
    //
//    [self launchPhotoEditorWithImage:editingResImage highResolutionImage:highResImage];
    [self displayEditorForImage:highResImage];
}

#pragma mark AFPhotoEditorControllerDelegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    [self dismissViewControllerAnimated:YES completion:^{
        UIStoryboard *mainStoryboard;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        }
        else
        {
            NSInteger screenHeight = (NSInteger)[UIScreen mainScreen].bounds.size.height;
            if (screenHeight == 480) {
                mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone4" bundle:nil];
            }
            else if (screenHeight == 568)
            {
                mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            }
            else if (screenHeight == 667)
            {
                mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone6" bundle:nil];
            }
            else
            {
                mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone6+" bundle:nil];
            }
        }
        
        ShareViewController *shareVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"shareVC"];
        shareVC.originalImage = image;
        shareVC.autoSave = NO;
        shareVC.hasAd = YES;
        
        BOOL show = [[AdmobViewController shareAdmobVC] decideShowRT:self];
        if(!show)//zzx0930
            [AdUtility tryShowInterstitialInVC:self.navigationController placeid:7];
        [self.navigationController pushViewController:shareVC animated:YES];
    }];
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark -
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [ASSETHELPER canAccessLibrary];

    ++self.appearTimesAfterLoad;
}

#pragma mark -
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            if ([ZBCommonMethod systemVersion]>=8.0) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
            break;
        default:
            break;
    }
}

@end
