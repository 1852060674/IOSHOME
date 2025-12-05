//
//  BackgroundViewController.m
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved. 
//

#import "BackgroundViewController.h"
#import "ViewController.h"

@interface BackgroundViewController ()
{
    NSString* selectedBackName;
    BOOL userdefined;
    ViewController* vc;
}
@end

@implementation BackgroundViewController

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
    self.bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    selectedBackName = [settings objectForKey:@"background"];
    userdefined = [((NSNumber*)[settings objectForKey:@"userdefined-background"]) boolValue];
    NSInteger index = [backNames indexOfObject:selectedBackName];
    [self.picker selectRow:index inComponent:0 animated:YES];
    if ([selectedBackName hasPrefix:@"userdefined"]) {
        NSString *retinaStr = @"";
        if ([[UIScreen mainScreen] scale] == 2.0) {
            retinaStr = @"@2x";
        }
        NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), selectedBackName,retinaStr];
        self.backImg.image = [UIImage imageWithContentsOfFile:imgName];
    }
    else
        self.backImg.image = [UIImage imageNamed:selectedBackName];
    ///
    vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setBackImg:nil];
    [self setBottomView:nil];
    [self setPicker:nil];
    [self setPicBtn:nil];
    [self setPicBtn:nil];
    [super viewDidUnload];
}
- (IBAction)dismissMyself:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settings" object:@"background"];
    /*
    ViewController* vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController] ;
     */
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
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
    selectedBackName = [backNames lastObject];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"userdefined-background"];
    [userDefaults setObject:selectedBackName forKey:@"background"];
    [userDefaults synchronize];
    /// update
    userdefined = YES;
    [self.picker reloadAllComponents];
    [self.picker selectRow:[backNames count]-1 inComponent:0 animated:YES];
    NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), selectedBackName, retinaStr];
    self.backImg.image = [UIImage imageWithContentsOfFile:imgName];
}

- (IBAction)pickUserdefined:(id)sender {
    ///
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

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = [backNames count];
    if (!userdefined) {
        rows -= 1;
    }
    return rows;
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (userdefined && row + 1 == [backNames count]) {
        return @"Custom";
    }
    else
        return [backNames objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedBackName = [backNames objectAtIndex:row];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:selectedBackName forKey:@"background"];
    [settings synchronize];
    ///
    if (userdefined && row + 1 == [backNames count]) {
        NSString *retinaStr = @"";
        if ([[UIScreen mainScreen] scale] == 2.0) {
            retinaStr = @"@2x";
        }
        NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), selectedBackName,retinaStr];
        self.backImg.image = [UIImage imageWithContentsOfFile:imgName];
    }
    else
        self.backImg.image = [UIImage imageNamed:selectedBackName];
}

@end
