//
//  HairColorViewController.m
//  HairColor
//
//  Created by ZB_Mac on 2016/11/21.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "HairColorViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MainLevelView_1.h"
#import "AutoDyeTopView.h"
#import "Masonry.h"
#import "HToolView.h"
#import "ComprehensiveCutoutView.h"
#import "MBProgressHUD.h"
#import "ASValueTrackingSlider.h"
#import "HairDyeSelectionView.h"
#import "AdUtility.h"
#import "HairDyeDescriptor.h"
#import "UIImage+Blend.h"
#import "UIImage+Rotation.h"
#import "LoadPhotoView.h"
#import "ShareViewController.h"
#import "CutoutViewController.h"
#import "CameraViewController.h"
#import "CreateCustomColorView.h"
#import "KGModal.h"
#import "ColorManger.h"
#import "UIColor+Hex.h"
#import "CKAlertViewController.h"
#import "ObjectStack.h"
#import "PhotoCache.h"
#import "PurchaseViewController.h"
#import "FakeLanchWindow.h"
#import "GlobalSettingManger.h"
#import "Toast+UIView.h"
@import Flurry_iOS_SDK;
#import "UIImage+Draw.h"
#import "SkinDetector.h"
#import "DermabrasionDevice.h"
#import "MoleRemover.h"
#import "ImageWhitenService.h"
#import "UIImage+vImage.h"
#import "MainLevelView_1.h"
#import <Photos/Photos.h>
#import "Admob.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>

#define DEFAULT_SMOOTH_STRENGHT 0.6
#define DEFAULT_WHITEH_STRENGHT 0.25

@interface HairColorViewController ()<ComprehensiveCutoutViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraViewControllerDelegate, CreateCustomColorViewDelegate, AdmobViewControllerDelegate, SFSafariViewControllerDelegate, AdmobVCBannerAdDelegate>
{
    BOOL _everAppear;
    
    UIImage *_resultImage;
    
    BOOL _everDraw;
    
    int _historyIndex;
    
    long _lastUndoTime;
    int _successiveUndo;
    long _lastRedoTime;
    int _successiveRedo;
    
    long _lastShowSuccessiveAlert;
    BOOL _rememberSuccessiveUndoRedo;
    BOOL _doSuccessiveUndoRedo;
    
    NSInteger _lastIndex;
    
    BOOL _beautifyOn;

    int _maxFrequentShowPopNumber;
    int _frequentShowPopNumber;
    
    BOOL bannerShowed;
    __weak IBOutlet UIView *contentView;
}
@property (nonatomic, strong) MainLevelView_1 *mainLevelView;
@property (nonatomic, strong) AutoDyeTopView  *mainTopView;
@property (nonatomic, strong) ComprehensiveCutoutView *cutoutView;
@property (nonatomic, strong) HairDyeSelectionView *hairDyeSelectionView;
@property (nonatomic, strong) HToolView *bottomToolView;

@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *maskImage;
@property (nonatomic, strong) UIImage *refinedMaskImage;
@property (nonatomic, strong) HairDyeDescriptor *hairDyeDescriptor;

@property (nonatomic, strong) ASValueTrackingSlider *alphaSlider;
@property (nonatomic, strong) ASValueTrackingSlider *brushSlider;

@property (nonatomic, strong) ObjectStack *objectStack;
@property (nonatomic, strong) PhotoCache *photoCache;

@property (nonatomic, strong) UIView *cutoutBtn;
@property (nonatomic, strong) UIView *beautifyView;
@property (nonatomic, strong) UIButton *beautifyBtn;
@property (nonatomic, strong) UILabel *beautifyLabel;

// new
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UITextField *textfield;
@property (nonatomic, retain) FakeLanchWindow *fakeLanchWindow;

@property (strong,nonatomic) UIImagePickerController* pickController;

@end

@implementation HairColorViewController

-(ObjectStack *)objectStack
{
    if (!_objectStack) {
        _objectStack = [[ObjectStack alloc] initWithMaxSize:100 andSupportRedo:YES];
    }
    return _objectStack;
}

-(PhotoCache *)photoCache
{
    if (!_photoCache) {
        _photoCache = [[PhotoCache alloc] initWithIdentifier:@"hairdye_middle_result_"];
    }
    return _photoCache;
}

-(void)loadView
{
    [super loadView];
    self.mainLevelView = [[MainLevelView_1 alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mainLevelView.clipsToBounds = YES;
    self.mainLevelView.backgroundColor = [UIColor whiteColor];
    //self.view = self.mainLevelView;
    //self->contentView = self.mainLevelView;
    [contentView addSubview:self.mainLevelView];
    //contentView.backgroundColor = UIColor.greenColor;
    [self.mainLevelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(contentView);
    }];
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
        alert.hairColorViewController = self;
                 alert.strContent = @"Thanks for using Hair color!\nIn this app, we need some permission to access the photo library, and camera to choose or take a photo of you. In this process, We do not collect or save any data getting from your device including processed data. By clicking 'Agree' you confirm that you have read and agree to our privacy policy.\nAt the same time, Ads may be displayed in this app. When requesting to 'track activity' in the next popup, please click 'Allow' to let us find more personalized ads. It's completely anonymous and only used for relevant ads.";
               
               [alert showAlert:self cancelAction:^(id  _Nullable object) {
                   //不同意
                   [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
                   [self exitApplication];
               } privateAction:^(id  _Nullable object) {
                       //   输入项目的隐私政策的 URL
                       SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://play99.cn/support/lotusstudio/slim/policy.html"]];
                       //sfVC.delegate = self;
                       [self presentViewController:sfVC animated:YES completion:nil];
    //        [self pushWebController:[YSCommonWebUrl userAgreementsUrl] isLoadOutUrl:NO title:@"用户协议"];
               } delegateAction:^(id  _Nullable object) {
                   NSLog(@"用户协议");
                       //   输入项目的隐私政策的 URL
                       SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://play99.cn/support/lotusstudio/slim/policy.html"]];
                       //sfVC.delegate = self;
                       [self presentViewController:sfVC animated:YES completion:nil];
               }
               ];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [self hairAreaSelected];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self firstProtocolAlter];
    _lastIndex = -1;
    _maxFrequentShowPopNumber = 2;
    self.originalImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"demo" ofType:@"jpg"]];
    self.maskImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mask" ofType:@"png"]];
    self.refinedMaskImage = self.maskImage;
    
    [self setupMainView];
    
    self.hairDyeDescriptor = [self.hairDyeSelectionView getDefaultDyeDesc];
    
    BOOL shownFeedback = [[AdmobViewController shareAdmobVC] decideShowRT:self];
    
    //shownFeedback = true;
    
    if (!shownFeedback && [AdUtility hasAd]) {
        self.fakeLanchWindow = [[FakeLanchWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.fakeLanchWindow setParentViewController:self];
        [self.fakeLanchWindow makeKeyAndVisible];
    }
    
    bannerShowed = NO;
}

