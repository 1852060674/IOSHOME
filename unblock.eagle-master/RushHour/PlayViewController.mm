//
//  PlayViewController.m
//  WordSearch
//
//  Created by apple on 13-8-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PlayViewController.h"
#import "TheSound.h"
#import "Config.h"
#import "Common.h"
#import "StagesViewController.h"
#import "BlockView.h"
#import "ApplovinMaxRewardWrapper.h"
#import "Admob.h"

#import <SafariServices/SafariServices.h>
#include "ApplovinMaxWrapper.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
@interface PlayViewController ()
{
    GameData* gameData;
    NSMutableArray* thePuzzle;
    NSTimer *timer;
    NSMutableArray* allBlockViews;
    int N;
    int bestMoves;
    int completeState;
    int minMoves;
    
    int freehints;
    BOOL ShowAdward;
    BOOL showing;
    //
}
@end

@implementation PlayViewController

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
    N = 0;
    bestMoves = 0;
    completeState = 0;
    minMoves = 0;
    ShowAdward=NO;
    self.completeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.completeView.hidden = YES;
    ///
    srand(time(NULL));
    ///
    gameData = [GameData sharedGD];
    ///
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updatestat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatestat:) name:@"updatestat" object:nil];
    ///
    //timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeDo) userInfo:nil repeats:YES];
    self.view.multipleTouchEnabled = NO;
    ///
//    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
//        self.opView.center = CGPointMake(self.opView.center.x, self.cellView.frame.origin.y+self.cellView.frame.size.height + kAdHeight + (self.view.frame.size.height - self.cellView.frame.origin.y - self.cellView.frame.size.height-kAdHeight)/2);
//    }
    
    [self reloadHintsBadge];
    [self updateHintsBadge];
    ///
    [self newGame];
}

-(void)viewWillAppear:(BOOL)animated {
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.adView placeid:0];
}

-(void)viewDidAppear:(BOOL)animated
{
    [[AdmobViewController shareAdmobVC] setRewardAdClient:(id<RewardAdWrapperDelegate>)self];
    [[AdmobViewController shareAdmobVC] setDelegate:self];
    [[AdmobViewController shareAdmobVC] init_reward_ad];
}

- (void) reloadHintsBadge {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    id obj = [settings objectForKey:FREE_HINTS_SETTING_KEY];
    freehints = (int)[obj integerValue];
}

- (void) updateHintsBadge {
    if(freehints == 0) {
        self.hintBadge.text = @"Ad";
    } else {
        self.hintBadge.text = [NSString stringWithFormat:@"%d", freehints];
    }
    if(freehints > 99) {
        self.hintBadge.hidden = YES;
    }
}

-(void)adMobVCDidCloseInterstitialAd:(AdmobViewController *)adMobVC
{
    self.completeView.hidden = NO;
}

-(void)adMobVCWillCloseInterstitialAd:(AdmobViewController *)adMobVC
{
    //self.completeView.hidden = NO;
}

-(void)adMobVCDidReceiveInterstitialAd:(AdmobViewController *)adMobVC
{
    
}


//- (void)RewardVideoAdDidRewardUserWithReward:(RewardAdWrapperDelegate *)adMobVC {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        freehints += 5;
//        NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
//        [settings setObject:[NSNumber numberWithInt:freehints] forKey:FREE_HINTS_SETTING_KEY];
//        [settings synchronize];
//        [self updateHintsBadge];
//    });
//}

- (void)RewardVideoAdDidRewardUserWithReward:(RewardAdWrapper*) rewardad rewardType:(NSString*) rewardtype amount:(double) rewardamount {
    NSLog(@"[ADUNION] Show Admob Inter Ad Idx:%d", 6600000);
    dispatch_async(dispatch_get_main_queue(), ^{
        freehints += 5;
        NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:[NSNumber numberWithInt:freehints] forKey:FREE_HINTS_SETTING_KEY];
        [settings synchronize];
        [self updateHintsBadge];
    });
}

