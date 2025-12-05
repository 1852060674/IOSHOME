//
//  CameraViewController.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-6.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "CameraViewController.h"
#import "GPUImage.h"
#import "MGDefine.h"
#import "GPUImageVideoCamera+FlashContoller.h"
#import "UIImage+Rotation.h"
#import "MGIrregularView.h"
#import "MGLineView.h"
#import "MGHorCView.h"
#import "MGTBArrowView.h"
#import "MGTBArrowActView.h"
#import "MGTBArrowAspectView.h"
#import "MGImageUtil.h"
#import "MGGPUUtil.h"
#import "LemonUtil.h"
#import "UIImage+Rotating.h"
#import "UIBezierPath+Points.h"
#import "MGImageUtil.h"
#import "MGSlider.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "PocketSVG.h"
#import "MGData.h"
@import AssetsLibrary;
@import Photos;
#import <SVProgressHUD.h>
#define MGStr(x) [NSString stringWithFormat:@"%i", (int)x]
#define MGChangeNums2(a,b)  @[@a,@b]
#define MGChangeNums(a,b,c,d)  @[@a,@b,@c,@d]
#define MGChangeNums6(a,b,c,d,e,f)  @[@a,@b,@c,@d,@e,@f]
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "NewDrawingDialog.h"
#import "AdUtility.h"
@import Flurry_iOS_SDK;

#import "EditorUtility.h"
@import AppLovinSDK;

#define kAllowImageMaxSize    MIN(((1920*1080)*0.8),((1920*1080)*0.8)*kScreenWidth/414)

#define MGLineWidth      4.0f

typedef NS_ENUM(NSInteger, FinishedAdsShowType) {
    ShowNotEver = 0,
    ShowOnce,
    ShowNever
};

@interface CameraViewController ()<MGIrregularViewDelegate,MGIrregularViewDataSource,MGHorCViewDataSource,MGHorCViewDelegate, MGTBArrowViewDelegate,MGTBArrowActViewDelegate,MGTBArrowAspectViewDelegate,MGLineViewDelegate,MGLineViewDataSource,MBProgressHUDDelegate, AdmobViewControllerDelegate>
{
    CGFloat adHeight;
    CGFloat bottomH;
    CGFloat toolBarH;
    
    UIButton *cameraBtn;
    UIButton *backBtn;
    UIButton *swapBtn;
    UIButton *flashBtn;
    UIButton *timerBtn;
    UILabel *timerLabel;
    //UIView *naviBarView;
    //UIView *naviBarView2;
    
    UIButton *changeBtn;
    UIButton *takeBtn;
    UIButton *photoBtn;
    UIView *bottomView;
    UIView *bottomView2;
    
    NSMutableArray *blurViews;
    
    NSMutableArray *pictureBezierPaths;
    NSMutableArray *lineBezierPaths;
    
    NSMutableArray *irregularViews;
    
    UIView *presentView;
    UIView *bordersView;
    NSMutableArray *lineViews;
    NSMutableArray *borders;
    
    NSInteger selectedIdx;
    NSInteger lastIdx;
    NSMutableArray *frameFlags;
    
    NSMutableArray *sublayoutEndpoints;
    NSMutableArray *sublayoutEndpointsBackup;
    NSMutableArray *lines;
    NSMutableArray *shapes;
    NSMutableArray *blurDirections;
    
    MGHorCView *mgCV;
    MGTBArrowView *mgTBAV;
    MGTBArrowActView *mgTBActView;
    MGTBArrowAspectView *mgTBAspectView;
    
    NSMutableDictionary *gpuImageArray;
    NSMutableDictionary *gpuIVArray;
    NSMutableDictionary *filtersArray;
    
    GPUImagePicture *currentPic;
    GPUImageView *currentGIV;
    
    CGRect originRect;
    MGSlider *blurSlider;
    CGFloat lastBlurValue;
    NSInteger sliderCount;
    
    NSInteger timerStatus;
    MBProgressHUD *mbHud;
    NSTimer *timer;
    NSInteger secs;
    
    UIImageView *maskBorder;
    BOOL isTakeOVer;
    UIView *bgIV;
    UIButton *shareBtn;
    AdmobViewController *_adViewController;
    
    CGRect irregularRect;
    
    GPUImageFilter *cropFilter;
    
    FinishedAdsShowType finishedShow;
    
    bool show_banner_ad_top;
    UIView *adview;
    UIView *baseview;
    CGFloat adheight;
    UIEdgeInsets safeAreaInsets;
}

@property (assign, nonatomic) NSInteger selectedIdx;
@property (assign, nonatomic) NSInteger lastIdx;
@property (assign, nonatomic) CGFloat edgeBlurValue;
@property (nonatomic,strong) NSArray *frameInfoArray;
@property (assign, nonatomic) CGRect cameraRect;
@property (strong, nonatomic) GPUImageView *gpuIV;
@property (strong, nonatomic) GPUImageStillCamera *stillCamera;
@property (strong, nonatomic) GPUImageFilter *basicFilter;
@property (strong, nonatomic) NSMutableDictionary *outputImages;
@property (strong, nonatomic) NSMutableDictionary *showImages;
@property (strong, nonatomic) NSMutableArray *allfilterArray;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

@property (nonatomic, strong) NewDrawingDialog* returnDialog;
@end

@implementation CameraViewController
@synthesize selectedIdx;
@synthesize lastIdx;
@synthesize pickerController;
@synthesize cameraRect;
@synthesize edgeBlurValue;
@synthesize progressHUD=_progressHUD;

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_stillCamera stopCameraCapture];
    [_stillCamera pauseCameraCapture];
}

- (void)loadView {
    [super loadView];
    adheight = MAAdFormat.banner.adaptiveSize.height;
    safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        safeAreaInsets = window.safeAreaInsets;
    }
    baseview = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:baseview];
    [baseview mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.top.mas_equalTo(self.view).mas_offset(safeAreaInsets.top);
        make.height.equalTo(self.view).offset(-1 * (safeAreaInsets.top + safeAreaInsets.bottom));
        make.width.mas_equalTo(kScreenWidth);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _adViewController = [AdmobViewController shareAdmobVC];
    _adViewController.delegate = self;
//    show_banner_ad_top = [self isADInTop];
    show_banner_ad_top = ![_adViewController IsPaid:kRemoveAd];
//    show_banner_ad_top = false;
    
    self.allfilterArray = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Filters" ofType:@"plist"]];
//    adheight = kSmartHeight;
    bottomH = (IS_IPAD?100:80);
    toolBarH = bottomH;
    selectedIdx = 0;
    sliderCount = 0;
    
    timerStatus = 0;
    isTakeOVer = NO;
    
    [self widgetsInit];
    
    if(show_banner_ad_top){
        adview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, adheight)];
        [baseview addSubview:adview];
    }


    
    [self createSaveSuccDialog];
    
    finishedShow = ShowNotEver;
    
    [[AdmobViewController shareAdmobVC] ifNeedShowNext:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"%@(%p) %@",NSStringFromClass([self class]),self,NSStringFromSelector(_cmd));
    
    for(id obj in blurViews){
        if([obj isKindOfClass:[UIVisualEffectView class]]){
            [((UIVisualEffectView*)obj) removeFromSuperview];
        }
    }
    
    [_basicFilter removeAllTargets];
    [_basicFilter removeOutputFramebuffer];
    
    [_stillCamera stopCameraCapture];
    [_stillCamera removeAllTargets];
    [_stillCamera removeOutputFramebuffer];
    
    [_outputImages removeAllObjects];
    [_showImages removeAllObjects];
    
    [filtersArray removeAllObjects];
    [gpuImageArray removeAllObjects];
    
    [_progressHUD removeFromSuperview];
    _progressHUD = nil;
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [mgCV.myCollection selectItemAtIndexPath:path animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    _adViewController.rootViewController = self;
    
    if(_stillCamera != nil){
        [_stillCamera startCameraCapture];
        [_stillCamera resumeCameraCapture];
    }
    
    if([_adViewController IsPaid:kRemoveAd]){
        mgCV.isPaid = YES;
        [mgCV unlockLocks];
        CGRect frame = adview.frame;
        frame.size.height = 0;
        adview.frame = frame;
    } else {
#ifdef ENABLE_AD
        [self show_banner_ad];
#endif
    }
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)refreshViews {
    [_outputImages removeAllObjects];
    [filtersArray removeAllObjects];
    [sublayoutEndpoints removeAllObjects];
    [sublayoutEndpointsBackup removeAllObjects];
    [lines removeAllObjects];
    [blurDirections removeAllObjects];
    if(show_banner_ad_top) {
        cameraRect = CGRectMake(0, adheight, kScreenWidth, kScreenHeight - adheight - bottomH - safeAreaInsets.top - safeAreaInsets.bottom);
    } else {
        cameraRect = CGRectMake(0, 0, kScreenWidth, kScreenHeight - bottomH - safeAreaInsets.top - safeAreaInsets.bottom);
    }
    [self setBgIVRect:cameraRect];
    presentView.frame = cameraRect;
    bordersView.frame = cameraRect;
    
    [self PointsInit];
    
    isTakeOVer = NO;
    selectedIdx = 0;
    sliderCount = 0;
    timerStatus = 0;
    
    
    [self blurViewsInit];
    [self irregularViewsInit];
    
    [self linesInit];
    [self borderInit];
    edgeBlurValue = 0.0;
    lastBlurValue = 0.0;
    blurSlider.value = 0.0;
    
    [self mgCVInit];
    [self mgTBArrowViewInit];
    [self mgTBArrowActViewInit];
    [self mgTBArrowAspectViewInit];
    
    [timerBtn setImage:[UIImage imageNamed:@"camera_timer"] forState:UIControlStateNormal];
    timerLabel.text = @"";
    bottomView2.hidden = YES;
    
    backBtn.hidden = NO;
    swapBtn.hidden = NO;
    flashBtn.hidden = NO;
    
    if(![_stillCamera isBackFacingCameraPresent]){
        swapBtn.hidden = YES;
        flashBtn.hidden = YES;
    }
}

- (void)createCamera
{
    NSString *sessionType = kDevice3(AVCaptureSessionPresetMedium, AVCaptureSessionPresetHigh, AVCaptureSessionPreset1280x720);
    
    if([MGData isIpad2]){
        sessionType = AVCaptureSessionPresetHigh;
    }
    
    if([GPUImageVideoCamera isBackFacingCameraPresent]){
        _stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:sessionType cameraPosition:AVCaptureDevicePositionBack];
    }else{
        _stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:sessionType cameraPosition:AVCaptureDevicePositionFront];
    }
    _stillCamera.jpegCompressionQuality = 0.7;
    _stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _stillCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    [_stillCamera setAutoExpose];
    
    //[_stillCamera addTarget:_gpuIV];
    
    cropFilter = [[GPUImageCropFilter alloc] init];
    if(IS_IPAD)
        ((GPUImageCropFilter*)cropFilter).cropRegion = CGRectMake(0.0, 160.0/1280.0, 1.0, 1.0-320.0/1280.0);
    else
        ((GPUImageCropFilter*)cropFilter).cropRegion = CGRectMake(0.0, (960-1280*2/3)/2/1280.0, 1.0, 1.0-(960-1280*2/3)/1280.0);
    
    _basicFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"normal"];//[[GPUImageBrightnessFilter alloc] init];
    
    if (IS_IPAD || kIsIphone35) {
        [_stillCamera addTarget:cropFilter];
        [cropFilter addTarget:_basicFilter];
    } else {
        [_stillCamera addTarget:_basicFilter];
    }
    [_basicFilter addTarget:_gpuIV];
    
    [self blurViewsInit];
}

- (void)blurViewsInit
{
    for(UIView *view in blurViews){
        [view removeFromSuperview];
    }
    [blurViews removeAllObjects];
    [frameFlags removeAllObjects];
    
    for(int i=0; i<sublayoutEndpoints.count; i++){
        UIView *visualEffectView = nil;
        if (kSystemVersion >= 8.0) {
            UIVisualEffectView *visualEffectView2 = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            visualEffectView2.frame = presentView.bounds;
            //            visualEffectView.alpha = 0.8;
            [presentView addSubview:visualEffectView2];
            visualEffectView = visualEffectView2;
        } else {  // iOS < 8.0
            visualEffectView = [[UIView alloc] init];
            visualEffectView.frame = presentView.bounds;
            visualEffectView.backgroundColor = [UIColor grayColor];
            visualEffectView.alpha = 0.6;
            [presentView addSubview:visualEffectView];
        }
        
        if(self.currentLayoutIndex < LastSimpleLineLayoutPattern+1){
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [pictureBezierPaths[i] CGPath];
            shapeLayer.fillRule = kCAFillRuleEvenOdd;
            visualEffectView.layer.mask = shapeLayer;
        } else {
            if (i == 0) {
                CGMutablePathRef path = CGPathCreateMutable();
                CGPathAddPath(path, nil, [pictureBezierPaths[i] CGPath]);
                CGPathAddRect(path, nil, visualEffectView.layer.bounds);
                
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                shapeLayer.path = path;
                CGPathRelease(path);
                
                shapeLayer.fillRule = kCAFillRuleEvenOdd;
                visualEffectView.layer.mask = shapeLayer;
            }else{
                CAShapeLayer *shapeLayer = [CAShapeLayer layer];
                shapeLayer.path = [pictureBezierPaths[i] CGPath];
                shapeLayer.fillRule = kCAFillRuleEvenOdd;
                visualEffectView.layer.mask = shapeLayer;
            }
        }
        
        [blurViews addObject:visualEffectView];
        [frameFlags addObject:[NSNumber numberWithBool:YES]];
        
        
        if(i == 0){
            [self hideBlurAtIndex:i];
        }
    }
}

- (void)hideBlurAtIndex:(NSInteger)index
{
    if(kSystemVersion >= 8.0){
        UIVisualEffectView *view = [blurViews objectAtIndex:index];
        view.hidden = YES;
    }else{
        UIView *view = [blurViews objectAtIndex:index];
        view.hidden = YES;
    }
}

- (void)showBlurAtIndex:(NSInteger)index
{
    if(kSystemVersion >= 8.0){
        UIVisualEffectView *view = [blurViews objectAtIndex:index];
        view.hidden = NO;
    }else{
        UIView *view = [blurViews objectAtIndex:index];
        view.hidden = NO;
    }
}

#pragma mark - MGLineView & Delegate & DataSource
- (void)linesInit
{
    for(MGLineView *line in lineViews){
        [line removeFromSuperview];
    }
    [lineViews removeAllObjects];
    
    NSInteger lineCount = (self.currentLayoutIndex < LastSimpleLineLayoutPattern+1) ? lines.count : 1;
    for (int i=0; i<lineCount; i++) {
        MGLineView *lineView = [[MGLineView alloc] initWithFrame:cameraRect];
        lineView.lineIndex = i;
        lineView.layoutIndex = self.currentLayoutIndex;
        lineView.delegate = self;
        lineView.dataSource = self;
        lineView.points = lines[i];
        lineView.bezierArea = lineBezierPaths[i];
        lineView.viewRect = irregularRect;
        lineView.width = MGLineWidth;
        lineView.backgroundColor = [UIColor clearColor];
        [lineView createPath];
        [baseview addSubview:lineView];
        [lineViews addObject:lineView];
    }
}