-(void) releaseFakeLaunchRef {
    self.fakeLanchWindow = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_everAppear) {
        if (![AdUtility hasAd]) {
            [self.mainLevelView showBanner:NO animated:YES completionAction:nil];
        }
    }
    if ([AdUtility hasAd]) {
        if ([[AdmobViewController shareAdmobVC] admob_ever_recive_banner]) {
            bannerShowed = YES;
            [self.mainLevelView showBanner:YES animated:YES completionAction:^(BOOL b) {
                [AdUtility tryShowBannerInView:self.mainLevelView.adContainerView];
            }];
        }
        else
        {
            [AdUtility tryShowBannerInView:self.mainLevelView.adContainerView];
            [AdmobViewController shareAdmobVC].delegate = self;
        }
        
        [[AdmobViewController shareAdmobVC] setBannerClient:self];
    }
    
    [[AdmobViewController shareAdmobVC] ifNeedShowNext:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[AdmobViewController shareAdmobVC] setBannerClient:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_everAppear) {
        [self useHairDyeDescriptor];
        if (_maskImage) {
            if (![self.cutoutView getMaskImage])
            {
                [self.cutoutView setMaskImage:_maskImage];
            }
        }
        [self cutoutBottomViewSelected:2];
        [self.bottomToolView selectAtIndex:2];
        
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"RememberCutHairAlert"]) {
//            [self showCutHairAlert];
//        }
//        else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CutHair"])
//        {
//            [self performSegueWithIdentifier:@"gotoCutout" sender:self];
//        }
        
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"SampleTipRemember"])
    }
    _everAppear = YES;
    [self updateUndoRedoBtns];
}

-(void)hairAreaSelected{
        CKAlertViewController *alertVC = [CKAlertViewController alertControllerWithTitle:NSLocalizedString(@"SAMPLE_HAIR_TIP", @"") message:NSLocalizedString(@"SAMPLE_HAIR_MSG", @"") remember:nil];

        CKAlertAction *cancel = [CKAlertAction actionWithTitle:NSLocalizedString(@"SAMPLE_HAIR_OK", @"") handler:^(CKAlertAction *action) {
            //[self firstProtocolAlter];
        }];
        [alertVC addAction:cancel];

//            CKAlertAction *sure = [CKAlertAction actionWithTitle:NSLocalizedString(@"SAMPLE_HAIR_NOTIP", @"") handler:^(CKAlertAction *action) {
//                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"SampleTipRemember"];
//            }];
//            [alertVC addAction:sure];
        [self presentViewController:alertVC animated:NO completion:nil];
}