- (void)layoutFlows
{
    srand(time(NULL));
    N = [[thePuzzle objectAtIndex:0] integerValue];
    bestMoves = [[thePuzzle objectAtIndex:2] integerValue];
    completeState = [[thePuzzle objectAtIndex:3] integerValue];
    minMoves = [[thePuzzle objectAtIndex:4] integerValue];
    [self.cellView resetDraw];
    [UIView animateWithDuration:0.01 animations:^{
        for (BlockView* fv in allBlockViews) {
            fv.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (allBlockViews == nil) {
            allBlockViews = [[NSMutableArray alloc] init];
        }
        else
            [allBlockViews removeAllObjects];
        CGFloat flowWidth = self.cellView.frame.size.height/N;
        self.cellView.cellsize = N;
        for (UIView* subv in self.cellView.subviews) {
            if ([subv isKindOfClass:[BlockView class]]) {
                [subv removeFromSuperview];
            }
        }
        int seq = 0;
        for (int i = 5; i < [thePuzzle count]; i++) {
            NSString *blockstr = [thePuzzle objectAtIndex:i];
            ///[1,0,1,0,2] - 1列0行横向非目标2长度
            NSArray* blockitems = [blockstr componentsSeparatedByString:@","];
            int x = [[blockitems objectAtIndex:0] integerValue];
            int y = [[blockitems objectAtIndex:1] integerValue];
            int hor = [[blockitems objectAtIndex:2] integerValue];
            int len = [[blockitems objectAtIndex:4] integerValue];
            int type = [[blockitems objectAtIndex:3] integerValue];
            CGRect frame = CGRectMake(x*flowWidth, y*flowWidth, hor == 1 ? flowWidth*len : flowWidth, hor == 1 ? flowWidth : flowWidth*len);
            BlockView* bv = [[BlockView alloc] initWithFrame:frame seq:seq x:x y:y hor:hor==1 len:len type:type==1];
            [self.cellView addSubview:bv];
            [allBlockViews addObject:bv];
            seq++;
        }
        self.cellView.allBlockViews = allBlockViews;
        self.cellView.targetView = self.targetView;
        [self.cellView spaceBoard];
        self.levelDescLabel.text = [NSString stringWithFormat:@"Level %d",gameData.no+1];
        self.levelDescLabel.textColor = [UIColor whiteColor];//[Common colors:gameData.no/(CELL_NUM*CELL_NUM)];
        self.packLabel.text = gameData.levelName;
        self.packLabel.textColor = [UIColor whiteColor];//[Common colors:gameData.no/(CELL_NUM*CELL_NUM)];
        ///
        [UIView animateWithDuration:0.1 animations:^{
            for (BlockView* fv in allBlockViews) {
                fv.alpha = 1;
            }
        } completion:^(BOOL finished) {
            ;
        }];
    }];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updatestat" object:nil];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
    [self removeNotification];
    [TheSound playTapSound];
    ShowAdward=NO;
}

- (void)newGame
{
    //
    thePuzzle = [[gameData.packPuzzles objectAtIndex:gameData.row] objectAtIndex:gameData.no];
    ///
    [self layoutFlows];
    ///
    [self updatePreNext];
    [self updateState];
    [self updatestat:nil];
    ///
    self.completeView.hidden = YES;
    
    if(gameData.no%7==6) {
        [[AdmobViewController shareAdmobVC] checkConfigUD];
    }
}

- (void)updatePreNext
{
    if (gameData.no == 0) {
        self.prevBtn.enabled = NO;
    }
    else
        self.prevBtn.enabled = YES;
    int total = [[gameData.packPuzzles objectAtIndex:gameData.row] count];
    total -= (total%(CELL_NUM*CELL_NUM));
    if (gameData.no >= total - 1)
        self.nextBtn.enabled = NO;
    else
        self.nextBtn.enabled = YES;
}

- (void)updateState
{
    switch (completeState) {
        case 0:
            self.stateView.image = [UIImage imageNamed:@""];
            break;
        case 1:
            self.stateView.image = [UIImage imageNamed:@"passed"];
            break;
        case 2:
            self.stateView.image = [UIImage imageNamed:@"perfect"];
            break;
        default:
            break;
    }
    if (bestMoves == 0) {
        self.bestLabel.text = [NSString stringWithFormat:@"Record: -"];
    }
    else
        self.bestLabel.text = [NSString stringWithFormat:@"Record: %d",bestMoves];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)timeDo
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    /// stop timer
    //[timer setFireDate:[NSDate distantFuture]];
    [Common saveGameData:gameData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

- (void)updatestat:(NSNotification*)notifacation
{
    int type = [notifacation.object integerValue];
    self.movesLabel.text = [NSString stringWithFormat:@"%d",self.cellView.moves];
    if (!self.cellView.hintFlag) {
        self.undoBtn.enabled = YES;
    }
    if (type == 1) {
        int total = [[gameData.packPuzzles objectAtIndex:gameData.row] count];
        total -= (total%(CELL_NUM*CELL_NUM));
        if (gameData.no >= total - 1)
        {
            self.nextLevelBtn.hidden = YES;
            self.nextPackLevel.hidden = NO;
        }
        else
        {
            self.nextLevelBtn.hidden = NO;
            self.nextPackLevel.hidden = YES;
        }
        if (self.cellView.moves <= minMoves) {
            self.winTitleLabel.text = @"Perfect!";
            self.winDescLabel.text = @"You completed the level with least moves possible!";
        }
        else
        {
            self.winTitleLabel.text = @"Passed!";
            self.winDescLabel.text = @"Can you complete the level with even less moves?";
        }
        //self.completeView.hidden = NO;
        ///
        if (bestMoves == 0 || bestMoves > self.cellView.moves) {
            bestMoves = self.cellView.moves;
        }
        if (completeState == 0) {
            int newcomp = [[gameData.packCompleted objectAtIndex:gameData.row] integerValue]+1;
            [gameData.packCompleted replaceObjectAtIndex:gameData.row withObject:[NSNumber numberWithInt:newcomp]];
        }
        if (self.cellView.moves == minMoves) {
            completeState = 2;
        }
        else
            completeState = 1;
        [self updateState];
        [thePuzzle replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:bestMoves]];
        [thePuzzle replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:completeState]];
        [TheSound playLevelUpSound];
        //
        ///cnt for show ad
        NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
        int timecnt = (int)[[settings objectForKey:@"cnt"] integerValue];
        timecnt++;
        [settings setObject:[NSNumber numberWithInt:timecnt] forKey:@"cnt"];
        [settings synchronize];
        [self showFullAds: timecnt];
        
        [[AdmobViewController shareAdmobVC] recordValidUseCount];
    }
    ///
    if (!self.cellView.hintFlag) {
        if ([self.cellView.undoMoves count] == 0) {
            self.undoBtn.enabled = NO;
        }
        else
            self.undoBtn.enabled = YES;
    }
}
// zzx 全屏
- (void)showFullAds: (int)timecnt
{
    if (timecnt % TIMECNT_FOR_AD == 0) {
        if (![[AdmobViewController shareAdmobVC] try_show_admob_interstitial:self ignoreTimeInterval:YES])
        {
            self.completeView.hidden = NO;
        }
    }
    else
    {
        if (![[AdmobViewController shareAdmobVC] try_show_admob_interstitial:self ignoreTimeInterval:NO])
        {
            self.completeView.hidden = NO;
        }
    }
    
}

