//
//  TopNavigationController.m
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "TopNavigationController.h"
#import "Config.h"
#import "admob.h"
@interface TopNavigationController ()

@end
BOOL oldman=false;
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
    NSLog(@"cell.sw.on = 000%d",[[NSUserDefaults standardUserDefaults] boolForKey:@"classic"]);
    // 添加清理处理异常情况
//    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    [standardUserDefaults removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
//    [standardUserDefaults synchronize];
    
    /// default
    BOOL classicCard = CLASSIC_CARD;
    BOOL orientation = YES;//!(IPHONE_LANDSCAPE);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        classicCard = YES;
        orientation = YES;
    }
    [self IsOldman];
    //定义两套初始化皮肤number.1
    NSLog(@"test first1 coming");
    NSDictionary *defaultValue=nil;
    if (oldman || Open_Old) {
        defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:@"CardBack-BlueGrid",@"cardback",
                        @"RedFelt",@"background",
                        [NSNumber numberWithInteger:0],@"level",
                        [NSNumber numberWithBool:YES],@"sound",
                        [NSNumber numberWithBool:YES],@"timemoves",
                        [NSNumber numberWithBool:orientation],@"orientation",
                        [NSNumber numberWithBool:YES],@"hints",
                        [NSNumber numberWithBool:TAP_MOVE],@"tapmove",
                        [NSNumber numberWithBool:NO],@"gamecenter",
                        [NSNumber numberWithBool:NO],@"holiday",
                        [NSNumber numberWithBool:NO],@"congra",
                        [NSNumber numberWithInt:1],@"speed",
                        [NSNumber numberWithInteger:orientation ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight],@"currentori",
                        [NSNumber numberWithBool:classicCard],@"classic",
                        [NSNumber numberWithInt:0],@"cnt",
                        [NSNumber numberWithBool:NO],@"rated",
                        [NSNumber numberWithInt:0],@"popratecnt",
                        nil];
    }else{
        defaultValue = [NSDictionary dictionaryWithObjectsAndKeys:@"cardback39",@"cardback",
                        @"bg0",@"background",
                        @"1",@"cardfront",
                        @[], customCardBgListKey,
                        @[], customDeskBgListKey,
                        [NSNumber numberWithInteger:0],@"level",
                        [NSNumber numberWithBool:YES],@"sound",
                        [NSNumber numberWithBool:YES],@"timemoves",
                        [NSNumber numberWithBool:orientation],@"orientation",
                        [NSNumber numberWithBool:YES],@"hints",
                        [NSNumber numberWithBool:TAP_MOVE],@"tapmove",
                        [NSNumber numberWithBool:NO],@"gamecenter",
                        [NSNumber numberWithBool:NO],@"holiday",
                        [NSNumber numberWithBool:NO],@"congra",
                        [NSNumber numberWithInt:1],@"speed",
                        [NSNumber numberWithInt:0],@"cnt",
                        [NSNumber numberWithInteger:orientation ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight],@"currentori",
                        [NSNumber numberWithBool:classicCard],@"classic",
                        [NSNumber numberWithBool:NO],@"rated",
                        [NSNumber numberWithInt:0],@"popratecnt",
                        nil];
    }
    
    
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


- (void) IsOldman{
    NSUserDefaults* settings1 = [NSUserDefaults standardUserDefaults];
    id obj = [settings1 objectForKey:New_Boy_Comming];
    BOOL NewMan =[settings1 boolForKey:@"changetoNewMan"];
    id obj1 = [settings1 objectForKey:@"changetoNewMan"];
    NSLog(@"beacuse of obj==nil");
    if (obj == nil) {
        if ([[[AdmobViewController shareAdmobVC] getAppUseStats] getAppOpenCountTotal] < 2) {
            long comingfly=[[[AdmobViewController shareAdmobVC] getAppUseStats] getAppOpenCountTotal];
            //        NSLog(@" zzx find he is old man %ld" , comingfly);
            [settings1 setObject:[NSNumber numberWithLong:comingfly] forKey:New_Boy_Comming];
            [settings1 synchronize];
            oldman =false;
        }else{
            oldman =true;
        }
    }
    if (obj1 == nil) {
        // 说明此前没有改变新老用户状态
        return ;
    }
    if (NewMan) {
        oldman =false;
        return;
    }else{
        oldman =true;
        return;
    }
}



@end
