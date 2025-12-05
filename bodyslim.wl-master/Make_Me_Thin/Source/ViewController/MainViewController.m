//
//  MainViewController.m
//  Make_Me_Thin
//
//  Created by ZB_Mac on 16/3/7.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "MainViewController.h"
#import "MBProgressHUD.h"
#import "Toast+UIView.h"
#import "AdUtility.h"
#import "CanvasView.h"
#import "CGRectCGPointUtility.h"
#import "ContinousSlider.h"
#import "DiscreteSlider.h"
#import "KGModal.h"
#import "ImageUtil.h"
#import "PopShareView.h"
#import "ShareView.h"
#import "ShareService.h"
#import "LuxandLandmark.h"
#import "FaceLandmarker.h"
#import "InterativeWarpInPlaceProcessor.h"
#import "ObjectStack.h"
#import "CGPointUtility.h"
#import <AVFoundation/AVFoundation.h>

#define kOpenTimes                @"OpenTimes"
#define kTipAdjustFaceTimes       @"TipFace"
#define kTipAdjustBodyTimes       @"TipBody"
#define kTipAdjustManualTimes     @"TipManual"

typedef enum : NSUInteger {
    kModeNone,
    kModeAutoThinFace,
    kModeSlim,
    kModeFreeStyle,
    kModeAutoThinHead,
} BBMode;

@interface HistoryFrame : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, readwrite) CGFloat strenght;
@property (nonatomic, readwrite) BBMode mode;
@property (nonatomic, strong) LuxandLandmark *landmark;
@end

@implementation HistoryFrame
@end

@interface MainViewController ()<CanvasViewDelegate, ShareViewDelegate, ShareServiceDelegate>
{
    NSInteger selectedOper;

    CGFloat radius;
    CGPoint start1, start2, final1, final2;
    
    BOOL _faceDetectEnd;
    
    BOOL _firstAppear;
    BOOL _everEditAfterEnterCurrentMode;
    
    NSMutableDictionary *_hasTipCurrentPhoto;
}
@property (weak, nonatomic) IBOutlet UIView *adContainer;
@property (weak, nonatomic) IBOutlet UIView *sliderContainer;
@property (weak, nonatomic) IBOutlet UIButton *compareBtn;

@property (weak, nonatomic) IBOutlet UIButton *undoBtn;
@property (weak, nonatomic) IBOutlet UIButton *redoBtn;
@property (weak, nonatomic) IBOutlet UIButton *thinFaceBtn;
@property (weak, nonatomic) IBOutlet UIButton *thinHeadBtn;
@property (weak, nonatomic) IBOutlet UIButton *thinFigureBtn;
@property (weak, nonatomic) IBOutlet UIButton *manualBtn;

@property (weak, nonatomic) IBOutlet UIView *mainContentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainAreaTopPositionConstraint;

@property (weak, nonatomic) IBOutlet UILabel *manualLabel;
@property (weak, nonatomic) IBOutlet UILabel *faceLabel;
@property (weak, nonatomic) IBOutlet UILabel *headLabel;
@property (weak, nonatomic) IBOutlet UILabel *slimLabel;

@property (strong, nonatomic) UIImage *processingImage;

@property (strong, nonatomic) CanvasView *canvasView;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) UIImageView *yaoView;
@property (strong, nonatomic) UIImageView *moveView;
@property (strong, nonatomic) UIImageView *xScaleView;
@property (strong, nonatomic) UIImageView *yScaleView;
@property (strong, nonatomic) UIImageView *rotateView;

@property (strong, nonatomic) NSArray *radiusArray;
@property (strong, nonatomic) ContinousSlider *strenghtSlider;
@property (strong, nonatomic) DiscreteSlider *radiusSlider;

@property (strong, nonatomic) InterativeWarpProcessorInPlace *defaultThinner;

@property (readwrite, nonatomic) BBMode mode;

@property (nonatomic, strong) UIImageView *tipImageView;
@property (strong, nonatomic) UIPopoverController *popController;

@property (weak, nonatomic) PopShareView *popShareView;

@property (nonatomic, strong) FaceLandmarker *faceFeatureDetector;
@property (nonatomic, strong) LuxandLandmark *faceLandmark;

@property (nonatomic, strong) ObjectStack* historyFrames;
@end

@implementation MainViewController

//@synthesize faceDefaultDetector=_faceDefaultDetector;
//-(FaceFeatureDetector *)faceDefaultDetector
//{
//    if (_faceDefaultDetector == nil) {
//        _faceDefaultDetector = [FaceFeatureDetector detectorEnableAccurateFaceDetection:YES viaWifiOnly:YES];
//        _faceDefaultDetector.enableScaleImage = NO;
//    }
//    return _faceDefaultDetector;
//}

-(ObjectStack *)historyFrames
{
    if (!_historyFrames) {
        _historyFrames = [[ObjectStack alloc] initWithMaxSize:4 andSupportRedo:YES andCanPopFirstObject:NO];
    }
    return _historyFrames;
}

-(FaceLandmarker *)faceFeatureDetector
{
    if (!_faceFeatureDetector) {
        _faceFeatureDetector = [FaceLandmarker defaultLandmarker];
    }
    return _faceFeatureDetector;
}

@synthesize defaultThinner=_defaultThinner;
-(InterativeWarpProcessorInPlace *)defaultThinner
{
    if (!_defaultThinner) {
        _defaultThinner = [[InterativeWarpProcessorInPlace alloc] init];
    }
    return _defaultThinner;
}

@synthesize mode=_mode;
-(void)setMode:(BBMode)mode
{
    _mode = mode;
    [self updateMaskViewForMode:mode];
    [self updateBottomBtnsForMode:mode];
    [self updateSlidersForMode:mode];
    [self updateCanvasForMode:mode];
    
    if (mode != kModeNone) {
        NSString *type = nil;
        switch (mode) {
            case kModeAutoThinFace:
            case kModeAutoThinHead:
                type = kTipAdjustFaceTimes;
                break;
            case kModeFreeStyle:
                type = kTipAdjustManualTimes;
                break;
            case kModeSlim:
                type = kTipAdjustBodyTimes;
                break;
            default:
                break;
        }
        [self isWantToTip:type];
    }
}