- (void)mgLineMovedWithViewIndex:(NSInteger)index
{
    [self sublayoutEndpointsRefeshAfterMoveLineIndex:index blurWidth:edgeBlurValue];
    [self sublayoutEndpointsBackupRefeshAfterMoveLineIndex:index blurWidth:0];
    
    for(int i=0; i<sublayoutEndpoints.count; i++){
        
        if(kSystemVersion >= 8.0){
            UIVisualEffectView *visualEffectView = [blurViews objectAtIndex:i];
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [pictureBezierPaths[i] CGPath];
            shapeLayer.fillRule = kCAFillRuleEvenOdd;
            visualEffectView.layer.mask = shapeLayer;
            [visualEffectView setNeedsDisplay];
        }else{
            UIView *visualEffectView = [blurViews objectAtIndex:i];
            CAShapeLayer *shapeLayer = [CAShapeLayer layer];
            shapeLayer.path = [pictureBezierPaths[i] CGPath];
            shapeLayer.fillRule = kCAFillRuleEvenOdd;
            visualEffectView.layer.mask = shapeLayer;
            
            [visualEffectView setNeedsDisplay];
        }
    }
    
    for(int i=0; i<sublayoutEndpoints.count; i++){
        MGIrregularView *irregularView = [irregularViews objectAtIndex:i];
        irregularView.bezierArea = pictureBezierPaths[i];
        irregularView.viewRect = [self rectWithEndpoints:sublayoutEndpoints[i]];
        irregularView.blur0Rect = [self rectWithEndpoints:sublayoutEndpointsBackup[i]];
        irregularView.clipsToBounds = YES;
        
        if(irregularView.isInEdit){
            //[irregularView setMaskLayer];
            [self borderWithIndex:i WithAutoHide:NO];
            //[irregularView setResfresh];
            [irregularView changeEdgeBlurWidth:blurSlider.value];
        }
    }
}

- (NSArray*)mgLineView:(MGLineView *)lineView AffectInIndex:(NSInteger)index
{
    NSArray *arr = [lines objectAtIndex:index];
    
    return arr;
}

- (NSInteger)numberOfLines {
    return lines.count;
}

- (void)mgLineChangedWithArray:(NSArray *)newPoint WithIndex:(NSInteger)index
{
    [self LinesRefreshAfterMoveLines:newPoint withLineIndex:index];
}

- (void)mgAffectLineChangedWithArray:(NSArray *)newPoint WithIndex:(NSInteger)index
{
    [self affectLinesRefreshAfterMoveLines:newPoint withAffectIndex:index];
}

#pragma mark - BorderInit
- (void)borderInit
{
    for(UIImageView *iv in borders){
        [iv removeFromSuperview];
    }
    [borders removeAllObjects];
    
    for(int i=0; i<irregularViews.count; i++){
        MGIrregularView *irView = irregularViews[i];
        UIImageView *iv = [[UIImageView alloc] init];
        iv.frame = irView.bounds;
        iv.userInteractionEnabled = NO;
        
        [bordersView addSubview:iv];
        [borders addObject:iv];
    }
}

- (void)borderWithIndex:(NSInteger)index WithAutoHide:(BOOL)isHide
{
    UIImageView *border = [borders objectAtIndex:index];
    MGIrregularView *irView = irregularViews[index];
    switch (irView.shapeType) {
        case BezierShaper:{
            border.frame = irView.blur0Rect;
            border.layer.borderWidth = irView.borderWidth;
            border.layer.borderColor = [UIColor whiteColor].CGColor;
            
            break;
        }
        case ImageShaper:{
            
            border.image = [MGImageUtil bezierPath:irView.bezierArea inRect:irView.frame WithWidth:irView.borderWidth];
            
            break;
        }
        case RectShaper:{
            
            if([self isNoKindOfAskewLine]){
                border.frame = irView.bounds;
                border.layer.borderWidth = irView.borderWidth;
                border.layer.borderColor = [UIColor whiteColor].CGColor;
            }else{
                border.image = [MGImageUtil bezierPath:irView.bezierArea inRect:irView.frame WithWidth:irView.borderWidth];
            }
            break;
        }
        default:
            break;
    }
    
    if(isHide && !isTakeOVer){
        border.hidden = YES;
    }
}

- (BOOL)isNoKindOfAskewLine {
    return
    self.currentLayoutIndex != LayoutPatternDiagonal &&
    self.currentLayoutIndex != LayoutPatternLeftArrowx2 &&
    self.currentLayoutIndex != LayoutPatternLeftArrowx1 &&
    self.currentLayoutIndex != LayoutPatternDownArrowx1 &&
    self.currentLayoutIndex != LayoutPatternDownArrowx2 &&
    self.currentLayoutIndex != LayoutPatternShapeSx1 &&
    self.currentLayoutIndex != LayoutPatternShapeSx2;
}

- (void)setBgIVRect:(CGRect)rect
{
    CGRect rect1 = baseview.bounds;
    CGRect rect2 = rect;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, rect2);
    CGPathAddRect(path, nil, rect1);
    shapeLayer.path = path;
    CGPathRelease(path);
    shapeLayer.fillRule = kCAFillRuleEvenOdd;
    bgIV.layer.mask = shapeLayer;
}

#pragma mark - widgets
- (void)widgetsInit
{
    NSLog(@"%f",baseview.bounds.size.height);
    _gpuIV = [[GPUImageView alloc] initWithFrame:baseview.bounds];
    [baseview addSubview:_gpuIV];
    
    bgIV = [[UIView alloc] initWithFrame:baseview.bounds];
    bgIV.backgroundColor = CameraBgColor;
    [baseview addSubview:bgIV];
    
    NSLog(@"%f", adheight);
    
    if(show_banner_ad_top) {
        cameraRect = CGRectMake(0, adheight, kScreenWidth, kScreenHeight-adheight-bottomH-safeAreaInsets.top-safeAreaInsets.bottom);
    } else {
        cameraRect = CGRectMake(0, 0, kScreenWidth, kScreenHeight-bottomH-safeAreaInsets.top-safeAreaInsets.bottom);
    }
    
    originRect = cameraRect;
    [self dataInit];
    
    presentView = [[UIView alloc] initWithFrame:cameraRect];
    [baseview addSubview:presentView];
    bordersView = [[UIView alloc] initWithFrame:cameraRect];
    [baseview addSubview:bordersView];
    bordersView.userInteractionEnabled = NO;
    
    [self createCamera];
    
    [self setBgIVRect:cameraRect];
    
    [self irregularViewsInit];
    [self borderInit];
    [self linesInit];
    pickerController = [[UIImagePickerController alloc] init];
    
    [self addNavi];
    [self addBottom];
    [self addBottom2];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerTask) userInfo:nil repeats:YES];
}

- (void)irregularViewsInit
{
    for(MGIrregularView *irView in irregularViews){
        [irView.contentView removeFromSuperview];
        irView.imageView.image = nil;
        [irView removeFromSuperview];
    }
    
    [irregularViews removeAllObjects];
    
    if(self.currentLayoutIndex < LayoutPatternDiagonal){
        for(int i=0; i<sublayoutEndpoints.count; i++){
            MGIrregularView *irregularView = [[MGIrregularView alloc] initWithFrame:presentView.bounds];
            irregularView.sublayoutIndex = i;
            irregularView.layoutIndex = self.currentLayoutIndex;
            irregularView.delegate = self;
            irregularView.dataSource = self;
            irregularView.bezierArea = pictureBezierPaths[i];
            irregularView.viewRect = [self rectWithEndpoints:sublayoutEndpoints[i]];
            irregularView.blur0Rect = [self rectWithEndpoints:sublayoutEndpointsBackup[i]];
            irregularView.shapeType = BezierShaper;
            irregularView.clipsToBounds = YES;
            [irregularView setMaskLayer0];
            
            irregularView.blurDirection = [blurDirections[i] integerValue];
            
            [presentView addSubview:irregularView];
            [irregularViews addObject:irregularView];
        }
    }else{
        for(int i=0; i<sublayoutEndpoints.count; i++){
            MGIrregularView *irregularView = [[MGIrregularView alloc] initWithFrame:presentView.bounds];
            irregularView.sublayoutIndex = i;
            irregularView.delegate = self;
            irregularView.dataSource = self;
            irregularView.layoutIndex = self.currentLayoutIndex;
            
            if(i == 0){
                irregularView.bezierArea = pictureBezierPaths[i];
                irregularView.viewRect = presentView.bounds;
                irregularView.shapeType = RectShaper;
            }else{
                irregularView.bezierArea = pictureBezierPaths[i];
                irregularView.viewRect = ([self isKindOfAskewLine]) ? [self rectWithEndpoints:sublayoutEndpoints[i]] : irregularRect;
                irregularView.shapeType = ImageShaper;
            }
            irregularView.clipsToBounds = YES;
            [irregularView setMaskLayer0];
            
            [presentView addSubview:irregularView];
            [irregularViews addObject:irregularView];
        }
    }
    
    [self irregularViewReorder];
}

- (BOOL)isKindOfAskewLine {
    return
    self.currentLayoutIndex == LayoutPatternDiagonal ||
    self.currentLayoutIndex == LayoutPatternLeftArrowx2 ||
    self.currentLayoutIndex == LayoutPatternLeftArrowx1 ||
    self.currentLayoutIndex == LayoutPatternDownArrowx1 ||
    self.currentLayoutIndex == LayoutPatternDownArrowx2 ||
    self.currentLayoutIndex == LayoutPatternShapeSx1 ||
    self.currentLayoutIndex == LayoutPatternShapeSx2;
}

- (void)irregularViewReorder
{
    for(int i=0; i<irregularViews.count; i++){
        if((self.currentLayoutIndex == V2_1x1_1x2 || self.currentLayoutIndex == V2_1x1_1x3) && i== 0){
            MGIrregularView *irregularView = [irregularViews objectAtIndex:i];
            [presentView bringSubviewToFront:irregularView];
        }
        if((self.currentLayoutIndex == V2_1x2_1x3) && i == 2){
            
            //      MGIrregularView *irregularView = [irregularViews objectAtIndex:i];
            //      [presentView sendSubviewToBack:irregularView];
        }
    }
}

#pragma mark - MGIrregularView Delegate
- (void)tapViewAtIndex:(NSInteger)index
{
    NSLog(@"click view in %i", (int)index);
    
    if(index != selectedIdx && ![self isPictureAtIndex:index]){
        [self hideBlurAtIndex:index];
        [self showBlurAtIndex:selectedIdx];
        
        selectedIdx = index;
    }
    
    if([self isInEdit] && index != selectedIdx){
        NSLog(@"is In Edit");
        
        //self.selectedIdx = index;
    }
}

- (void)tapFocusInPoint:(CGPoint)point WithIndex:(NSInteger)index
{
    [_stillCamera setFocusInPoint:point InView:[irregularViews objectAtIndex:index]];
    
    if(isTakeOVer){
        self.selectedIdx = index;
        
        for (int i=0; i<borders.count; i++) {
            UIImageView *iv = [borders objectAtIndex:i];
            if (i == index) {
                iv.hidden = !iv.hidden;
            } else {
                iv.hidden = YES;
            }
        }
    }
}

- (BOOL)isTakeOverAtMGIrregularView:(MGIrregularView *)view
{
    return isTakeOVer;
}