-(void)setupMainView
{
    __weak HairColorViewController *_wSelf = self;

    /// top
    NSArray  *apparray= [[NSBundle mainBundle] loadNibNamed:@"AutoDyeTopView" owner:nil options:nil];
    AutoDyeTopView *cutoutTopView = (AutoDyeTopView *)[apparray firstObject];
    
    [cutoutTopView setActions:^(NSInteger index) {
        switch (index)
        {
            case 0:
            {
                [_wSelf loadPhoto];
                break;
            }
            case 1:
            {
                [_wSelf undo];
                break;
            }
            case 2:
            {
                [_wSelf redo];
                break;
            }
            case 3:
            {
                [_wSelf savePhoto];
                break;
            }
            default:
                break;
        }
    }];
    [_mainLevelView.shellTopBarView addSubview:cutoutTopView];
    [cutoutTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(_mainLevelView.shellTopBarView);
    }];
    _mainTopView = cutoutTopView;
    
    // bottom
    NSMutableArray *cellDatas = [NSMutableArray array];
    NSArray *titles = @[
                        NSLocalizedString(@"PAINT_TITLE", @"bottom bar"),
                        NSLocalizedString(@"ERASER_TITLE", @"bottom bar"),
                        NSLocalizedString(@"COLOR_TITLE", @"bottom bar"),
                        NSLocalizedString(@"ADD_TITLE", @"bottom bar"),
                        ];
    NSArray *icons = @[
                       @"btn_brush",
                       @"btn_eraser",
                       @"btn_color",
                       @"btn_color+",
                       ];
    NSArray *icons_h = @[
                         @"btn_brush_h",
                         @"btn_eraser_h",
                         @"btn_color_h",
                         @"btn_color+_h",
                         ];
    NSArray *colors = @[
                        [UIColor colorWithRed:241.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0],
                        [UIColor colorWithRed:165.0/255.0 green:120.0/255.0 blue:240.0/255.0 alpha:1.0],
                        [UIColor colorWithRed:56.0/255.0 green:217.0/255.0 blue:246.0/255.0 alpha:1.0],
                        [UIColor colorWithRed:0.0/255.0 green:232.0/255.0 blue:142.0/255.0 alpha:1.0],
                        ];
    for (NSInteger idx=0; idx<titles.count; ++idx) {
        HToolViewCellAttributes *attributes = [HToolViewCellAttributes new];
        attributes.title = titles[idx];
        attributes.icon = [UIImage imageNamed:icons[idx]];
        attributes.selectedIcon = [UIImage imageNamed:icons_h[idx]];
        attributes.selectedTitleColor = colors[idx];
        attributes.titleColor = [UIColor blackColor];
        attributes.imageViewContentMode = UIViewContentModeScaleAspectFit;
        attributes.imageViewInsets = UIEdgeInsetsMake(2, 0, 2, 0);
        
        [cellDatas addObject:attributes];
    }
    
    HToolView *bottomToolView = [[HToolView alloc] initWithFrame:_mainLevelView.shellBottomBarView.bounds andCellDatas:cellDatas];
    bottomToolView.titleRatio = 0.25;
    bottomToolView.widthRatio = 1.20;
    bottomToolView.showSelectedMode = 4;
    
    [bottomToolView setActions:^(NSInteger index) {
        [_wSelf cutoutBottomViewSelected:index];
    }];
    
    [_mainLevelView.shellBottomBarView addSubview:bottomToolView];
    
    [bottomToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(_mainLevelView.shellBottomBarView);
    }];
    
    _bottomToolView = bottomToolView;
    // pop 1
    HairDyeSelectionView *selectionView = [[HairDyeSelectionView alloc] initWithFrame:_mainLevelView.popView_2.bounds andEnableImageDye:YES];
    selectionView.clipsToBounds = NO;
    selectionView.showLock = ![AdUtility advanceColorAvailable];
    //    selectionView.showRTLock = YES;
    [selectionView setupViews];
    
    selectionView.backgroundColor = [UIColor whiteColor];
    [_mainLevelView.popView_2 addSubview:selectionView];
    
    [selectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.right.equalTo(_mainLevelView.popView_2);
    }];
    
    [selectionView setActions:^(HairDyeDescriptor *dyeDescriptor) {
//        dyeDescriptor.alpha = _wSelf.alphaSlider.value;
//        dyeDescriptor.highlight = _wSelf.hightlightSlider.value;
        _wSelf.hairDyeDescriptor = dyeDescriptor;
        
        if ([_wSelf.cutoutView getMaskImage])
        {
            [_wSelf tryShowFrequentPop];
        }
        [_wSelf useHairDyeDescriptor];
        
        if (![_wSelf.cutoutView getMaskImage])
        {
            [_wSelf.view makeToast:NSLocalizedString(@"PAINT_TO_DYE", @"") duration:2.0 position:@"center"];
        }
    }];

    [selectionView setAddCustomActions:^(NSInteger mode) {
        switch (mode) {
            case 0:
            {
                [_wSelf showCreateCustomColor];
                break;
            }
            case 1:
            {
                [_wSelf performSegueWithIdentifier:@"gotoCamera" sender:self];
                break;
            }
            default:
                break;
        }
    }];
    
    [selectionView setLockActions:^(NSInteger lockMode) {
        [_wSelf showPurchase];
    }];
    self.hairDyeSelectionView = selectionView;
    // pop 2
    ASValueTrackingSlider *brushSizeSlider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectZero];
    [brushSizeSlider setPopupContainerView:_mainLevelView.popView_1];
    brushSizeSlider.font = [UIFont systemFontOfSize:15];
    brushSizeSlider.popUpViewColor = [UIColor colorWithRed:241.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
    brushSizeSlider.minimumValueImage = [UIImage imageNamed:@"thin_line"];
    brushSizeSlider.maximumValueImage = [UIImage imageNamed:@"bold_line"];
    [brushSizeSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    [brushSizeSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_track"] forState:UIControlStateNormal];
    [brushSizeSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_track"] forState:UIControlStateNormal];
    brushSizeSlider.minimumValue = 5;
    brushSizeSlider.maximumValue = 40;
    [brushSizeSlider addTarget:self action:@selector(cutoutDrawLineBrushSizeChanged:) forControlEvents:UIControlEventValueChanged];
    brushSizeSlider.value = [_cutoutView drawLineWidth];
    [_mainLevelView.popView_1 addSubview:brushSizeSlider];
    self.brushSlider = brushSizeSlider;
    
    ASValueTrackingSlider *brushAlphaSlider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectZero];
    [brushAlphaSlider setPopupContainerView:_mainLevelView.popView_1];
    brushAlphaSlider.font = [UIFont systemFontOfSize:15];
    brushAlphaSlider.popUpViewColor = [UIColor colorWithRed:241.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
    brushAlphaSlider.minimumValueImage = [UIImage imageNamed:@"alpha_shallow"];
    brushAlphaSlider.maximumValueImage = [UIImage imageNamed:@"alpha_deep"];
    [brushAlphaSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
    [brushAlphaSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_track"] forState:UIControlStateNormal];
    [brushAlphaSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_track"] forState:UIControlStateNormal];
    brushAlphaSlider.minimumValue = 0.05;
    brushAlphaSlider.maximumValue = 1.00;
    [brushAlphaSlider addTarget:self action:@selector(cutoutDrawLineBrushAlphaChanged:) forControlEvents:UIControlEventValueChanged];
    brushAlphaSlider.value = [_cutoutView drawLineWidth];
    [_mainLevelView.popView_1 addSubview:brushAlphaSlider];
    self.alphaSlider = brushAlphaSlider;
    
    [@[brushSizeSlider, brushAlphaSlider] mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedItemLength:32 leadSpacing:2 tailSpacing:2];
    [@[brushSizeSlider, brushAlphaSlider] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_mainLevelView.popView_1).offset(8);
        make.right.equalTo(_mainLevelView.popView_1).offset(-8);
    }];
    
    // main
    [self setupCutoutView];

    // cutout btn
    UIView *cutoutView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.mainLevelView.contentView addSubview:cutoutView];
    [cutoutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(60));
        make.width.equalTo(@(50));
        make.left.equalTo(self.mainLevelView.contentView).offset(8);
        make.bottom.equalTo(self.mainLevelView.contentView).offset(-8);
    }];
    _cutoutBtn = cutoutView;
    
    UIButton *cutoutBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [cutoutView addSubview:cutoutBtn];
    [cutoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(cutoutBtn.mas_height);
        make.left.right.top.equalTo(cutoutView);
    }];
    [cutoutBtn setImage:[UIImage imageNamed:@"btn_smart_stoke_h"] forState:UIControlStateNormal];
    [cutoutBtn setImageEdgeInsets:UIEdgeInsetsMake(16, 10, 4, 10)];
    [cutoutBtn addTarget:self action:@selector(showCutout) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:10];
    label.text = NSLocalizedString(@"HAIR_AREA_BTN", @"");
    [cutoutView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(cutoutView);
        make.top.equalTo(cutoutBtn.mas_bottom);
    }];
    
    // beautify btn
    UIView *beautifyView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.mainLevelView.contentView addSubview:beautifyView];
    [beautifyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(60));
        make.width.equalTo(@(50));
        make.right.equalTo(self.mainLevelView.contentView).offset(-8);
        make.bottom.equalTo(self.mainLevelView.contentView).offset(-8);
    }];
    _beautifyView = beautifyView;
    
    UIButton *beautifyBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    [beautifyView addSubview:beautifyBtn];
    [beautifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(beautifyBtn.mas_height);
        make.left.right.top.equalTo(beautifyView);
    }];
    [beautifyBtn setImage:[UIImage imageNamed:@"btn_smart_stoke_h"] forState:UIControlStateNormal];
    [beautifyBtn setImageEdgeInsets:UIEdgeInsetsMake(16, 10, 4, 10)];
    [beautifyBtn addTarget:self action:@selector(onekeyBeautify) forControlEvents:UIControlEventTouchUpInside];
    _beautifyBtn = beautifyBtn;
    
    UILabel *beautifyLabel = [UILabel new];
    beautifyLabel.textAlignment = NSTextAlignmentCenter;
    beautifyLabel.font = [UIFont systemFontOfSize:10];
    beautifyLabel.text = NSLocalizedString(@"BEAUTIFY", @"");
    [beautifyView addSubview:beautifyLabel];
    [beautifyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(beautifyView);
        make.top.equalTo(beautifyBtn.mas_bottom);
    }];
    _beautifyLabel = beautifyLabel;
    
    [_beautifyBtn setImage:[UIImage imageNamed:@"btn_beautify_off"] forState:UIControlStateNormal];
    beautifyLabel.textColor = [UIColor blackColor];
}

