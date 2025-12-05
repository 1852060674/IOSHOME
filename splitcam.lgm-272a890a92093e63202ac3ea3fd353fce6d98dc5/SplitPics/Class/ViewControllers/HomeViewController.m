//
//  HomeViewController.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-4.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "HomeViewController.h"
#import "MGScrollView.h"
#import "MGDefine.h"
#import "CameraViewController.h"
#import "MGData.h"
#import "AppDelegate.h"
#import "MGMailCShare.h"
#import "HomeCollectionViewCell.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "MGDefine.h"
#import "EditorUtility.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
#import "AdUtility.h"
#import "FakeLanchWindow.h"
//@import Flurry_iOS_SDK;
#import "ProtocolAlerView.h"
@import AppLovinSDK;


#define LayoutNums  14

@interface HomeViewController ()<UIAlertViewDelegate>
{
    CGFloat adHeight;
    
    UIButton *cameraBtn;
    UIButton *swapBtn;
    UIButton *flashBtn;
    
    UIButton *rightBtn;
    
    AdmobViewController *_adViewController;
    NSMutableArray *lockArray;
    NSMutableArray *lockIVArray;
    
    CameraViewController *camerVC;
    
    bool show_banner_ad_top;
    UIView *naviBarView;
    UIView *adview;
}
@property (nonatomic, strong) NSArray * layoutPatterNames;
@end

@implementation HomeViewController
static CGFloat minimumInteritemSpacing = 30;
static CGFloat minimumLineSpacing = 30;
static UIEdgeInsets insetsForSection;
static CGSize itemSize;
- (void)viewDidLoad {
    [super viewDidLoad];
    _adViewController = [AdmobViewController shareAdmobVC];
    _adViewController.rootViewController = self;
    show_banner_ad_top = ![_adViewController IsPaid:kRemoveAd];
    
    adHeight = MAAdFormat.banner.adaptiveSize.height;
    adview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, adHeight)];
    [self.view addSubview:adview];
    
    minimumInteritemSpacing = (IS_IPAD)?100:30;
    minimumLineSpacing =  (IS_IPAD)?100:30;
    insetsForSection = (IS_IPAD)?UIEdgeInsetsMake(50, 50, 50, 50):UIEdgeInsetsMake(30, 30, 30, 30);
    NSInteger num = kDevice2(2, 3);
    CGFloat width = (kScreenWidth - (num-1)  *minimumInteritemSpacing - 2* insetsForSection.left)/num;
    itemSize = CGSizeMake(width, width);
    
    // Do any additional setup after loading the view.
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"frames" ofType:@"plist"];
    NSArray *frameInfoArray = [[NSArray alloc] initWithContentsOfFile:filePath];
    _layoutPatterNames = [frameInfoArray valueForKey:@"ImageName"];
    
//    adHeight = kSmartHeight;

    lockArray = @[@(V2_1x1_1x2),@(LayoutPatternSquare),@(H2_3x1_2x1),@(LayoutPatternTriangle),@(LayoutPatternLeftArrowx1),@(LayoutPatternShapeSx1)].mutableCopy;
    lockIVArray = [[NSMutableArray alloc] init];
    

    
    if([_adViewController IsPaid:kRemoveAd]){
        [lockArray removeAllObjects];
    }
    
    [self widgetsInit];
    

    [self scrollViewInit];
    
    [self firstProtocolAlter];
    if ([AdUtility hasAd]) {
        _fakeLanchWindow = [[FakeLanchWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_fakeLanchWindow setPreController:self];
        [_fakeLanchWindow makeKeyAndVisible];
    }
    
    
}

//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _adViewController.rootViewController = self;
    
    if(![_adViewController IsPaid:kRemoveAd]){
        [adview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(naviBarView.mas_bottom).mas_offset(0);
            make.height.mas_equalTo(adHeight);
            make.width.mas_equalTo(kScreenWidth);
        }];
    }else{
//        adview = [[UIView alloc] initWithFrame:CGRectZero];
        [adview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.top.equalTo(naviBarView.mas_bottom).mas_offset(0);
            make.height.mas_equalTo(0);
            make.width.mas_equalTo(kScreenWidth);
        }];
    }
    
    if([_adViewController IsPaid:kRemoveAd]){
//        [adview mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(0);
//        }];
        
        rightBtn.hidden = YES;
        
        for(UIImageView *imageView in lockIVArray){
            [imageView removeFromSuperview];
        }
        [lockArray removeAllObjects];
        [lockIVArray removeAllObjects];
        [self.collectionView reloadData];
    } else {
#ifdef ENABLE_AD
        [self show_banner_ad];
#endif
    }
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)widgetsInit
{
    self.view.backgroundColor = CameraBgColor;
    [self addNavi];
}

