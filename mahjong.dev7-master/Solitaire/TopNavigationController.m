//
//  TopNavigationController.m
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "TopNavigationController.h"
#import "Config.h"

@interface TopNavigationController ()
 
@end

@implementation TopNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    /// default
    NSDictionary *defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"sound",
                                  [NSNumber numberWithInt:0],@"cnt",
                                  [NSNumber numberWithBool:NO],@"rated",
                                  [NSNumber numberWithInt:0],@"popratecnt",
                                  nil];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings registerDefaults:defaultValue];
    [settings synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(BOOL)shouldAutorotate{
    return YES;//[[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end
