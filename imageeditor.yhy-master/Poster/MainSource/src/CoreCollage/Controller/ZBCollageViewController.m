//
//  ZBCollageViewController.m
//  Collage
//
//  Created by shen on 13-6-24.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBCollageViewController.h"
#import "ZBCommonDefine.h"
#import "ZBCollageMainView.h"
#import "BHDragView.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZBCommonMethod.h"
#import <MessageUI/MessageUI.h>
#import "ZBAppDelegate.h"
#import <AviarySDK/AviarySDK.h>
#import "Admob.h"
#import "AdUtility.h"
#import "GlobalSettingManger.h"
#import "ShareViewController.h"
#import "AssetHelper.h"
#import "SharePopupCommon.h"
@import AppLovinSDK;

@interface ZBCollageViewController ()<ZBCollageMainViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,AFPhotoEditorControllerDelegate,UIPopoverControllerDelegate>
{
    ZBCollageMainView *_collageMainView;
    CollageType _currentCollageType;
    UIButton *upgradeButton;
}

@property (atomic, strong)NSMutableArray *selectedImages;
@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (nonatomic, strong) UIPopoverController * popover;
@property (nonatomic, strong) UIView * adView;
@end

@implementation ZBCollageViewController
@synthesize selectedImages = _selectedImages;
@synthesize assetLibrary;
@synthesize selectedAssets;
@synthesize popover;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}


- (id)initWithSelectedImges:(NSArray*)imagesArray
{
    self = [super init];
    
//    return self;
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        if (nil != imagesArray) {
            _selectedImages = [[NSMutableArray alloc] init];
//            NSMutableArray *_selectedPhoto = [[NSMutableArray alloc] initWithCapacity:1];
//            for (ALAsset *asset in imagesArray) {
//                if (nil == asset || ![asset isKindOfClass:[ALAsset class]]) {
//                    break;
//                }
//                UIImage *_image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
//                [_selectedPhoto addObject:_image];
//            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                for (NSString *assetIdentifier in imagesArray) {
                    [ASSETHELPER getImageForAssetIdentifier:assetIdentifier targetSize:CGSizeZero type:ASSET_PHOTO_FULL_RESOLUTION withStartHandler:^(NSString *identifier) {
                        
                    } withCompletionHandler:^(NSString *identifier, UIImage *image) {
                        [self.selectedImages addObject:image];
                        
                        if (self.selectedImages.count == imagesArray.count)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self setupView];
                            });
                        }
                    }];
                }
            });
        }
        self.selectedAssets = [[NSMutableArray alloc] initWithArray:imagesArray];
        [ZBCommonMethod setUserSelectedAssets:imagesArray];
        _currentCollageType = CollageTypeGrid;
    }
    return self;
}

-(void)setupView
{
    ShowCollageType _showType = [ZBCommonMethod showAllCollageType];
    switch (_showType) {
        case ShowCollageTypeGrid:
            _collageMainView = [[ZBCollageMainView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) withSelectedImgesArray:self.selectedImages andCollageType:CollageTypeGrid];
            break;
        case ShowCollageTypeFree:
            _collageMainView = [[ZBCollageMainView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight) withSelectedImgesArray:self.selectedImages andCollageType:CollageTypeFree];
            break;
        case ShowCollageTypeJoin:
            _collageMainView = [[ZBCollageMainView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight) withSelectedImgesArray:self.selectedImages andCollageType:CollageTypeJoin];
            break;
        case ShowCollageTypePoster:
            _collageMainView = [[ZBCollageMainView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight) withSelectedImgesArray:self.selectedImages andCollageType:CollageTypePoster];
            break;
        case ShowCollageTypeAll:
            _collageMainView = [[ZBCollageMainView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavigationBarHeight) withSelectedImgesArray:self.selectedImages];
            break;
        default:
            break;
    }
    _collageMainView.delegate = self;
    [self.view addSubview:_collageMainView];
}

