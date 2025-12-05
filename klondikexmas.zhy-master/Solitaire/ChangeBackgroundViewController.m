//
//  ChangeBackgroundViewController.m
//  Solitaire
//
//  Created by apple on 13-7-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ChangeBackgroundViewController.h"
#import "ViewController.h"
#import "PicView.h"
#import "UIApplication+Size.h"

@interface ChangeBackgroundViewController ()
{
    NSString* selectedBackName;
    BOOL userdefined;
    ViewController* vc;
    
    NSMutableArray* picViews;
    CGFloat picWidth;
    CGFloat picHeight;
    CGFloat picSpace;
}

@end

@implementation ChangeBackgroundViewController

static NSDictionary *backNameByIndex = nil;
static NSMutableArray *backNames = nil;

@synthesize popOver;

+ (void)initialize
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"background" ofType:@"plist"];
    backNameByIndex = [[NSDictionary alloc] initWithContentsOfFile:path];
    backNames = [[NSMutableArray alloc] init];
    for (int i = 0; i < [backNameByIndex count]; i++) {
        [backNames addObject:[backNameByIndex objectForKey:[NSString stringWithFormat:@"%d",i]]];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picSelected:) name:@"backgroundpic" object:nil];
    //
    self.bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    userdefined = [((NSNumber*)[settings objectForKey:@"userdefined-background"]) boolValue];
    selectedBackName = [settings objectForKey:@"background"];
    /// here is model to request
//    vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    UINavigationController *navigationController = nil;

    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        navigationController = (UINavigationController *)rootViewController;
    } else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        navigationController = tabBarController.selectedViewController;
    }

    NSArray *viewControllers = navigationController.viewControllers;
    vc = (ViewController*)viewControllers[0];
    if (vc == nil) {
        NSLog(@"error becouse of ViewconTroller load file");
    }
    ///
    [self setBackImage];
    ///
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        picWidth = 180;
        picHeight = 180;
        picSpace = 20;
    }
    else
    {
        picWidth = 120;
        picHeight = 120;
        picSpace = 10;
    }
    picViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < [backNameByIndex count]; i++) {
        PicView* pv = [[PicView alloc] initWithFrame:CGRectMake(-900, -900, picWidth, picHeight) border:5];
        /*
        if (userdefined && i + 1 == [backNames count]) {
            NSString *retinaStr = @"";
            if ([[UIScreen mainScreen] scale] == 2.0) {
                retinaStr = @"@2x";
            }
            NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), [backNames lastObject],retinaStr];
            [pv setImage:imgName custom:YES idx:i type:PIC_BACKGROUND];
        }
        else
        {
            [pv setImage:[backNames objectAtIndex:i] custom:NO idx:i type:PIC_BACKGROUND];
        }
         */
        [pv setCheck:NO];
        [picViews addObject:pv];
        [self.scrollView addSubview:pv];
    }
    ((PicView*)[picViews lastObject]).hidden = !userdefined;
    [self setLayoutImags];
    /// layout
    [self layoutPics];
    
    self.scrollView.layer.cornerRadius = 10;
    self.scrollView.layer.masksToBounds = YES;
    UIButton *addPhotoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    NSString *str = NSLocalizedStringFromTable(@"Photo Albums", @"Language", nil);
    [addPhotoButton setTitle:str forState: UIControlStateNormal];
    [addPhotoButton addTarget:self action:@selector(addPhotoButtonTapped) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addPhotoButton];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    UIFont *font = [UIFont systemFontOfSize:17.0];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    [addPhotoButton.titleLabel setFont:font];
    [addPhotoButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [addPhotoButton.titleLabel setFont:font];
   
}
- (void)addPhotoButtonTapped {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (void)setLayoutImags
{
    for (int i = 0; i < [backNameByIndex count]; i++) {
        PicView* pv = [picViews objectAtIndex:i];
        if (userdefined && i + 1 == [backNames count]) {
            NSString *retinaStr = @"";
            if ([[UIScreen mainScreen] scale] == 2.0) {
                retinaStr = @"@2x";
            }
            NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), [backNames lastObject],retinaStr];
            [pv setImage:imgName custom:YES idx:i type:PIC_BACKGROUND];
        }
        else
        {
            [pv setImage:[vc getRealBackImgName:[backNames objectAtIndex:i]] custom:NO idx:i type:PIC_BACKGROUND];
        }
    }
}

- (void)setBackImage
{
    NSString* realImgName = [vc getRealBackImgName:selectedBackName];
    if ([realImgName hasPrefix:@"userdefined"]) {
        NSString *retinaStr = @"";
        if ([[UIScreen mainScreen] scale] == 2.0) {
            retinaStr = @"@2x";
        }
        NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), realImgName,retinaStr];
        self.backImg.image = [UIImage imageWithContentsOfFile:imgName];
    }
    else
        self.backImg.image = [UIImage imageNamed:realImgName];
}