-(void)setupCutoutView
{
    ComprehensiveCutoutView *cutoutView = [[ComprehensiveCutoutView alloc] initWithFrame:self.mainLevelView.contentView.bounds andImage:self.originalImage];
    [self.mainLevelView.contentView addSubview:cutoutView];
    [cutoutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self.mainLevelView.contentView);
    }];
    [cutoutView setDefaultParaments];
    cutoutView.magnifierParentView = self.mainLevelView.contentView;
    cutoutView.delegate = self;
    self.cutoutView = cutoutView;
    
    self.alphaSlider.value = self.cutoutView.brushAlpha;
    self.brushSlider.value = self.cutoutView.brushRadius;

    [self.mainLevelView.contentView bringSubviewToFront:self.cutoutBtn];
    [self.mainLevelView.contentView bringSubviewToFront:self.beautifyView];
}

-(void)showCreateCustomColor
{
    CreateCustomColorView *view = [[CreateCustomColorView alloc] initWithFrame:contentView.bounds];
    //CreateCustomColorView *view = [[CreateCustomColorView alloc] initWithFrame:self->contentView.bounds];
    view.delegate = self;
    [[KGModal sharedInstance] setTapOutsideToDismiss:NO];
    [[KGModal sharedInstance] setShowCloseButton:NO];
    [[KGModal sharedInstance] showWithContentView:view andAnimated:YES];
}
#pragma mark -
-(void)loadPhoto
{
    __weak HairColorViewController *_wSelf = self;

    NSArray *apparray= [[NSBundle mainBundle] loadNibNamed:@"LoadPhotoView" owner:nil options:nil];
    LoadPhotoView *loadPhotoView = (LoadPhotoView *)[apparray firstObject];
    [loadPhotoView setActions:^(NSInteger loadPhotoMethod) {
        switch (loadPhotoMethod) {
            case 1:
                [_wSelf loadPhotoFromAlbumn];
                break;
            case 2:
                [_wSelf loadPhotoFromCamera];
                break;
            default:
                break;
        }
    }];
    loadPhotoView.frame = self->contentView.bounds;
    [self->contentView addSubview:loadPhotoView];
    [loadPhotoView showBtn:YES animated:YES completionAction:nil];
}

-(void)savePhoto
{
    UIImage *image = self.cutoutView.imageView.image;
    
    image = [image imageBlendedWithImage:self.cutoutView.selectedColorView.image blendMode:kCGBlendModeNormal alpha:1.0];
    
    
    UIImage *maskImage = [self.cutoutView getMaskImage];
    UIImage *selectionImage = self.cutoutView.selectionColorView.image;
    
    if (maskImage) {
        image = [image imageBlendedWithImage:selectionImage maskImage:maskImage blendMode:kCGBlendModeNormal alpha:self.cutoutView.selectionColorView.alpha];
    }
    
    _resultImage = image;

    [AdUtility tryShowInterstitialInVC:self.navigationController ignoreTimeInterval:NO];
    [self performSegueWithIdentifier:@"gotoShare" sender:self];
    
    [[AdmobViewController shareAdmobVC] recordValidUseCount];
}
-(void)redoAll
{
    [self.cutoutView jumpToLast];
    
    [self.objectStack jumpToLast];
    NSString *key = (NSString *)[self.objectStack getTopObject];
    UIImage *midResult = [self.photoCache cachedImageWithKey:key];
    if (_beautifyOn) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *result;
            if (midResult) {
                result = [self doOneKeyBeautifyWithImage:midResult];
                result = [result imageMaskedWithImage:midResult];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cutoutView.selectedColorView.image = result;
            });
        });
    }
    else
    {
        self.cutoutView.selectedColorView.image = midResult;
    }
    [self updateUndoRedoBtns];
}
-(void)redo
{
//    [self tryShowFrequentPop];

    long now = time(NULL);
    if (now - _lastRedoTime < 4) {
        ++_successiveRedo;
    }
    else
    {
        _successiveRedo = 1;
    }
    _lastRedoTime = now;
    
    if (_successiveRedo >= 5)
    {
        if (_rememberSuccessiveUndoRedo) {
            if (_doSuccessiveUndoRedo) {
                [self redoAll];
                return;
            }
        }
        else if (now - _lastShowSuccessiveAlert >= 30)
        {
            _lastShowSuccessiveAlert = now;
            [self showSuccessiveRedoUndoAlert:1];
            return;
        }
    }

    if ([self.objectStack canRedo])
    {
        [self redo_midResult];
    }
    else
    {
        [self.cutoutView redo];
    }

    [self updateUndoRedoBtns];
}

-(void)undoAll
{
    [self.cutoutView jumpToFirst];
    
    [self.objectStack jumpToFirst];
    NSString *key = (NSString *)[self.objectStack getUndoObject];
    UIImage *midResult = [self.photoCache cachedImageWithKey:key];
    if (_beautifyOn) {
        [MBProgressHUD showSharedHUDInView:self.view];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *result;
            if (midResult) {
                result = [self doOneKeyBeautifyWithImage:midResult];
                result = [result imageMaskedWithImage:midResult];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                self.cutoutView.selectedColorView.image = result;
                [MBProgressHUD hideSharedHUD];
            });
        });
    }
    else
    {
        self.cutoutView.selectedColorView.image = midResult;
    }
    [self updateUndoRedoBtns];
}
-(void)undo
{
//    [self tryShowFrequentPop];
    
    long now = time(NULL);
    if (now - _lastUndoTime < 4) {
        ++_successiveUndo;
    }
    else
    {
        _successiveUndo = 1;
    }
    _lastUndoTime = now;
    
    if (_successiveUndo >= 5)
    {
        if (_rememberSuccessiveUndoRedo) {
            if (_doSuccessiveUndoRedo) {
                [self undoAll];
                return;
            }
        }
        else if (now - _lastShowSuccessiveAlert >= 30)
        {
            _lastShowSuccessiveAlert = now;
            [self showSuccessiveRedoUndoAlert:0];
            return;
        }
    }

    if ([self.cutoutView canUndo]) {
        [self.cutoutView undo];
    }
    else
    {
        [self undo_midResult];
    }
    
    [self updateUndoRedoBtns];
}

