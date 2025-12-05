//
//  ViewController.m
//  Make_Me_Thin
//
//  Created by ZB_Mac on 16/3/7.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "HomeViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Rotation.h"
#import "ZBCommonDefine.h"
#import "AdUtility.h"
#import "MBProgressHUD.h"
#import "AdUtility.h"
#import "Admob.h"
#import "MainViewController.h"
#import "ZBHelpViewController.h"
#import "SettingViewController.h"
#import "PurchaseViewController.h"
#import "FakeLanchWindow.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>

@interface HomeViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImage *_originalImage;
}
@property (weak, nonatomic) IBOutlet UIView *adContainer;
@property (weak, nonatomic) IBOutlet UIButton *purchaseBtn;

@property (weak, nonatomic) IBOutlet UILabel *helpLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UILabel *cameraLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@end

@implementation HomeViewController
- (IBAction)onAlbum:(id)sender {
    [self loadPhotoFromAlbum];
}
- (IBAction)onCamera:(id)sender {
    [self loadPhotoFromCamera];
}
- (IBAction)onFeedback:(id)sender {
    [[[AdmobViewController shareAdmobVC] rtService] showRT:self];
}
- (IBAction)onSetting:(id)sender {
    SettingViewController *settingVC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:settingVC animated:YES];
    
}
- (IBAction)onHelp:(id)sender {
    ZBHelpViewController *_helpVC = [[ZBHelpViewController alloc] init];
    [self presentViewController:_helpVC animated:YES completion:nil];
}
- (IBAction)onPurchase:(id)sender {
    PurchaseViewController *purchaseVC = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:[NSBundle mainBundle]];
    [self presentViewController:purchaseVC animated:YES completion:nil];
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
                 alert.strContent = @"n the process of using this app, you will be asked to take or provide some photos. In some use case, we need upload those photo to our server, and use algorithm to detect and analysis the faces on them. And after that, we use the result data to gauide the image processing. In this procedure, we are not store any photo or result data on our server, or send them to any third party. When we finish face detection on server, any related information will be immediately deleted. If you have any questions, please contact us with email wliuliu66@163.com\n\nBy click Agree button below means that you know this procedure and allow us to upload face photo to our server when you using this app.";
               
               [alert showAlert:self cancelAction:^(id  _Nullable object) {
                   //不同意
                   [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"firstLaunch"];
                   [self exitApplication];
               } privateAction:^(id  _Nullable object) {
                       //   输入项目的隐私政策的 URL
                       SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://fruitcasino.online/support/wangliu/bodyslim/policy.html"]];
                       //sfVC.delegate = self;
                       [self presentViewController:sfVC animated:YES completion:nil];
    //        [self pushWebController:[YSCommonWebUrl userAgreementsUrl] isLoadOutUrl:NO title:@"用户协议"];
               } delegateAction:^(id  _Nullable object) {
                   NSLog(@"用户协议");
                       //   输入项目的隐私政策的 URL
                       SFSafariViewController *sfVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"https://fruitcasino.online/support/wangliu/bodyslim/policy.html"]];
                       //sfVC.delegate = self;
                       [self presentViewController:sfVC animated:YES completion:nil];
               }
               ];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //获取用户编辑之后的图像
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        _originalImage = [image rotateAndScaleWithMaxSize:MEDIUM_RESOLUTION];
        [picker dismissViewControllerAnimated:YES completion:^{
            [AdUtility tryShowInterstitialInVC:self.navigationController];
            [self performSegueWithIdentifier:@"gotoEdit" sender:self];
        }];
        
        [[AdmobViewController shareAdmobVC] checkConfigUD];
    }
    else
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

-(void)loadPhotoFromAlbum
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
    pickerController.allowsEditing = NO;
    pickerController.delegate = self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

-(void)loadPhotoFromCamera
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
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
    pickerController.allowsEditing = NO;
    
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        pickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    else
    {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            pickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        }
    }
    pickerController.delegate = self;
    
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark -
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIViewController *VC = segue.destinationViewController;
    NSString *identifier = segue.identifier;
    
    if ([VC isKindOfClass:[MainViewController class]] && [identifier isEqualToString:@"gotoEdit"]) {
        MainViewController *mainVC = (MainViewController *)VC;
        mainVC.originalImage = _originalImage;
        _originalImage = nil;
    }
}
#pragma mark -
- (void)loadView
{
    [super loadView];
    if ([AdUtility hasAd]) {
        _fakeLanchWindow = [[FakeLanchWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_fakeLanchWindow setPreController:self];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self firstProtocolAlter];
    
    BOOL shown = [[AdmobViewController shareAdmobVC] ifNeedShowNext:self];
    if(!shown) {
        shown = [[AdmobViewController shareAdmobVC] decideShowRT:self];
    }
    
    if (!shown && [AdUtility hasAd]) {
        [_fakeLanchWindow makeKeyAndVisible];
    }
    
    self.albumLabel.text = NSLocalizedString(@"ALBUM", @"");
    self.cameraLabel.text = NSLocalizedString(@"CAMERA", @"");
    self.feedbackLabel.text = NSLocalizedString(@"FEEDBACK", @"");
    self.helpLabel.text = NSLocalizedString(@"HELP", @"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.purchaseBtn.hidden = ![AdUtility hasAd];
}

- (void)viewDidAppear:(BOOL)animated {
    [AdUtility tryShowBannerInView:self.adContainer];
}
@end