@synthesize radiusArray=_radiusArray;
-(NSArray *)radiusArray
{
    if (_radiusArray == nil) {
        _radiusArray = @[@(25.6),
                         @(30.4),
                         @(35.5),
                         @(40.2),
                         @(45.1),];
    }
    return _radiusArray;
}

#pragma mark -
-(void)useImage:(UIImage *)image
{
    _faceDetectEnd = NO;
    
    self.processingImage = image;
    self.canvasView.image = image;
    self.imageView.image = image;
    
    self.mode = kModeNone;
    [self.defaultThinner setSrcImage:image];
    [MBProgressHUD showSharedHUDInView:self.view];
    
    //
    [self.faceFeatureDetector asynLandmarkImage:_originalImage withMethodList:@[@(LandmarkMethodFacepp), @(LandmarkSourceLuxand), @(LandmarkSourceZB),  @(LandmarkSourceCI)] andEndBlock:^(NSArray *landmarks) {

        if(landmarks){
            self.faceLandmark = landmarks.firstObject;
        }else{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"DETECTION_ERROR_TITLE", @"") preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];

            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        //landmarks保存几种landmark集合，实际上，asynLandmarkImage也就只会处理找到的第一个landmark，landmarks只有一个元素

        //mode : 瘦身or瘦脸or自动
        BBMode mode = [[NSUserDefaults standardUserDefaults]  integerForKey:@"slim-mode"];
        
        if (mode==kModeNone) {
            mode = kModeAutoThinFace;
        }
        
        if (mode==kModeAutoThinHead || mode==kModeAutoThinFace) {
            if (![self faceFeatureUsable:self.originalImage]) {
                mode = kModeFreeStyle;
            }
        }
        
        self.mode = mode;
        
        NSString *type = nil;
        switch (mode) {
            case kModeAutoThinFace:
            case kModeAutoThinHead:
                type = kTipAdjustFaceTimes;
                break;
            case kModeFreeStyle:
                type = kTipAdjustManualTimes;
                break;
            case kModeSlim:
                type = kTipAdjustBodyTimes;
                break;
            default:
                break;
        }
        //根据打开次数确定是否打开操作提示
        [self isWantToTip:type];
        
        [MBProgressHUD hideSharedHUD];
        _faceDetectEnd = YES;
        //添加原图遮罩
        [self shapeMaskView];
        
        //保存初次进入视图的页面
        [self makeAndPushHistoryFrame];
        
//        UIImage *image = [self drawPoints:@[[NSValue valueWithCGPoint:self.faceLandmark.contourLeft6],
//                                            [NSValue valueWithCGPoint:self.faceLandmark.contourRight6],
//                                            [NSValue valueWithCGPoint:self.faceLandmark.noseTip],
//                                            [NSValue valueWithCGPoint:self.faceLandmark.leftEyeCenter],
//                                            [NSValue valueWithCGPoint:self.faceLandmark.rightEyeCenter],
//                                            ] InImage:self.imageView.image withColor:[UIColor greenColor]];
//        self.canvasView.image = image;
    }];
}

-(void)setupViews
{
    self.canvasView = [[CanvasView alloc] initWithFrame:AVMakeRectWithAspectRatioInsideRect(self.originalImage.size, self.mainContentView.bounds) andImage:self.originalImage];
    self.canvasView.radius = [self.radiusArray.firstObject floatValue];
    self.canvasView.mode = kCanvasModeDrag;
    self.canvasView.supportInteraction = YES;
    self.canvasView.delegate = self;
//    self.canvasView.image = self.originalImage;
    [self.mainContentView addSubview:self.canvasView];
    [self.canvasView setupMirrorInView:self.mainContentView];
    
    self.imageView.hidden = YES;
    [self setupMaskView];
    [self loadButtons];
}

- (void)isWantToTip:(NSString *)type
{
    NSInteger openTimes = [[[NSUserDefaults standardUserDefaults] objectForKey:type] integerValue];
    BOOL hasCurrentPhotoTip = [[_hasTipCurrentPhoto objectForKey:type] boolValue];
    if (openTimes<2 && !hasCurrentPhotoTip)
    {
        [_hasTipCurrentPhoto setValue:@(YES) forKey:type];
        
        openTimes++;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:openTimes] forKey:type];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([type isEqualToString:kTipAdjustFaceTimes]) {
            self.tipImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            if (IS_IPAD) {
                self.tipImageView.image = [ImageUtil loadResourceImage:@"ipad_help_2"];
            }
            else
            {
                if ([ZBCommonMethod currentResolution]==UIDevice_iPhoneTallerHiRes) {
                    self.tipImageView.image = [ImageUtil loadResourceImage:@"i5_help_2"];
                    
                }
                else
                {
                    self.tipImageView.image = [ImageUtil loadResourceImage:@"i4_help_2"];
                    
                }
            }
            [self.view addSubview:self.tipImageView];
            self.tipImageView.userInteractionEnabled = YES;
            self.tipImageView.tag = 1888;
            
            UITapGestureRecognizer *_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
            [self.tipImageView addGestureRecognizer:_tapGesture];
        }
        else if([type isEqualToString:kTipAdjustBodyTimes])
        {
            self.tipImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];

            if (IS_IPAD) {
                self.tipImageView.image = [ImageUtil loadResourceImage:@"ipad_help_3"];
            }
            else
            {
                if ([ZBCommonMethod currentResolution]==UIDevice_iPhoneTallerHiRes) {
                    self.tipImageView.image = [ImageUtil loadResourceImage:@"i5_help_3"];
                    
                }
                else
                {
                    self.tipImageView.image = [ImageUtil loadResourceImage:@"i4_help_3"];
                    
                }
            }
            [self.view addSubview:self.tipImageView];
            self.tipImageView.userInteractionEnabled = YES;
            self.tipImageView.tag = 1889;
            
            UITapGestureRecognizer *_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
            [self.tipImageView addGestureRecognizer:_tapGesture];
        }
        else if([type isEqualToString:kTipAdjustManualTimes])
        {
            self.tipImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            if (IS_IPAD) {
                self.tipImageView.image = [ImageUtil loadResourceImage:@"ipad_help_1"];
            }
            else
            {
                if ([ZBCommonMethod currentResolution]==UIDevice_iPhoneTallerHiRes) {
                    self.tipImageView.image = [ImageUtil loadResourceImage:@"i5_help_1"];
                    
                }
                else
                {
                    self.tipImageView.image = [ImageUtil loadResourceImage:@"i4_help_1"];
                    
                }
            }
            [self.view addSubview:self.tipImageView];
            self.tipImageView.userInteractionEnabled = YES;
            self.tipImageView.tag = 1888;
            
            UITapGestureRecognizer *_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
            [self.tipImageView addGestureRecognizer:_tapGesture];
        }
    }
}