-(void)redo_midResult
{
    NSString *key = (NSString *)[self.objectStack getRedoObject];
    
    UIImage *midResult = [self.photoCache cachedImageWithKey:key];
    
//    self.cutoutView.selectedColorView.image = midResult;
    
    if (_beautifyOn) {
        [MBProgressHUD showSharedHUDInView:self.view];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *result;
            if (midResult) {
                result = [self doOneKeyBeautifyWithImage:midResult];
                result = [result imageMaskedWithImage:midResult];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                self.cutoutView.selectedColorView.image = result;
                [MBProgressHUD hideSharedHUD];
            });
        });
    }
    else
    {
        self.cutoutView.selectedColorView.image = midResult;
    }
}

-(void)undo_midResult
{
    NSString *key = (NSString *)[self.objectStack getUndoObject];

    UIImage *midResult = [self.photoCache cachedImageWithKey:key];
    
    if (_beautifyOn) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *result;
            if (midResult) {
                result = [self doOneKeyBeautifyWithImage:midResult];
                result = [result imageMaskedWithImage:midResult];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                self.cutoutView.selectedColorView.image = result;
            });
        });
    }
    else
    {
        self.cutoutView.selectedColorView.image = midResult;
    }
}

-(void)push_MidResult:(UIImage *)image
{
    NSString *key = [NSString stringWithFormat:@"mid_%d", _historyIndex];
    [self.photoCache addCacheImage:image withKey:key];
    
    [self.objectStack pushObject:key];
    
    ++_historyIndex;
}

-(void)showSuccessiveRedoUndoAlert:(NSInteger)mode
{
    NSString *message;

    switch (mode) {
        case 0:
            message = NSLocalizedString(@"SUCCESSIVE_UNDO_MSG", @"");
            break;
        case 1:
            message = NSLocalizedString(@"SUCCESSIVE_REDO_MSG", @"");
            break;
        default:
            break;
    }
    
    CKAlertViewController *alertVC = [CKAlertViewController alertControllerWithTitle:NSLocalizedString(@"SUCCESSIVE_REDOUNDO_TIP", @"") message:message remember:NSLocalizedString(@"SUCCESSIVE_REMEMBER", @"")];

    __weak CKAlertViewController *_wAlertVC = alertVC;
    __weak HairColorViewController *_wHairVC = self;
    CKAlertAction *cancel = [CKAlertAction actionWithTitle:NSLocalizedString(@"SUCCESSIVE_REDOUNDO_NO", @"") handler:^(CKAlertAction *action) {
        if ([_wAlertVC isCheckBtnSelected]) {
            _rememberSuccessiveUndoRedo = YES;
            _doSuccessiveUndoRedo = NO;
        }
    }];
    
    CKAlertAction *sure = [CKAlertAction actionWithTitle:NSLocalizedString(@"SUCCESSIVE_REDOUNDO_OK", @"") handler:^(CKAlertAction *action) {

        switch (mode) {
            case 0:
                [_wHairVC undoAll];
                break;
            case 1:
                [_wHairVC redoAll];
                break;
            default:
                break;
        }
        if ([_wAlertVC isCheckBtnSelected]) {
            _rememberSuccessiveUndoRedo = YES;
            _doSuccessiveUndoRedo = YES;
        }
    }];
    
    [alertVC addAction:cancel];
    [alertVC addAction:sure];
    
    [self presentViewController:alertVC animated:NO completion:nil];
}

-(void)showCutHairAlert
{
    CKAlertViewController *alertVC = [CKAlertViewController alertControllerWithTitle:NSLocalizedString(@"FIND_HAIR_TIP", @"") message:NSLocalizedString(@"FIND_HAIR_MSG", @"") remember:NSLocalizedString(@"REMEMBER_CHOOSE", @"")];
    
    __weak CKAlertViewController *_wAlertVC = alertVC;
    __weak HairColorViewController *_wHairVC = self;
    CKAlertAction *cancel = [CKAlertAction actionWithTitle:NSLocalizedString(@"FIND_HAIR_NO", @"") handler:^(CKAlertAction *action) {
//        NSLog(@"点击了 %@ 按钮",action.title);
        if ([_wAlertVC isCheckBtnSelected]) {
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"RememberCutHairAlert"];
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"CutHair"];
        }
        
        [self tryShowFrequentPop];
    }];
    
    CKAlertAction *sure = [CKAlertAction actionWithTitle:NSLocalizedString(@"FIND_HAIR_OK", @"") handler:^(CKAlertAction *action) {
//        NSLog(@"点击了 %@ 按钮",action.title);
        [_wHairVC performSegueWithIdentifier:@"gotoCutout" sender:_wHairVC];
        if ([_wAlertVC isCheckBtnSelected]) {
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"RememberCutHairAlert"];
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"CutHair"];
        }
    }];
    
    [alertVC addAction:cancel];
    [alertVC addAction:sure];
    
    [self presentViewController:alertVC animated:NO completion:nil];
}

-(void)showCutout
{
    [self performSegueWithIdentifier:@"gotoCutout" sender:self];
}

-(void)onekeyBeautify
{
    if(!_beautifyOn && [self lkBeautify]) {
        return;
    }
    
    _beautifyOn = !_beautifyOn;

    if (_beautifyOn) {
        [_beautifyBtn setImage:[UIImage imageNamed:@"btn_beautify_on"] forState:UIControlStateNormal];
        _beautifyLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:60.0/255.0 blue:128.0/255.0 alpha:1.0];
    }
    else
    {
        [_beautifyBtn setImage:[UIImage imageNamed:@"btn_beautify_off"] forState:UIControlStateNormal];
        _beautifyLabel.textColor = [UIColor blackColor];
    }
    
    if (_beautifyOn) {
        [MBProgressHUD showSharedHUDInView:self.view];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            UIImage *image = [self doOneKeyBeautifyWithImage:self.originalImage];
            UIImage *selectedImage_ = [self.photoCache cachedImageWithKey:(NSString *)[self.objectStack getTopObject]];
            UIImage *selectedImage;
            if (selectedImage_) {
                selectedImage = [self doOneKeyBeautifyWithImage:selectedImage_];
                selectedImage = [selectedImage imageMaskedWithImage:selectedImage_];
            }
            UIImage *coloredImage = [self.hairDyeDescriptor hairDyeImage:image withMaskImage:self.refinedMaskImage];
            if (self.refinedMaskImage) {
                coloredImage = [coloredImage imageMaskedWithImage:self.refinedMaskImage];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cutoutView.imageView.image = image;
                self.cutoutView.selectedColorView.image = selectedImage;
                self.cutoutView.selectionColorView.image = coloredImage;
                [MBProgressHUD hideSharedHUD];
            });
        });
    }
    else
    {
        UIImage *image = self.originalImage;
        UIImage *selectedImage = [self.photoCache cachedImageWithKey:(NSString *)[self.objectStack getTopObject]];
        UIImage *coloredImage = [self.hairDyeDescriptor hairDyeImage:image withMaskImage:self.refinedMaskImage];
        if (self.refinedMaskImage) {
            coloredImage = [coloredImage imageMaskedWithImage:self.refinedMaskImage];
        }
        
        self.cutoutView.imageView.image = image;
        self.cutoutView.selectedColorView.image = selectedImage;
        self.cutoutView.selectionColorView.image = coloredImage;
    }
}

