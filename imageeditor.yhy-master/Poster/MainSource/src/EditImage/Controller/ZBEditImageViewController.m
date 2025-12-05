//
//  ZBEditImageViewController.m
//  Poster
//
//  Created by shen on 13-8-2.
//  Copyright (c) 2013年 ZBNetwork. All rights reserved.
//

#import "ZBEditImageViewController.h"
#import "ZBEditImageView.h"
#import "ZBCommonDefine.h"
#import <QuartzCore/QuartzCore.h>
#import "ShareViewController.h"
#import "AdUtility.h"
#import "AssetHelper.h"

@interface ZBEditImageViewController ()
{
    ZBEditImageView *_editImageView;
    float _adHeight;
    UIImage *_image;
}

@end

@implementation ZBEditImageViewController

- (id)initWithImage:(UIImage*)image
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        _adHeight = 0;
        _image = image;
        
        if (kSystemVersion>=7.0) {
            _editImageView = [[ZBEditImageView alloc] initWithFrame:CGRectMake(kEditImageViewLefGap, kEditImageViewTopGap+kStatusBarHeight+kNavigationBarHeight, kScreenWidth-2*kEditImageViewLefGap, kScreenHeight-2*kEditImageViewTopGap-_adHeight-kNavigationBarHeight-kStatusBarHeight)];
        }
        else
        {
            _editImageView = [[ZBEditImageView alloc] initWithFrame:CGRectMake(kEditImageViewLefGap, kEditImageViewTopGap, kScreenWidth-2*kEditImageViewLefGap, kScreenHeight-2*kEditImageViewTopGap-_adHeight-kNavigationBarHeight)];
        }
        
        [self.view addSubview:_editImageView];
//        _editImageView.imageView.image = image;
//        [self performSelector:@selector(loadImage) withObject:nil afterDelay:0.5];
        [_editImageView setImageViewWithImage:_image];
        
    }
    return self;
}

- (void)loadImage
{
    [_editImageView setImageViewWithImage:_image];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self setNeedsStatusBarAppearanceUpdate];
    [ASSETHELPER canAccessLibrary];
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];//（一定要注意，这个地方如果没有动画效果，即设为NO的话是怎么都会有黑框)
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom method

- (void)share
{
//	SHKItem *item = [SHKItem image:[self getPuzzleImage] title:@"handleImage"];
//	SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
//	
//	[actionSheet showFromToolbar:self.navigationController.toolbar];
    
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
        }
    }
    
    ShareViewController *shareVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"shareVC"];
    shareVC.originalImage = resultImage;
    shareVC.autoSave = NO;
    shareVC.hasAd = YES;
    
    BOOL show = [[AdmobViewController shareAdmobVC] decideShowRT:self];
    if(!show)//zzx0930
        [AdUtility tryShowInterstitialInVC:self.navigationController placeid:5];
    [self.navigationController pushViewController:shareVC animated:YES];
}

- (UIImage*)getPuzzleImage
{
//    UIImage *_puzzleImage = nil;
//    CGSize _imageSize = _editImageView.frame.size;
//    // Create the bitmap context
//    UIGraphicsBeginImageContextWithOptions(_imageSize, NO, 0);
//    CGContextRef bitmap = UIGraphicsGetCurrentContext();
//    [_editImageView.layer renderInContext:bitmap];
//    _puzzleImage= UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    
    return _editImageView.imageView.image;
}

#pragma mark -
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