#pragma mark -

- (void)singleTap:(UITapGestureRecognizer*)tap
{
    if (tap.view.tag == 1889) {
        self.tipImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        if (IS_IPAD) {
            self.tipImageView.image = [ImageUtil loadResourceImage:@"ipad help"];
        }
        else
        {
            if ([ZBCommonMethod currentResolution]==UIDevice_iPhoneTallerHiRes) {
                self.tipImageView.image = [ImageUtil loadResourceImage:@"i5 help"];
                
            }
            else
            {
                self.tipImageView.image = [ImageUtil loadResourceImage:@"i4 help"];
                
            }
        }
        [self.view addSubview:self.tipImageView];
        self.tipImageView.userInteractionEnabled = YES;
        self.tipImageView.tag = 1888;
        
        UITapGestureRecognizer *_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self.tipImageView addGestureRecognizer:_tapGesture];
    }
    [tap.view removeFromSuperview];
}

#pragma mark - actions
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onShare:(id)sender {
//    [[AdmobViewController shareAdmobVC] recordValidUseCount];
    
    [ShareService defaultService].delegate = self;
    [[ShareService defaultService] saveToAlbumn:self.processingImage];
    NSArray  *apparray= [[NSBundle mainBundle]loadNibNamed:@"PopShareView" owner:nil options:nil];
    PopShareView *shareView = (PopShareView *)[apparray firstObject];
    shareView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:shareView];
    
    NSArray *constraints_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[shareView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(shareView)];
    NSArray *constraints_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[shareView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(shareView)];
    
    [self.view addConstraints:constraints_H];
    [self.view addConstraints:constraints_V];
    [self.view layoutIfNeeded];
    
    ShareView *shareContentView = [[ShareView alloc] initWithFrame:shareView.shareContentView.bounds];
    [shareContentView setupSubView];
    shareContentView.delegate = self;
    [shareView.shareContentView addSubview:shareContentView];
    _popShareView = shareView;
    
    [shareView show];
}
- (IBAction)onUndo:(id)sender {
    
    HistoryFrame *item = (HistoryFrame *)[self.historyFrames getUndoObject];
    
    [self useHistoryFrame:item];
    
    [self updateUndoRedo];
}
- (IBAction)onRedo:(id)sender {
    HistoryFrame *item = (HistoryFrame *)[self.historyFrames getRedoObject];

    [self useHistoryFrame:item];
    
    [self updateUndoRedo];
}
- (IBAction)onThinFace:(id)sender {
    if (self.mode == kModeAutoThinFace) {
        return;
    }
    if (![self faceFeatureUsable:self.originalImage]) {
        [self.view makeToast:NSLocalizedString(@"FACE_NOT_DETECT_MSG_THIN_FACE", @"") duration:2.0 position:@"center"];
        return;
    }

    [self.defaultThinner makeCurrentMapKeyFrame];
    self.mode = kModeAutoThinFace;
    self.strenghtSlider.selectedValue = 0.0;
    [self updateUndoRedo];
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.mode forKey:@"slim-mode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)onThinHead:(id)sender {
    if (self.mode == kModeAutoThinHead) {
        return;
    }
    if (![self faceFeatureUsable:self.originalImage]) {
        [self.view makeToast:NSLocalizedString(@"FACE_NOT_DETECT_MSG_THIN_HEAD", @"") duration:2.0 position:@"center"];
        return;
    }
    
    [self.defaultThinner makeCurrentMapKeyFrame];
    self.mode = kModeAutoThinHead;
    self.strenghtSlider.selectedValue = 0.0;

    [self updateUndoRedo];
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.mode forKey:@"slim-mode"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (IBAction)onThinFigure:(id)sender {
    if (self.mode == kModeSlim) {
        return;
    }
    [self.defaultThinner makeCurrentMapKeyFrame];
    self.mode = kModeSlim;
    self.strenghtSlider.selectedValue = 0.0;

    [self updateUndoRedo];

    [[NSUserDefaults standardUserDefaults] setInteger:self.mode forKey:@"slim-mode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)onManual:(id)sender {
    if (self.mode == kModeFreeStyle) {
        return;
    }
    [self.defaultThinner makeCurrentMapKeyFrame];
    self.mode = kModeFreeStyle;
    [self updateUndoRedo];
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.mode forKey:@"slim-mode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)onReset:(id)sender {
    
    [self.historyFrames reset];
    [self useHistoryFrame:(HistoryFrame *)[self.historyFrames getTopObject]];
    [self updateUndoRedo];
}

- (IBAction)onCompareDown:(id)sender {
    self.canvasView.image = self.originalImage;
}
- (IBAction)onCompareUp:(id)sender {
    self.canvasView.image = self.processingImage;
}

- (void)strenghtValueChanged:(id)sender {
    if (self.mode != kModeNone)
    {
//        if (self.mode == kModeAutoThinFace)
        {
            [MBProgressHUD showSharedHUDInView:self.view];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *image = [self processImage];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (image) {
                        self.processingImage = image;
                        self.canvasView.image = self.processingImage;
                        [MBProgressHUD hideSharedHUD];
                        
                        [self makeAndPushHistoryFrame];
                        
                        [self updateUndoRedo];
                    }
                    else
                    {
                        [MBProgressHUD hideSharedHUD];
                    }
                });
            });
        }
    }
}