- (BOOL)isPictureAtIndex:(NSInteger)index
{
    if([frameFlags[index] boolValue]){
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)isInEdit
{
    for(int i=0; i<frameFlags.count; i++){
        
        if([frameFlags[i] boolValue]){
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - -addNavi
- (void)addNavi
{
//    naviBarView = [[UIView alloc] init];
//    naviBarView.frame = CGRectMake(0, 0, kScreenWidth, kSmartHeight);
//    naviBarView.backgroundColor = [UIColor blackColor];
//    [baseview addSubview:naviBarView];
    
    CGFloat cellW = kNavigationBarHeight;
    CGFloat cellH = kNavigationBarHeight;
    
    CGFloat gap = kNavigationBarHeight/10;
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if(show_banner_ad_top) {
        backBtn.frame = CGRectMake(0, adheight, cellW, cellH);
    } else {
        backBtn.frame = CGRectMake(0, 0, cellW, cellH);
    }
    
    [backBtn setImage:[UIImage imageNamed:naviBarBack] forState:UIControlStateNormal];
    [backBtn setContentMode:UIViewContentModeCenter];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(gap, gap, gap, gap)];
    [backBtn addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
    
    swapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if(show_banner_ad_top) {
        swapBtn.frame = CGRectMake(kScreenWidth-cellW, adheight, cellW, cellH);
    } else {
        swapBtn.frame = CGRectMake(kScreenWidth-cellW, 0, cellW, cellH);
    }
    
    [swapBtn setImage:[UIImage imageNamed:@"camera_swap"] forState:UIControlStateNormal];
    [swapBtn setContentMode:UIViewContentModeCenter];
    [swapBtn setImageEdgeInsets:UIEdgeInsetsMake(gap, gap, gap, gap)];
    [swapBtn addTarget:self action:@selector(clickSwapBtn) forControlEvents:UIControlEventTouchUpInside];
    
    flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if(show_banner_ad_top) {
        flashBtn.frame = CGRectMake(kScreenWidth-cellW, adheight+kNavigationBarHeight, cellW, cellH);
    } else {
        flashBtn.frame = CGRectMake(kScreenWidth-cellW, kNavigationBarHeight, cellW, cellH);
    }
    [flashBtn setImage:[UIImage imageNamed:@"camera_flash"] forState:UIControlStateNormal];
    [flashBtn setContentMode:UIViewContentModeCenter];
    [flashBtn setImageEdgeInsets:UIEdgeInsetsMake(gap, gap, gap, gap)];
    [flashBtn addTarget:self action:@selector(clickFlashBtn) forControlEvents:UIControlEventTouchUpInside];
    
    if([_stillCamera cameraPosition] == AVCaptureDevicePositionBack){
        flashBtn.enabled = YES;
    }else{
        flashBtn.enabled = NO;
    }
    
    FlashStatus flashStatus = [_stillCamera flashStatus];
    if(flashStatus == ON){
        [flashBtn setImage:[UIImage imageNamed:@"camera_flash_hl"] forState:UIControlStateNormal];
    }else{
        [flashBtn setImage:[UIImage imageNamed:@"camera_flash"] forState:UIControlStateNormal];
    }
    
    [baseview addSubview:backBtn];
    [baseview addSubview:flashBtn];
    [baseview addSubview:swapBtn];
    
    if(![_stillCamera isBackFacingCameraPresent]){
        swapBtn.hidden = YES;
        flashBtn.hidden = YES;
    }
    
}

- (void)clickLeftBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickSwapBtn
{
    [_stillCamera rotateCamera];
    
    if([_stillCamera cameraPosition] == AVCaptureDevicePositionBack){
        flashBtn.enabled = YES;
    }else{
        flashBtn.enabled = NO;
    }
}

- (void)clickFlashBtn
{
    FlashStatus flashStatus = [_stillCamera changeFlash];
    
    if(flashStatus == ON){
        [flashBtn setImage:[UIImage imageNamed:@"camera_flash_hl"] forState:UIControlStateNormal];
    }else{
        [flashBtn setImage:[UIImage imageNamed:@"camera_flash"] forState:UIControlStateNormal];
    }
}

- (void)clickShareBtn
{
    [[AdmobViewController shareAdmobVC] recordValidUseCount];
    
    //Share
    //self.cameraRect = CGRectMake(0, 0, 720, 1280);
    UIImage *image = [MGImageUtil getImageFromView:presentView];
    [self shareImage:image];
}

#pragma mark - -addBottom
- (void)addBottom
{
    bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0, kScreenHeight-bottomH-safeAreaInsets.bottom, kScreenWidth, bottomH+safeAreaInsets.bottom);
    bottomView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView];
    
    CGFloat gap = bottomH/5;
    timerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    timerBtn.frame = CGRectMake(((kScreenWidth-bottomH)/2-bottomH)/2, 0, bottomH, bottomH);
    [timerBtn setImage:[UIImage imageNamed:@"camera_timer"] forState:UIControlStateNormal];
    [timerBtn setContentMode:UIViewContentModeCenter];
    [timerBtn setImageEdgeInsets:UIEdgeInsetsMake(gap, gap, gap, gap)];
    [timerBtn addTarget:self action:@selector(clickTimerBtn) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat labelW = 18;
    timerLabel = [[UILabel alloc] init];
    timerLabel.frame = CGRectMake(bottomH-labelW-gap, bottomH-labelW-gap, labelW, labelW);
    timerLabel.font = [UIFont systemFontOfSize:14];
    timerLabel.textColor = [UIColor whiteColor];
    timerLabel.text = @"";
    timerLabel.textAlignment = NSTextAlignmentCenter;
    
    takeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    takeBtn.frame = CGRectInset(CGRectMake((kScreenWidth-bottomH)/2, 0, bottomH, bottomH), 5, 5);
    [takeBtn setImage:[UIImage imageNamed:@"camera_take"] forState:UIControlStateNormal];
    [takeBtn addTarget:self action:@selector(clickTakeBtn) forControlEvents:UIControlEventTouchUpInside];
    
    photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    photoBtn.frame = CGRectMake((kScreenWidth+bottomH)/2+((kScreenWidth-bottomH)/2-bottomH)/2, 0, bottomH, bottomH);
    [photoBtn setImage:[UIImage imageNamed:@"camera_photo"] forState:UIControlStateNormal];
    [photoBtn setContentMode:UIViewContentModeCenter];
    [photoBtn setImageEdgeInsets:UIEdgeInsetsMake(gap, gap, gap, gap)];
    [photoBtn addTarget:self action:@selector(clickPhotoBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:takeBtn];
    [bottomView addSubview:timerBtn];
    [timerBtn addSubview:timerLabel];
    [bottomView addSubview:photoBtn];
}


- (void)clickTimerBtn
{
    if(timerStatus == 0){
        timerStatus = 1;
    }else if(timerStatus == 1){
        timerStatus = 2;
    }else if(timerStatus == 2){
        timerStatus = 3;
    }else{
        timerStatus = 0;
    }
    
    if(timerStatus == 0){
        [timerBtn setImage:[UIImage imageNamed:@"camera_timer"] forState:UIControlStateNormal];
        timerLabel.text = @"";
    }else{
        [timerBtn setImage:[UIImage imageNamed:@"camera_timer_hl"] forState:UIControlStateNormal];
        timerLabel.text = [NSString stringWithFormat:@"%ld", (long)timerStatus*5];
    }
}

- (void)addBottom2
{
    bottomView2 = [[UIView alloc] init];
    bottomView2.frame = CGRectMake(0, kScreenHeight-bottomH-safeAreaInsets.bottom, kScreenWidth, bottomH+safeAreaInsets.bottom);
    bottomView2.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomView2];
    bottomView2.hidden = YES;
    
    NSArray *toolBarItemArray = @[@"btn_back",@"btn_effect",@"btn_aspect",@"btn_filters",@"btn_adjust",@"navi_share"];
    
    CGFloat btnW = kScreenWidth/toolBarItemArray.count;
    CGFloat btnH = bottomH-30;
    CGFloat imgH = (btnW <btnH) ? btnW : btnH;
    imgH = imgH*0.8;
    
    CGFloat gapX = (btnW-imgH)/2;
    CGFloat gapY = (btnH-imgH)/2;
    
    for(int i=0; i<toolBarItemArray.count; i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnW*i, bottomH-btnH, btnW, btnH);
        [btn setImage:[UIImage imageNamed:toolBarItemArray[i]] forState:UIControlStateNormal];
        [btn setContentMode:UIViewContentModeCenter];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(gapY, gapX, gapY, gapX)];
        [btn addTarget:self action:@selector(clickToolBarBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [bottomView2 addSubview:btn];
        
        if(i == toolBarItemArray.count-1){
            shareBtn = btn;
        }
    }
    
    CGFloat sliderW = kDevice2(280, 640);
    blurSlider = [[MGSlider alloc] init];
    blurSlider.frame = CGRectMake((kScreenWidth-sliderW)/2, 5, sliderW, bottomH-btnH);
    blurSlider.maximumValue = (IS_IPAD?50.0:30.0);
    blurSlider.minimumValue = 0.0;
    blurSlider.value = 0.0;
    
    if(IS_IPAD){
        [blurSlider addTarget:self action:@selector(changeBlurEnd:) forControlEvents:UIControlEventTouchUpInside];
        [blurSlider addTarget:self action:@selector(changeBlurEnd:) forControlEvents:UIControlEventTouchUpOutside];
    }else{
        [blurSlider addTarget:self action:@selector(changeBlurValue:) forControlEvents:UIControlEventValueChanged];
    }
    [blurSlider setMinimumTrackTintColor:HEXCOLOR(0xd8d8d8ff)];
    [blurSlider setMaximumTrackTintColor:HEXCOLOR(0x4f4f4fff)];
    [bottomView2 addSubview:blurSlider];
    lastBlurValue = 0.0;
    
    [self mgCVInit];
    [self mgTBArrowViewInit];
    [self mgTBArrowActViewInit];
    [self mgTBArrowAspectViewInit];
}

- (void)blurSliderInit
{
    blurSlider.value = 0.0;
}

- (void)changeBlurValue:(MGSlider*)slider
{
    if(sliderCount % 2 == 0){
        self.edgeBlurValue = slider.value;
        
        for(int i=0; i<sublayoutEndpoints.count; i++){
            MGIrregularView *irregularView = [irregularViews objectAtIndex:i];
            irregularView.blurWidth = edgeBlurValue;
        }
        
        [self hideBorder];
    }
    
    sliderCount++;
}

- (void)changeBlurEnd:(MGSlider*)slider
{
    self.edgeBlurValue = slider.value;
    
    for(int i=0; i<sublayoutEndpoints.count; i++){
        MGIrregularView *irregularView = [irregularViews objectAtIndex:i];
        irregularView.blurWidth = edgeBlurValue;
    }
    
    [self hideBorder];
}

- (void)hideBorder
{
    for(UIImageView *iv in borders){
        iv.hidden = YES;
    }
}

- (void)clickToolBarBtn:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    NSInteger barButtonIndex = btn.tag;
    
    switch(barButtonIndex){
        case 0:{
            [self clickLeftBtn];
            break;
        }
        case 1:{
            for(int i=0; i<borders.count; i++){
                UIImageView *iv = borders[i];
                if(self.selectedIdx == i){
                    iv.hidden = NO;
                }else{
                    iv.hidden = YES;
                }
            }
            [mgTBActView showSelf];
            break;
        }
        case 2:{
            [self hideBorder];
            [mgTBAspectView showSelf];
            break;
        }
        case 3:{
            
            for(int i=0; i<borders.count; i++){
                UIImageView *iv = borders[i];
                if(self.selectedIdx == i){
                    iv.hidden = NO;
                }else{
                    iv.hidden = YES;
                }
            }
            [mgCV showSelf];
            break;
        }
        case 4:{
            for(int i=0; i<borders.count; i++){
                UIImageView *iv = borders[i];
                if(self.selectedIdx == i){
                    iv.hidden = NO;
                }else{
                    iv.hidden = YES;
                }
            }
            [mgTBAV showSelf];
            break;
        }
        case 5:{
            long vu = [[AdmobViewController shareAdmobVC] getValidUseCount];
            if([EditorUtility showEditor:self count:vu]) {
                break;
            }
            //share
            [self hideBorder];
            [self showTipStatus];
            [self performSelector:@selector(clickShareBtn) withObject:nil afterDelay:0.05];
            break;
        }
        default:{
            break;
        }
    }
    if(barButtonIndex!=0 && barButtonIndex!=5) {
#ifdef ENABLE_AD
        [AdUtility tryShowInterstitialInVC:self.navigationController];
#endif
    }
}

#pragma mark - Take
- (void)clickTakeBtn
{
    if(timerStatus != 0){
        if(mbHud != nil){
            [mbHud removeFromSuperview];
            mbHud = nil;
        }
        
        mbHud = [[MBProgressHUD alloc] initWithView:baseview];
        [baseview addSubview:mbHud];
        
        mbHud.mode = MBProgressHUDModeText;
        mbHud.label.text = [NSString stringWithFormat:@"%ld", (long)timerStatus*5];
        mbHud.label.font = [UIFont systemFontOfSize:60];
        mbHud.minSize = CGSizeMake(100, 100);
        mbHud.removeFromSuperViewOnHide = YES;
        mbHud.delegate = self;
        
        //        [mbHud showWhileExecuting:@selector(hudTask) onTarget:self withObject:nil animated:YES];
        
        
        dispatch_async_on_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, ^{
            [self hudTask];
        });
        
    }else{
        [self takeImage];
    }
}

- (void)takeImage
{
    
#if TARGET_OS_SIMULATOR
    
    
    PHFetchResult * result = [PHAsset fetchAssetsWithOptions:nil];
    NSInteger i = 0;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-variable"
    for (id obj in sublayoutEndpoints) {
#pragma clang diagnostic pop
        PHAsset * asset = [result objectAtIndex:(i%result.count)];
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:(PHImageContentModeDefault) options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [self takeOver:result];
        }];
        i++;
    }
    
    return;
    
#else
    
    
    [self showTipStatus];
    
    __weak CameraViewController *weakSelf = self;
    
    //    [_stillCamera capturePhotoAsJPEGProcessedUpToFilter:_basicFilter withCompletionHandler:^(NSData *processedJPEG, NSError *error) {
    //
    //        [weakSelf takeOver:[UIImage imageWithData:processedJPEG]];
    //    }];
    
    [_stillCamera capturePhotoAsImageProcessedUpToFilter:_basicFilter withOrientation:UIImageOrientationUp withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        [weakSelf takeOver:processedImage];
    }];
    
    //    __weak CameraViewController *weakSelf = self;
    //    [_stillCamera capturePhotoAsImageProcessedUpToFilter:_basicFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
    //        [weakSelf takeOver:processedImage];
    //    }];
    
    //    UIImage *image = [_basicFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp];
    //    [self takeOver:image];
    
    //    [_basicFilter useNextFrameForImageCapture];
    //    UIImage *capturedImage = [_basicFilter imageFromCurrentFramebuffer];
    //    [self takeOver:capturedImage];
#endif
    
}

void dispatch_async_on_main_queue(dispatch_block_t block) {
    dispatch_async(dispatch_get_main_queue(), block);
}

void dispatch_async_on_global_queue(long identifier, dispatch_block_t block) {
    dispatch_async(dispatch_get_global_queue(identifier, 0), block);
}

- (void)hudTask
{
    secs = 0;
    while(secs < (timerStatus*5)*10+5){
        usleep(10000);
        
        dispatch_async_on_main_queue(^{
            mbHud.label.text = [NSString stringWithFormat:@"%ld", (long)((timerStatus*5)*10+2-secs)/10];
            [mbHud showAnimated:YES];
        });
        if(secs >= (timerStatus*5)*10){
            dispatch_async_on_main_queue(^{
                [mbHud hideAnimated:YES];
                [self takeImage];
            });
            break;
        }
    }
}

- (void)timerTask
{
    secs++;
    
    if(secs > 1000000){
        secs /= 100;
    }
}

- (void)clickPhotoBtn
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        pickerController.allowsEditing = NO;
        [pickerController setSourceType:sourceType];
        pickerController.delegate = self;
        
        [self presentViewController:pickerController animated:YES completion:nil];
    }
}

- (void)takeOver:(UIImage*)processedImage
{
    CGFloat scaleX = processedImage.size.width/self.gpuIV.bounds.size.width;
    CGFloat scaleY = processedImage.size.height/self.gpuIV.bounds.size.height;
    
    CGRect cutRect = CGRectMake(self.cameraRect.origin.x*scaleX, self.cameraRect.origin.y*scaleY,
                                self.cameraRect.size.width*scaleX, self.cameraRect.size.height*scaleY);
    
    UIImage *output = [MGImageUtil cutImage:processedImage WithRect:cutRect];
    
    output = [output rotateAndScaleWithMaxPixels:kAllowImageMaxSize WithMinPixels:kAllowImageMaxSize/10];
    
    [self.outputImages setObject:output forKey:MGStr(selectedIdx)];
    
    MGIrregularView *irregularView = [irregularViews objectAtIndex:selectedIdx];
    irregularView.borderColor = [UIColor whiteColor];
    irregularView.borderWidth = 2.0;
    [irregularView setMaskLayer];
    [self borderWithIndex:selectedIdx WithAutoHide:YES];
    [irregularView setImageViewData:output];
    
    [irregularView changeEdgeBlurWidth:blurSlider.value];
    
    frameFlags[selectedIdx] = [NSNumber numberWithBool:NO];
    
    [self filterInitAtIndex:selectedIdx];
    
    [self cameraCurrentStatus:true];
    
    [self performSelector:@selector(hideTipStatus) withObject:nil afterDelay:0.2];
}

- (void)cameraCurrentStatus:(BOOL) showad
{
    if([self getAndSetNextIdx] != 100){
        [self hideBlurAtIndex:selectedIdx];
        
        isTakeOVer = NO;
        
        if(timerStatus != 0){
            [self clickTakeBtn];
        }
    } else {
        if(finishedShow == ShowNotEver) {
            if(showad) {
#ifdef ENABLE_AD
                [AdUtility tryShowInterstitialInVC:self.navigationController];
#endif
                finishedShow = ShowNever;
            } else {
                finishedShow = ShowOnce;
            }
        }
        
        [self cameraFinished];
    }
}

