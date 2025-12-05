//
//  RulesViewController.m
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "RulesViewController.h" 
#import "ViewController.h"

@interface RulesViewController ()
{
    ViewController* vc;
}

@end

@implementation RulesViewController

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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"txt"];
    NSString* text = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    self.textView.text = text;
    ///
    vc = (ViewController*)[(UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)done:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