-(void)radiusValueChanged:(id)sender
{
    self.canvasView.radius = [self.radiusArray[self.radiusSlider.selectedValue-self.radiusSlider.minValue] floatValue];
}

-(UIImage *)processImage
{
    UIImage *image;
    LuxandLandmark *realLandmark = [self.faceLandmark copy];
    NSArray *points = [self.faceLandmark usedLandmarks];
    NSArray *realPoints = [self.defaultThinner applyPoints:points];
    if (realPoints) {
        [realLandmark setUsedLandmarks:realPoints];
    }
    
    switch (self.mode) {
        case kModeAutoThinFace:
        {
            image = [self.defaultThinner translateFromStartPoint1:realLandmark.contourLeft6 toEndPoint1:realLandmark.noseTip withRadius1:[realLandmark faceContourRadius]*1.75 andFromStartPoint2:realLandmark.contourRight6 toEndPoint2:realLandmark.noseTip withRadius2:[realLandmark faceContourRadius]*1.75 andWait:YES andStrenght:self.strenghtSlider.selectedValue*0.6 andSpeedFirst:NO andDepressRadialWarp:YES];
            break;
        }
        case kModeSlim:
        {
            [self getPara];
            
            image = [self.defaultThinner translateFromStartPoint1:start1 toEndPoint1:final1 withRadius1:radius andFromStartPoint2:start2 toEndPoint2:final2 withRadius2:radius andWait:YES andStrenght:self.strenghtSlider.selectedValue andSpeedFirst:NO andDepressRadialWarp:NO];

            break;
        }
        case kModeFreeStyle:
        {
            image = [self.defaultThinner translateFromStartPoint:start1 toEndPoint:final1 withRadius:radius andWait:YES andStrenght:0.05 andSpeedFirst:NO andDepressRadialWarp:NO];
            
            break;
        }
        case kModeAutoThinHead:
        {
            image = [self.defaultThinner shrinkAtCenterPoint:[CGPointUtility pointFromPoint:[CGPointUtility pointFromPoint:realLandmark.leftEyeCenter toPoint:realLandmark.rightEyeCenter byRatio:0.5] toPoint:realLandmark.noseTip byRatio:0.5] withRadius:[realLandmark faceContourRadius]*4 andWait:YES andStrenght:self.strenghtSlider.selectedValue andSpeedFirst:NO];
//            [self.defaultThinner setStrenght:self.strenghtSlider.selectedValue];
//            image = [self.defaultThinner autoSmallHead:image];
//
            break;
        }
        default:
            break;
    }
//    switch (self.mode) {
//        case kModeAutoThinFace:
//        {
//            [self.defaultThinner setStrenght:self.strenghtSlider.selectedValue];
//            image = [self.defaultThinner autoThinFace:image];
//            break;
//        }
//        case kModeSlim:
//        {
//            [self.defaultThinner setStrenght:self.strenghtSlider.selectedValue];
//            [self getPara];
//            image = [self.defaultThinner slim:image fromCenter1:start1 toFinal1:final1 withRadius1:radius andFromCenter2:start2 toFinal2:final2 withRadius2:radius];
//
//            break;
//        }
//        case kModeFreeStyle:
//        {
//            self.defaultThinner.strenght = 0.3;
//            image = [self.defaultThinner thinFace:image atCenter:start1 withRadius:radius andFinal:final1];
//
//            break;
//        }
//        case kModeAutoThinHead:
//        {
//            [self.defaultThinner setStrenght:self.strenghtSlider.selectedValue];
//            image = [self.defaultThinner autoSmallHead:image];
//
//            break;
//        }
//        default:
//            break;
//    }
    
//    image = [self drawPoints:@[[NSValue valueWithCGPoint:realLandmark.contourLeft6],
//                                        [NSValue valueWithCGPoint:realLandmark.contourRight6],
//                                        [NSValue valueWithCGPoint:realLandmark.noseTip],
//                                        [NSValue valueWithCGPoint:realLandmark.leftEyeCenter],
//                                        [NSValue valueWithCGPoint:realLandmark.rightEyeCenter],
//                                        ] InImage:image withColor:[UIColor greenColor]];
    
    return image;
}

-(UIImage *)drawPoints:(NSArray *)points InImage:(UIImage *)image withColor:(UIColor *)dotColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, image.size.width, image.size.height, 8, image.size.width*4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    CGContextSetFillColorWithColor(context, dotColor.CGColor);
    
    NSInteger dotSize = 7;
    for (NSValue *value in points) {
        CGPoint point = [value CGPointValue];
        point.y = image.size.height-point.y;
        CGContextFillEllipseInRect(context, CGRectMake(point.x-dotSize, point.y-dotSize, dotSize*2+1, dotSize*2+1));
    }
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    image = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(context);
    CGImageRelease(imageRef);
    return image;
}

-(void)makeAndPushHistoryFrame
{
    HistoryFrame *frame = [HistoryFrame new];
    
    frame.image = self.processingImage;
    frame.strenght = self.defaultThinner.strenght;
    frame.mode = self.mode;
    
    LuxandLandmark *realLandmark = [self.faceLandmark copy];
    NSArray *points = [self.faceLandmark usedLandmarks];
    NSArray *realPoints = [self.defaultThinner applyPoints:points];
    if (realPoints) {
        [realLandmark setUsedLandmarks:realPoints];
    }
    
    frame.landmark = realLandmark;
    
    [self.historyFrames pushObject:frame];
}