- (void)cameraFinished
{
    [[AdmobViewController shareAdmobVC] checkConfigUD];
    
    //拍完做的事情
    //naviBarView2.hidden = NO;
    bottomView2.hidden = NO;
    backBtn.hidden = YES;
    swapBtn.hidden = YES;
    flashBtn.hidden = YES;
    
    isTakeOVer = YES;
    [self setBgIVRect:CGRectMake(0, 0, 0, 0)];
    
    //    [self.stillCamera stopCameraCapture];
    
    if(self.currentLayoutIndex < LayoutPatternDiagonal){
        for(int i=0; i<irregularViews.count; i++){
            MGIrregularView *irregularView = [irregularViews objectAtIndex:i];
            irregularView.backgroundColor = [UIColor grayColor];
        }
    }else{
        for(int i=0; i<irregularViews.count; i++){
            MGIrregularView *irregularView = [irregularViews objectAtIndex:i];
            [irregularView setIrregularTypeLayer];
            irregularView.backgroundColor = [UIColor grayColor];
        }
    }
    
    for(int i=0; i<lineViews.count; i++){
        MGLineView *lineView = [lineViews objectAtIndex:i];
        [lineView hideLine];
    }
    
    self.edgeBlurValue = blurSlider.value;
    
}

- (void)adMobVCWillCloseInterstitialAd:(AdmobViewController *)adMobVC
{
}

- (NSInteger)getAndSetNextIdx
{
    for(int i=1; i<frameFlags.count; i++){
        NSInteger next = (selectedIdx+i)%frameFlags.count;
        
        if([frameFlags[next] boolValue]){
            self.selectedIdx = next;
            return next;
        }
    }
    
    return 100;
}

- (void)setSelectedIdx:(NSInteger)newValue
{
    selectedIdx = newValue;
    mgTBAV.selectedPictureIdx = selectedIdx;
    mgCV.selectedPictureIdx = selectedIdx;
}

- (void)clickChangeBtn
{
    
}

#pragma mark - -MGHorCView DataSource&Delegate
- (void)mgCVInit
{
    if(mgCV != nil){
        [mgCV removeFromSuperview];
        mgCV = nil;
    }
    mgCV = [[MGHorCView alloc] initWithFrame:CGRectMake(0, kScreenHeight-toolBarH-safeAreaInsets.bottom, kScreenWidth, toolBarH)];
    mgCV.delegate = self;
    mgCV.dataSource = self;
    [self.view addSubview:mgCV];
    
    [mgCV setDefaultDataWith:sublayoutEndpoints.count];
}

- (NSInteger)numberOfItemsInMGHorCVIew:(MGHorCView *)view
{
    return 23+self.allfilterArray.count;
}

- (UIImage*)imageInMGHorCView:(MGHorCView *)view AtIndex:(NSInteger)index
{
    if (index > 22) {
        return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"filterNew%li",(long)index-23] ofType:@"jpg"]];
    }
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"filter%li",(long)index] ofType:@"jpg"]];
}

- (void)mgHorCViewdidSelectItemAtIndex:(NSInteger)index
{
    [self showTipStatus];
    
    [self performSelector:@selector(effectInImage:) withObject:[NSNumber numberWithInteger:index] afterDelay:0.1];
}

- (void)effectInImage:(id)obj {
    UIImage *image;
    NSNumber *num = (NSNumber*)obj;
    NSInteger index = [num integerValue];
    
    if(index == 0){
        image = [_outputImages objectForKey:MGStr(selectedIdx)];
    }else{
        if (index > 22) {
            NSString * name = self.allfilterArray[index-23];
            image = [LemonUtil lemonFilter:[_outputImages objectForKey:MGStr(selectedIdx)] Withname:name];
        } else {
            image = [LemonUtil lemonFilter:[_outputImages objectForKey:MGStr(selectedIdx)] WithIndex:index];
        }
    }
    [self setFiltersPictureAtIndex:selectedIdx WithImage:image WithType:0];
    
    usleep(100000);
    
    [self hideTipStatus];
}

- (BOOL)selectUpgrade:(NSInteger)type
{
    if(type == 0){
        [_adViewController doUpgradeInApp:self product:kRemoveAd];
    }else{
        return NO;
    }
    
    return YES;
}

- (void)mghorCViewHide
{
    for(UIImageView *iv in borders){
        iv.hidden = YES;
    }
}

#pragma mark - -MGTBArrowView
- (void)mgTBArrowViewInit
{
    if(mgTBAV != nil){
        [mgTBAV removeFromSuperview];
        mgTBAV = nil;
    }
    mgTBAV = [[MGTBArrowView alloc] initWithFrame:CGRectMake(0, kScreenHeight-toolBarH-safeAreaInsets.bottom, kScreenWidth, toolBarH)];
    mgTBAV.delegate = self;
    [self.view addSubview:mgTBAV];
    
    [mgTBAV setDefaultDataWith:sublayoutEndpoints.count];
}

- (void)mgTBAVHide
{
    for(UIImageView *iv in borders){
        iv.hidden = YES;
    }
}

- (void)mgTBAVAdjustAtIndex:(NSInteger)index WithValue:(float)value
{
    MGGPUAdjustFilter *mgAdjustFilter = [filtersArray objectForKey:MGStr(selectedIdx)];
    //GPUImagePicture *pic = [gpuImageArray objectForKey:MGStr(selectedIdx)];
    UIImage *image = [_outputImages objectForKey:MGStr(selectedIdx)];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    [pic addTarget:mgAdjustFilter];
    
    switch (index) {
        case 0:
        {
            mgAdjustFilter.brightness = value;
            break;
        }
        case 1:
        {
            mgAdjustFilter.contrast = value;
            break;
        }
        case 2:
        {
            mgAdjustFilter.saturation = value;
            break;
        }
        case 3:
        {
            mgAdjustFilter.exposure = value;
            break;
        }
        case 4:
        {
            mgAdjustFilter.blurRadiusInPixels = value;
            break;
        }
        default:
            break;
    }
    
    [mgAdjustFilter useNextFrameForImageCapture];
    [pic processImage];
    MGIrregularView *irregularView = [irregularViews objectAtIndex:selectedIdx];
    [irregularView.imageView setImage:[mgAdjustFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp]];
}

#pragma mark - Filtes Setting
- (void)filterInitAtIndex:(NSInteger)index
{
    UIImage *input = [_outputImages objectForKey:MGStr(index)];
    if(input == nil)
        return;
    
    MGGPUAdjustFilter *mgAdjustFilterLast = [filtersArray objectForKey:MGStr(index)];
    if(mgAdjustFilterLast != nil){
        [mgAdjustFilterLast removeAllTargets];
        mgAdjustFilterLast = nil;
    }
    MGGPUAdjustFilter *mgAdjustFilter = [[MGGPUAdjustFilter alloc] init];
    [filtersArray setObject:mgAdjustFilter forKey:MGStr(index)];
    
    //    GPUImagePicture *pic = [gpuImageArray objectForKey:MGStr(index)];
    //    if(pic != nil){
    //        [pic removeAllTargets];
    //        pic = nil;
    //    }
    //    GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:input];
    //    [gpuImageArray setObject:gpuImage forKey:MGStr(index)];
    //
    //    [gpuImage addTarget:mgAdjustFilter];
}

- (void)setFiltersPictureAtIndex:(NSInteger)index WithImage:(UIImage*)image WithType:(NSInteger)type
{
    if(image == nil)
        return;
    
    MGGPUAdjustFilter *mgAdjustFilter = [filtersArray objectForKey:MGStr(index)];
    if(mgAdjustFilter == nil){
        return;
    }
    
    //    GPUImagePicture *pic = [gpuImageArray objectForKey:MGStr(index)];
    //    if(pic != nil){
    //        [pic removeAllTargets];
    //        pic = nil;
    //    }
    //    GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:image];
    //    [gpuImageArray setObject:gpuImage forKey:MGStr(index)];
    
    GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:image];
    [gpuImage addTarget:mgAdjustFilter];
    
    [mgAdjustFilter useNextFrameForImageCapture];
    [gpuImage processImage];
    MGIrregularView *irregularView = [irregularViews objectAtIndex:index];
    
    if(type == 0){
        [irregularView.imageView setImage:[mgAdjustFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp]];
    }else if(type == 1){
        [irregularView setImageViewData:[mgAdjustFilter imageFromCurrentFramebufferWithOrientation:UIImageOrientationUp]];
    }
    
    [gpuImage removeAllTargets];
    gpuImage = nil;
}

#pragma mark - -MGTBArrowActView
- (void)mgTBArrowActViewInit
{
    if(mgTBActView != nil){
        [mgTBActView removeFromSuperview];
        mgTBActView = nil;
    }
    mgTBActView = [[MGTBArrowActView alloc] initWithFrame:CGRectMake(0, kScreenHeight-toolBarH-safeAreaInsets.bottom, kScreenWidth, toolBarH)];
    mgTBActView.delegate = self;
    [self.view addSubview:mgTBActView];
}

- (void)mgTBArrowActViewHide
{
    for(UIImageView *iv in borders){
        iv.hidden = YES;
    }
}

