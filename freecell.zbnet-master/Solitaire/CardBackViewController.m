//
//  CardBackViewController.m
//  Solitaire 
//
//  Created by apple on 13-7-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CardBackViewController.h"
#import "ViewController.h"

@interface CardBackViewController ()
{
    NSString* selectedBackName;
    BOOL userdefined;
    ViewController* vc;
    int BACKIMG_WIDTH;
    int BACKIMG_HEIGHT;
}

@end

@implementation CardBackViewController

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
    ///
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        BACKIMG_WIDTH = 80;
        BACKIMG_HEIGHT = 120;
    }
    else
    {
        BACKIMG_WIDTH = 70;
        BACKIMG_HEIGHT = 110;
    }
	// Do any additional setup after loading the view.
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    selectedBackName = [settings objectForKey:@"cardback"];
    userdefined = [((NSNumber*)[settings objectForKey:@"userdefined-backcard"]) boolValue];
    NSInteger index = [backNames indexOfObject:selectedBackName];
    [self.picker selectRow:index inComponent:0 animated:YES];
    ///
    vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissMyself:(id)sender {
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
    selectedBackName = [backNames lastObject];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"userdefined-backcard"];
    [userDefaults setObject:selectedBackName forKey:@"cardback"];
    [userDefaults synchronize];
    /// update
    userdefined = YES;
    [self.picker reloadAllComponents];
    [self.picker selectRow:[backNames count]-1 inComponent:0 animated:YES];
}

- (IBAction)pickPhoto:(id)sender {
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
    [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

#pragma UIPicker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	return BACKIMG_WIDTH;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return BACKIMG_HEIGHT;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = [backNames count];
    if (!userdefined) {
        rows -= 1;
    }
    return rows;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (!view)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BACKIMG_WIDTH, BACKIMG_HEIGHT)];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, BACKIMG_WIDTH, BACKIMG_HEIGHT)];
        imgView.contentMode = UIViewContentModeScaleToFill;
        [view addSubview:imgView];
    }
    NSString* imgName = [backNames objectAtIndex:row];
    UIImage *img = nil;
    if (userdefined && row + 1 == [backNames count]) {
        imgName = [NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(), imgName];
        img = [UIImage imageWithContentsOfFile:imgName];
    }
    else
    {
        img = [UIImage imageNamed:[imgName stringByAppendingPathExtension:@"png"]];
    }
    [(UIImageView *)[view.subviews objectAtIndex:0] setImage:img];
    //
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedBackName = [backNames objectAtIndex:row];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:selectedBackName forKey:@"cardback"];
    [settings synchronize];
}


- (void)viewDidUnload {
    [self setPicker:nil];
    [self setPicBtn:nil];
    [super viewDidUnload];
}
@end