- (void)scrollViewInit
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat adH = !show_banner_ad_top ? 0 : adHeight;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + adH, kScreenWidth, kScreenHeight-kNavigationBarHeight - adH)collectionViewLayout:layout];
    [self.view addSubview:self.collectionView];
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        safeAreaInsets = window.safeAreaInsets;
    }
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
//        make.top.equalTo(adview.mas_bottom).mas_offset(0);
        make.bottom.equalTo(self.view);
        make.width.mas_equalTo(kScreenWidth);
    }];
    if(show_banner_ad_top){
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(adview.mas_bottom).mas_offset(0);
        }];
    }else{
        [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(naviBarView.mas_bottom);
        }];
    }

    
    [self.collectionView registerNib:[UINib nibWithNibName:@"HomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.backgroundColor = [UIColor blackColor];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

-(BOOL) isADInTop {
    NSDictionary* exconfig = [[[AdmobViewController shareAdmobVC] configCenter] getExConfig];
    BOOL adbottom = true;
    @try {
        adbottom = [exconfig[@"adbottom_home"] boolValue];
    } @catch (NSException *exception) {
        adbottom = true;
    } @finally {
    }
    return !adbottom;
}
#ifdef ENABLE_AD
- (void) show_banner_ad {
    CGFloat adH = !show_banner_ad_top ? 0 : adHeight;
    if([self isADInTop]) {
//        [Flurry logEvent:@"show_ad_top" withParameters:@{@"page":@"home"}];
        self.collectionView.frame = CGRectMake(0, kNavigationBarHeight + adH, kScreenWidth, kScreenHeight-kNavigationBarHeight - adH);
        adview.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, adHeight);
        [_adViewController show_admob_banner:adview placeid:@"homepage"];
    } else {
//        [Flurry logEvent:@"show_ad_bottom" withParameters:@{@"page":@"home"}];
        self.collectionView.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight - adH);
        adview.frame = CGRectMake(0, kScreenHeight-adHeight, kScreenWidth, adHeight);
        [_adViewController show_admob_banner:adview placeid:@"homepage"];
    }
}
#endif

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.layoutPatterNames.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return insetsForSection;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return minimumInteritemSpacing;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSString * path = [[NSBundle mainBundle] pathForResource:self.layoutPatterNames[indexPath.item] ofType:@"png"];
    if (path) {
        cell.layoutImageView.image = [UIImage imageWithContentsOfFile:path];
    }
    if ([MGData num:indexPath.item isInArray:lockArray]) {
        cell.lockImageView.hidden = NO;
    } else {
        cell.lockImageView.hidden = YES;
    }
    return cell;
}

//- (void)scrollViewInitBackup
//{
//    MGScrollView *scrollView = [[MGScrollView alloc] init];
//    scrollView.frame = CGRectMake(0, kNavigationBarHeight, kScreenWidth, kScreenHeight-kNavigationBarHeight);
//    [self.view addSubview:scrollView];
//    
//    CGFloat btnW = kDevice2(kScreenWidth/(3), kScreenWidth/(4));
//    CGFloat gapBasic = kDevice2(btnW/4, btnW/6);
//    
//    int row = 0, col = 0;
//    CGFloat lockW = (IS_IPAD?80:40);
//    for(int i=0; i<LayoutNums; i++){
//        row = i / kDevice2(2, 3);
//        col = i % kDevice2(2, 3);
//        
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake(gapBasic+(btnW+gapBasic*2)*col, gapBasic+(btnW+gapBasic*2)*row+kSmartHeight,
//                               btnW, btnW);
//        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"layout%i", i]] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(clickLayout:) forControlEvents:UIControlEventTouchUpInside];
//        btn.tag = i;
//        
//        [scrollView addSubview:btn];
//        
//        if([MGData num:i isInArray:lockArray]){
//            UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
//            iv.frame = CGRectMake((kW(btn)-lockW)/2, (kH(btn)-lockW)/2, lockW, lockW);
//            [btn addSubview:iv];
//            [lockIVArray addObject:iv];
//        }
//    }
//    
//    scrollView.contentSize = CGSizeMake(0, gapBasic+(btnW+gapBasic*2)*(row+1)+kSmartHeight);
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger currentLayoutIdx = indexPath.item;
    
    [MGData mgDownWith:kDownStart];
    
    
#if TARGET_OS_SIMULATOR
#else
    
    if([MGData num:currentLayoutIdx isInArray:lockArray]){
        [_adViewController doUpgradeInApp:self product:kRemoveAd];
        return;
    }
#endif
    
    if([EditorUtility showEditor:self idx:currentLayoutIdx]) {
        return;
    }
    
    
//#ifdef ENABLE_AD
//    [_adViewController show_admob_interstitial:self.navigationController placeid:0];
//#endif
    /*
     
     */
    if (camerVC == nil) {
        camerVC = [[CameraViewController alloc] init];
        camerVC.currentLayoutIndex = currentLayoutIdx;
        [self.navigationController pushViewController:camerVC animated:YES];
    } else {
        camerVC.currentLayoutIndex = currentLayoutIdx;
        [self.navigationController pushViewController:camerVC animated:YES];
        [camerVC refreshViews];
    }
    
    
    
    /*
     CameraViewController * VC = [[CameraViewController alloc] init];
     VC.currentLayoutIndex = currentLayoutIdx;
     [self.navigationController pushViewController:VC animated:YES];
     */
    
    
}