-(void)useHistoryFrame:(HistoryFrame *)item
{
    if (item) {
        UIImage *image = item.image;
        image = image?image:self.originalImage;
        self.processingImage = image;
        self.canvasView.image = image;
//        image = item.processedImage;
//        image = image?image:self.originalImage;
//        self.processedImage = image;
        self.mode = item.mode;
        self.strenghtSlider.selectedValue = item.strenght;
        [self.defaultThinner setSrcImage:image];
        self.faceLandmark = item.landmark;
    }
    else
    {
        self.processingImage = self.originalImage;
        self.canvasView.image = self.processingImage;
        self.strenghtSlider.selectedValue = 0.0;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.image = self.originalImage;
    _firstAppear = YES;
    
    _hasTipCurrentPhoto = [[NSMutableDictionary alloc] init];
    
    self.manualLabel.text = NSLocalizedString(@"MANUAL_WORD", @"");
    self.faceLabel.text = NSLocalizedString(@"THIN_FACE_WORD", @"");
    self.headLabel.text = NSLocalizedString(@"THIN_HEAD_WORD", @"");
    self.slimLabel.text = NSLocalizedString(@"SLIM_WORD", @"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.historyFrames reset];
    [self updateUndoRedo];
}

-(void)adjustUI
{
    if ([ZBCommonMethod isIpad]) {
        self.mainAreaTopPositionConstraint.constant = 90;
    }
    
    if (![AdUtility hasAd] && self.mainAreaTopPositionConstraint.constant!=0) {
        self.mainAreaTopPositionConstraint.constant = 0;
    }
    
    if (![AdUtility hasAd]) {
        [self.adContainer removeFromSuperview];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self adjustUI];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self adjustUI];

    if (_firstAppear) {
        [self.view layoutIfNeeded];
        [self setupViews];
        [self useImage:_originalImage];
        //处理前进后退按钮
        [self updateUndoRedo];
    }
    _firstAppear = NO;
    
    [AdUtility tryShowBannerInView:self.adContainer];
}

-(void)doShareFromView:(UIView *)view
{
    NSString *textToShare = NSLocalizedString(@"SHARE_TEXT", @"Share");
    
    UIImage *imageToShare = self.canvasView.image;
    
    NSURL *urlToShare = [NSURL URLWithString:APP_URL];
    
    NSArray *activityItems = nil;
    
    if (imageToShare != nil) {
//        activityItems = @[textToShare, urlToShare, imageToShare];
        activityItems = @[imageToShare];

    }
    else
    {
        activityItems = @[textToShare, urlToShare];
    }
    
    NSArray *applicationActivities = nil;
    NSArray *excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:applicationActivities];
    
    //不出现在活动项目
    activityVC.excludedActivityTypes = excludedActivityTypes;
    
    if ([ZBCommonMethod systemVersion]>=8.0) {
        UIActivityViewControllerCompletionWithItemsHandler handler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError){
            if (completed) {
                
                if (activityType == UIActivityTypeSaveToCameraRoll) {
                    [AdUtility tryShowInterstitialInVC:self.navigationController];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SAVED_TIP_TITLE", @"share") message:NSLocalizedString(@"SAVED_TIP_MESSAGE", @"share") delegate:self cancelButtonTitle:NSLocalizedString(@"SAVED_TIP_CANCEL", @"share") otherButtonTitles:nil];
                    [alertView show];
                }
            }
        };
        activityVC.completionWithItemsHandler = handler;
    }
    else if ([ZBCommonMethod systemVersion] >= 6.0)
    {
        UIActivityViewControllerCompletionHandler handler = ^(NSString *activityType, BOOL completed){
            if (completed) {
                
                if (activityType == UIActivityTypeSaveToCameraRoll) {
                    [AdUtility tryShowInterstitialInVC:self.navigationController];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SAVED_TIP_TITLE", @"share") message:NSLocalizedString(@"SAVED_TIP_MESSAGE", @"share") delegate:self cancelButtonTitle:NSLocalizedString(@"SAVED_TIP_CANCEL", @"share") otherButtonTitles:nil];
                    [alertView show];
                }
            }
        };
        activityVC.completionHandler = handler;
    }
    
    if ([ZBCommonMethod isIpad]) {
        self.popController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        CGRect frame = view.frame;
        frame.origin = [self.view convertPoint:frame.origin fromView:view.superview];
        [self.popController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentViewController:activityVC animated:TRUE completion:nil];
    }
}

#pragma mark -
-(void)updateBottomBtnsForMode:(BBMode)mode
{
    self.thinFaceBtn.selected = mode==kModeAutoThinFace;
    self.thinHeadBtn.selected = mode==kModeAutoThinHead;
    self.thinFigureBtn.selected = mode==kModeSlim;
    self.manualBtn.selected = mode==kModeFreeStyle;
    
    self.faceLabel.textColor = (mode==kModeAutoThinFace)?HIGHLIGHT_COLOR:[UIColor blackColor];
    self.headLabel.textColor = (mode==kModeAutoThinHead)?HIGHLIGHT_COLOR:[UIColor blackColor];
    self.slimLabel.textColor = (mode==kModeSlim)?HIGHLIGHT_COLOR:[UIColor blackColor];
    self.manualLabel.textColor = (mode==kModeFreeStyle)?HIGHLIGHT_COLOR:[UIColor blackColor];
}

-(void)updateSlidersForMode:(BBMode)mode
{
    self.strenghtSlider.hidden = mode==kModeFreeStyle;
    self.radiusSlider.hidden = mode!=kModeFreeStyle;
}

-(void)updateCanvasForMode:(BBMode)mode
{
    self.canvasView.supportInteraction = mode==kModeFreeStyle;
    self.canvasView.mode = mode==kModeFreeStyle?kCanvasModeDrag:kCanvasModeNone;
}

-(void)updateMaskViewForMode:(BBMode)mode
{
    self.maskView.hidden = mode!=kModeSlim;
}

-(void)updateUndoRedo
{
    self.undoBtn.enabled = [self.historyFrames canUndo];
    self.redoBtn.enabled = [self.historyFrames canRedo];
}

-(void) setupMaskView
{
    self.maskView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-210)*0.5, (CGRectGetHeight(self.view.frame)-210)*0.5, 210, 210)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"yao"]];
    CGRect frame;
    frame.size = imageView.image.size;
    frame.size.width /= 2;
    frame.size.height /= 2;
    imageView.center = CGPointMake(105, 105);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.maskView addSubview:imageView];
    self.yaoView = imageView;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(140, 140, 70, 70)];
    imageView.image = [UIImage imageNamed:@"curvedarrowdownl"];
    [self.maskView addSubview:imageView];
    self.rotateView = imageView;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(140, 70, 70, 70)];
    imageView.image = [UIImage imageNamed:@"straightarrowr"];
    [self.maskView addSubview:imageView];
    self.xScaleView = imageView;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 140, 70, 70)];
    imageView.image = [UIImage imageNamed:@"straightarrowdown"];
    [self.maskView addSubview:imageView];
    self.yScaleView = imageView;
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 70, 70, 70)];
    imageView.image = [UIImage imageNamed:@"straightarrowshi"];
    [self.maskView addSubview:imageView];
    self.moveView = imageView;
    
    [self.mainContentView addSubview:self.maskView];
}

