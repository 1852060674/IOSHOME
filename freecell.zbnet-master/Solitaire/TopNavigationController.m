//
//  TopNavigationController.m
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "TopNavigationController.h"
#import "Config.h"


@interface TopNavigationController (){
    BOOL tOri;
    BOOL firstin;
    UIInterfaceOrientation cur;
}
 
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
  [super awakeFromNib];
    /// default
    BOOL classicCard = CLASSIC_CARD;
    BOOL orientation = !(IPHONE_LANDSCAPE);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        classicCard = YES;
        orientation = YES;
    }
    NSDictionary *defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:@"cardback37",@"cardback",
                                  @"20",@"20png",
                                  @"bg0",@"background",
                                  @[], customCardBgListKey,
                                  @[], customDeskBgListKey,
                                  [NSNumber numberWithBool:YES], stockOnRight_key,
                                  [NSNumber numberWithBool:NO], freecellOnTop_key,
                                  @"4",@"cardfront",
                                  [NSNumber numberWithBool:NO],stockOnRight_key,
                                  [NSNumber numberWithBool:YES],win_animate_key,
                                  [NSNumber numberWithBool:NO],@"draw3",
                                  [NSNumber numberWithBool:YES],@"sound",
                                  [NSNumber numberWithBool:YES],@"timemoves",
                                  [NSNumber numberWithBool:YES],@"orientation",
                                  [NSNumber numberWithBool:YES],@"tempori",
                                  [NSNumber numberWithBool:YES],@"hints",
                                  [NSNumber numberWithBool:TAP_MOVE],@"tapmove",
                                  [NSNumber numberWithBool:NO],@"gamecenter",
                                  [NSNumber numberWithBool:NO],@"holiday",
                                  [NSNumber numberWithBool:NO],@"congra",
                                  [NSNumber numberWithInteger:orientation ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight],@"currentori",
                                  [NSNumber numberWithBool:classicCard],@"classic",
                                  [NSNumber numberWithInt:0],@"bg",
                                  [NSNumber numberWithInt:10],@"bk",
                                  [NSNumber numberWithInt:0],@"cf",
                                  @"",@"selectbg",
                                  @"",@"selectbk",
                                  [NSNumber numberWithBool:NO],@"rated",
                                  [NSNumber numberWithInt:0],@"popratecnt",
                                  [NSNumber numberWithInt:0],@"cnt",
                                  nil];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    [settings registerDefaults:defaultValue];
    [settings synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    firstin = YES;
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
    if (!firstin) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setBool:[settings boolForKey:@"tempori"] forKey:@"orientation"];
        [settings synchronize];
    }
    else{
        firstin = NO;
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setInteger:[[UIApplication sharedApplication] statusBarOrientation] forKey:@"currentori"];
        [settings synchronize];

      
    }
}

- (void)viewDidDisappear:(BOOL)animated{
  [super viewDidDisappear:animated];
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//    tOri = [settings boolForKey:@"orientation"];
//    cur = [settings integerForKey:@"currentori"];
//    [settings setBool:NO forKey:@"orientation"];
//    [settings synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
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
    return NO;
}

-(BOOL)shouldAutorotate{
    //return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    if (firstin) {
        return YES;
    }
    else
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

- (NSUInteger)supportedInterfaceOrientations
{
    BOOL rotateFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    if (rotateFlag) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else
    {
        NSInteger ori;
        if (firstin) {
            //ori = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentori"];
            ori = [[UIApplication sharedApplication] statusBarOrientation];
        }
        else
            ori = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentori"];
        return (1 << ori);
    }
//    return UIInterfaceOrientationMaskAll;
//    int ori = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentori"];
//    return (1 << ori);
}

@end