- (void)layoutPics
{
    CGFloat eachWidth = picWidth + picSpace;
    CGFloat eachHeight = picHeight + picSpace;
    int cols = (int)(self.scrollView.frame.size.width/eachWidth);
    CGFloat realWidth = self.scrollView.frame.size.width/cols;
    CGFloat offsetX = realWidth - eachWidth;
    ///
    int rows = [picViews count]/cols;
    if ([picViews count]%cols != 0) {
        rows+=1;
    }
    // zzx 20240206
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, eachHeight*(rows))];
    NSInteger index = [backNames indexOfObject:selectedBackName];
    [((PicView*)[picViews objectAtIndex:index]) setCheck:YES];
    //
    CGFloat baseX = 0;//self.scrollView.frame.origin.x;
    CGFloat baseY = 0;//self.scrollView.frame.origin.y;
    [UIView animateWithDuration:0.2 animations:^{
    for (PicView* pv in picViews) {
        int idx = pv.theid;
        pv.frame = CGRectMake(baseX + realWidth*(idx%cols) + picSpace/2 + offsetX/2, baseY + eachHeight*(idx/cols) + picSpace/2, picWidth, picHeight);
    }
    //[self.scrollView setContentOffset:CGPointMake(0, baseY + eachHeight*(index/cols) + picSpace/2) animated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"background"];
//    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
//    [self.navigationController popViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    ///
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    ///
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    float scale = [[UIScreen mainScreen] scale];
    UIImage* scaleImage = [self reSizeImage:image toSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width*scale, [[UIScreen mainScreen] bounds].size.height*scale)];
    NSString *retinaStr = @"";
    if (scale == 2.0)
        retinaStr = @"@2x";
    NSString* path = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), [backNames lastObject], retinaStr];
    [UIImagePNGRepresentation(scaleImage) writeToFile:path atomically:YES];
    // last
    NSInteger index = [backNames indexOfObject:selectedBackName];
    [((PicView*)[picViews objectAtIndex:index]) setCheck:NO];
    [((PicView*)[picViews objectAtIndex:index]) setNeedsDisplay];
    selectedBackName = [backNames lastObject];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"userdefined-background"];
    [userDefaults setObject:selectedBackName forKey:@"background"];
    [userDefaults synchronize];
    /// update
    userdefined = YES;
    NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), selectedBackName, retinaStr];
    self.backImg.image = [UIImage imageWithContentsOfFile:imgName];
    [((PicView*)[picViews lastObject]) setCheck:YES];
    [((PicView*)[picViews lastObject]) setImage:imgName custom:YES idx:[backNames count]-1 type:PIC_BACKGROUND];
    ((PicView*)[picViews lastObject]).hidden = !userdefined;
    [((PicView*)[picViews lastObject]) setNeedsDisplay];
    //[self.scrollView setContentOffset:CGPointMake(0, [self.scrollView contentSize].height-2*picHeight) animated:YES];
}


- (IBAction)pick:(id)sender {
    ///
    UIImagePickerController *pc = [[UIImagePickerController alloc] init];
    pc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    //pc.allowsEditing = YES;
    pc.delegate = self;
    pc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:pc animated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    BOOL rotateFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    if (rotateFlag) {
        return YES;
    }
    else
    {
        return (toInterfaceOrientation == [[NSUserDefaults standardUserDefaults] integerForKey:@"currentori"]);
    }
    //return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self layoutPics];
    [self setBackImage];
    [self setLayoutImags];
}

- (void)viewWillAppear:(BOOL)animated
{
    //
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self layoutPics];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

- (void)picSelected:(NSNotification*)notifacation
{
    NSNumber* object = notifacation.object;
    int idx = [object integerValue];
    for (PicView* pv in picViews) {
        if (pv.theid == idx) {
            [pv setCheck:YES];
        }
        else
            [pv setCheck:NO];
        [pv setNeedsDisplay];
    }
    //
    selectedBackName = [backNames objectAtIndex:idx];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:selectedBackName forKey:@"background"];
    [settings synchronize];
    /*
    ///
    if (userdefined && idx + 1 == [backNames count]) {
        NSString *retinaStr = @"";
        if ([[UIScreen mainScreen] scale] == 2.0) {
            retinaStr = @"@2x";
        }
        NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), selectedBackName,retinaStr];
        self.backImg.image = [UIImage imageWithContentsOfFile:imgName];
    }
    else
        self.backImg.image = [UIImage imageNamed:selectedBackName];
     */
    [self setBackImage];
}

- (void)viewDidUnload {
    [self setBackImg:nil];
    [self setBottomView:nil];
    [self setPicBtn:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