- (void)mgTBArrowActViewSelectItemAt:(NSInteger)index
{
    switch (index) {
        case 0:{
            
            //naviBarView2.hidden = YES;
            bottomView2.hidden = YES;
            
            backBtn.hidden = NO;
            swapBtn.hidden = NO;
            flashBtn.hidden = NO;
            
            isTakeOVer = NO;
            
            for(MGLineView *line in lineViews){
                [line showLine];
            }
            [self hideBorder];
            
            
            [self set0EdgeBlurValue];
            MGIrregularView *irregularView = [irregularViews objectAtIndex:self.selectedIdx];
            
            if(self.currentLayoutIndex < LayoutPatternDiagonal){
                [irregularView setMaskLayer0];
            }else{
                if(selectedIdx == 0){
                    [irregularView setMaskLayer0];
                }else{
                    MGIrregularView *irView = [irregularViews objectAtIndex:0];
                    [irView setMaskLayer];
                    [irregularView setMaskLayer0];
                }
            }
            
            [_stillCamera startCameraCapture];
            [self setBgIVRect:cameraRect];
            
            
            [mgTBActView hideSelf];
            
            frameFlags[selectedIdx] = [NSNumber numberWithBool:YES];
            break;
        }
        case 1:{
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if([UIImagePickerController isSourceTypeAvailable:sourceType])
            {
                pickerController.allowsEditing = NO;
                [pickerController setSourceType:sourceType];
                pickerController.delegate = self;
                
                [self presentViewController:pickerController animated:YES completion:nil];
            }
            break;
        }
        case 2:{
            UIImage *image = [_outputImages objectForKey:MGStr(selectedIdx)];
            image = [image rotateInDegrees:90.0f];
            [_outputImages setObject:image forKey:MGStr(selectedIdx)];
            [self setFiltersPictureAtIndex:selectedIdx WithImage:image WithType:1];
            
            MGIrregularView *irView = irregularViews[selectedIdx];
            [irView setResfresh];
            [irView setResfreshWithBlur:blurSlider.value];
            break;
        }
        case 3:{
            UIImage *image = [_outputImages objectForKey:MGStr(selectedIdx)];
            //            image = [image horizontalFlip];
            image = [image FlippedImageRedrawNewHorizontal:YES vertical:NO];
            [_outputImages setObject:image forKey:MGStr(selectedIdx)];
            [self setFiltersPictureAtIndex:selectedIdx WithImage:image WithType:0];
            break;
        }
        case 4:{
            UIImage *image = [_outputImages objectForKey:MGStr(selectedIdx)];
            //            image = [image verticalFlip];
            image = [image FlippedImageRedrawNewHorizontal:NO vertical:YES];
            
            [_outputImages setObject:image forKey:MGStr(selectedIdx)];
            [self setFiltersPictureAtIndex:selectedIdx WithImage:image WithType:0];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - MGTBArrowAspectView
- (void)mgTBArrowAspectViewInit
{
    if(mgTBAspectView != nil){
        [mgTBAspectView removeFromSuperview];
        mgTBAspectView = nil;
    }
    mgTBAspectView = [[MGTBArrowAspectView alloc] initWithFrame:CGRectMake(0, kScreenHeight-toolBarH-safeAreaInsets.bottom, kScreenWidth, toolBarH)];
    mgTBAspectView.delegate = self;
    [self.view addSubview:mgTBAspectView];
}

- (void)mgTBArrowAspectViewSelectItemAt:(NSInteger)index
{
    switch (index) {
        case 0:{
            //      self.cameraRect = originRect;
            [self isChangeCameraRect:originRect previous:cameraRect];
            break;
        }
        case 1:{
            //1x1
            CGFloat width = (originRect.size.width < originRect.size.height) ? originRect.size.width : originRect.size.height;
            CGFloat height = width;
            if(height > originRect.size.height){
                height = originRect.size.height;
                width = originRect.size.height/height*originRect.size.width;
            }
            
            CGRect rect = CGRectInset(originRect, (originRect.size.width-width)/2, (originRect.size.height-width)/2);
            [self isChangeCameraRect:rect previous:cameraRect];
            break;
        }
        case 2:{
            //3x2
            CGFloat width = (originRect.size.width < originRect.size.height) ? originRect.size.width : originRect.size.height;
            CGFloat height = (int)(width*2/3);
            if(height > originRect.size.height){
                height = originRect.size.height;
                width = originRect.size.height/height*originRect.size.width;
            }
            
            CGRect rect = CGRectInset(originRect, (originRect.size.width-width)/2, (originRect.size.height-height)/2);
            [self isChangeCameraRect:rect previous:cameraRect];
            break;
        }
        case 3:{
            //3x4
            CGFloat width = (originRect.size.width < originRect.size.height) ? originRect.size.width : originRect.size.height;
            CGFloat height = (int)(width*4/3);
            
            if(height > originRect.size.height){
                height = (int)(originRect.size.height);
                //                width = (int)(originRect.size.height/height*originRect.size.width);
                width = (int)(height*3/4);
            }
            
            CGRect rect = CGRectInset(originRect, (originRect.size.width-width)/2, (originRect.size.height-height)/2);
            [self isChangeCameraRect:rect previous:cameraRect];
            break;
        }
        default:
            break;
    }
}



- (void)isChangeCameraRect:(CGRect)rect previous:(CGRect)previousRect {
    switch (self.currentLayoutIndex) {
            
            
            
        case G2x1:
        case G3x1:
        case G4x1:
        case G5x1:
        case G6x1:{
            self.cameraRect = rect;
            break;
        }
            
            
        case G1x2:
        case G1x3:
        case G1x4:
        case G1x5:
        case G1x6:
        case H2_2x1_1x1:
        case H2_3x1_1x1:
        case H2_3x1_2x1:
        case H3_2x1_1x1_1x1:
        case V2_1x1_1x2:
        case V2_1x1_1x3:
        case V2_1x2_1x3:
        case V3_1x2_1x1_1x1:{
            cameraRect = rect;
            [self isChangeCameraRectCropMode:rect previous:previousRect];
            break;
        }
            
        default: {
            self.cameraRect = rect;
            break;
        }
    }
    cameraRect = rect;
}


- (void)isChangeCameraRectCropMode:(CGRect)rect previous:(CGRect)previousRect{
    CGFloat insetX = (CGRectGetWidth(previousRect) - CGRectGetWidth(rect))/2;
    CGFloat insetY = (CGRectGetHeight(previousRect) - CGRectGetHeight(rect))/2;
    if (insetX == 0 && insetY == 0) {
        NSLog(@"same rect");
        return;
    }
    
    CGPoint insetPoint = CGPointMake(insetX, insetY);
    if (insetX == 0) {
        [self refreshDataSource:rect previous:previousRect insetAxis:1 insetPoint:insetPoint];
    } else if (insetY == 0) {
        [self refreshDataSource:rect previous:previousRect insetAxis:0 insetPoint:insetPoint];
    }
}

- (void)refreshDataSource:(CGRect)rect previous:(CGRect)previousRect insetAxis:(NSInteger)axis insetPoint:(CGPoint)insetPoint {
    CGFloat inset = 0;
    presentView.frame = rect;
    bordersView.frame = rect;
    if (axis == 0) {
        inset = insetPoint.x;
    } else if (axis == 1) {
        inset = insetPoint.y;
    }
    BOOL shouldReset = NO;
    CGFloat previousHeight = CGRectGetHeight(previousRect);
    CGFloat previousWidth = CGRectGetWidth(previousRect);
    for (int i = 0;i<lines.count;i++) {
        if (shouldReset) {
            break;
        }
        NSMutableArray * pointsOfLine = [lines[i] mutableCopy];
        NSString * firstPointStr = [pointsOfLine firstObject];
        NSString * lastPointStr = [pointsOfLine lastObject];
        CGPoint firstPoint = CGPointFromString(firstPointStr);
        CGPoint lastPoint = CGPointFromString(lastPointStr);
        
        
        
        
        for (int j = 0; j < pointsOfLine.count; j++) {
            
            NSString * string = pointsOfLine[j];
            CGPoint point = CGPointFromString(string);
            if (axis == 0) {
                CGFloat relativeInsetX = inset/previousWidth;
                
                if (fabs(firstPoint.x - lastPoint.x) < 0.0001) {
                    firstPoint.x = (firstPoint.x-relativeInsetX)/(1-2*relativeInsetX);
                    if (firstPoint.x < 0 || firstPoint.x > 1) {
                        shouldReset = YES;
                        break;
                    }
                }
                if (point.x != 0 && point.x != 1) {
                    point.x = (point.x-relativeInsetX)/(1-2*relativeInsetX);
                    point.x = MIN(1, point.x);
                    point.x = MAX(0, point.x);
                }
                
            } else if (axis == 1) {
                CGFloat relativeInsetY = inset/previousHeight;
                
                if (fabs(firstPoint.y - lastPoint.y) < 0.0001) {
                    firstPoint.y = (firstPoint.y-relativeInsetY)/(1-2*relativeInsetY);
                    
                    if (firstPoint.y < 0 || firstPoint.y > 1) {
                        shouldReset = YES;
                        break;
                    }
                }
                if (point.y != 0 && point.y != 1) {
                    point.y = (point.y-relativeInsetY)/(1-2*relativeInsetY);
                    point.y = MIN(1, point.y);
                    point.y = MAX(0, point.y);
                }
            }
            NSString * newString = NSStringFromCGPoint(point);
            [pointsOfLine replaceObjectAtIndex:j withObject:newString];
        }
        
        [lines replaceObjectAtIndex:i withObject:pointsOfLine];
    }
    for (int j = 0; j < sublayoutEndpoints.count; j++) {
        NSMutableArray * pointsOfShape = [sublayoutEndpoints[j] mutableCopy];
        NSMutableArray * pointsOfShapeBackup = [sublayoutEndpointsBackup[j] mutableCopy];
        if (shouldReset) {
            break;
        }
        for (int k = 0; k < pointsOfShape.count;k++) {
            NSString * string = pointsOfShape[k];
            NSString * stringBackup = pointsOfShapeBackup[k];
            CGPoint point = CGPointFromString(string);
            CGPoint pointBackup = CGPointFromString(stringBackup);
            if (axis == 0) {
                CGFloat relativeInsetX = inset/previousWidth;
                if (point.x != 0 && point.x != 1) {
                    point.x = (point.x-relativeInsetX)/(1-2*relativeInsetX);
                    point.x = MIN(1, point.x);
                    point.x = MAX(0, point.x);
                }
                if (pointBackup.x != 0 && pointBackup.x != 1) {
                    pointBackup.x = (pointBackup.x-relativeInsetX)/(1-2*relativeInsetX);
                    pointBackup.x = MIN(1, pointBackup.x);
                    pointBackup.x = MAX(0, pointBackup.x);
                }
                
            } else if (axis == 1) {
                CGFloat relativeInsetY = inset/previousHeight;
                if (point.y != 0 && point.y != 1) {
                    point.y = (point.y-relativeInsetY)/(1-2*relativeInsetY);
                    point.y = MIN(1, point.y);
                    point.y = MAX(0, point.y);
                }
                if (pointBackup.y != 0 && pointBackup.y != 1) {
                    pointBackup.y = (pointBackup.y-relativeInsetY)/(1-2*relativeInsetY);
                    pointBackup.y = MIN(1, pointBackup.y);
                    pointBackup.y = MAX(0, pointBackup.y);
                }
            }
            NSString * newString = NSStringFromCGPoint(point);
            NSString * newStringBackup = NSStringFromCGPoint(pointBackup);
            [pointsOfShape replaceObjectAtIndex:k withObject:newString];
            [pointsOfShapeBackup replaceObjectAtIndex:k withObject:newStringBackup];
            
        }
        [sublayoutEndpoints replaceObjectAtIndex:j withObject:pointsOfShape];
        [sublayoutEndpointsBackup replaceObjectAtIndex:j withObject:pointsOfShapeBackup];
    }
    
    if (shouldReset) {
        NSDictionary *dicts;
        if(self.currentLayoutIndex < self.frameInfoArray.count)
            dicts = self.frameInfoArray[self.currentLayoutIndex];
        sublayoutEndpoints = [[dicts objectForKey:@"sublayoutEndpoints"] mutableCopy];
        sublayoutEndpointsBackup = [[dicts objectForKey:@"sublayoutEndpoints"] mutableCopy];
        lines = [[dicts objectForKey:@"lines"] mutableCopy];
    }
    [self setBgIVRect:rect];
    
    [self PointsRefresh];
    [self refreshSimpleLineViewsAfterRefreshPoints:rect shouldChangeContentOffset:NO insetPoint:insetPoint];
    for(int ci=0; ci<lines.count; ci++)
        [self mgLineMovedWithViewIndex:ci];
}


- (void)refreshSimpleLineViewsAfterRefreshPoints:(CGRect)newRect shouldChangeContentOffset:(BOOL)shouldChangeContentOffset insetPoint:(CGPoint)insetPoint {
    for(int i=0; i<lineViews.count; i++){
        MGLineView *lineView = [lineViews objectAtIndex:i];
        lineView.points = lines[i];
        lineView.frame = newRect;
        lineView.bezierArea = pictureBezierPaths[i];
        [lineView createPath];
        //        [lineView setNeedsDisplay];
    }
    
    for(UIImageView *iv in borders){
        iv.frame = bordersView.bounds;
    }
    
    for(int i=0; i<sublayoutEndpoints.count; i++){
        MGIrregularView *irregularView = irregularViews[i];
        
        if(self.currentLayoutIndex < LayoutPatternDiagonal){
            CGRect oldFrame = irregularView.contentView.frame;
            irregularView.frame = presentView.bounds;
            irregularView.bezierArea = pictureBezierPaths[i];
            irregularView.viewRect = [self rectWithEndpoints:sublayoutEndpoints[i]];
            irregularView.blur0Rect = [self rectWithEndpoints:sublayoutEndpointsBackup[i]];
            [irregularView setMaskLayer];
            [self borderWithIndex:i WithAutoHide:NO];
            if (shouldChangeContentOffset) {
                [irregularView setResfresh];
            } else {
                CGPoint point = irregularView.contentView.contentOffset;
                CGFloat offsetX = oldFrame.origin.x - irregularView.viewRect.origin.x;
                CGFloat offsetY = oldFrame.origin.y - irregularView.viewRect.origin.y;
                irregularView.contentView.contentOffset = CGPointMake(point.x+insetPoint.x-offsetX, point.y+insetPoint.y-offsetY);
                irregularView.contentView.frame = irregularView.viewRect;
                
            }
            
        }
    }
}

- (void)refreshViewsAfterRefreshPoints:(CGRect)newRect shouldChangeContentOffset:(BOOL)shouldChangeContentOffset insetPoint:(CGPoint)insetPoint {
    for(int i=0; i<lineViews.count; i++){
        MGLineView *lineView = [lineViews objectAtIndex:i];
        lineView.frame = newRect;
        lineView.bezierArea = pictureBezierPaths[i];
        [lineView createPath];
        //        [lineView setNeedsDisplay];
    }
    
    for(UIImageView *iv in borders){
        iv.frame = bordersView.bounds;
    }
    
    for(int i=0; i<sublayoutEndpoints.count; i++){
        MGIrregularView *irregularView = irregularViews[i];
        
        if(self.currentLayoutIndex < LayoutPatternDiagonal){
            CGRect oldFrame = irregularView.contentView.frame;
            irregularView.frame = presentView.bounds;
            irregularView.bezierArea = pictureBezierPaths[i];
            irregularView.viewRect = [self rectWithEndpoints:sublayoutEndpoints[i]];
            irregularView.blur0Rect = [self rectWithEndpoints:sublayoutEndpointsBackup[i]];
            [irregularView setMaskLayer];
            [self borderWithIndex:i WithAutoHide:NO];
            if (shouldChangeContentOffset) {
                [irregularView setResfresh];
            } else {
                CGPoint point = irregularView.contentView.contentOffset;
                CGFloat offsetX = oldFrame.origin.x - irregularView.viewRect.origin.x;
                CGFloat offsetY = oldFrame.origin.y - irregularView.viewRect.origin.y;
                
                irregularView.contentView.contentOffset = CGPointMake(point.x+insetPoint.x+offsetX, point.y+insetPoint.y+offsetY);
                
                [irregularView setResfresh];
            }
            
            for(int ci=0; ci<lines.count; ci++) {
                [self mgLineMovedWithViewIndex:ci];
            }
        }else{
            irregularView.frame = presentView.bounds;
            if(i == 0) {
                irregularView.viewRect = presentView.bounds;
                irregularView.bezierArea = pictureBezierPaths[i];
                irregularView.shapeType = RectShaper;
            } else {
                irregularView.viewRect = ([self isKindOfAskewLine]) ? [self rectWithEndpoints:sublayoutEndpoints[i]] : irregularRect;
                irregularView.bezierArea = pictureBezierPaths[i];
                irregularView.shapeType = ImageShaper;
            }
            [irregularView setMaskLayer];
            [self borderWithIndex:i WithAutoHide:NO];
            
            [irregularView changeEdgeBlurWidth:blurSlider.value];
        }
    }
    
}


- (void)setCameraRect:(CGRect)newRect
{
    cameraRect = newRect;
    presentView.frame = newRect;
    bordersView.frame = newRect;
    
    [self setBgIVRect:newRect];
    
    [self PointsRefresh];
    [self refreshViewsAfterRefreshPoints:newRect shouldChangeContentOffset:YES insetPoint:CGPointZero];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        if(finishedShow == ShowOnce) {
#ifdef ENABLE_AD
            [AdUtility tryShowInterstitialInVC:self.navigationController];
#endif
            finishedShow = ShowNever;
        }
    }];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize rawSize;
    CGFloat scale = 1.0;
    while(image.size.width*image.size.height*scale*scale > kAllowImageMaxSize){
        scale -= 0.01;
    }
    rawSize = CGSizeMake(image.size.width*scale, image.size.height*scale);
    image = [MGImageUtil scaleImage:image toSize:rawSize];
    image = [image rotateImage];
    
    MGIrregularView *irregularView = [irregularViews objectAtIndex:self.selectedIdx];
    [irregularView setImageViewData:image];
    irregularView.borderColor = [UIColor whiteColor];
    irregularView.borderWidth = 2.0;
    //[irregularView setBorderWithAutoHide:YES];
    [irregularView setMaskLayer];
    [self borderWithIndex:self.selectedIdx WithAutoHide:YES];
    [irregularView changeEdgeBlurWidth:blurSlider.value];
    
    frameFlags[selectedIdx] = [NSNumber numberWithBool:NO];
    
    [_outputImages setObject:image forKey:MGStr(selectedIdx)];
    
    [self filterInitAtIndex:selectedIdx];
    
    [self cameraCurrentStatus:false];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)dataInit
{
    pictureBezierPaths = [[NSMutableArray alloc] init];
    lineBezierPaths = [[NSMutableArray alloc] init];
    
    [self PointsInit];
    
    _outputImages = [[NSMutableDictionary alloc] init];
    _showImages = [[NSMutableDictionary alloc] init];
    filtersArray = [[NSMutableDictionary alloc] init];
    gpuImageArray = [[NSMutableDictionary alloc] init];
    
    blurViews = [[NSMutableArray alloc] init];
    frameFlags = [[NSMutableArray alloc] init];
    
    lineViews = [[NSMutableArray alloc] init];
    borders = [[NSMutableArray alloc] init];
    irregularViews = [[NSMutableArray alloc] init];
    
    lastIdx = 99;
    
}

- (void)PointsInit
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"frames" ofType:@"plist"];
    self.frameInfoArray = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    NSDictionary *dicts;
    if(self.currentLayoutIndex < self.frameInfoArray.count)
        dicts = self.frameInfoArray[self.currentLayoutIndex];
    sublayoutEndpoints = [[dicts objectForKey:@"sublayoutEndpoints"] mutableCopy];
    sublayoutEndpointsBackup = [[dicts objectForKey:@"sublayoutEndpoints"] mutableCopy];
    lines = [[dicts objectForKey:@"lines"] mutableCopy];
    blurDirections = [[dicts objectForKey:@"blurDirection"] mutableCopy];
    
    
    [pictureBezierPaths removeAllObjects];
    [lineBezierPaths removeAllObjects];
    
    if(self.currentLayoutIndex >= LastSimpleLineLayoutPattern+1)
        shapes = [[dicts objectForKey:@"shape"] mutableCopy];
    
    if(self.currentLayoutIndex < LastSimpleLineLayoutPattern+1){
        for(int i=0; i<sublayoutEndpoints.count; i++){
            UIBezierPath *path1 = [UIBezierPath bezierPath];
            NSArray *subPoints = [sublayoutEndpoints objectAtIndex:i];
            [self drawPath:path1 subPoints:subPoints sublayoutIndex:i];
            [pictureBezierPaths addObject:path1];
        }
    }else{
        CGFloat view_w = cameraRect.size.width < cameraRect.size.height ? cameraRect.size.width : cameraRect.size.height;
        CGFloat view_gapX = (cameraRect.size.width-view_w)/2;
        CGFloat view_gapY = (cameraRect.size.height-view_w)/2;
        CGRect rect = CGRectFromString(shapes[0]);
        
        if(!IS_IPAD){
            rect = CGRectMake(kRX(rect)*view_w+view_gapX, kRY(rect)*view_w+view_gapY, kRW(rect)*view_w, kRH(rect)*view_w);
        }else{
            CGFloat reduce = 0.1;
            rect = CGRectInset(rect, kRW(rect)*reduce, kRH(rect)*reduce);
            rect = CGRectMake(kRX(rect)*view_w+view_gapX, kRY(rect)*view_w+view_gapY, kRW(rect)*view_w, kRH(rect)*view_w);
        }
        
        if(self.currentLayoutIndex == LayoutPatternCircle){
            
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
            [pictureBezierPaths addObject:path];
            [pictureBezierPaths addObject:path];
            
            [lineBezierPaths addObject:path];
            
            irregularRect = rect;
        }else if(self.currentLayoutIndex == LayoutPatternSquare){
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
            [pictureBezierPaths addObject:path];
            [pictureBezierPaths addObject:path];
            
            [lineBezierPaths addObject:path];
            
            irregularRect = rect;
        }else if(self.currentLayoutIndex == LayoutPatternTriangle){
            
            NSMutableArray *bezierPoints = [[NSMutableArray alloc] init];
            NSMutableArray *pointsArr = [shapes[1] mutableCopy];
            for(int i=0; i<pointsArr.count; i++){
                CGPoint p = CGPointFromString(pointsArr[i]);
                p.x *= kRW(rect);
                p.y *= kRH(rect);
                p.x += kRX(rect);
                p.y += kRY(rect);
                
                [bezierPoints addObject:[NSValue valueWithCGPoint:p]];
            }
            UIBezierPath *path = [self createBezierPath:bezierPoints];
            [pictureBezierPaths addObject:path];
            [pictureBezierPaths addObject:path];
            [lineBezierPaths addObject:path];
            
            irregularRect = rect;
        }else if(self.currentLayoutIndex == LayoutPatternHeart){
            CGPathRef myPath = [PocketSVG pathFromSVGFileNamed:@"model0"];
            myPath = createPathRotatedAroundBoundingBoxCenter(myPath, kRW(rect)/500.0, kRX(rect), kRY(rect));
            UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:myPath];
            
            CGPathRelease(myPath);
            
            [pictureBezierPaths addObject:path];
            [pictureBezierPaths addObject:path];
            [lineBezierPaths addObject:path];
            
            irregularRect = rect;
        }
    }
    
    if(self.currentLayoutIndex < LastSimpleLineLayoutPattern+1){
        for(int i=0; i<lines.count; i++){
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            NSArray *subLines = [lines objectAtIndex:i];
            for(int j=0; j<subLines.count; j++){
                CGPoint point = CGPointFromString(subLines[j]);
                
                if(j == 0){
                    [path moveToPoint:CGPointMake(point.x*cameraRect.size.width, point.y*cameraRect.size.height)];
                }else{
                    [path addLineToPoint:CGPointMake(point.x*cameraRect.size.width, point.y*cameraRect.size.height)];
                }
            }
            [path closePath];
            
            [lineBezierPaths addObject:path];
        }
    }
}