- (void)loadView
{
    [super loadView];
    
    BOOL isPaid = ![AdUtility hasAd];
    if (!isPaid) {
        float buttonSize = 45;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            buttonSize = 35;
        }
        upgradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (kSystemVersion>=7.0) {
            upgradeButton.frame = CGRectMake(kScreenWidth - buttonSize - 5, kNavBarHeight + 5, buttonSize, buttonSize);
        } else {
            upgradeButton.frame = CGRectMake(kScreenWidth - buttonSize - 5,  5, buttonSize, buttonSize);
        }
        //upgradeButton.frame = CGRectMake(kScreenWidth - buttonSize - 5, kNavBarHeight + 5, buttonSize, buttonSize);
        [upgradeButton setImage:[UIImage imageNamed:@"update-btn"] forState:UIControlStateNormal];
        [upgradeButton addTarget:self action:@selector(updateApps) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:upgradeButton];
    }
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(goToHomeView)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(handleImage)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    
    ShowCollageType _showType = [ZBCommonMethod showAllCollageType];
    switch (_showType) {
        case ShowCollageTypeGrid:
        {
            self.navigationItem.title = @"Grid";
        }
            break;
        case ShowCollageTypeFree:
        {
            self.navigationItem.title = @"Free";
        }
            break;
        case ShowCollageTypeJoin:
        {
            self.navigationItem.title = @"Join";
        }
            break;
        case ShowCollageTypePoster:
        {
            self.navigationItem.title = @"Poster";
        }
            break;
        case ShowCollageTypeAll:
        {
            float _segmentedControlWidth;
            if (IS_IPAD) {
                _segmentedControlWidth = 400;
            }
            else
                _segmentedControlWidth = 150;
            UISegmentedControl *segmentedControl=[[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, _segmentedControlWidth, 30.0f) ];
            [segmentedControl insertSegmentWithTitle:@"Grid" atIndex:0 animated:YES];
            [segmentedControl insertSegmentWithTitle:@"Free" atIndex:1 animated:YES];
            [segmentedControl insertSegmentWithTitle:@"Join" atIndex:2 animated:YES];
            [segmentedControl insertSegmentWithTitle:@"Poster" atIndex:3 animated:YES];
            segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
            segmentedControl.tintColor = [UIColor blackColor];
            [segmentedControl setSelectedSegmentIndex:0];
            segmentedControl.multipleTouchEnabled=NO;
            [segmentedControl addTarget:self action:@selector(clickSegmentAction:) forControlEvents:UIControlEventValueChanged];
            self.navigationItem.titleView = segmentedControl;

        }
            break;
        default:
            break;
    }

    
    ALAssetsLibrary * _assetLibrary = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:_assetLibrary];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editIrregularImage:) name:kIrregularEditImage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIrregularImage:) name:kIrregularChangeImage object:nil];
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        safeAreaInsets = window.safeAreaInsets;
    }
    
    CGFloat adheight = MAAdFormat.banner.adaptiveSize.height;
    self.adView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - adheight - safeAreaInsets.bottom, kScreenWidth, adheight)];
    
    [self.view addSubview:self.adView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.view bringSubviewToFront:self.adView];
    [AdUtility tryShowBannerInView:self.adView placeid:@"collagepage"];

    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    
}

-(void)updateApps
{
#ifdef ENABLE_IAP
    [[AdmobViewController shareAdmobVC] doUpgradeInApp:self product:kRemoveAd];
#endif
}

#pragma mark -- custom method
- (void)clickSegmentAction:(id)sender
{
    UISegmentedControl *_segControl = (UISegmentedControl*)sender;
    [_collageMainView turnGridAndFreeCollageViewAnimation:_segControl.selectedSegmentIndex];
}