- (void)loadButtons
{
    self.strenghtSlider = [[ContinousSlider alloc] initWithFrame:self.sliderContainer.bounds andTitle:nil andMinValue:0.0 andMaxValue:0.08 andNormalColor:NORMAL_COLOR andHighlightColor:HIGHLIGHT_COLOR andPointerImage:[UIImage imageNamed:@"thumb"]];
    self.strenghtSlider.instanceValueChanged = NO;
    [self.strenghtSlider addTarget:self action:@selector(strenghtValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.sliderContainer addSubview:self.strenghtSlider];
    
    self.radiusSlider = [[DiscreteSlider alloc] initWithFrame:self.sliderContainer.bounds andMinValue:1 andMaxValue:5 andNormalColor:NORMAL_COLOR andHighlightColor:HIGHLIGHT_COLOR andPointerImages:@[[UIImage imageNamed:@"thumb_1"],[UIImage imageNamed:@"thumb_2"],[UIImage imageNamed:@"thumb_3"],[UIImage imageNamed:@"thumb_4"],[UIImage imageNamed:@"thumb_5"]]];
    [self.radiusSlider addTarget:self action:@selector(radiusValueChanged:) forControlEvents:UIControlEventValueChanged];

    [self.sliderContainer addSubview:self.radiusSlider];
    
}
// 假设人是直立的
-(void) shapeMaskView
{
    //？_faceDetectEnd应该总为true吧
    if (_faceDetectEnd == NO) {
        return;
    }
    if (self.faceLandmark.resultValid) {
        
        CGRect imageRect = CGRectZero;
        //canvasView从相册选择的图片
        imageRect.size = self.canvasView.imageView.image.size;
        
        CGPoint noseTipPoint = self.faceLandmark.noseTip;//获取鼻子的点坐标
        //修改鼻子坐标
        noseTipPoint = [CGRectCGPointUtility imageViewConvertPoint:noseTipPoint fromImageRect:imageRect toViewRect:self.canvasView.imageView.bounds];
        
        CGRect faceRect = [CGRectCGPointUtility imageViewConvertRect:[self.faceLandmark getFaceRect] fromImageRect:imageRect toViewRect:self.canvasView.imageView.bounds];
        
        //mask？面罩？
        CGPoint maskCenter = noseTipPoint;
        maskCenter.y += faceRect.size.height*4;
        
        if (maskCenter.y+20 >= self.maskView.superview.frame.size.height) {
            maskCenter.y = self.maskView.superview.frame.size.height-20;
        }
        //修剪框
        //根据给定的纵横比和容器矩形，计算并返回一个新的矩形，使得该矩形在容器内保持纵横比不变，并尽可能填充或适应容器。
        CGRect clipFrame = AVMakeRectWithAspectRatioInsideRect(self.originalImage.size, self.canvasView.bounds);
        clipFrame = [self.mainContentView convertRect:clipFrame fromView:self.canvasView];
        maskCenter.x = MAX(MIN(CGRectGetMaxX(clipFrame), maskCenter.x), CGRectGetMinX(clipFrame));
        maskCenter.y = MAX(MIN(CGRectGetMaxY(clipFrame), maskCenter.y), CGRectGetMinY(clipFrame));
        
        CGFloat yaoWidth = MIN(faceRect.size.width*3, CGRectGetWidth(self.maskView.superview.bounds));
        CGFloat rateWidth = yaoWidth/self.yaoView.frame.size.width;
        CGFloat yaoHeight = faceRect.size.height*4 ;
        CGFloat rateHeight = yaoHeight/self.yaoView.frame.size.height;
        
        CGAffineTransform transform = self.yaoView.transform;
        transform = CGAffineTransformScale(transform, rateWidth, rateHeight);
        self.yaoView.transform = transform;
        
        transform = self.maskView.transform;
        self.maskView.transform = CGAffineTransformIdentity;
        self.maskView.center = maskCenter;
        self.maskView.transform = transform;
        
    }
}

-(void)getPara
{
    CGRect imageRect = CGRectZero;
    imageRect.size = self.canvasView.imageView.image.size;
    
    radius = self.yaoView.frame.size.height;
    
    final1 = [self.canvasView.imageView convertPoint:self.yaoView.center fromView:self.maskView];
    final2 = final1;
    
    
    start1 = self.yaoView.frame.origin;
    start1.y += self.yaoView.frame.size.height/2.0;
    start1 = [self.canvasView.imageView convertPoint:start1 fromView:self.maskView];
    
    start2 = self.yaoView.frame.origin;
    start2.x += self.yaoView.frame.size.width;
    start2.y += self.yaoView.frame.size.height/2.0;
    start2 = [self.canvasView.imageView convertPoint:start2 fromView:self.maskView];
    
    NSLog(@"radius: %f", radius);
    NSLog(@"final1: (%f, %f)", final1.x, final1.y);
    NSLog(@"final2: (%f, %f)", final2.x, final2.y);
    NSLog(@"start1: (%f, %f)", start1.x, start1.y);
    NSLog(@"start2: (%f, %f)", start2.x, start2.y);
    
    start2 = [CGRectCGPointUtility imageViewConvertPoint:start2 fromViewRect:self.canvasView.imageView.frame toImageRect:imageRect];
    start1 = [CGRectCGPointUtility imageViewConvertPoint:start1 fromViewRect:self.canvasView.imageView.frame toImageRect:imageRect];
    radius = [CGRectCGPointUtility imageViewConvertLength:radius fromViewRect:self.canvasView.imageView.frame toImageRect:imageRect];
    final1 = [CGRectCGPointUtility imageViewConvertPoint:final1 fromViewRect:self.canvasView.imageView.frame toImageRect:imageRect];
    final2 = [CGRectCGPointUtility imageViewConvertPoint:final2 fromViewRect:self.canvasView.imageView.frame toImageRect:imageRect];
    
    NSLog(@"radius: %f", radius);
    NSLog(@"final1: (%f, %f)", final1.x, final1.y);
    NSLog(@"final2: (%f, %f)", final2.x, final2.y);
    NSLog(@"start1: (%f, %f)", start1.x, start1.y);
    NSLog(@"start2: (%f, %f)", start2.x, start2.y);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"%s", __FUNCTION__);
    NSInteger count = [[[event allTouches] allObjects] count];
    selectedOper = 0;
    if (count == 1) {
        UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
        CGPoint point = [mytouch locationInView:self.maskView];
        
        if (CGRectContainsPoint(self.moveView.frame, point)) {
            selectedOper = 1;
        }
        else if (CGRectContainsPoint(self.xScaleView.frame, point)) {
            selectedOper = 2;
        }
        else if (CGRectContainsPoint(self.yScaleView.frame, point)) {
            selectedOper = 3;
        }
        else if (CGRectContainsPoint(self.rotateView.frame, point)) {
            selectedOper = 4;
        }
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    NSLog(@"%s", __FUNCTION__);
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    CGPoint point = [mytouch locationInView:self.view];
    CGPoint lastPoint = [mytouch previousLocationInView:self.view];
    
    switch (selectedOper) {
        case 1:
        {
//            CGAffineTransform transform = self.maskView.transform;
//            self.maskView.transform = CGAffineTransformIdentity;
//            self.maskView.frame = CGRectOffset(self.maskView.frame, point.x-lastPoint.x, point.y-lastPoint.y);
//            self.maskView.transform = transform;
            
            CGPoint center = self.maskView.center;
            
            center.x += point.x-lastPoint.x;
            center.y += point.y-lastPoint.y;
            
            CGRect clipFrame = AVMakeRectWithAspectRatioInsideRect(self.originalImage.size, self.canvasView.bounds);
            clipFrame = [self.mainContentView convertRect:clipFrame fromView:self.canvasView];
            center.x = MAX(MIN(CGRectGetMaxX(clipFrame), center.x), CGRectGetMinX(clipFrame));
            center.y = MAX(MIN(CGRectGetMaxY(clipFrame), center.y), CGRectGetMinY(clipFrame));
            
            self.maskView.center = center;
            break;
        }
        case 2:
        {
            CGPoint center = self.maskView.center;
            CGFloat lastDistance = sqrt((center.x-lastPoint.x)*(center.x-lastPoint.x)+(center.y-lastPoint.y)*(center.y-lastPoint.y));
            CGFloat distance = sqrt((center.x-point.x)*(center.x-point.x)+(center.y-point.y)*(center.y-point.y));
            
            CGAffineTransform transform = self.yaoView.transform;
            transform = CGAffineTransformScale(transform, distance/lastDistance, 1.0);
            self.yaoView.transform = transform;
            
            //            CGRect frame = self.yaoView.frame;
            //            NSLog(@"frame: (%f, %f, %f, %f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            //            frame = self.yaoView.bounds;
            //            NSLog(@"bound: (%f, %f, %f, %f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            //            point = CGPointMake(50, 50);
            //            point = [self.canvasView convertPoint:point fromView:self.yaoView];
            //            NSLog(@"point: (%f, %f)", point.x, point.y);
            break;
        }
        case 3:
        {
            CGPoint center = self.maskView.center;
            CGFloat lastDistance = sqrt((center.x-lastPoint.x)*(center.x-lastPoint.x)+(center.y-lastPoint.y)*(center.y-lastPoint.y));
            CGFloat distance = sqrt((center.x-point.x)*(center.x-point.x)+(center.y-point.y)*(center.y-point.y));
            
            CGAffineTransform transform = self.yaoView.transform;
            transform = CGAffineTransformScale(transform, 1.0, distance/lastDistance);
            self.yaoView.transform = transform;
            break;
        }
        case 4:
        {
            CGPoint center = self.maskView.center;
            CGFloat lastDistance = sqrt((center.x-lastPoint.x)*(center.x-lastPoint.x)+(center.y-lastPoint.y)*(center.y-lastPoint.y));
            CGFloat distance = sqrt((center.x-point.x)*(center.x-point.x)+(center.y-point.y)*(center.y-point.y));
            
            CGPoint vector = CGPointMake(point.x-center.x, point.y-center.y);
            CGPoint lastVector = CGPointMake(lastPoint.x-center.x, lastPoint.y-center.y);
            
            CGFloat cosinA = vector.x/distance;
            CGFloat A = acos(cosinA);
            CGFloat cosinB = lastVector.x/lastDistance;
            CGFloat B = acos(cosinB);
            CGAffineTransform transform = self.maskView.transform;
            transform = CGAffineTransformRotate(transform, A-B);
            self.maskView.transform = transform;
            NSLog(@"cosinA: %f, A: %f, cosinB: %f, B: %f", cosinA, A, cosinB, B);
            if (A>B) {
                A=A;
            }
            
            CGRect frame = self.yaoView.frame;
            NSLog(@"frame: (%f, %f, %f, %f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            frame = self.yaoView.bounds;
            NSLog(@"bound: (%f, %f, %f, %f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
            point = CGPointMake(50, 50);
            point = [self.canvasView convertPoint:point fromView:self.maskView];
            NSLog(@"point: (%f, %f)", point.x, point.y);
            break;
        }
        default:
            break;
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (selectedOper) {
        [self.defaultThinner makeCurrentMapKeyFrame];
        self.strenghtSlider.selectedValue = 0.0;
    }
    selectedOper = 0;
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    selectedOper = 0;
}

#pragma mark - canvas view delegate

-(void)touchEndWithEndPointInImage:(CGPoint)endPoint andStartPointInImage:(CGPoint)startPoint
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        CGFloat scale = [self.canvasView getImageViewScale];

        radius = [self.radiusArray[self.radiusSlider.selectedValue-self.radiusSlider.minValue] floatValue]*sqrt(scale)*2;
        start1 = startPoint;
        final1 = endPoint;
        
        self.canvasView.userInteractionEnabled = NO;
        UIImage *image = [self processImage];

        if (image) {
            self.processingImage = image;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.canvasView.image = image;
                [self makeAndPushHistoryFrame];
                [self.defaultThinner makeCurrentMapKeyFrame];
                [self updateUndoRedo];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.canvasView.userInteractionEnabled = YES;
        });
    });
}