-(void)showPurchase
{
    PurchaseViewController *purchaseVC = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:purchaseVC animated:YES completion:nil];
}

#pragma mark -
-(void)tryShowFrequentPop
{
    if (_frequentShowPopNumber < _maxFrequentShowPopNumber) {
        BOOL shown = [AdUtility tryShowInterstitialInVC:self ignoreTimeInterval:NO];
        
        if (shown)
        {
            ++_frequentShowPopNumber;
        }
    }
}

-(void)useHairDyeDescriptor
{
//    [MBProgressHUD showSharedHUDInView:self.view];
    
    if (_beautifyOn) {
        [MBProgressHUD showSharedHUDInView:self.view];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        UIImage *coloredImage = [self.hairDyeDescriptor hairDyeImage:self.originalImage withMaskImage:self.refinedMaskImage];

        UIImage *coloredImage = [self.hairDyeDescriptor hairDyeImage:self.originalImage withMaskImage:self.refinedMaskImage];
        
        if (self.refinedMaskImage) {
            coloredImage = [self.originalImage imageBlendedWithImage:coloredImage maskImage:self.refinedMaskImage];
        }

        if (_beautifyOn && coloredImage) {
            coloredImage = [self doOneKeyBeautifyWithImage:coloredImage];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _cutoutView.selectionColorView.image = coloredImage;
            _cutoutView.selectionColorView.backgroundColor = nil;
            
            [Flurry logEvent:@"Manual Dye" withParameters:@{@"colorIndex":[NSString stringWithFormat:@"%d_%d", (int)self.hairDyeDescriptor.indexPath.section, (int)self.hairDyeDescriptor.indexPath.row], @"groupName":self.hairDyeDescriptor.dyeGroupName}];

            if (_beautifyOn) {
                [MBProgressHUD hideSharedHUD];
            }
//            [MBProgressHUD hideSharedHUD];
        });
    });
}

- (UIImage *)doOneKeyBeautifyWithImage:(UIImage *)srcImage;
{
    UIImage *result = srcImage;
    
    UIImage *moleFreeImage = result;
    
    result = [[DermabrasionDevice defaultProcessor] surfaceSmoothImage:moleFreeImage byStrenght:DEFAULT_SMOOTH_STRENGHT];
    
    UIImage *skinMask = [SkinDetector getSkinMaskImageWithSrcImage:moleFreeImage];
    
    result = [moleFreeImage imageBlendedWithImage:result atOrigin:CGPointZero maskImage:[skinMask boxBlurWithRadius_2:7]];
    
    result = [[DermabrasionDevice defaultProcessor] shadowLighten:result byStrenght:0.5];
    
    result = [[ImageWhitenService defaultProcessor] whitenImage:result byStrenght:DEFAULT_WHITEH_STRENGHT];
    
    return result;
}

-(void)addHairDye
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // save old
        UIImage *maskImage = [self.cutoutView getMaskImage];
//        UIImage *coloredImage = self.cutoutView.selectionColorView.image;
        UIImage *coloredImage = [self.hairDyeDescriptor hairDyeImage:self.originalImage withMaskImage:self.refinedMaskImage];
        if (self.refinedMaskImage) {
//            coloredImage = [coloredImage imageMaskedWithImage:self.refinedMaskImage];
            coloredImage = [self.originalImage imageBlendedWithImage:coloredImage maskImage:self.refinedMaskImage];
        }
        
        NSString *key = (NSString *)[self.objectStack getTopObject];
        UIImage *manualColoredImage = [self.photoCache cachedImageWithKey:key];
        
        if (maskImage)
        {
            if (manualColoredImage) {
                manualColoredImage = [manualColoredImage imageBlendedWithImage:coloredImage maskImage:maskImage blendMode:kCGBlendModeNormal alpha:_cutoutView.selectionColorView.alpha];
            }
            else
            {
                manualColoredImage = [coloredImage imageMaskedWithImage:maskImage alpha:_cutoutView.selectionColorView.alpha];
            }
            manualColoredImage = [self.originalImage imageBlendedWithImage:manualColoredImage blendMode:kCGBlendModeNormal alpha:1.0];
            
            [self push_MidResult:manualColoredImage];
            
            if (_beautifyOn) {
                manualColoredImage = [self doOneKeyBeautifyWithImage:manualColoredImage];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _cutoutView.selectedColorView.image = manualColoredImage;
            _cutoutView.selectionColorView.image = nil;
            // prepare new
            self.hairDyeDescriptor = [self.hairDyeSelectionView getRandomDyeDesc];
            [self.hairDyeSelectionView selectDyeDescriptorAtIndex:self.hairDyeDescriptor.indexPath];
            
            [self useHairDyeDescriptor];
            [_cutoutView setMaskImage:nil];
            [_cutoutView clearHistoryIndex:0];
            
            [self updateUndoRedoBtns];
            
            [self.view makeToast:NSLocalizedString(@"DYE_FINALIZED", @"") duration:1.5 position:@"center"];
            //[self->contentView makeToast:NSLocalizedString(@"DYE_FINALIZED", @"") duration:1.5 position:@"center"];
        });
    });
}

-(void)addColor:(UIColor *)color
{
    [[ColorManger defaultUserManger] addCustomColor:[UIColor hexFromUIColor:color]];
    
    [self.hairDyeSelectionView updateUIForCustomColorAddition];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.hairDyeSelectionView selectNewCustomColor];
    });
}