#pragma mark - edgeBlurWidth Changed
- (void)setEdgeBlurValue:(CGFloat)newValue
{
    CGFloat deltaValue = newValue-lastBlurValue;
    edgeBlurValue = newValue;
    
    if(self.currentLayoutIndex < LayoutPatternDiagonal){
        [self sublayoutEndpointsRefeshAfterChangeBlurWidth:deltaValue];
        [self sublayoutEndpointsBackupRefeshAfterChangeBlurWidth:0.0];
        
        for(int i=0; i<sublayoutEndpoints.count; i++){
            MGIrregularView *irregularView = [irregularViews objectAtIndex:i];
            irregularView.bezierArea = pictureBezierPaths[i];
            irregularView.viewRect = [self rectWithEndpoints:sublayoutEndpoints[i]];
            irregularView.blur0Rect = [self rectWithEndpoints:sublayoutEndpointsBackup[i]];
            irregularView.clipsToBounds = YES;
            
            if(irregularView.isInEdit){
                [irregularView setMaskLayer];
            }
            irregularView.blurWidth = newValue;
            [irregularView changeEdgeBlurWidth:newValue];
        }
    }else{
        
        
        
        MGIrregularView *irregularView1 = [irregularViews objectAtIndex:1];
        irregularView1.blurWidth = newValue;
        [irregularView1 changeEdgeBlurWidth:newValue];
        
        if (self.currentLayoutIndex == LayoutPatternLeftArrowx2 || self.currentLayoutIndex == LayoutPatternDownArrowx2 || self.currentLayoutIndex == LayoutPatternShapeSx2) {
            MGIrregularView *irregularView2 = [irregularViews objectAtIndex:2];
            irregularView2.blurWidth = newValue;
            [irregularView2 changeEdgeBlurWidth:newValue];
        }
        
        
    }
    
    lastBlurValue = newValue;
}

- (void)set0EdgeBlurValue
{
    CGFloat deltaValue = 0.0-lastBlurValue;
    blurSlider.value = 0.0;
    sliderCount = 0;
    lastBlurValue = blurSlider.value;
    edgeBlurValue = 0.0;
    
    if(self.currentLayoutIndex < LayoutPatternDiagonal){
        
        [self sublayoutEndpointsRefeshAfterChangeBlurWidth:deltaValue];
        [self sublayoutEndpointsBackupRefeshAfterChangeBlurWidth:0.0];
        
        for(int i=0; i<sublayoutEndpoints.count; i++){
            MGIrregularView *irregularView = [irregularViews objectAtIndex:i];
            irregularView.bezierArea = pictureBezierPaths[i];
            irregularView.viewRect = [self rectWithEndpoints:sublayoutEndpoints[i]];
            irregularView.blur0Rect = [self rectWithEndpoints:sublayoutEndpointsBackup[i]];
            irregularView.clipsToBounds = YES;
            
            irregularView.blurWidth = 0.0;
            [irregularView changeEdgeBlurWidth:0.0];
        }
    }else{
        MGIrregularView *irregularView = [irregularViews objectAtIndex:1];
        irregularView.blurWidth = 0.0;
        [irregularView changeEdgeBlurWidth:0.0];
    }
}

//Lines change
#pragma mark - LinesChanged
- (void)LinesRefreshAfterMoveLines:(NSArray*)newLines withLineIndex:(NSInteger)index
{
    [lines replaceObjectAtIndex:index withObject:newLines];
}

- (void)affectLinesRefreshAfterMoveLines:(NSArray*)newLines withAffectIndex:(NSInteger)index
{
    [lines replaceObjectAtIndex:index withObject:newLines];
    MGLineView *lineView = [lineViews objectAtIndex:index];
    lineView.points = lines[index];
    //    [lineView setNeedsDisplay];
    [lineView createPath];
}
#pragma mark - switch layout

- (void)sublayoutEndpointsRefeshAfterMoveLineIndex:(NSInteger)lineIndex blurWidth:(CGFloat)blurWidth {
    [self sublayoutEndpointsRefeshAfterMoveLineIndex:lineIndex blurWidth:blurWidth backup:NO];
}

- (void)sublayoutEndpointsBackupRefeshAfterMoveLineIndex:(NSInteger)lineIndex blurWidth:(CGFloat)blurWidth {
    [self sublayoutEndpointsRefeshAfterMoveLineIndex:lineIndex blurWidth:blurWidth backup:YES];
}

- (void)sublayoutEndpointsRefeshAfterChangeBlurWidth:(CGFloat)blurWidth {
    [self sublayoutEndpointsRefeshAfterChangeBlurWidth:blurWidth backup:NO];
}

- (void)sublayoutEndpointsBackupRefeshAfterChangeBlurWidth:(CGFloat)blurWidth {
    [self sublayoutEndpointsRefeshAfterChangeBlurWidth:blurWidth backup:YES];
}


- (void)sublayoutEndpointsRefeshAfterMoveLineIndex:(NSInteger)lineIndex blurWidth:(CGFloat)blurWidth backup:(BOOL)backup {
    switch(self.currentLayoutIndex){
        case G1x2:
        case G1x3:
        case G1x4:
        case G1x5:
        case G1x6:{
            [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            break;
        }
        case G2x1:
        case G3x1:
        case G4x1:
        case G5x1:
        case G6x1:{
            [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            break;
        }
        case H2_2x1_1x1:{
            if(lineIndex == 0){
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            }else{
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            }
            break;
        }
        case V2_1x1_1x2:{
            if(lineIndex == 0){
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            }else{
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            }
            break;
        }
        case H2_3x1_1x1:{
            if(lineIndex == 0){
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            }else if(lineIndex == 1) {
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            } else {
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:2 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            }
            break;
        }
        case V2_1x1_1x3:{
            if(lineIndex == 0){
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            }else if(lineIndex == 1) {
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            } else {
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            }
            break;
        }
        case H2_3x1_2x1:{
            if(lineIndex == 0){
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:4 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            }else if(lineIndex == 1) {
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            } else if(lineIndex == 2) {
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:2 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            } else if(lineIndex == 3) {
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:3 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:4 lineIndex:3 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            }
            break;
        }
        case V2_1x2_1x3:{
            if(lineIndex == 0){
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:4 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            }else if(lineIndex == 1) {
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            } else if(lineIndex == 2) {
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:4 lineIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            } else if(lineIndex == 3) {
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:3 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            }
            break;
        }
        case H3_2x1_1x1_1x1:{
            if(lineIndex == 0) {
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            } else if(lineIndex == 1){
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            }else if(lineIndex == 2) {
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            }
            break;
        }
        case V3_1x2_1x1_1x1:{
            
            if(lineIndex == 0) {
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            } else if(lineIndex == 1){
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            }else  if(lineIndex == 2) {
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:2 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            }
            break;
        }
        case G2x2:{
            if(lineIndex == 0){
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:0 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            }else{
                [self sublayoutEndpointsChangedSublayoutIndex:0 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:1 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:2 lineIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:3 lineIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            }
            break;
        }
        case LayoutPatternDiagonal:{
            NSArray *line = lines[0];
            CGPoint first = CGPointFromString(line[0]);
            CGPoint second = CGPointFromString(line[1]);
            if(first.y <= 0.0){
                NSMutableArray *subPoints1 = [sublayoutEndpoints[0] mutableCopy];
                NSMutableArray *subPoints2 = [sublayoutEndpoints[1] mutableCopy];
                if(subPoints1.count == 5){
                    [subPoints1 removeObjectAtIndex:3];
                    [subPoints1 removeObjectAtIndex:2];
                }
                
                CGPoint point1 = CGPointFromString(subPoints1[1]);
                CGPoint point2 = CGPointFromString(subPoints1[2]);
                
                point1.y = second.y;
                point2.x = first.x;
                
                NSString *pointStr1 = NSStringFromCGPoint(point1);
                NSString *pointStr2 = NSStringFromCGPoint(point2);
                
                [subPoints1 replaceObjectAtIndex:1 withObject:pointStr1];
                [subPoints1 replaceObjectAtIndex:2 withObject:pointStr2];
                
                NSArray *arr = [[NSArray alloc] initWithArray:subPoints1];
                [sublayoutEndpoints replaceObjectAtIndex:0 withObject:arr];
                
                if(subPoints2.count == 3){
                    [subPoints2 insertObject:pointStr2 atIndex:1];
                    [subPoints2 insertObject:pointStr1 atIndex:2];
                    
                    CGPoint p1 = CGPointMake(1.0, 0.0);
                    CGPoint p2 = CGPointMake(0.0, 1.0);
                    
                    [subPoints2 replaceObjectAtIndex:0 withObject:NSStringFromCGPoint(p1)];
                    [subPoints2 replaceObjectAtIndex:3 withObject:NSStringFromCGPoint(p2)];
                    
                    [sublayoutEndpoints replaceObjectAtIndex:1 withObject:(NSArray*)[subPoints2 copy]];
                }else{
                    [subPoints2 replaceObjectAtIndex:2 withObject:pointStr1];
                    [subPoints2 replaceObjectAtIndex:1 withObject:pointStr2];
                    [sublayoutEndpoints replaceObjectAtIndex:1 withObject:(NSArray*)[subPoints2 copy]];
                }
            }else{
                NSMutableArray *subPoints2 = [sublayoutEndpoints[1] mutableCopy];
                NSMutableArray *subPoints1 = [sublayoutEndpoints[0] mutableCopy];
                if(subPoints2.count == 5){
                    [subPoints2 removeObjectAtIndex:2];
                    [subPoints2 removeObjectAtIndex:1];
                }
                
                CGPoint point1 = CGPointFromString(subPoints2[0]);
                CGPoint point2 = CGPointFromString(subPoints2[1]);
                
                point1.y = first.y;
                point2.x = second.x;
                
                [subPoints2 replaceObjectAtIndex:0 withObject:NSStringFromCGPoint(point1)];
                [subPoints2 replaceObjectAtIndex:1 withObject:NSStringFromCGPoint(point2)];
                [sublayoutEndpoints replaceObjectAtIndex:1 withObject:[subPoints2 copy]];
                
                
                if(subPoints1.count == 3){
                    [subPoints1 insertObject:NSStringFromCGPoint(point2) atIndex:2];
                    [subPoints1 insertObject:NSStringFromCGPoint(point1) atIndex:3];
                    
                    CGPoint p1 = CGPointMake(1.0, 0.0);
                    CGPoint p2 = CGPointMake(0.0, 1.0);
                    
                    [subPoints1 replaceObjectAtIndex:4 withObject:NSStringFromCGPoint(p1)];
                    [subPoints1 replaceObjectAtIndex:1 withObject:NSStringFromCGPoint(p2)];
                    
                    [sublayoutEndpoints replaceObjectAtIndex:0 withObject:(NSArray*)[subPoints1 copy]];
                }else{
                    [subPoints1 replaceObjectAtIndex:2 withObject:NSStringFromCGPoint(point2)];
                    [subPoints1 replaceObjectAtIndex:3 withObject:NSStringFromCGPoint(point1)];
                    [sublayoutEndpoints replaceObjectAtIndex:0 withObject:(NSArray*)[subPoints1 copy]];
                }
            }
            break;
        }
            
        case LayoutPatternShapeSx1:{
            [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@2,@3] axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1] axis:0 delta:-blurWidth backup:backup];
            break;
        }
        case LayoutPatternShapeSx2:{
            
            switch (lineIndex) {
                case 0:
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@2,@3] axis:0 delta:blurWidth backup:backup];
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1] axis:0 delta:-blurWidth backup:backup];
                    break;
                case 1:
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@2,@3] axis:0 delta:blurWidth backup:backup];
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1] axis:0 delta:-blurWidth backup:backup];
                    break;
                default:
                    break;
            }
            break;
        }
            
        case LayoutPatternDownArrowx1:{
            [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@1,@2,@3] axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@4,@3] axis:1 delta:-blurWidth backup:backup];
            break;
        }
        case LayoutPatternDownArrowx2:{
            
            switch (lineIndex) {
                case 0:
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@1,@2,@3] axis:1 delta:blurWidth backup:backup];
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@5,@4] axis:1 delta:-blurWidth backup:backup];
                    break;
                case 1:
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@1,@2,@3] axis:1 delta:blurWidth backup:backup];
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@4,@3] axis:1 delta:-blurWidth backup:backup];
                    break;
                default:
                    break;
            }
            break;
        }
            
        case LayoutPatternLeftArrowx1:{
            [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@2,@3,@4] axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1,@2] axis:0 delta:-blurWidth backup:backup];
            break;
        }
        case LayoutPatternLeftArrowx2:{
            
            switch (lineIndex) {
                case 0:
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@2,@3,@4] axis:0 delta:blurWidth backup:backup];
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1,@2] axis:0 delta:-blurWidth backup:backup];
                    break;
                case 1:
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex lineIndex:lineIndex endpointIndices:@[@3,@4,@5] axis:0 delta:blurWidth backup:backup];
                    [self sublayoutEndpointsChangedSublayoutIndex:lineIndex+1 lineIndex:lineIndex endpointIndices:@[@0,@1,@2] axis:0 delta:-blurWidth backup:backup];
                    break;
                default:
                    break;
            }
            break;
        }
        default:{
            break;
        }
    }
    
    [self PointsRefresh];
}



