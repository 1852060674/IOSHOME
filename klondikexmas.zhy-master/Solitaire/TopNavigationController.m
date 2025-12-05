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
    BOOL classicCard = CLASSIC_CARD;
    BOOL orientation = !(IPHONE_LANDSCAPE);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        classicCard = YES;
        orientation = YES;
    }
    NSDictionary *defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:@"christmas1",@"cardback",
                                  @"ChristmasBg1",@"background",
                                  [NSNumber numberWithBool:NO],@"draw3",
                                  [NSNumber numberWithBool:YES],@"sound",
                                  [NSNumber numberWithBool:YES],@"timemoves",
                                  [NSNumber numberWithBool:orientation],@"orientation",
                                  [NSNumber numberWithBool:YES],@"hints",
                                  [NSNumber numberWithBool:TAP_MOVE],@"tapmove",
                                  [NSNumber numberWithBool:NO],@"gamecenter",
                                  [NSNumber numberWithBool:NO],@"holiday",
                                  [NSNumber numberWithBool:NO],@"congra",
                                  [NSNumber numberWithInteger:orientation ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight],@"currentori",
                                  [NSNumber numberWithBool:classicCard],@"classic",
                                  [NSNumber numberWithInt:1],kOpenTimes,
                                  [NSNumber numberWithInt:0],@"cnt",
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
    BOOL rotateFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    if (rotateFlag) {
        return YES;
    }
    else
    {
        return (interfaceOrientation == [[NSUserDefaults standardUserDefaults] integerForKey:@"currentori"]);
    }
    //return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

-(BOOL)shouldAutorotate{
    return YES;//[[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

- (NSUInteger)supportedInterfaceOrientations
{
    BOOL rotateFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    if (rotateFlag) {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        int ori = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentori"];
        return (1 << ori);
    }
    //return UIInterfaceOrientationMaskAll;
}

@end