- (void)goToHomeView
{
//    if (_pickImageView.presentView.selectedImagesDic.count>0) {
//        //        UIActionSheet *_remendActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Save images" otherButtonTitles:@"Delete images", nil];
//        //        [_remendActionSheet showInView:self.view];
//        //保存图片
//        if (self.delegate && [self.delegate respondsToSelector:@selector(returnSelectedImages:)]) {
//            [self.delegate returnSelectedImages:_pickImageView.presentView.selectedImagesDic];
//        }
//    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)handleImage
{
    //    UIActionSheet *aActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"Albums" otherButtonTitles:@"Facebook",@"Twitter",@"Email", nil];
    //    [aActionSheet showInView:self.view];
    [self share];
}

- (void)share
{
    for (UIView *aView in [_collageMainView.presentView subviews]) {
        if ([aView isKindOfClass:[BHDragView class]]) {
            [((BHDragView*)aView) hiddenDeleteButtonIcon:YES];
        }
    }

    UIImage *resultImage = [self getPuzzleImage];
    
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
        else if (screenHeight == 736)
        {
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone6+" bundle:nil];
        }else{
            mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone6+" bundle:nil];
        }
    }
    
    ShareViewController *shareVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"shareVC"];
    shareVC.originalImage = resultImage;
    shareVC.autoSave = NO;
    shareVC.hasAd = YES;
    
    BOOL show = [[AdmobViewController shareAdmobVC] decideShowRT:self];
    if(!show)///zzx0930
        [AdUtility tryShowInterstitialInVC:self.navigationController placeid:3];
    [self.navigationController pushViewController:shareVC animated:YES];
}

- (UIImage*)getPuzzleImage
{
    UIImage *_puzzleImage = nil;
    CGSize _imageSize = _collageMainView.presentView.frame.size;
    
    if (_collageMainView.currentCollageType == CollageTypeGrid) {
        // Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(_imageSize, NO, 0);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        [_collageMainView.presentView.layer renderInContext:bitmap];
    }
    else if( _collageMainView.currentCollageType == CollageTypeFree)
    {
        // Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(_collageMainView.freecollageView.bounds.size, NO, 0);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        [_collageMainView.freecollageView.layer renderInContext:bitmap];
    }
    else if (_collageMainView.currentCollageType == CollageTypeJoin)
    {
        // Create the bitmap context
        UIGraphicsBeginImageContextWithOptions(_collageMainView.joinCollageView.bounds.size, NO, 0);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        [_collageMainView.joinCollageView.layer renderInContext:bitmap];
    }
    else if(_collageMainView.currentCollageType == CollageTypePoster)
    {
        UIGraphicsBeginImageContextWithOptions(_collageMainView.posterCollageView.bounds.size, NO, 0);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        [_collageMainView.posterCollageView.layer renderInContext:bitmap];
    }
    
    _puzzleImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();    
    
    return _puzzleImage;
}

- (void)editIrregularImage:(NSNotification*)notification
{
    NSDictionary *_infoDic = [notification object];//获取到传递的对象
    UIImage *_editImage = [_infoDic valueForKey:@"IrregularEditImage"];
    
    [self editImage:_editImage];
}

- (void)changeIrregularImage:(NSNotification*)notification
{   
    NSDictionary *_infoDic = [notification object];//获取到传递的对象
    NSValue *_rectValue = [_infoDic valueForKey:@"IrregularChangeImage"];
    
    CGRect _rect = [_rectValue CGRectValue];
    [self openAlbumAnLibrary:UIImagePickerControllerSourceTypePhotoLibrary withRect:_rect];
}

#pragma mark -- BHPickImagesViewDelegate

- (void)openAlbumAnLibrary:(NSUInteger)sourceType withRect:(CGRect)rect
{
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:sourceType];
        [imagePicker setDelegate:self];
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else{
        [self presentViewControllerInPopover:rect];
    }
    //    [imagePicker release];
}

- (void)editImage:(UIImage *)image
{
    if (nil == image) {
        return;
    }
//    [self launchPhotoEditorWithImage:image highResolutionImage:image];
    [self displayEditorForImage:image];
}

- (void)changeCollageType:(CollageType)type
{
    _currentCollageType = type;
}

- (BOOL) canChangeBackground:(NSInteger)index {
    if([ShareCommon needPopup:self pagetype:Collection_Background item:index]) {
        return FALSE;
    }
    return TRUE;
}

- (BOOL)canAddSticker:(NSInteger)index {
    if([ShareCommon needPopup:self pagetype:Collection_Sticker item:index]) {
        return FALSE;
    }
    return TRUE;
}