#pragma mark - ImageWraperDatasource
-(BOOL)faceFeatureUsable:(UIImage *)image
{
    return self.faceLandmark.resultValid;
}
-(BOOL)accurateFaceFeatureUsable:(UIImage *)image
{
    return (self.faceLandmark.resultSource==LandmarkSourceFacePP);
}
-(CGPoint)leftEyeCenterForImage:(UIImage *)image
{
    return self.faceLandmark.leftEyeCenter;
}

-(CGPoint)leftEyeLeftForImage:(UIImage *)image
{
    return self.faceLandmark.leftEyeLeft;
}
-(CGPoint)leftEyeBottomForImage:(UIImage *)image
{
    return self.faceLandmark.leftEyeBottom;
}
-(CGPoint)leftEyeRightForImage:(UIImage *)image
{
    return self.faceLandmark.leftEyeRight;
}
-(CGPoint)leftEyeTopForImage:(UIImage *)image
{
    return self.faceLandmark.leftEyeTop;
}

-(CGPoint)rightEyeCenterForImage:(UIImage *)image
{
    return self.faceLandmark.rightEyeCenter;
}
-(CGPoint)rightEyeLeftForImage:(UIImage *)image
{
    return self.faceLandmark.rightEyeLeft;
}
-(CGPoint)rightEyeBottomForImage:(UIImage *)image
{
    return self.faceLandmark.rightEyeBottom;
}
-(CGPoint)rightEyeRightForImage:(UIImage *)image
{
    return self.faceLandmark.rightEyeRight;
}
-(CGPoint)rightEyeTopForImage:(UIImage *)image
{
    return self.faceLandmark.rightEyeTop;
}

