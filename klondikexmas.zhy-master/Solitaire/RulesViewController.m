//
//  RulesViewController.m
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "RulesViewController.h" 
#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "Zhconfig.h"
@interface RulesViewController ()
{
    ViewController* vc;
    __weak IBOutlet NSLayoutConstraint *textViewBtm;
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
    //zzx 20240218
    self.navigationItem.title = @"Rules";
    UIFont *font = [UIFont systemFontOfSize:24.0];
    NSDictionary *attributes = @{NSFontAttributeName: font};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    
    
    self.navigationController.hidesBarsOnSwipe = NO;
//    self.textView.layer.cornerRadius = 5;
//    self.textView.layer.masksToBounds = YES;
//    self.textView.layer.borderWidth = 1.0f;
//    self.textView.layer.shadowRadius = shadowRadius;
    if (![self isNotchScreen] && kScreenWidth <811 && kScreenHeight <811) {
        textViewBtm.constant=-10;
    }
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
    [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

- (IBAction)done:(id)sender {
//    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
- (BOOL)isNotchScreen {
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        if (safeAreaInsets.left>0) {
            NSLog(@"这是safeAreaInsets.left>0屏");
            return YES;
        }
        if (safeAreaInsets.right>0) {
            NSLog(@"这是safeAreaInsets.right>0屏");
            return YES;
        }
        if (safeAreaInsets.bottom>0) {
            NSLog(@"这是safeAreaInsets.bottom>0屏");
            return YES;
        }
        if (safeAreaInsets.top > 0) {
            // 是刘海屏
            NSLog(@"这是刘海屏");
            return YES;
        }
    }
    NSLog(@"zzx have not hair");
    return NO;
}

@end
