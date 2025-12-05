//
//  PickImagesAssetViewController.m
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-18.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import "PickImagesAssetViewController.h"
#import "PickImagesAssetView.h"
#import "ZBCollageViewController.h"
#import "TKAlertCenter.h"
#import "ZBSelectedThumbnailView.h"
#import "ZBAppDelegate.h"
#import "AdUtility.h"
#import "Admob.h"
#import "GlobalSettingManger.h"
#import "ZBCommonMethod.h"
@import AppLovinSDK;

@interface PickImagesAssetViewController ()
{
}
@property (nonatomic, assign) PickerImageFilterType filterType;
@property (nonatomic, strong) PickImagesAssetView *imagesAssetView;
@property (nonatomic, strong) UIView *adView;
@end

@implementation PickImagesAssetViewController
@synthesize assetsGroup = _assetsGroup;
@synthesize filterType = _filterType;
@synthesize imagesAssetView = _imagesAssetView;

- (id)initWithAssetLibray:(ALAssetsGroup*)assetsGroup withType:(PickerImageFilterType)filterType
{
    self = [super init];
    if (self) {
       //self.view.backgroundColor = [UIColor whiteColor];
        self.assetsGroup = assetsGroup;
        self.filterType = filterType;
    }
    return self;
}

- (void)dealloc
{
}

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        safeAreaInsets = window.safeAreaInsets;
    }
    
//    _imagesAssetView = [[PickImagesAssetView alloc] initWithAssetsGroup:self.assetsGroup];
    CGFloat _adHeight = MAAdFormat.banner.adaptiveSize.height;
    
    if (![AdUtility hasAd]) {
        _adHeight = 0;
    }
    NSLog(@"%f",kNavigationBarHeight + safeAreaInsets.top + kAdHeiht);
    CGRect rect = CGRectMake(0, kNavigationBarHeight + safeAreaInsets.top + _adHeight, kScreenWidth, kScreenHeight - (kNavigationBarHeight + safeAreaInsets.top + safeAreaInsets.bottom + _adHeight));
    
    _imagesAssetView = [[PickImagesAssetView alloc] initWithFrame:rect];

    _imagesAssetView.filterType = self.filterType;
    [self.view addSubview:_imagesAssetView];
    
    CGFloat adheight = MAAdFormat.banner.adaptiveSize.height;
    self.adView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + safeAreaInsets.top, kScreenWidth, adheight)];
    [self.view addSubview:self.adView];
    
    [_imagesAssetView addSelectedAssetsOnScrollview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(goToHomePage)];
  //  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Collage" style:UIBarButtonItemStyleDone target:self action:@selector(startToColleage)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(startToColleage)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
//    self.navigationItem.title = @"Puzzle Images";
    
    [[AdmobViewController shareAdmobVC] checkConfigUD];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [AdUtility tryShowBannerInView:self.adView placeid:@"pickassets"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"memorry warning!!!");
}

#pragma mark -- custom method
- (void)startToColleage
{
    NSMutableArray *_selectedPhoto = [[NSMutableArray alloc] initWithCapacity:1];
    for (UIView *aView in [_imagesAssetView.bottomScrollView subviews]) {
        if ([aView isKindOfClass:[ZBSelectedThumbnailView class]]) {
            [_selectedPhoto addObject:((ZBSelectedThumbnailView*)aView).assetIdentifier];
        }
    }
    //zzx0930
    if (_selectedPhoto.count>0 )
    {
        ZBCollageViewController *_createImageViewController = [[ZBCollageViewController alloc] initWithSelectedImges:_selectedPhoto];
        
        if(![[AdmobViewController shareAdmobVC] ifNeedShowNext:self.navigationController])
            [AdUtility tryShowInterstitialInVC:self.navigationController placeid:2];

        [self.navigationController pushViewController:_createImageViewController animated:YES];
    }
    else if(_imagesAssetView.selectedAssets.count == 0)
    {
        //提示用户还没有选择图片，至少选择一张
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Please at least select  1 photo!"]; 
    }
//    else
//    {
//        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"Please select  at most 7 photo!"]; 
//    }
}

- (void)goToHomePage
{
    NSMutableArray *_selectedPhoto = [[NSMutableArray alloc] initWithCapacity:1];
    for (UIView *aView in [_imagesAssetView.bottomScrollView subviews]) {
        if ([aView isKindOfClass:[ZBSelectedThumbnailView class]]) {
            [_selectedPhoto addObject:((ZBSelectedThumbnailView*)aView).assetIdentifier];
        }
    }
    
    [ZBCommonMethod setUserSelectedAssets:_selectedPhoto];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark -
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