-(void)maskImageChanged
{
    [Flurry logEvent:@"Accept Mask Edit"];
    
    if (_maskImage) {
        if (![self.cutoutView getMaskImage] && !self.cutoutView.selectedColorView.image)
        {
            if (_beautifyOn) {
                [MBProgressHUD showSharedHUDInView:self.view];
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                
                UIImage *coloredImage = [self.hairDyeDescriptor hairDyeImage:self.originalImage withMaskImage:self.refinedMaskImage];
                
                if (self.refinedMaskImage) {
                    coloredImage = [self.originalImage imageBlendedWithImage:coloredImage maskImage:self.refinedMaskImage];
                }
                
                if (_beautifyOn && coloredImage) {
                    coloredImage = [self doOneKeyBeautifyWithImage:coloredImage];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _cutoutView.selectionColorView.image = coloredImage;
                    _cutoutView.selectionColorView.backgroundColor = nil;
                    
                    [Flurry logEvent:@"Manual Dye" withParameters:@{@"colorIndex":[NSString stringWithFormat:@"%d_%d", (int)self.hairDyeDescriptor.indexPath.section, (int)self.hairDyeDescriptor.indexPath.row], @"groupName":self.hairDyeDescriptor.dyeGroupName}];
                    
                    if (_beautifyOn) {
                        [MBProgressHUD hideSharedHUD];
                    }
                    
                    // refinedMaskImage不为空，染色图片已经过蒙版处理，可以直接置图层蒙版为全1.0
                    if (self.refinedMaskImage) {
                        UIImage *realMask = [UIImage drawImageWithColor:[UIColor colorWithWhite:0.0 alpha:1.0] size:self.originalImage.size scale:self.originalImage.scale];
                        
                        [self.cutoutView setMaskImageWithoutSave:realMask];
                    }
                });
            });

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self cutoutBottomViewSelected:2];
                [self.bottomToolView selectAtIndex:2];
//                [self useHairDyeDescriptor];
            });
        }
        else
        {
            [self useHairDyeDescriptor];
        }
//        else
//        {
//            UIImage *maskImage = [self.cutoutView getMaskImage];
//            maskImage = [maskImage imageBlendedWithImage:_maskImage blendMode:kCGBlendModeNormal alpha:1.0];
//            [self.cutoutView setMaskImage:maskImage];
//        }
    }
    else
    {
        [self useHairDyeDescriptor];
    }
}

#pragma mark -
-(void)updateUndoRedoBtns
{
    UIButton * button = _mainTopView.topToolBtns[1];
    button.enabled = [_cutoutView canUndo] || [self.objectStack canUndo];
    
    button = _mainTopView.topToolBtns[2];
    button.enabled = [_cutoutView canRedo] || [self.objectStack canRedo];;
}

-(void)cutoutBottomViewSelected:(NSInteger)index
{
    CutoutMode cutoutMode = kCutoutModeNone;
    NSInteger popViewType = 0;
    switch (index) {
        case 0:
        {
            cutoutMode = kCutoutModeNormalBrush;
            popViewType = 1;
            break;
        }
        case 1:
        {
            cutoutMode = kCutoutModeNormalEraser;
            popViewType = 1;
            break;
        }
        case 2:
        {
            cutoutMode = kCutoutModeNormalBrush;
            popViewType = 2;
            break;
        }
        case 3:
        {
            cutoutMode = kCutoutModeNormalBrush;
            popViewType = 2;
            
            [self addHairDye];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.bottomToolView selectAtIndex:2];
            });
            break;
        }
        default:
            break;
    }

    if (_lastIndex == index && [_mainLevelView currentPopViewType] == popViewType && index!=3)
    {
        popViewType = 0;
    }
    
    [_mainLevelView showPopView:popViewType animated:YES completionAction:nil];
    
    _lastIndex = index;
    
    [_mainLevelView showPopView:popViewType animated:YES completionAction:nil];
    _cutoutView.cutoutMode = cutoutMode;
}

-(void)cutoutDrawLineBrushSizeChanged:(UISlider *)slider
{
    self.cutoutView.brushRadius = slider.value;
}

-(void)cutoutDrawLineBrushAlphaChanged:(UISlider *)slider
{
    self.cutoutView.brushAlpha = slider.value;
}

#pragma mark - Load Photo
-(void)loadPhotoFromAlbumn
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    NSArray *supportMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    BOOL photoSupported = NO;
    for (NSString *type in supportMediaTypes) {
        if ([type isEqualToString:(NSString *)kUTTypeImage]) {
            photoSupported = YES;
            break;
        }
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] == NO || photoSupported == NO) {
        return;
    }
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = sourceType;
    pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

-(void)loadPhotoFromCamera
{
    
////    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    self.pickController.sourceType;
//
//    self.pickController.mediaTypes;
//    //指定媒体类型是什么 照片还是视频
//    //默认为 照片
//    //通过下一行方法可以返回支持的类型
////    [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
//    //查到很多资料都是"kUTTypeMovie","kUTTypeImage"这两个参数名称但是我测试后发现已经变成下面这两种名称
//    //"public.image"  照片
//    //"public.movie"  视频
//    //如果全部支持可以这么设置
////    self.pickController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
//    //单个支持
//    self.pickController.mediaTypes = @[@"public.image"];
//
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
//
//    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//        //相册访问权限
//         if (status == PHAuthorizationStatusAuthorized) {
//                NSLog(@"Authorized");
//            }else{
//                NSLog(@"Denied or Restricted");
//            }
//    }];
    
    //在跳转到相机的方法中
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        self.pickController = [[UIImagePickerController alloc]init];
//        self.pickController.sourceType = UIImagePickerControllerSourceTypeCamera;
//        self.pickController.mediaTypes = @[@"public.image"];
//        self.pickController.delegate = self;         //代理设置
//        self.pickController.allowsEditing = NO;      //是否提供编辑交互界面
//    }else{
//        return;
//    }
    
    
    NSArray *supportMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    BOOL photoSupported = NO;

    for (NSString *type in supportMediaTypes) {
        if ([type isEqualToString:(NSString *)kUTTypeImage]) {
            photoSupported = YES;
            break;
        }
    }

    //[UIImagePickerController isSourceTypeAvailable:sourceType]
    //如果设备可用返回YES 否则返回NO
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] == NO || photoSupported == NO) {
        return;
    }

    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = sourceType;
    pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;

    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //获取用户编辑之后的图像
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSInteger resolution = ([ZBCommonMethod isAboveIphone4S] || [ZBCommonMethod isAboveIpad3])?1536:1024;
        self.originalImage = [image rotateAndScaleWithMaxSize:resolution];
        self.refinedMaskImage = nil;
        self.maskImage = nil;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [self.cutoutView removeFromSuperview];
            
            [self setupCutoutView];
            [self useHairDyeDescriptor];
            [self updateUndoRedoBtns];
            [self cutoutBottomViewSelected:0];
            [self.bottomToolView selectAtIndex:0];
            
            [self.photoCache removeAllCachedImage];
            [self.objectStack reset];
            [self updateUndoRedoBtns];
            _beautifyOn = NO;
            [_beautifyBtn setImage:[UIImage imageNamed:@"btn_beautify_off"] forState:UIControlStateNormal];
            _beautifyLabel.textColor = [UIColor blackColor];
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"RememberCutHairAlert"]) {
                [self showCutHairAlert];
            }
            else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CutHair"])
            {
                [self performSegueWithIdentifier:@"gotoCutout" sender:self];
            }
            else
            {
                [self tryShowFrequentPop];
            }
            
            [Flurry logEvent:@"New Photo"];
        }];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self tryShowFrequentPop];
        }];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ComprehensiveCutoutViewDelegate
-(void)comprehensiveCutoutViewDidChange:(ComprehensiveCutoutView *)cutoutView
{
    [self.objectStack deleteRedoObjects];;
    [self updateUndoRedoBtns];
    _everDraw = YES;
    self.cutoutBtn.hidden = NO;
    self.beautifyView.hidden = NO;
    
}

-(void)comprehensiveCutoutViewWillBeginDraw:(ComprehensiveCutoutView *)cutoutView
{
//    [_mainLevelView showPopView:0 animated:YES completionAction:nil];
    self.cutoutBtn.hidden = YES;
    self.beautifyView.hidden = YES;

}

-(void)comprehensiveCutoutViewDidEndDraw:(ComprehensiveCutoutView *)cutoutView
{
    self.cutoutBtn.hidden = NO;
    self.beautifyView.hidden = NO;
}

-(void)comprehensiveCutoutViewWillBeginTimeConsumingOperation:(ComprehensiveCutoutView *)cutoutView
{
    [MBProgressHUD showSharedHUDInView:self.view];
}

-(void)comprehensiveCutoutViewDidFinishTimeConsumingOperation:(ComprehensiveCutoutView *)cutoutView
{
    [self updateUndoRedoBtns];
    [MBProgressHUD hideSharedHUD];
}

#pragma mark - CameraViewControllerDelegate
-(void)cameraVC:(CameraViewController *)cameraVC didFinishWithColor:(UIColor *)color
{
    [self addColor:color];
}

-(void)cameraVCDidCancel:(CameraViewController *)cameraVC
{
    
}

#pragma mark - CreateCustomColorViewDelegate
-(void)createCustomColorView:(CreateCustomColorView *)view didFinishCreateColor:(UIColor *)color
{
    [[KGModal sharedInstance] hideAnimated:YES];

    [self addColor:color];
}

-(void)createCustomColorViewDidCancel:(CreateCustomColorView *)view
{
    [[KGModal sharedInstance] hideAnimated:YES];
}

#pragma mark - AdmobViewControllerDelegate
- (void)adMobVCDidReceiveInterstitialAd:(AdmobViewController *)adMobVC {
    if([self.fakeLanchWindow isKeyWindow]) {
        [self.fakeLanchWindow adMobVCDidReceiveInterstitialAd:adMobVC];
    }
}

- (void)adMobVCDidCloseInterstitialAd:(AdmobViewController *)adMobVC {
    if([self.fakeLanchWindow isKeyWindow]) {
        [self.fakeLanchWindow adMobVCDidCloseInterstitialAd:adMobVC];
    }
}

-(void)adMobVCBannerAdLoaded:(ADWrapper *)bannerad
{
    if([AdUtility hasAd] && !bannerShowed) {
        bannerShowed = YES;
        [self.mainLevelView showBanner:YES animated:YES completionAction:^(BOOL b) {
            [AdUtility tryShowBannerInView:self.mainLevelView.adContainerView];
        }];
    }
}

#pragma mark -
#pragma mark -
-(UIView *)getContentView
{
    return _cutoutView;
}

-(UIImage *)getContentImage
{
    return _resultImage?_resultImage:_originalImage;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    __weak HairColorViewController *wSelf = self;
    UIViewController *VC = segue.destinationViewController;
    NSString *identifier = segue.identifier;
    
    if ([VC isKindOfClass:[ShareViewController class]] && [identifier isEqualToString:@"gotoShare"])
    {
        ShareViewController *shareVC = (ShareViewController *)VC;
        shareVC.originalImage = _resultImage;
    }
    else if ([VC isKindOfClass:[CutoutViewController class]] && [identifier isEqualToString:@"gotoCutout"])
    {
        CutoutViewController *cutoutVC = (CutoutViewController *)VC;
        cutoutVC.originalImage = _originalImage;
        cutoutVC.maskImage = _maskImage;
        [cutoutVC setActions:^(BOOL accept, UIImage *maskImage, UIImage *refinedMask) {
            if (accept) {
                wSelf.maskImage = maskImage;
                wSelf.refinedMaskImage = refinedMask;
                [wSelf maskImageChanged];
            }
            [wSelf tryShowFrequentPop];
        }];
        
        [Flurry logEvent:@"Enter Mask Edit"];
    }
    else if ([VC isKindOfClass:[CameraViewController class]] && [identifier isEqualToString:@"gotoCamera"])
    {
        CameraViewController *cameraVC = (CameraViewController *)VC;
        cameraVC.delegate = self;
    }
}


-(BOOL) lkBeautify {
    if([[AdmobViewController shareAdmobVC] IsPaid:kRemoveAd]) {
        return FALSE;
    }
    GRTService* service = (GRTService*)[[AdmobViewController shareAdmobVC] rtService];
    if([service isRT] || [service isGRT])
        return FALSE;
    
    NSString* msg = @"unlock one key beautify";
    if([[[AdmobViewController shareAdmobVC] rtService] getCurrentLanguageType] == 1)
        msg = @"解锁一键美颜";
    
    return [[AdmobViewController shareAdmobVC] getRT:self isLock:true rd:msg cb:^{}];
}


#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


//void RequestSKAdNetwork()
//{
//    if (@available(iOS 14.0, *)) {
//        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
//            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
//                UnitySendMessage("SDK", "RequestSKAdNetworkResult", "1");
//            } else {
//                UnitySendMessage("SDK", "RequestSKAdNetworkResult", "0");
//            }
//        }];
//    } else {
//        UnitySendMessage("SDK", "RequestSKAdNetworkResult", "1");
//    }
//}

@end
