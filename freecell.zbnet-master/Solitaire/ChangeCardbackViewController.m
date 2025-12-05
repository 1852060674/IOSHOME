//
//  ChangeCardbackViewController.m
//  Solitaire
//
//  Created by apple on 13-7-21.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ChangeCardbackViewController.h"
#import "ViewController.h"
#import "PicView.h"

@interface ChangeCardbackViewController ()
{
    NSString* selectedBackName;
    BOOL userdefined;
    ViewController* vc;
    
    NSMutableArray* picViews;
    CGFloat picWidth;
    CGFloat picHeight;
    CGFloat picSpaceWidth;
    CGFloat picSpaceHeight;
}

@end

@implementation ChangeCardbackViewController

@synthesize popOver;

static NSDictionary *backNameByIndex = nil;
static NSMutableArray *backNames = nil;

+ (void)initialize
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cardback" ofType:@"plist"];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picSelected:) name:@"cardbackpic" object:nil];
	// Do any additional setup after loading the view.
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    selectedBackName = [settings objectForKey:@"cardback"];
    userdefined = [((NSNumber*)[settings objectForKey:@"userdefined-backcard"]) boolValue];
    ///
    vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
    ///
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        picWidth = 80;
        picHeight = 120;
        picSpaceWidth = 60;
        picSpaceHeight = 20;
    }
    else
    {
        picWidth = 60;
        picHeight = 80;
        picSpaceWidth = 30;
        picSpaceHeight = 10;
    }
    picViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < [backNameByIndex count]; i++) {
        PicView* pv = [[PicView alloc] initWithFrame:CGRectMake(-900, -900, picWidth, picHeight) border:0];
        if (userdefined && i + 1 == [backNames count]) {
            NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(), [backNames lastObject]];
            [pv setImage:imgName custom:YES idx:i type:PIC_CARDBACK];
        }
        else
        {
            [pv setImage:[backNames objectAtIndex:i] custom:NO idx:i type:PIC_CARDBACK];
        }
        [pv setCheck:NO];
        [picViews addObject:pv];
        [self.scrollView addSubview:pv];
    }
    ((PicView*)[picViews lastObject]).hidden = !userdefined;
    /// layout
    [self layoutPics];
}

- (void)layoutPics
{
    CGFloat eachWidth = picWidth + picSpaceWidth;
    CGFloat eachHeight = picHeight + picSpaceHeight;
    int cols = (int)(self.scrollView.frame.size.width/eachWidth);
    CGFloat realWidth = self.scrollView.frame.size.width/cols;
    CGFloat offsetX = realWidth - eachWidth;
    ///
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, eachHeight*([picViews count]/cols + 2))];
    NSInteger index = [backNames indexOfObject:selectedBackName];
    [((PicView*)[picViews objectAtIndex:index]) setCheck:YES];
    //
    CGFloat baseX = self.scrollView.frame.origin.x;
    CGFloat baseY = self.scrollView.frame.origin.y;
    [UIView animateWithDuration:0.2 animations:^{
        for (PicView* pv in picViews) {
            int idx = pv.theid;
            pv.frame = CGRectMake(baseX + realWidth*(idx%cols) + picSpaceWidth/2 + offsetX/2, baseY + eachHeight*(idx/cols) + picSpaceHeight/2, picWidth, picHeight);
        }
        //[self.scrollView setContentOffset:CGPointMake(0, baseY + eachHeight*(index/cols) + picSpaceHeight/2 - picHeight) animated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPicBtn:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (IBAction)done:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"cardback"];
    [self dismissModalViewControllerAnimated:YES];
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.popOver dismissPopoverAnimated:YES];
    }
    else
        [self dismissModalViewControllerAnimated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    ///
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.popOver dismissPopoverAnimated:YES];
    }
    else
        [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    ///
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage* scaleImage = [self reSizeImage:image toSize:CGSizeMake(104, 145)];
    NSString* path = [NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(), [backNames lastObject]];
    [UIImagePNGRepresentation(scaleImage) writeToFile:path atomically:YES];
    // last
    NSInteger index = [backNames indexOfObject:selectedBackName];
    [((PicView*)[picViews objectAtIndex:index]) setCheck:NO];
    [((PicView*)[picViews objectAtIndex:index]) setNeedsDisplay];
    selectedBackName = [backNames lastObject];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"userdefined-backcard"];
    [userDefaults setObject:selectedBackName forKey:@"cardback"];
    [userDefaults synchronize];
    /// update
    userdefined = YES;
    NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(), selectedBackName];
    [((PicView*)[picViews lastObject]) setCheck:YES];
    [((PicView*)[picViews lastObject]) setImage:imgName custom:YES idx:[backNames count]-1 type:PIC_CARDBACK];
    ((PicView*)[picViews lastObject]).hidden = !userdefined;
    [((PicView*)[picViews lastObject]) setNeedsDisplay];
    //[self.scrollView setContentOffset:CGPointMake(0, [self.scrollView contentSize].height-2*picHeight) animated:YES];
}

- (IBAction)pick:(id)sender {
    UIImagePickerController *pc = [[UIImagePickerController alloc] init];
    pc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    //pc.allowsEditing = YES;
    pc.delegate = self;
    //for ipad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:pc];
        self.popOver = popover;
        self.popOver.popoverContentSize = CGSizeMake(300, 300);
        [self.popOver presentPopoverFromRect:self.picBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    //for other
    else
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
    //[vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self layoutPics];
}

- (void)viewWillAppear:(BOOL)animated
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
    [settings setObject:selectedBackName forKey:@"cardback"];
    [settings synchronize];
}

- (void)setBackImage
{
    
}

@end
