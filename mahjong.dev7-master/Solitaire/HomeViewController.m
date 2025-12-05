//
//  HomeViewController.m
//  Mahjong
//
//  Created by yysdsyl on 14-11-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "HomeViewController.h"
#import "Solitaire.h"
#import "TheSound.h"
#import "LayoutCell.h"
#import "Config.h"
#import "MBProgressHUD.h"
#import "Admob.h"
#include "ApplovinMaxWrapper.h"
#import "ProtocolAlerView.h"
#import <SafariServices/SafariServices.h>
#include "ApplovinMaxWrapper.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
extern Solitaire* game;

@interface HomeViewController ()
{
    __weak IBOutlet UIView *backView;
    __weak IBOutlet NSLayoutConstraint *admobHeight;
    NSMutableArray* allCells;
    double layoutwidth;
    //
    int LAYOUT_ROWS;
    BOOL firstin;
    //
    //
    MBProgressHUD* nethud;
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ///
    nethud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    nethud.labelText = @"loading ...";
    //
    allCells = [[NSMutableArray alloc] init];
    firstin = YES;
    // Do any additional setup after loading the view.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        [self.soundBtn setBackgroundImage:[UIImage imageNamed:@"btn_soundon"] forState:UIControlStateNormal];
    }
    else
        [self.soundBtn setBackgroundImage:[UIImage imageNamed:@"btn_soundoff"] forState:UIControlStateNormal];
    self.bgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg%d.jpg",game.groupId]];
    self.adView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    //
    //[self layoutLevels];
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"levelChoose" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(levelChoose:) name:@"levelChoose" object:nil];
    //
}

- (void)layoutLevels
{
    LAYOUT_ROWS = 2;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        LAYOUT_ROWS = 3;
    }
    int MAX_LAYOUT_NUM = GROUP_SIZE;
    //
    double layoutheight = (self.levelsScrollView.frame.size.height / LAYOUT_ROWS) * 0.98;
    layoutwidth = layoutheight * 1.6;
    self.levelsScrollView.contentSize = CGSizeMake((MAX_LAYOUT_NUM / LAYOUT_ROWS + (MAX_LAYOUT_NUM % LAYOUT_ROWS == 0 ? 0 : 1)) * layoutwidth+layoutwidth*0.2, self.levelsScrollView.frame.size.height);
    int currentidx = 0;
    for (int i = 0; i < MAX_LAYOUT_NUM; i++)
    {
        int layoutidx = i + game.groupId * GROUP_SIZE;
        //
        LayoutCell* lc = nil;
        lc = [[LayoutCell alloc] initWithFrame:CGRectMake(layoutwidth*0.05+(i/LAYOUT_ROWS)*layoutwidth, layoutheight*0.05+(i%LAYOUT_ROWS)*layoutheight, layoutwidth*0.9, layoutheight*0.9) lock:[[game.layoutlocks objectAtIndex:layoutidx] boolValue] stars:[[game.layoutstars objectAtIndex:layoutidx] integerValue] layoutid:layoutidx];
        //zzx bug1
//        [self.levelsScrollView addSubview:lc];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.levelsScrollView addSubview:lc];
            [lc updateState];
            [allCells addObject:lc];
        });
       
        //
        if ([[game.layoutlocks objectAtIndex:layoutidx] boolValue] == NO)
            currentidx = i;
    }
    if (currentidx / LAYOUT_ROWS - 1 >= 0)
        currentidx = currentidx / LAYOUT_ROWS - 1;
    else
        currentidx = currentidx / LAYOUT_ROWS;
    [self.levelsScrollView scrollRectToVisible:CGRectMake(layoutwidth*currentidx-100, 0, self.levelsScrollView.frame.size.width, self.levelsScrollView.frame.size.height) animated:YES];
}

- (void)levelChoose:(NSNotification*)notify
{ //
    LayoutCell* lc = notify.object;
    if (!lc.locked)
    {
        [TheSound playTapSound];
        game.layoutid = lc.layoutid;
        [self performSegueWithIdentifier:@"playSegue" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (firstin) {
        return;
    }
    //
    LayoutCell* lastUnlock = nil;
    for (LayoutCell* lc in allCells) {
        lc.locked = [[game.layoutlocks objectAtIndex:lc.layoutid] boolValue];
        lc.stars = [[game.layoutstars objectAtIndex:lc.layoutid] integerValue];
        if (lc.layoutid == game.unlockone) {
            lastUnlock = lc;
        }
        else
        {
            [lc updateState];
        }
    }
    //
    int currentidx = 0;
    for (int i = 0; i < GROUP_SIZE; i++)
    {
        int layoutidx = i + game.groupId * GROUP_SIZE;
        //
        if ([[game.layoutlocks objectAtIndex:layoutidx] boolValue] == NO)
            currentidx = i;
    }
    if (currentidx / LAYOUT_ROWS - 1 >= 0)
        currentidx = currentidx / LAYOUT_ROWS - 1;
    else
        currentidx = currentidx / LAYOUT_ROWS;
    [self.levelsScrollView scrollRectToVisible:CGRectMake(layoutwidth*currentidx-100, 0, self.levelsScrollView.frame.size.width, self.levelsScrollView.frame.size.height) animated:YES];
    //
    //
    if (game.unlockone != -1 && lastUnlock != nil)
    {
        game.unlockone = -1;
        [lastUnlock unlockAnim];
    }
}

- (void)loadlevels
{
    if (firstin)
    {
        [self layoutLevels];
        firstin = NO;
        [nethud hide:YES];
        return;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
    ApplovinMaxWrapper *applovinWrapper = [[ApplovinMaxWrapper alloc] init];
    CGFloat admobHeight1 = [applovinWrapper getAdmobHeight];
    NSLog(@"3 admobHeight1=%f",admobHeight1);
    admobHeight.constant=admobHeight1;
    //
//    [[AdmobViewController shareAdmobVC] show_admob_banner:0 posy:0 width:self.adView.frame.size.width height:self.adView.frame.size.height view:self.adView];
    [[AdmobViewController shareAdmobVC] show_admob_banner_smart:0.0 posy:0.0 view:self.adView];
    //
    if (!firstin) {
        return;
    }
    ///ios7
    [self performSelectorInBackground:@selector(loadlevels) withObject:self];
    
    [self.view bringSubviewToFront:backView];
    [self.view bringSubviewToFront:_adView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender {
    [TheSound playTapSound];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"levelChoose" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSound:(id)sender {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    BOOL sound = [settings boolForKey:@"sound"];
    sound = !sound;
    [settings setBool:sound forKey:@"sound"];
    [settings synchronize];
    if (sound) {
        [self.soundBtn setBackgroundImage:[UIImage imageNamed:@"btn_soundon"] forState:UIControlStateNormal];
    }
    else
        [self.soundBtn setBackgroundImage:[UIImage imageNamed:@"btn_soundoff"] forState:UIControlStateNormal];
    //
    [TheSound playTapSound];
}
@end