- (void)sublayoutEndpointsRefeshAfterChangeBlurWidth:(CGFloat)blurWidth backup:(BOOL)backup {
    switch(self.currentLayoutIndex){
        case G1x2:
        case G1x3:
        case G1x4:
        case G1x5:
        case G1x6:
        {
            for (NSInteger i = 0; i < sublayoutEndpoints.count-1; i++) {
                [self sublayoutEndpointsChangedSublayoutIndex:i endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:i+1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            }
            break;
        }
        case G2x1:
        case G3x1:
        case G4x1:
        case G5x1:
        case G6x1:
        {
            for (NSInteger i = 0; i < sublayoutEndpoints.count-1; i++) {
                [self sublayoutEndpointsChangedSublayoutIndex:i endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
                [self sublayoutEndpointsChangedSublayoutIndex:i+1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            }
            break;
        }
            
        case H2_2x1_1x1:{
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            break;
        }
        case V2_1x1_1x2:{
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            break;
        }
        case G2x2:{
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            break;
        }
        case H2_3x1_1x1:{
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            
            
            
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            
            
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            break;
        }
        case V2_1x1_1x3:{
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            break;
        }
        case H2_3x1_2x1:{
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:4 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:4 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            
            break;
        }
        case V2_1x2_1x3:{
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:4 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            
            
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:4 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            break;
        }
        case H3_2x1_1x1_1x1:{
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            
            break;
        }
        case V3_1x2_1x1_1x1:{
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            
            
            [self sublayoutEndpointsChangedSublayoutIndex:2 endpointIndices:MGChangeNums2(1, 2) axis:1 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:3 endpointIndices:MGChangeNums2(0, 3) axis:1 delta:-blurWidth backup:backup];
            
            
            [self sublayoutEndpointsChangedSublayoutIndex:0 endpointIndices:MGChangeNums2(2, 3) axis:0 delta:blurWidth backup:backup];
            [self sublayoutEndpointsChangedSublayoutIndex:1 endpointIndices:MGChangeNums2(0, 1) axis:0 delta:-blurWidth backup:backup];
            
            break;
        }
        case LayoutPatternDiagonal:{
            break;
        }
        default:{
            break;
        }
    }
    
    [self PointsRefresh];
}
-  (void)sublayoutEndpointsChangedSublayoutIndex:(NSInteger)sublayoutIndex endpointIndices:(NSArray*)endpointIndices axis:(NSInteger)axis delta:(CGFloat)delta backup:(BOOL)backup {
    
    
    NSMutableArray * sublayoutEndpointsDataSource = backup ? sublayoutEndpointsBackup : sublayoutEndpoints;
    
    NSMutableArray *subPoints = [sublayoutEndpointsDataSource[sublayoutIndex] mutableCopy];
    CGPoint point1 = CGPointFromString(subPoints[[endpointIndices[0] integerValue]]);
    CGPoint point2 = CGPointFromString(subPoints[[endpointIndices[1] integerValue]]);
    CGPoint point3 = endpointIndices.count > 2 ? CGPointFromString(subPoints[[endpointIndices[2] integerValue]]) : CGPointZero;
    
    if (axis == 0) {
        point1.x = point1.x+delta/[self getBlurDen]/2;
        point2.x = point2.x+delta/[self getBlurDen]/2;
        point3.x = point3.x+delta/[self getBlurDen]/2;
    } else {
        point1.y = point1.y+delta/[self getBlurDen]/2;
        point2.y = point2.y+delta/[self getBlurDen]/2;
        point3.y = point3.y+delta/[self getBlurDen]/2;
    }
    
    NSString *pointStr1 = NSStringFromCGPoint(point1);
    NSString *pointStr2 = NSStringFromCGPoint(point2);
    NSString *pointStr3 = NSStringFromCGPoint(point3);
    
    [subPoints replaceObjectAtIndex:[endpointIndices[0] integerValue] withObject:pointStr1];
    [subPoints replaceObjectAtIndex:[endpointIndices[1] integerValue] withObject:pointStr2];
    if (endpointIndices.count > 2) {
        [subPoints replaceObjectAtIndex:[endpointIndices[2] integerValue] withObject:pointStr3];
    }
    NSArray *arr = [[NSArray alloc] initWithArray:subPoints];
    [sublayoutEndpointsDataSource replaceObjectAtIndex:sublayoutIndex withObject:arr];
    
}

- (void)sublayoutEndpointsChangedSublayoutIndex:(NSInteger)sublayoutIndex endpointIndices:(NSArray*)endpointIndices axis:(NSInteger)axis delta:(CGFloat)delta {
    [self sublayoutEndpointsChangedSublayoutIndex:sublayoutIndex endpointIndices:endpointIndices axis:axis delta:delta backup:NO];
}

- (void)sublayoutEndpointsBackupChangedSublayoutIndex:(NSInteger)sublayoutIndex endpointIndices:(NSArray*)endpointIndices axis:(NSInteger)axis delta:(CGFloat)delta {
    [self sublayoutEndpointsChangedSublayoutIndex:sublayoutIndex endpointIndices:endpointIndices axis:axis delta:delta backup:YES];
}

- (void)sublayoutEndpointsChangedSublayoutIndex:(NSInteger)sublayoutIndex lineIndex:(NSInteger)lineIdx endpointIndices:(NSArray*)endpointIndices axis:(NSInteger)axis delta:(CGFloat)delta backup:(BOOL)backup {
    NSMutableArray * sublayoutEndpointsDataSource = backup ? sublayoutEndpointsBackup : sublayoutEndpoints;
    NSArray *line = lines[lineIdx];
    CGPoint changedPoint1 = CGPointFromString(line[0]);
    CGPoint changedPoint2 = CGPointFromString(line[1]);
    CGPoint changedPoint3 = line.count > 2 ? CGPointFromString(line[2]) : CGPointZero;
    
    NSMutableArray *subPoints = [sublayoutEndpointsDataSource[sublayoutIndex] mutableCopy];
    CGPoint point1 = CGPointFromString(subPoints[[endpointIndices[0] integerValue]]);
    CGPoint point2 = CGPointFromString(subPoints[[endpointIndices[1] integerValue]]);
    CGPoint point3 = endpointIndices.count > 2 ? CGPointFromString(subPoints[[endpointIndices[2] integerValue]]) : CGPointZero;
    if(axis == 0){
        point1.x = changedPoint1.x+delta/[self getBlurDen]/2;
        point2.x = changedPoint2.x+delta/[self getBlurDen]/2;
        point3.x = changedPoint3.x+delta/[self getBlurDen]/2;
    }else{
        point1.y = changedPoint1.y+delta/[self getBlurDen]/2;
        point2.y = changedPoint2.y+delta/[self getBlurDen]/2;
        point3.y = changedPoint3.y+delta/[self getBlurDen]/2;
    }
    
    NSString *pointStr1 = NSStringFromCGPoint(point1);
    NSString *pointStr2 = NSStringFromCGPoint(point2);
    NSString *pointStr3 = NSStringFromCGPoint(point3);
    
    [subPoints replaceObjectAtIndex:[endpointIndices[0] integerValue] withObject:pointStr1];
    [subPoints replaceObjectAtIndex:[endpointIndices[1] integerValue] withObject:pointStr2];
    if (endpointIndices.count > 2) {
        [subPoints replaceObjectAtIndex:[endpointIndices[2] integerValue] withObject:pointStr3];
    }
    NSArray *arr = [[NSArray alloc] initWithArray:subPoints];
    [sublayoutEndpointsDataSource replaceObjectAtIndex:sublayoutIndex withObject:arr];
}

- (void)sublayoutEndpointsChangedSublayoutIndex:(NSInteger)sublayoutIndex lineIndex:(NSInteger)lineIdx endpointIndices:(NSArray*)endpointIndices axis:(NSInteger)axis delta:(CGFloat)delta {
    [self sublayoutEndpointsChangedSublayoutIndex:sublayoutIndex lineIndex:lineIdx endpointIndices:endpointIndices axis:axis delta:delta backup:NO];
}

- (void)sublayoutEndpointsBackupChangedSublayoutIndex:(NSInteger)sublayoutIndex lineIndex:(NSInteger)lineIdx endpointIndices:(NSArray*)endpointIndices axis:(NSInteger)axis delta:(CGFloat)delta {
    [self sublayoutEndpointsChangedSublayoutIndex:sublayoutIndex lineIndex:lineIdx endpointIndices:endpointIndices axis:axis delta:delta backup:YES];
}


- (NSArray*)mutableToArray:(NSMutableArray*)mutableArr;
{
    NSArray *arr = [mutableArr copy];
    return arr;
}


- (void)drawPath:(UIBezierPath *)path1 subPoints:(NSArray *)subPoints sublayoutIndex:(NSInteger)i {
    
    if (self.currentLayoutIndex == LayoutPatternShapeSx1) {
        
        
        CGPoint point1 = CGPointFromString(subPoints[0]);
        CGPoint point2 = CGPointFromString(subPoints[1]);
        CGPoint point3 = CGPointFromString(subPoints[2]);
        CGPoint point4 = CGPointFromString(subPoints[3]);
        
        if (i == 0) {
            
            point1 = CGPointMake(point1.x*cameraRect.size.width, point1.y*cameraRect.size.height);
            point2 = CGPointMake(point2.x*cameraRect.size.width, point2.y*cameraRect.size.height);
            
            CGPoint curveBegin = CGPointMake(point3.x*cameraRect.size.width, point3.y*cameraRect.size.height);
            CGPoint curveEnd = CGPointMake(point4.x*cameraRect.size.width, point4.y*cameraRect.size.height);
            
            CGFloat curveMin = MIN(curveBegin.y, curveEnd.y);
            CGFloat curveLength = fabs(curveEnd.y-curveBegin.y);
            
            CGPoint curveControl1 = CGPointMake((point3.x-curveApex)*cameraRect.size.width, curveMin+curveLength*0.25);
            CGPoint curveControl2 = CGPointMake((point3.x+curveApex)*cameraRect.size.width, curveMin+curveLength*0.75);
            
            
            
            [path1 moveToPoint:point1];
            [path1 addLineToPoint:point2];
            [path1 addLineToPoint:curveBegin];
            [path1 addCurveToPoint:curveEnd controlPoint1:curveControl2 controlPoint2:curveControl1];
            [path1 closePath];
            
        } else if (i == 1){
            
            
            point3 = CGPointMake(point3.x*cameraRect.size.width, point3.y*cameraRect.size.height);
            point4 = CGPointMake(point4.x*cameraRect.size.width, point4.y*cameraRect.size.height);
            CGPoint curveBegin = CGPointMake(point1.x*cameraRect.size.width, point1.y*cameraRect.size.height);
            CGPoint curveEnd = CGPointMake(point2.x*cameraRect.size.width, point2.y*cameraRect.size.height);
            
            CGFloat curveMin = MIN(curveBegin.y, curveEnd.y);
            CGFloat curveLength = fabs(curveEnd.y-curveBegin.y);
            
            CGPoint curveControl1 = CGPointMake((point1.x-curveApex)*cameraRect.size.width, curveMin+curveLength*0.25);
            CGPoint curveControl2 = CGPointMake((point1.x+curveApex)*cameraRect.size.width, curveMin+curveLength*0.75);
            [path1 moveToPoint:curveBegin];
            [path1 addCurveToPoint:curveEnd controlPoint1:curveControl1 controlPoint2:curveControl2];
            [path1 addLineToPoint:point3];
            [path1 addLineToPoint:point4];
            [path1 closePath];
            
        }
    } else if (self.currentLayoutIndex == LayoutPatternShapeSx2) {
        
        CGPoint point1 = CGPointFromString(subPoints[0]);
        CGPoint point2 = CGPointFromString(subPoints[1]);
        CGPoint point3 = CGPointFromString(subPoints[2]);
        CGPoint point4 = CGPointFromString(subPoints[3]);
        
        if (i == 0) {
            
            
            
            point1 = CGPointMake(point1.x*cameraRect.size.width, point1.y*cameraRect.size.height);
            point2 = CGPointMake(point2.x*cameraRect.size.width, point2.y*cameraRect.size.height);
            
            CGPoint curveBegin = CGPointMake(point3.x*cameraRect.size.width, point3.y*cameraRect.size.height);
            CGPoint curveEnd = CGPointMake(point4.x*cameraRect.size.width, point4.y*cameraRect.size.height);
            
            CGFloat curveMin = MIN(curveBegin.y, curveEnd.y);
            CGFloat curveLength = fabs(curveEnd.y-curveBegin.y);
            CGPoint curveControl1 = CGPointMake((point3.x-curveApex)*cameraRect.size.width, curveMin+curveLength*0.25);
            CGPoint curveControl2 = CGPointMake((point3.x+curveApex)*cameraRect.size.width, curveMin+curveLength*0.75);
            
            
            
            [path1 moveToPoint:point1];
            [path1 addLineToPoint:point2];
            [path1 addLineToPoint:curveBegin];
            [path1 addCurveToPoint:curveEnd controlPoint1:curveControl2 controlPoint2:curveControl1];
            [path1 closePath];
            
        } else if (i == 1){
            
            
            CGPoint curveLeftBegin = CGPointMake(point1.x*cameraRect.size.width, point1.y*cameraRect.size.height);
            CGPoint curveLeftEnd = CGPointMake(point2.x*cameraRect.size.width, point2.y*cameraRect.size.height);
            
            CGFloat curveLeftMin = MIN(curveLeftBegin.y, curveLeftEnd.y);
            CGFloat curveLeftLength = fabs(curveLeftEnd.y-curveLeftBegin.y);
            
            CGPoint curveLeftControl1 = CGPointMake((point1.x-curveApex)*cameraRect.size.width, curveLeftMin+curveLeftLength*0.25);
            CGPoint curveLeftControl2 = CGPointMake((point1.x+curveApex)*cameraRect.size.width, curveLeftMin+curveLeftLength*0.75);
            
            CGPoint curveRightBegin = CGPointMake(point3.x*cameraRect.size.width, point3.y*cameraRect.size.height);
            CGPoint curveRightEnd = CGPointMake(point4.x*cameraRect.size.width, point4.y*cameraRect.size.height);
            
            CGFloat curveRightMin = MIN(curveRightBegin.y, curveRightEnd.y);
            CGFloat curveRightLength = fabs(curveRightEnd.y-curveRightBegin.y);
            
            
            CGPoint curveRightControl1 = CGPointMake((point3.x-curveApex)*cameraRect.size.width, curveRightMin+curveRightLength*0.25);
            CGPoint curveRightControl2 = CGPointMake((point3.x+curveApex)*cameraRect.size.width, curveRightMin+curveRightLength*0.75);
            
            [path1 moveToPoint:curveLeftBegin];
            [path1 addCurveToPoint:curveLeftEnd controlPoint1:curveLeftControl1 controlPoint2:curveLeftControl2];
            [path1 addLineToPoint:curveRightBegin];
            [path1 addCurveToPoint:curveRightEnd controlPoint1:curveRightControl2 controlPoint2:curveRightControl1];
            [path1 closePath];
            
            
            
            
            
        } else if (i == 2){
            
            point3 = CGPointMake(point3.x*cameraRect.size.width, point3.y*cameraRect.size.height);
            point4 = CGPointMake(point4.x*cameraRect.size.width, point4.y*cameraRect.size.height);
            CGPoint curveBegin = CGPointMake(point1.x*cameraRect.size.width, point1.y*cameraRect.size.height);
            CGPoint curveEnd = CGPointMake(point2.x*cameraRect.size.width, point2.y*cameraRect.size.height);
            
            CGFloat curveMin = MIN(curveBegin.y, curveEnd.y);
            CGFloat curveLength = fabs(curveEnd.y-curveBegin.y);
            CGPoint curveControl1 = CGPointMake((point1.x-curveApex)*cameraRect.size.width, curveMin+curveLength*0.25);
            CGPoint curveControl2 = CGPointMake((point1.x+curveApex)*cameraRect.size.width, curveMin+curveLength*0.75);
            [path1 moveToPoint:curveBegin];
            [path1 addCurveToPoint:curveEnd controlPoint1:curveControl1 controlPoint2:curveControl2];
            [path1 addLineToPoint:point3];
            [path1 addLineToPoint:point4];
            [path1 closePath];
            
        }
    } else {
        int count = (int)subPoints.count;
        
        for(int j=0; j<count; j++){
            CGPoint point = CGPointFromString(subPoints[j]);
            
            if(j == 0){
                [path1 moveToPoint:CGPointMake(point.x*cameraRect.size.width, point.y*cameraRect.size.height)];
            }else{
                [path1 addLineToPoint:CGPointMake(point.x*cameraRect.size.width, point.y*cameraRect.size.height)];
            }
        }
        [path1 closePath];
    }
    
    
}

//cameraRect change
- (void)PointsRefresh
{
    [pictureBezierPaths removeAllObjects];
    [lineBezierPaths removeAllObjects];
    
    if(self.currentLayoutIndex < LastSimpleLineLayoutPattern+1){
        for(int i=0; i<sublayoutEndpoints.count; i++){
            UIBezierPath *path1 = [UIBezierPath bezierPath];
            
            NSArray *subPoints = [sublayoutEndpoints objectAtIndex:i];
            [self drawPath:path1 subPoints:subPoints sublayoutIndex:i];
            [pictureBezierPaths addObject:path1];
        }
    }else{
        CGFloat view_w = cameraRect.size.width < cameraRect.size.height ? cameraRect.size.width : cameraRect.size.height;
        CGFloat view_gapX = (cameraRect.size.width-view_w)/2;
        CGFloat view_gapY = (cameraRect.size.height-view_w)/2;
        CGRect rect = CGRectFromString(shapes[0]);
        
        if(!IS_IPAD){
            rect = CGRectMake(kRX(rect)*view_w+view_gapX, kRY(rect)*view_w+view_gapY, kRW(rect)*view_w, kRH(rect)*view_w);
        }else{
            CGFloat reduce = 0.1;
            rect = CGRectInset(rect, kRW(rect)*reduce, kRH(rect)*reduce);
            rect = CGRectMake(kRX(rect)*view_w+view_gapX, kRY(rect)*view_w+view_gapY, kRW(rect)*view_w, kRH(rect)*view_w);
        }
        
        if(self.currentLayoutIndex == LayoutPatternCircle){
            
            UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
            [pictureBezierPaths addObject:path];
            [pictureBezierPaths addObject:path];
            
            [lineBezierPaths addObject:path];
            
            irregularRect = rect;
        }else if(self.currentLayoutIndex == LayoutPatternSquare){
            
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
            [pictureBezierPaths addObject:path];
            [pictureBezierPaths addObject:path];
            
            [lineBezierPaths addObject:path];
            
            irregularRect = rect;
        }else if(self.currentLayoutIndex == LayoutPatternTriangle){
            
            NSMutableArray *bezierPoints = [[NSMutableArray alloc] init];
            NSMutableArray *pointsArr = [shapes[1] mutableCopy];
            for(int i=0; i<pointsArr.count; i++){
                CGPoint p = CGPointFromString(pointsArr[i]);
                p.x *= kRW(rect);
                p.y *= kRH(rect);
                p.x += kRX(rect);
                p.y += kRY(rect);
                
                [bezierPoints addObject:[NSValue valueWithCGPoint:p]];
            }
            UIBezierPath *path = [self createBezierPath:bezierPoints];
            [pictureBezierPaths addObject:path];
            [pictureBezierPaths addObject:path];
            [lineBezierPaths addObject:path];
            
            irregularRect = rect;
        }else if(self.currentLayoutIndex == LayoutPatternHeart){
            CGPathRef myPath = [PocketSVG pathFromSVGFileNamed:@"model0"];
            myPath = createPathRotatedAroundBoundingBoxCenter(myPath, kRW(rect)/500.0, kRX(rect), kRY(rect));
            
            UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:myPath];
            CGPathRelease(myPath);
            
            [pictureBezierPaths addObject:path];
            [pictureBezierPaths addObject:path];
            [lineBezierPaths addObject:path];
            
            irregularRect = rect;
        }
        
    }
    
    if(self.currentLayoutIndex < LastSimpleLineLayoutPattern+1){
        for(int i=0; i<lines.count; i++){
            UIBezierPath *path = [UIBezierPath bezierPath];
            
            NSArray *subLines = [lines objectAtIndex:i];
            for(int j=0; j<subLines.count; j++){
                CGPoint point = CGPointFromString(subLines[j]);
                
                if(j == 0){
                    [path moveToPoint:CGPointMake(point.x*cameraRect.size.width, point.y*cameraRect.size.height)];
                }else{
                    [path addLineToPoint:CGPointMake(point.x*cameraRect.size.width, point.y*cameraRect.size.height)];
                }
            }
            [path closePath];
            
            [lineBezierPaths addObject:path];
        }
    }
}

- (CGRect)rectWithEndpoints:(NSArray*)array
{
    CGRect rect = CGRectZero;
    CGFloat minX = INT_MAX;
    CGFloat maxX = 0;
    CGFloat minY = INT_MAX;
    CGFloat maxY = 0;
    
    for(int i=0; i<array.count; i++){
        NSString *pointString = [array objectAtIndex:i];
        CGPoint point = CGPointFromString(pointString);
        if (point.x <= minX) {
            minX = point.x;
        }
        if (point.x >= maxX) {
            maxX = point.x;
        }
        if (point.y <= minY) {
            minY = point.y;
        }
        if (point.y >= maxY) {
            maxY = point.y;
        }
        rect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
    }
    
    
    if (self.currentLayoutIndex == LayoutPatternShapeSx1 || self.currentLayoutIndex == LayoutPatternShapeSx2) {
        rect = CGRectInset(rect, -2*curveApex, 0);
        if (rect.origin.x < 0) {
            rect.size.width += rect.origin.x;
            rect.origin.x = 0;
        } else if (rect.origin.x + rect.size.width > 1) {
            rect.size.width = 1 - rect.origin.x;
        }
    }
    
    rect.origin.x = rect.origin.x*cameraRect.size.width;
    rect.origin.y = rect.origin.y*cameraRect.size.height;
    rect.size.width = rect.size.width*cameraRect.size.width;
    rect.size.height = rect.size.height*cameraRect.size.height;
    return rect;
}

- (CGFloat)getBlurDen
{
    return MIN(self.cameraRect.size.width, self.cameraRect.size.height);
}

- (UIImage*)createImageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}



- (UIBezierPath*)createBezierPath:(NSArray*)array
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    for(int i=0; i<array.count; i++){
        CGPoint point = [array[i] CGPointValue];
        
        if(i == 0){
            [path moveToPoint:point];
        }else{
            [path addLineToPoint:point];
        }
    }
    [path closePath];
    
    return path;
}


