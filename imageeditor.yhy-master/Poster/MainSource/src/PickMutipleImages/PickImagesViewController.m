//
//  PickImagesViewController.m
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-17.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import "PickImagesViewController.h"
#import "PickImagesView.h"
#import "ZBCommonDefine.h"
#import "PickImagesAssetViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZBColorDefine.h"
#import "ZBAppDelegate.h"
#import "AdUtility.h"
#import "Admob.h"
#import "GlobalSettingManger.h"
#import "AssetHelper.h"
#import <Masonry/Masonry.h>
@import AppLovinSDK;

@interface PickImagesViewController ()<PickImagesViewDelegate>
{
}

@property (nonatomic, strong)PickImagesView *pickImageView;

@property (nonatomic, strong)UIView *adView;

@end

@implementation PickImagesViewController
@synthesize pickImageView = _pickImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        
        [self.view addSubview:self.pickImageView];
        UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.keyWindow;
            safeAreaInsets = window.safeAreaInsets;
        }
   
        float _adHeight = kAdHeiht;
        if (![AdUtility hasAd])
            _adHeight = 0;
//        kNavigationBarHeight
        CGRect rect = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
//        kNavigationBarHeight + safeAreaInsets.top + _adHeight
        
        PickImagesView *pickImgageViewTemp = [[PickImagesView alloc] initWithFrame:rect];
        pickImgageViewTemp.delegate = self;
        
        self.pickImageView = pickImgageViewTemp;
        [self.view addSubview:self.pickImageView];
        
//        [self.pickImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.view).mas_offset(safeAreaInsets.top);
//            make.height.mas_equalTo(kScreenWidth);
//            make.width.mas_equalTo(kScreenHeight - kNavigationBarHeight - safeAreaInsets.top - _adHeight);
//        }];
        
        CGFloat adheight = MAAdFormat.banner.adaptiveSize.height;
        self.adView = [[UIView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + safeAreaInsets.top, kScreenWidth, adheight)];
        [self.view addSubview:self.adView];

    }
    return self;
}

- (void)dealloc
{
//    [self.pickImageView release];
//    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//        kNavBarHeight


    
    self.navigationItem.title = @"Albums";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.pickImageView getAssetsFromAlbum:YES];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [AdUtility tryShowBannerInView:self.adView  placeid:@"pickimage"];
}


- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"memorry warning Home");
}

#pragma mark -- custom method


#pragma mark -- PickImagesViewDelegate

- (void)goToImagesStitch:(ALAssetsGroup*)assetGroup withType:(PickerImageFilterType)filterType
{
    PickImagesAssetViewController *_pickImagesAssetViewController = [[PickImagesAssetViewController alloc] initWithAssetLibray:assetGroup withType:filterType];
    _pickImagesAssetViewController.title = [assetGroup valueForProperty:ALAssetsGroupPropertyName];
    [self.navigationController pushViewController:_pickImagesAssetViewController animated:YES];
//    [_pickImagesAssetViewController release];
}

-(void)gotoAlbumGroupAtIndex:(NSInteger)groupIndex
{
    [ASSETHELPER getPhotoListOfGroupByIndex:groupIndex result:nil];
    PickImagesAssetViewController *_pickImagesAssetViewController = [[PickImagesAssetViewController alloc] init];
    [self.navigationController pushViewController:_pickImagesAssetViewController animated:YES];
}

#pragma mark -
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
