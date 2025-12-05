//
//  CameraViewController.m
//  Meitu
//
//  Created by ZB_Mac on 15-4-9.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "CameraViewController.h"
#import "GPUImage.h"
#import "ZBCommonMethod.h"
#import "UIImage+Rotation.h"
#import <CoreMotion/CoreMotion.h>
#import "Masonry.h"

#define MOTION_UPDATE_INTERVAL 0.2
#define ORIENTATION_UPDATE_INTERVAL 0.2
#define ANIMATION_DURATION 0.2

@interface CameraViewController ()<GPUImageVideoCameraDelegate>
{
    CGFloat matchSizeRatio;
}

@property (weak, nonatomic) IBOutlet UIView *topBar;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIView *mainArea;
@property (weak, nonatomic) IBOutlet UIView *subBottomBar;

@property (strong, nonatomic) UIButton *cameraBtn;
@property (strong, nonatomic) UIButton *flashBtn;
@property (strong, nonatomic) UIButton *shotBtn;
@property (strong, nonatomic) UIButton *closeBtn;

@property (strong, nonatomic) GPUImageVideoCamera *camera;
@property (strong, nonatomic) GPUImageView *cameraView;
@property (strong, nonatomic) GPUImageView *colorCameraView;
@property (strong, nonatomic) GPUImageAverageColor *averageFilter;
@property (strong, nonatomic) GPUImageCropFilter *cropFilter;
@property (strong, nonatomic) GPUImageSolidColorGenerator *generator;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *cameraTipView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    matchSizeRatio = 0.5;

    [self loadContent];
    
    [self setupBars];
    
    CGFloat width = CGRectGetWidth(self.mainArea.bounds);
    CGFloat height = CGRectGetHeight(self.mainArea.bounds);
    
    self.cameraTipView = [[UIView alloc] initWithFrame:CGRectMake(width*(1.0-matchSizeRatio)/2.0, (height-width*matchSizeRatio)/2.0, width*matchSizeRatio, width*matchSizeRatio)];
    self.cameraTipView.backgroundColor = [UIColor clearColor];
    self.cameraTipView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.cameraTipView.layer.borderWidth = 2.0;
    [self.mainArea addSubview:self.cameraTipView];

    [self.cameraTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.mainArea);
        make.width.equalTo(self.mainArea.mas_width).multipliedBy(matchSizeRatio);
        make.height.equalTo(self.mainArea.mas_width).multipliedBy(matchSizeRatio);
    }];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width*matchSizeRatio, width*matchSizeRatio/3.0)];
    label.center = CGPointMake(CGRectGetMidX(self.cameraTipView.bounds), CGRectGetMidY(self.cameraTipView.bounds));
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize:CGRectGetHeight(label.bounds)*0.45];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textColor = [UIColor whiteColor];
    label.text = @"MATCH AREA";
    [self.cameraTipView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cameraTipView);
    }];
}

-(void)setupBars
{
    UIButton *button;
    UIView *container;
    UIButton *sButton;
    // top bar

    // bottom bar
    container = [self.bottomBar viewWithTag:100];
    button = [[UIButton alloc] initWithFrame:container.bounds];
    [button setImage:[UIImage imageNamed:@"btn_camera_capture_normal"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(shotBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    self.shotBtn = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container);
    }];
    
    container = [self.bottomBar viewWithTag:101];
    button = [[UIButton alloc] initWithFrame:container.bounds];
    [button setImage:[UIImage imageNamed:@"btn_camera_close_white"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:button];
    self.closeBtn = button;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container);
    }];
    
    // sub bottom bar
    container = [self.subBottomBar viewWithTag:100];
    sButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sButton.frame = container.bounds;
    [sButton setTitle:NSLocalizedStringFromTable(@"RETAKE_PHOTO", @"camera", @"camera") forState:UIControlStateNormal];
    [sButton addTarget:self action:@selector(retakeBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:sButton];
    [sButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container);
    }];
    
    container = [self.subBottomBar viewWithTag:101];
    sButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sButton.frame = container.bounds;
    [sButton setTitle:NSLocalizedStringFromTable(@"USE_PHOTO", @"camera", @"camera") forState:UIControlStateNormal];
    [sButton addTarget:self action:@selector(useImageBtnHandler:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:sButton];
    [sButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container);
    }];
    
    self.subBottomBar.hidden = YES;
}