static CGPathRef createPathRotatedAroundBoundingBoxCenter(CGPathRef path, CGFloat scale, CGFloat x, CGFloat y)
{
    CGRect bounds = CGPathGetBoundingBox(path); // might want to use CGPathGetPathBoundingBox
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-variable"
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
#pragma clang diagnostic pop
    CGAffineTransform transform = CGAffineTransformIdentity;
    //transform = CGAffineTransformTranslate(transform, center.x, center.y);
    transform = CGAffineTransformTranslate(transform, x, y);
    transform = CGAffineTransformScale(transform, scale, scale);
    
    return CGPathCreateCopyByTransformingPath(path, &transform);
}



#pragma mark - - HUD show&hide
-(MBProgressHUD *)progressHUD
{
    if (_progressHUD==nil) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:baseview];
        [_progressHUD setCenter:baseview.center];
        [baseview addSubview:_progressHUD];
        //        _progressHUD.delegate = self;
        _progressHUD.label.text = kLocalizable(@"Waiting...");
        _progressHUD.userInteractionEnabled = YES;
        _progressHUD.label.font = [UIFont systemFontOfSize:15];
    }
    return _progressHUD;
}

- (void)showTipStatus
{
    [self.progressHUD.superview bringSubviewToFront:self.progressHUD];
    [self.progressHUD showAnimated:YES];
}

- (void)hideTipStatus
{
    [self.progressHUD hideAnimated:YES];
}

- (void)shareImage:(UIImage*)image
{
    NSString *textToShare = @"share Image";
    UIImage *imageToShare = image;
    NSArray *activityItems = @[textToShare, imageToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems
                                                                            applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeMail];
    /*
     
     activityVC.completionHandler = ^(NSString *activityType, BOOL completed) {
     NSLog(@" activityType: %@", activityType);
     NSLog(@" completed: %i", completed);
     if([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
     if([MGData showAds:_adViewController inVC:self.navigationController]){
     isSaveAdsShow = YES;
     }else{
     isSaveAdsShow = NO;
     }
     }
     };
     
     
     */
    
    
    __weak typeof(self) weakSelf = self;
    
    activityVC.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
        NSLog(@" activityType: %@", activityType);
        NSLog(@" completed: %i", completed);
        if([activityType isEqualToString:UIActivityTypeSaveToCameraRoll]){
            
            BOOL show = [[AdmobViewController shareAdmobVC] decideShowRT:self];
            if(!show) {
                
                if([_adViewController getValidUseCount] > 3) {
                    [UIView transitionWithView:self.returnDialog duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            self.returnDialog.hidden = FALSE;
                        } completion:NULL];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
#ifdef ENABLE_AD
                        if(![_adViewController IsPaid:kRemoveAd]){
                            if ([_adViewController try_show_admob_interstitial:weakSelf.navigationController placeid:3 ignoreTimeInterval:YES]) {
                                [Flurry logEvent:@"SADADialog" withParameters:@{@"after":@1}];
                            }
                        }
                        
#endif
                    });
                } else {
#ifdef ENABLE_AD
                    if([_adViewController IsPaid:kRemoveAd]&&![_adViewController try_show_admob_interstitial:weakSelf.navigationController placeid:3 ignoreTimeInterval:YES]) {
                        [UIView transitionWithView:self.returnDialog duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            self.returnDialog.hidden = FALSE;
                        } completion:NULL];
                        
                        [Flurry logEvent:@"SADADialog" withParameters:@{@"after":@0}];
                    } else {
                        [SVProgressHUD showSuccessWithStatus:kLocalizable(@"DIALOG_MSG")];
                    }
#endif
                }
                
            } else {
                [SVProgressHUD showSuccessWithStatus:kLocalizable(@"DIALOG_MSG")];
            }
                
        }
    };
    
    if (IS_IPAD)
    {
        _popover = nil;
        if(_popover == nil){
            
            _popover = [[UIPopoverController alloc] initWithContentViewController:activityVC];
            _popover.delegate = self;
            _popover.popoverContentSize = CGSizeMake(400, 450);
            
            [_popover presentPopoverFromRect:shareBtn.frame inView:bottomView2 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            [self hideTipStatus];
        }
    }
    else
    {
        [self presentViewController:activityVC animated:YES completion:^{
            [weakSelf hideTipStatus];
        }];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [_popover dismissPopoverAnimated:YES];
    _popover = nil;
}


#pragma mark -
#pragma mark save succ dialog
-(void) createSaveSuccDialog {
    CGRect bo = [UIScreen mainScreen].bounds;
    
    //add new drawing dialog
    NSString* title = NSLocalizedString(@"DIALOG_TITLE", nil);
    NSString* message = NSLocalizedString(@"DIALOG_MSG", nil);
    NSString* cancel = NSLocalizedString(@"DIALOG_CANCEL", nil);
    NSString* confirm = NSLocalizedString(@"DIALOG_CONFIRM", nil);
    
    self.returnDialog = [[NewDrawingDialog alloc] initWithFrame:bo];
    [self.returnDialog dialogWithTitle:title Message:message Confirm:confirm Cancel:cancel];
    [self.returnDialog setHidden:TRUE];
    
    __weak typeof(self) weakSelf = self;
    [self.returnDialog setConfirmHandler:^(){
        [weakSelf.returnDialog setHidden:TRUE];
    }];
    
    [self.returnDialog setCancelHandler:^(){
        [weakSelf.returnDialog setHidden:TRUE];
        
    }];
    
    [baseview addSubview:self.returnDialog];
}

#pragma mark -
#pragma mark banner ad position switch

-(BOOL) isADInTop {
    NSDictionary* exconfig = [[[AdmobViewController shareAdmobVC] configCenter] getExConfig];
    BOOL adbottom = true;
    @try {
        adbottom = [exconfig[@"adbottom_camera"] boolValue];
    } @catch (NSException *exception) {
        adbottom = true;
    } @finally {
    }
    return !adbottom;
    //    return false;
}
#ifdef ENABLE_AD
- (void) show_banner_ad {
    if(show_banner_ad_top) {
        [Flurry logEvent:@"show_ad_top" withParameters:@{@"page":@"camera"}];
        adview.frame = CGRectMake(0, 0, kScreenWidth, kAdHeight);
        [_adViewController show_admob_banner:adview placeid:@"mainpage"];
    } else {
        [Flurry logEvent:@"show_ad_bottom" withParameters:@{@"page":@"camera"}];
        adview.frame = CGRectMake(0, kScreenHeight-adheight-bottomH, kScreenWidth, kAdHeight);
        [_adViewController show_admob_banner:adview placeid:@"mainpage"];
    }
}
#endif

@end