- (IBAction)replay:(id)sender {
    [self newGame];
    [TheSound playTapSound];
}

- (IBAction)hint:(id)sender {
    if (!self.completeView.hidden || self.cellView.hintFlag) {
        return;
    }
    if(freehints == 0) {
        if([self showHint]) {
            return;
        }
        [[AdmobViewController shareAdmobVC] init_reward_ad];
        [[AdmobViewController shareAdmobVC] showRewardAd:self placeid:0];
        return ;
    } else {
        freehints -= 1;
        NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
        [settings setObject:[NSNumber numberWithInt:freehints] forKey:FREE_HINTS_SETTING_KEY];
        [settings synchronize];
        [self updateHintsBadge];
    }
    
    self.undoBtn.enabled = NO;
    [self.cellView hint];
    [TheSound playTapSound];
}

- (IBAction)prev:(id)sender {
    gameData.no--;
    [gameData.packCurrent replaceObjectAtIndex:gameData.row withObject:[NSNumber numberWithInt:gameData.no]];
    [self newGame];
    [TheSound playTapSound];
}

- (IBAction)next:(id)sender {
    gameData.no++;
    [gameData.packCurrent replaceObjectAtIndex:gameData.row withObject:[NSNumber numberWithInt:gameData.no]];
    [self newGame];
    [TheSound playTapSound];
}

- (IBAction)close:(id)sender {
    self.completeView.hidden = YES;
    [TheSound playTapSound];
}

- (IBAction)undo:(id)sender {
    if (!self.completeView.hidden) {
        return;
    }
    [self.cellView undo];
    [TheSound playTapSound];
}

- (BOOL) showHint {
    AdmobViewController* vc = [AdmobViewController shareAdmobVC];
    if([vc hasInAppPurchased])
        return FALSE;
    GRTService* ser = (GRTService*)[vc rtService];
    if([ser isRT] || [ser isGRT]) {
        return FALSE;
    }
    
    NSDictionary* ex = [[[AdmobViewController shareAdmobVC] configCenter] getExConfig];
    long count = 0;
    @try {
        if(ex != nil && [ex valueForKey:@"lt"] != nil) {
            count = [ex[@"lt"] integerValue];
        }
    } @catch(NSException*) {
        count = 0;
    } @finally {
        
    }
    
    if(count <= 0) {
        return [vc getRT:self isLock:true rd:@"unlock hint" cb:^(){}];
    }
    return FALSE;
}

@end