-(CGRect)faceRectForImage:(UIImage *)image
{
    return [self.faceLandmark getFaceRect];
}

-(CGPoint)noseTipForImage:(UIImage *)image
{
    return self.faceLandmark.noseTip;
}

-(CGPoint)faceContourLeft1ForImage:(UIImage *)image
{
    return self.faceLandmark.contourLeft1;
}
-(CGPoint)faceContourLeft2ForImage:(UIImage *)image
{
    return self.faceLandmark.contourLeft2;
}
-(CGPoint)faceContourLeft3ForImage:(UIImage *)image
{
    return self.faceLandmark.contourLeft3;
}
-(CGPoint)faceContourLeft4ForImage:(UIImage *)image
{
    return self.faceLandmark.contourLeft4;
}
-(CGPoint)faceContourLeft5ForImage:(UIImage *)image
{
    return self.faceLandmark.contourLeft5;
}
-(CGPoint)faceContourLeft6ForImage:(UIImage *)image
{
    return self.faceLandmark.contourLeft6;
}
-(CGPoint)faceContourLeft7ForImage:(UIImage *)image
{
    return self.faceLandmark.contourLeft7;
}
-(CGPoint)faceContourLeft8ForImage:(UIImage *)image
{
    return self.faceLandmark.contourLeft8;
}
-(CGPoint)faceContourLeft9ForImage:(UIImage *)image
{
    return self.faceLandmark.contourLeft9;
}
-(CGPoint)faceContourRight1ForImage:(UIImage *)image
{
    return self.faceLandmark.contourRight1;
}
-(CGPoint)faceContourRight2ForImage:(UIImage *)image
{
    return self.faceLandmark.contourRight2;
}
-(CGPoint)faceContourRight3ForImage:(UIImage *)image
{
    return self.faceLandmark.contourRight3;
}
-(CGPoint)faceContourRight4ForImage:(UIImage *)image
{
    return self.faceLandmark.contourRight4;
}
-(CGPoint)faceContourRight5ForImage:(UIImage *)image
{
    return self.faceLandmark.contourRight5;
}
-(CGPoint)faceContourRight6ForImage:(UIImage *)image
{
    return self.faceLandmark.contourRight6;
}
-(CGPoint)faceContourRight7ForImage:(UIImage *)image
{
    return self.faceLandmark.contourRight7;
}
-(CGPoint)faceContourRight8ForImage:(UIImage *)image
{
    return self.faceLandmark.contourRight8;
}
-(CGPoint)faceContourRight9ForImage:(UIImage *)image
{
    return self.faceLandmark.contourRight9;
}

-(CGPoint)faceContourChinForImage:(UIImage *)image
{
    return self.faceLandmark.contourChin;
}

#pragma mark - ShareViewDelegate

-(void)shareView:(ShareView *)shareView shareImageToPlatform:(ZBShareType)shareType
{
    [_popShareView hide];
    
    [[ShareService defaultService] setDelegate:self];
    [[ShareService defaultService] showShareToPlatForm:shareType inVC:self fromView:shareView title:[[ShareService defaultService] getShareTitle] content:[[ShareService defaultService] getShareContent] image:self.processingImage];
}

#pragma mark - share service delegate
-(void)shareServiceDidEndShare:(ShareService *)shareService shareType:(ZBShareType)shareType result:(ShareServiceResult)resultCode
{
    NSString *message = [[ShareService defaultService] getResultTipMessageWithShareType:shareType andResult:resultCode];
    
    if (message != nil) {
        [self.view makeToast:message duration:2.0 position:@"center"];
    }
}

-(void)shareServiceDidEndSave:(ShareService *)shareService result:(ShareServiceResult)resultCode
{
    if (resultCode == kShareServiceSuccess) {
        [self.view makeToast:NSLocalizedStringFromTable(@"SHARE_SAVED", @"share", @"") duration:2.0 position:@"center"];
    }
}

#pragma mark -
-(void)dealloc
{
    
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