- (BOOL) canChangeTemplate:(NSInteger)index {
    if([ShareCommon needPopup:self pagetype:Collection_Template item:index]) {
        return FALSE;
    }
    return TRUE;
}

#pragma mark - Popover Methods

- (void) presentViewControllerInPopover:(CGRect)rect
{
    
    CGRect popoverRect = rect;
    
    if (_currentCollageType == CollageTypeGrid) {
//        popoverRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width/2, rect.size.height/2);
    }
    else if(_currentCollageType == CollageTypeJoin)
    {
        popoverRect = CGRectMake(kScreenWidth/2,200,100,100);
    }
    else if(_currentCollageType == CollageTypeFree)
    {
//        popoverRect = CGRectMake(rect.origin.x+rect.size.width/2, rect.origin.y, rect.size.width, rect.size.height);
    }
//    if (_popover == nil)
//    {
//        
//        imagePickerIpad = [[UIImagePickerController alloc] init];
//        
//        _popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerIpad];
//        [_popover setDelegate:self];
//        imagePickerIpad.Delegate = self;
//        
//        imagePickerIpad.SourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
//    }
//    
//    [_popover presentPopoverFromRect:popoverRect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    
    UIPopoverController *_popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
    [_popover setDelegate:self];
    self.popover.popoverContentSize = CGSizeMake(300, 300);
    self.popover = _popover;
//    [self setShouldReleasePopover:YES];
    
    
    if (_currentCollageType == CollageTypeGrid) {
        [self.popover presentPopoverFromRect:popoverRect inView:_collageMainView.presentView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if(_currentCollageType == CollageTypeFree)
    {
        [self.popover presentPopoverFromRect:popoverRect inView:_collageMainView.freecollageView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if(_currentCollageType == CollageTypeJoin)
    {
         
        [self.popover presentPopoverFromRect:popoverRect inView:_collageMainView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if(_currentCollageType == CollageTypePoster)
    {
        [self.popover presentPopoverFromRect:popoverRect inView:_collageMainView.posterCollageView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) dismissPopoverWithCompletion:(void(^)(void))completion
{
    [self.popover dismissPopoverAnimated:YES];
    [self setPopover:nil];
    
    NSTimeInterval delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        completion();
    });
}

#pragma mark - UIImagePicker Delegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    void(^completion)(void)  = ^(void){
        
        if (nil == assetURL) {
            UIImage *_image = [info objectForKey:UIImagePickerControllerOriginalImage];
            
//            [self launchPhotoEditorWithImage:_image highResolutionImage:_image];
            [self displayEditorForImage:_image];
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:completion];
    }
    else{
        [self dismissPopoverWithCompletion:completion];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Photo Editor Launch Methods

- (void) launchEditorWithAsset:(ALAsset *)asset
{
    UIImage * editingResImage = [self editingResImageForAsset:asset];
    UIImage * highResImage = [self highResImageForAsset:asset];
    //
//    [self launchPhotoEditorWithImage:editingResImage highResolutionImage:highResImage];
    [self displayEditorForImage:highResImage];
}

#pragma mark - ALAssets Helper Methods

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

#pragma mark - Photo Editor Creation and Presentation
//- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
//{
//    // Initialize the photo editor and set its delegate
//    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
//    [photoEditor setDelegate:self];
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
//    // Present the photo editor.
//    [self presentViewController:photoEditor animated:YES completion:nil];
//}

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

#pragma mark AFPhotoEditorControllerDelegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
//    switch (_currentCollageType) {
//        case CollageTypeGrid:
//            [_collageMainView setSelectedImage:image];
//            break;
//        case CollageTypeFree:
//            [_collageMainView.freecollageView addAnNewImage:image];
//            break;
//        default:
//            break;
//    }
    [_collageMainView setSelectedImage:image];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (![AdUtility hasAd]) {
        upgradeButton.hidden = YES;
    }
    
    // Delete IAP entrance
    upgradeButton.hidden = YES;
}

#pragma mark -
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


@end