- (void)clickLayout:(id)sender {
    UIButton *btn = (UIButton*)sender;
    int index = (int)btn.tag;
    
    [MGData mgDownWith:kDownStart];
    
    if([MGData num:index isInArray:lockArray]){
        [_adViewController doUpgradeInApp:self product:kRemoveAd];
        return;
    }
    
    
    
    [MGData tryShowAds:_adViewController inVC:self.navigationController];
    
    if(camerVC == nil){
        camerVC = [[CameraViewController alloc] init];
        camerVC.currentLayoutIndex = index;
        [self.navigationController pushViewController:camerVC animated:YES];
    }else{
        camerVC.currentLayoutIndex = index;
        [self.navigationController pushViewController:camerVC animated:YES];
        [camerVC refreshViews];
    }
    
}

#pragma mark -addNavi
- (void)addNavi
{
    naviBarView = [[UIView alloc] init];
    naviBarView.frame = CGRectMake(0, 0, kScreenWidth, kNavigationBarHeight);
    naviBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:naviBarView];
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        safeAreaInsets = window.safeAreaInsets;
    }
    [naviBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).mas_offset(safeAreaInsets.top);
        make.height.mas_equalTo(kNavigationBarHeight);
        make.width.mas_equalTo(kScreenWidth);
    }];
    
    CGFloat cellW = kNavigationBarHeight;
    CGFloat cellH = kNavigationBarHeight;
    CGFloat gap = kNavigationBarHeight/10;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, cellW, cellH);
    [leftBtn setImage:[UIImage imageNamed:naviBarBack] forState:UIControlStateNormal];
    [leftBtn setContentMode:UIViewContentModeCenter];
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(gap, gap, gap, gap)];
    [leftBtn addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
    
    rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(kScreenWidth-cellW, 0, cellW, cellH);
    [rightBtn setImage:[UIImage imageNamed:naviBarUpgrade] forState:UIControlStateNormal];
    [rightBtn setContentMode:UIViewContentModeCenter];
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(gap, gap, gap, gap)];
    [rightBtn addTarget:self action:@selector(clickRightBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:naviBarView.bounds];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = kLocalizable(@"Select Layout");
    
    //[naviBarView addSubview:leftBtn];
    [naviBarView addSubview:rightBtn];
    [naviBarView addSubview:titleLabel];
    
    leftBtn.hidden = YES;
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
                 alert.strContent = @"Thanks for using Split Camera!\nIn this app, we need some permission to access the photo library, and camera to choose or take a photo of you. In this process, We do not collect or save any data getting from your device including processed data. By clicking \"Agree\" you confirm that you have read and agree to our privacy policy.\nAt the same time, Ads may be displayed in this app. When requesting to \"track activity\" in the next popup, please click \"Allow\" to let us find more personalized ads. It's completely anonymous and only used for relevant ads.";
               
               [alert showAlert:self cancelAction:^(id  _Nullable object) {
                   //不同意
                   [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
                   [self exitApplication];
               } privateAction:^(id  _Nullable object) {
                       //   输入项目的隐私政策的 URL
                       SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://play99.cn/support/hfstudio/splitcam/policy.html"]];
                       //sfVC.delegate = self;
                       [self presentViewController:sfVC animated:YES completion:nil];
    //        [self pushWebController:[YSCommonWebUrl userAgreementsUrl] isLoadOutUrl:NO title:@"用户协议"];
               } delegateAction:^(id  _Nullable object) {
                   NSLog(@"用户协议");
                       //   输入项目的隐私政策的 URL
                       SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://play99.cn/support/hfstudio/splitcam/policy.html"]];
                       //sfVC.delegate = self;
                       [self presentViewController:sfVC animated:YES completion:nil];
               }
               ];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void)clickLeftBtn
{
    
}

- (void)clickRightBtn
{
    [_adViewController doUpgradeInApp:self product:kRemoveAd];
    
}

@end