-(void)loadContent
{
    AVCaptureDevicePosition cameraPosition = AVCaptureDevicePositionBack;
    
    if ([GPUImageVideoCamera isBackFacingCameraPresent] == NO) {
        if ([GPUImageVideoCamera isFrontFacingCameraPresent] == NO) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTable(@"NO_CAMERA_TITLE", @"camera", "No Camera alert") message:NSLocalizedStringFromTable(@"NO_CAMERA_MESSAGE", @"camera", @"No Camera alert") delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"OK", @"camera", @"") otherButtonTitles:nil];
            [alertView show];
            return;
        }
        else
        {
            cameraPosition = AVCaptureDevicePositionFront;
        }
    }
    
    CGFloat presetWidth, presetHeight;
    if ([ZBCommonMethod currentResolution] == UIDevice_iPhoneStandardRes || [ZBCommonMethod currentResolution] == UIDevice_iPhoneHiRes) {
        self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:cameraPosition];
        presetWidth = 480.0;
        presetHeight = 640.0;
    }
    else{
        self.camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:cameraPosition];
        presetWidth = 720.0;
        presetHeight = 1280.0;
    }
    
    self.camera.delegate = self;
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.camera.horizontallyMirrorFrontFacingCamera = YES;
    
    self.cameraView = [[GPUImageView alloc] initWithFrame:self.mainArea.bounds];
    self.cameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    [self.camera addTarget:self.cameraView];
    
    [self.mainArea addSubview:self.cameraView];
    
    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.mainArea);
    }];
    
    self.colorCameraView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.mainArea.bounds)*0.3, CGRectGetWidth(self.mainArea.bounds)*0.3)];
    [self.mainArea addSubview:self.colorCameraView];
    [self.colorCameraView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.mainArea);
        make.width.equalTo(self.mainArea).multipliedBy(0.3);
        make.height.equalTo(self.mainArea).multipliedBy(0.3);
    }];
    
    self.colorCameraView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;

    self.averageFilter = [[GPUImageAverageColor alloc] init];
    CGFloat matchHeightRatio = matchSizeRatio*presetWidth/presetHeight;
    
    self.cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake((1.0-matchSizeRatio)/2.0, (1.0-matchHeightRatio)/2.0, matchSizeRatio, matchHeightRatio)];
    
    [self.camera addTarget:self.cropFilter];
    [self.cropFilter addTarget:self.averageFilter];
    
    GPUImageSolidColorGenerator *colorGenerator = [[GPUImageSolidColorGenerator alloc] init];
    [colorGenerator forceProcessingAtSize:[self.colorCameraView sizeInPixels]];
    self.generator = colorGenerator;
    
    [self.averageFilter setColorAverageProcessingFinishedBlock:^(CGFloat redComponent, CGFloat greenComponent, CGFloat blueComponent, CGFloat alphaComponent, CMTime frameTime) {
        [colorGenerator setColorRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];
    }];
    [colorGenerator addTarget:self.colorCameraView];

    self.imageView = [[UIImageView alloc] initWithFrame:self.mainArea.bounds];
    self.imageView.hidden = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.mainArea addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.mainArea);
    }];
    [self.camera startCameraCapture];
}

-(void)shotBtnHandler:(UIButton *)button
{
    [self takeShotNow];
}

-(void)closeBtnHandler:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(cameraVCDidCancel:)]) {
            [self.delegate cameraVCDidCancel:self];
        }
    }];
}

-(void)retakeBtnHandler:(UIButton *)button
{
    self.topBar.hidden = NO;
    self.bottomBar.hidden = NO;
    self.subBottomBar.hidden = YES;
    [self.camera resumeCameraCapture];
    self.imageView.hidden = YES;
    self.cameraTipView.hidden = NO;
}

-(void)useImageBtnHandler:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(cameraVC:didFinishWithColor:)]) {
            [self.delegate cameraVC:self didFinishWithColor:self.imageView.backgroundColor];
        }
    }];
}

-(void)takeShotNow
{
//    [self.averageFilter extractAverageColorAtFrameTime:CMTimeMake(0, 100)];
    GPUVector4 color = self.generator.color;

    [self processColor:[UIColor colorWithRed:color.one green:color.two blue:color.three alpha:1.0]];
}

#pragma mark - update model
-(void)processColor:(UIColor *)color
{
    self.bottomBar.hidden = YES;
    self.subBottomBar.hidden = NO;
    [self.camera pauseCameraCapture];
    self.imageView.hidden = NO;
    self.imageView.backgroundColor = color;
    self.cameraTipView.hidden = YES;
}

#pragma mark -

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.topBar.hidden = NO;
    self.bottomBar.hidden = NO;
    self.subBottomBar.hidden = YES;
    self.imageView.hidden = YES;

    [self.camera resumeCameraCapture];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.camera pauseCameraCapture];
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
    [self.camera stopCameraCapture];
    [self.camera removeAllTargets];
    
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
