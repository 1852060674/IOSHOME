//
//  ViewController.m
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ViewController.h"
#import "MoveAction.h"
#import "AppDelegate.h"
#import "UIApplication+Size.h"
#import "Config.h"
#import "Admob.h"
#import "ZhConfig.h"
#import "ApplovinMaxWrapper.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PicView.h"
enum enum_tagid {
    TAG_PLAY = 1,
    TAG_AUTOCOMPLETE = 2
    };

@interface ViewController ()
{
    NSTimer *timer;
    BOOL undoFlag;
    NSMutableArray *winBoards;
    BOOL firstIn;
    ///
    ///
    BOOL tipFirst;
    //
    UIActionSheet *newActionSheet;
    BOOL sheetShowFlag;
    UIActionSheet *autoActionSheet;
    BOOL autoSheetShowFlag;
    BOOL firstAds;
    BOOL startAds;
    BOOL liuhaiScrren;
    
    AVAudioSession *audioSession;
}

@end

@implementation ViewController
@synthesize game = _game;
@synthesize gameStat = _gameStat;
@synthesize showCongra = _showCongra;
@synthesize setshow;

- (void)loadSettings
{
    
    audioSession= [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    /// load
    //cardback
    NSString* backCardName = [settings objectForKey:@"cardback"];
    [CardView setBackImage:backCardName];
    //sound
    self.gameView.sound = [settings boolForKey:@"sound"];
    //time/moves
    if (![settings boolForKey:@"timemoves"]) {
        self.gameView.timeLabel.hidden = YES;
        self.gameView.movesLabel.hidden = YES;
    }
    //hints
    if (![settings boolForKey:@"hints"]) {
        self.gameView.btnHint.hidden = YES;
    }
    //tapmove
    self.gameView.autoOn = [settings boolForKey:@"tapmove"];
    //gamecenter
    if (![settings boolForKey:@"gamecenter"]) {
        self.gameView.btnGC.hidden = YES;
    }
    //holiday
    if (![settings boolForKey:@"holiday"]) {
        self.gameView.gameDecoration.hidden = YES;
    }
    //congra
    self.showCongra = [settings boolForKey:@"congra"];
    //classic cards
    if ([settings boolForKey:@"classic"]) {
        [Card setClassic:YES];
    }
    else
        [Card setClassic:NO];
    /////
    //load winboard
    winBoards = [[NSMutableArray alloc] init];
    NSString *boardFile = [[NSBundle mainBundle] pathForResource:@"win" ofType:@"board"];
    NSString *boardStr = [NSString stringWithContentsOfFile:boardFile encoding:NSUTF8StringEncoding error:nil];
    NSArray* lines = [boardStr componentsSeparatedByString:@"\n"];
    for (NSString* board in lines) {
        NSMutableArray* seqs = [[NSMutableArray alloc] init];
        NSArray* cards = [board componentsSeparatedByString:@" "];
        for (NSString* num in cards) {
            [seqs addObject:[NSNumber numberWithInteger:[num integerValue]]];
        }
    [winBoards addObject:seqs];
    }

}

- (IBAction)showSet:(id)sender {
    if (self.gameView.hinting) {
        return;
    }
    self.setshow = NO;
    [self performSegueWithIdentifier:@"setsegue" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _AdmobHeightt.constant=admobHeight;
    _SpanlishMoveX.constant=8;
    [_itStatusSizeCtr setFont:[UIFont systemFontOfSize:14.0]];
    [_itStatusSizeCtr1 setFont:[UIFont systemFontOfSize:14.0]];
    [_itStatusSizeCtr2 setFont:[UIFont systemFontOfSize:14.0]];
    liuhaiScrren = [self isNotchScreen] && (screen_bounds.size.width >811 || screen_bounds.size.height);
	// Do any additional setup after loading the view, typically from a nib.
    //
    /* splash animate
    UIImage *splashImage = [UIImage imageNamed:@"Default"];
    UIImageView *splashImageView = [[UIImageView alloc] initWithImage:splashImage];
    splashImageView.transform=CGAffineTransformMakeScale(0.0f, 0.0f);
    AppDelegate* ad = [[UIApplication sharedApplication] delegate];
    [ad.window.rootViewController.view addSubview:splashImageView];
    [ad.window.rootViewController.view bringSubviewToFront:splashImageView];
    [UIView animateWithDuration:1.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         splashImageView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                     } completion:^(BOOL finished){
                         if (finished) {
                             [splashImageView removeFromSuperview];
                         }
                     }];
     */
    /// settings
    [self loadSettings];
    /// game stat
    NSString* pathStat = [NSString stringWithFormat:@"%@/Documents/stat.dat",NSHomeDirectory()];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathStat]) {
        NSData *data = [NSData dataWithContentsOfFile:pathStat];
        self.gameStat = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        self.gameStat = [[GameStat alloc] init];
    }
    /// game.dat
    NSString* path = [NSString stringWithFormat:@"%@/Documents/game.dat",NSHomeDirectory()];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.game = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        self.game = [[Solitaire alloc] init:winBoards];
        [self.game freshGame:winBoards];
    }
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.game.draw3 = [settings boolForKey:@"draw3"];
    //[self.game freshGame];
    firstAds = YES;
    startAds = NO;
    self.setshow = NO;
    self.gameView.delegate = self;
    //self.gameView.game = _game;
    firstIn = YES;
    tipFirst = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    ///
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoCompleteDone:) name:@"autoCompleteDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoCompleteActionSheet:) name:@"autoAction" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSettings:) name:@"settings" object:nil];
    
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(bannerShake) userInfo:nil repeats:YES];
    
    //
    [[AdmobViewController shareAdmobVC] decideShowRT:self];
}

-(void) bannerShake
{
    NSLog(@"=====hidden===");
    self.gameView.admobView.hidden = YES;
    [self performSelector:@selector(showBanner) withObject:self afterDelay:2.0];
}

-(void) showBanner
{
    self.gameView.admobView.hidden = NO;
    NSLog(@"=====show===");
}

- (void)updateTime
{
    if (self.game.won) {
        return;
    }
    ///
    self.game.times++;
    self.gameView.timeLabel.text = [NSString stringWithFormat:@"%@ %d:%02d",NSLocalizedStringFromTable(@"time", @"Language", nil),self.game.times/60,self.game.times%60];
    if (self.game.times%10 == 0) {
        self.game.scores -= 2;
        if (self.game.scores < 0) {
            self.game.scores = 0;
        }
        self.gameView.scoreLabel.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedStringFromTable(@"score", @"Language", nil),self.game.scores];
    }
}

- (IBAction)undo:(id)sender {
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag)
        return;
    undoFlag = YES;
    self.gameView.topCards = [self.game undoAction];
    if ([self.gameView.topCards count] > 0) {
        self.game.moves++;
        self.game.scores -= 2;
        if (self.game.scores < 0) {
            self.game.scores = 0;
        }
        [self.gameView computeCardLayout:0.2 destPos:-1 destIdx:-1];
    }
    if (![self.game canUndo]) {
        self.gameView.btnUndo.hidden = YES;
    }
    else
    {
        self.gameView.btnUndo.hidden = NO;
    }
    undoFlag = NO;
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

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[AdmobViewController shareAdmobVC] willOrientationChangeTo:toInterfaceOrientation];
    
    if (sheetShowFlag)
    {
        [newActionSheet dismissWithClickedButtonIndex:1 animated:NO];
        sheetShowFlag = YES;
    }
    if (autoSheetShowFlag)
    {
        [autoActionSheet dismissWithClickedButtonIndex:1 animated:NO];
        autoSheetShowFlag = YES;
    }
    [self.gameView rotateLayout:toInterfaceOrientation];
    //
    [self.gameView uiAdjust];
}

- (NSString*)getRealBackImgName:(NSString*)name
{
    if ([name hasPrefix:@"userdefined"])
        return name;
    CGSize fs = [UIApplication currentSize];
    NSString* landscapeBack = [name stringByAppendingString:@"_landscape"];
    NSString *appDirectory = [[NSBundle mainBundle] bundlePath];
    NSString *checkExist = [appDirectory stringByAppendingPathComponent:[landscapeBack stringByAppendingString:@".png"]];
    NSString *checkExist2 = [appDirectory stringByAppendingPathComponent:[landscapeBack stringByAppendingString:@"@2x.png"]];
    if (fs.width > fs.height
        && ([[NSFileManager defaultManager] fileExistsAtPath:checkExist]
            || [[NSFileManager defaultManager] fileExistsAtPath:checkExist2])) {
            return landscapeBack;
        }
    else
    {
        return name;
    }
    ///
    return name;
}

- (void)setBackImage
{
    //background
    NSString* newBack = [self getRealBackImgName:[[NSUserDefaults standardUserDefaults] objectForKey:@"background"]];
    if ([newBack hasPrefix:@"userdefined"]) {
        NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(), newBack];
        self.gameView.gameBg.image = [UIImage imageWithContentsOfFile:imgName];
    }
    else
    {
        self.gameView.gameBg.image = [UIImage imageNamed:newBack];
    }
}

- (void)showNewActionSheet
{
    newActionSheet = [[UIActionSheet alloc]
                      initWithTitle:nil
                      delegate:self
                      cancelButtonTitle:nil
                      destructiveButtonTitle:nil
                      otherButtonTitles:NSLocalizedStringFromTable(@"newgame", @"Language", nil), NSLocalizedStringFromTable(@"replay", @"Language", nil), NSLocalizedStringFromTable(@"cancel", @"Language", nil), nil];
    newActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    newActionSheet.tag = TAG_PLAY;
    [newActionSheet showInView:self.view];
    sheetShowFlag = YES;
}

- (void)showAutoActionSheet
{
    autoActionSheet = [[UIActionSheet alloc]
                       initWithTitle:nil
                       delegate:self
                       cancelButtonTitle:nil
                       destructiveButtonTitle:nil
                       otherButtonTitles:NSLocalizedStringFromTable(@"autohint", @"Language", nil), NSLocalizedStringFromTable(@"cancel", @"Language", nil), nil];
    autoActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    autoActionSheet.tag = TAG_AUTOCOMPLETE;
    [autoActionSheet showInView:self.view];
    autoSheetShowFlag = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[AdmobViewController shareAdmobVC] onOrientationChangeFrom:fromInterfaceOrientation];
    
    [self.gameView uiAdjust];
    [self setBackImage];
    //
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 || [[UIDevice currentDevice] userInterfaceIdiom]) && sheetShowFlag)
    {
        [self performSelectorOnMainThread:@selector(showNewActionSheet) withObject:self waitUntilDone:YES];
    }
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 || [[UIDevice currentDevice] userInterfaceIdiom]) && autoSheetShowFlag)
    {
        [self performSelectorOnMainThread:@selector(showAutoActionSheet) withObject:self waitUntilDone:YES];
    }
}

- (void) viewDidLayoutSubviews {
    ///ios7
    if (firstIn) {
        [self.gameView setLayoutGuideTop:self.topLayoutGuide.length Bottom:self.bottomLayoutGuide.length];
        [self.gameView firstInCompute];
        self.gameView.game = _game;
        firstIn = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // hide navigate bar
    self.navigationController.navigationBarHidden = YES;
    /// start timer
    [timer setFireDate:[NSDate distantPast]];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.setshow
        && !startAds
        && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        self.setshow = NO;
        [self.gameView uiAdjust];
        return;
    }
    if (startAds)
        startAds = NO;
    [self.gameView rotateLayout:[[UIApplication sharedApplication] statusBarOrientation]];
    [self.gameView uiAdjust];
    [self setBackImage];
    ///
    if (tipFirst) {
        if (self.view.frame.size.width > self.view.frame.size.height) {
            [AdmobViewController shareAdmobVC].landscape = YES;
        }
        tipFirst = NO;
    }
    
    //
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.gameView.admobView placeid:@"gamepage"];
    [[AdmobViewController shareAdmobVC] setBannerAlign:AD_BOTTOM];
}

- (void)viewWillDisappear:(BOOL)animated
{
    /// stop timer
    [timer setFireDate:[NSDate distantFuture]];
    ///
    if (self.gameView.hinting) {
        [self.gameView stopHintAnamiation];
    }
    ///
    NSString* path = [NSString stringWithFormat:@"%@/Documents/game.dat",NSHomeDirectory()];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.game];
    [data writeToFile:path atomically:YES];
    //stat
    path = [NSString stringWithFormat:@"%@/Documents/stat.dat",NSHomeDirectory()];
    data = [NSKeyedArchiver archivedDataWithRootObject:self.gameStat];
    [data writeToFile:path atomically:YES];
    ///User Settings
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    //draw3
    [settings setBool:self.game.draw3 forKey:@"draw3"];
    //sound
    [settings setBool:self.gameView.sound forKey:@"sound"];
    //timemoves
    [settings setBool:!self.gameView.timeLabel.hidden forKey:@"timemoves"];
    //hints
    [settings setBool:!self.gameView.btnHint.hidden forKey:@"hints"];
    //tapmove
    [settings setBool:self.gameView.autoOn forKey:@"tapmove"];
    //gamecenter
    [settings setBool:!self.gameView.btnGC.hidden forKey:@"gamecenter"];
    //holiday
    [settings setBool:!self.gameView.gameDecoration.hidden forKey:@"holiday"];
    //congra
    [settings setBool:self.showCongra forKey:@"congra"];
    //classic
    [settings setBool:[Card classic] forKey:@"classic"];
    ///
    [settings synchronize];
}

#pragma mark game protocal
-(BOOL)movedFan:(NSArray *)f toTableau:(uint)t {
    if ([_game canDropFan:f onTableau:t])
    {
        [_game didDropFan:f onTableau:t];
        return YES;
    }
    return NO;
}

-(BOOL)movedCard:(Card *)c toFoundation:(uint)f {
    if ([_game canDropCard:c onFoundation:f])
    {
        [_game didDropCard:c onFoundation:f];
        return YES;
    }
    return NO;
}

- (void)moveStockToWaste {
    if ([_game canDealCard])
        [_game didDealCard];
    else
        [_game collectWasteCardsIntoStock];
}

- (BOOL)flipCard:(Card *)c
{
    if ([_game canFlipCard:c]) {
        [_game didFlipCard:c];
        return YES;
    }
    
    return NO;
}
- (void)viewDidUnload {
    [self setGameView:nil];
    [super viewDidUnload];
}

- (IBAction)newGame:(id)sender {
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag)
        return;
    /*
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:NSLocalizedStringFromTable(@"newgame", @"Language", nil), NSLocalizedStringFromTable(@"replay", @"Language", nil), NSLocalizedStringFromTable(@"cancel", @"Language", nil), nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = TAG_PLAY;
    [actionSheet showInView:self.view];
     */
    [self showNewActionSheet];
}

- (void)cancelDelay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)eachCompleteMove
{
    self.gameView.topCards = [self.game completeEach];
    if (self.gameView.sound && [self getCurrentSound])
        AudioServicesPlaySystemSound(self.gameView.clickQuickSound);
    [self.gameView computeCardLayout:HINTINFO_TIME destPos:-1 destIdx:-1];
}

- (IBAction)autoComplete:(id)sender {
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag)
        return;
    int cnt = 0;
    [self.view setUserInteractionEnabled:NO];
    for (int i = 0; i < [self.game cardsLeftCnt]; i++)
    {
        [self performSelector:@selector(eachCompleteMove) withObject:nil afterDelay:cnt*HINTINFO_TIME];
        cnt++;
    }
}

- (IBAction)gameCenter:(id)sender {
    if (self.gameView.hinting) {
        return;
    }
    
    //[self performSegueWithIdentifier:@"winsegue" sender:self];
}

- (void)eachHintMove:(NSArray*)param
{
    [self.gameView displayHint:[param objectAtIndex:0] toPos:[[param objectAtIndex:1] integerValue] toIdx:[[param objectAtIndex:2] integerValue] seq:[[param objectAtIndex:3] integerValue] total:[[param objectAtIndex:4] integerValue]];
}

- (IBAction)showHint:(id)sender {
    if (self.game.won) {
        return;
    }
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag)
        return;
    NSArray* hints = [self.game hintActions];
    NSInteger total = [hints count];
    if (total == 0) {
        NSString* hintInfo = [NSString stringWithFormat:NSLocalizedStringFromTable(@"nomoves", @"Language", nil)];
        self.gameView.hintLabel.alpha = 0.0;
        self.gameView.hintLabel.text = hintInfo;
        [UIView animateWithDuration:5*HINTINFO_TIME delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.gameView.hintLabel.alpha = 1.0;
                         } completion:^(BOOL finished){
                             [UIView animateWithDuration:5*HINTINFO_TIME
                                animations:^{
                             self.gameView.hintLabel.alpha = 0;
                                }];
                         }];
    }
    else
    {
        self.gameView.hinting = YES;
        int cardNum = 0;
        for (MoveAction* ma in hints) {
            cardNum += ma.cardcnt;
        }
        self.gameView.anaCnt = cardNum;
        self.gameView.anaIdx = 0;
        for (int i = 0; i < total; i++) {
            MoveAction* ma = [hints objectAtIndex:i];
            int pos = ma.to;
            int idx = ma.toIdx;
            NSMutableArray* cards = [[NSMutableArray alloc] init];
            switch (ma.from) {
                case POS_TABEAU:
                    {
                        NSUInteger tempCnt = [[_game tableau:ma.fromIdx] count];
                        for (int i = tempCnt - ma.cardcnt; i < tempCnt; i++) {
                            [cards addObject:[[_game tableau:ma.fromIdx] objectAtIndex:i]];
                        }
                    }
                    break;
                case POS_FOUNDATION:
                    [cards addObject:[[_game foundation:ma.fromIdx] lastObject]];
                    break;
                case POS_WASTE:
                    [cards addObject:[[_game waste] lastObject]];
                    break;
                default:
                    break;
            }
            NSArray* param = [[NSArray alloc] initWithObjects:cards, [NSNumber numberWithInt:pos], [NSNumber numberWithInt:idx], [NSNumber numberWithInt:i+1], [NSNumber numberWithInt:total], nil];
            [self performSelector:@selector(eachHintMove:) withObject:param afterDelay:(MOVE_TIME+HINTINFO_TIME*2)*i];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == TAG_PLAY) {
        if (buttonIndex == 0) {
            ///update gamestat
            if (self.game.won == NO) {
                if (self.game.draw3) {
                    self.gameStat.draw3.lostCnt++;
                }
                else
                {
                    self.gameStat.draw1.lostCnt++;
                }
            }
            ///
            [self.game freshGame:winBoards];
            self.gameView.game = _game;
        }
        else if (buttonIndex == 1)
        {
            ///update gamestat
            if (self.game.won == NO) {
                if (self.game.draw3) {
                    self.gameStat.draw3.lostCnt++;
                }
                else
                {
                    self.gameStat.draw1.lostCnt++;
                }
            }
            [self.game replayGame];
            self.gameView.game = _game;
        }
        ///
        if (buttonIndex == 0 || buttonIndex == 1) {
            NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
            int timecnt = [[settings objectForKey:@"cnt"] integerValue];
            timecnt++;
            [settings setObject:[NSNumber numberWithInt:timecnt] forKey:@"cnt"];
            if (timecnt % TIMECNT_FOR_AD == 0) {
                self.setshow = NO;
               
                // temporary not show inter ad when start a game. as admob policy poblem
                //[[AdmobViewController shareAdmobVC] try_show_admob_interstitial:self placeid:3 ignoreTimeInterval:NO];
            }
        }
        //
        //
        sheetShowFlag = NO;
    }
    else if (actionSheet.tag == TAG_AUTOCOMPLETE)
    {
        if (buttonIndex == 0) {
            [self autoComplete:self];
        }
        autoSheetShowFlag = NO;
    }
}

- (void)autoCompleteDone:(NSNotification*)notifacation
{
    /// update stat
    if (self.game.won == NO) {
        if (self.game.draw3) {
            [self.gameStat.draw3 updateStat:self.game.times scores:self.game.scores moves:self.game.moves undos:self.game.undos];
        }
        else
        {
            [self.gameStat.draw1 updateStat:self.game.times scores:self.game.scores moves:self.game.moves undos:self.game.undos];
        }
        //
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        int timecnt = [[settings objectForKey:@"cnt"] integerValue];
        if(timecnt >= 2) {
            [[AdmobViewController shareAdmobVC] try_show_admob_interstitial:self placeid:2 ignoreTimeInterval:NO];
        }
        
        [[AdmobViewController shareAdmobVC] checkConfigUD];
    }
    ///
    self.game.won = YES;
    self.gameView.winLabel.hidden = NO;
    self.gameView.btnUndo.hidden = YES;
    self.gameView.btnWin.hidden = YES;
    NSString* path = [NSString stringWithFormat:@"%@/Documents/stat.dat",NSHomeDirectory()];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.gameStat];
    [data writeToFile:path atomically:YES];
}

- (void)autoCompleteActionSheet:(NSNotification*)notifacation
{
    /*
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
otherButtonTitles:NSLocalizedStringFromTable(@"autohint", @"Language", nil), NSLocalizedStringFromTable(@"cancel", @"Language", nil), nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = TAG_AUTOCOMPLETE;
    [actionSheet showInView:self.view];
     */
    [self showAutoActionSheet];
}

- (void)changeSettings:(NSNotification*)notifacation
{
    NSString* object = notifacation.object;
    if ([object isEqualToString:@"cardback"]) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        NSString* newBack = [settings objectForKey:@"cardback"];
        [CardView setBackImage:newBack];
        [self.gameView updateCardBack];
    }
    else if ([object isEqualToString:@"classic"])
    {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        BOOL classic = [settings boolForKey:@"classic"];
        [Card setClassic:classic];
        [self.gameView updateCardForground];
    }
    else if ([object isEqualToString:@"background"]) {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        NSString* newBack = [settings objectForKey:@"background"];
        if ([newBack hasPrefix:@"userdefined"]) {
            NSString *retinaStr = @"";
            if ([[UIScreen mainScreen] scale] == 2.0) {
                retinaStr = @"@2x";
            }
            NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), newBack, retinaStr];
            self.gameView.gameBg.image = [UIImage imageWithContentsOfFile:imgName];
        }
        else
            self.gameView.gameBg.image = [UIImage imageNamed:newBack];
    }
}

- (void)updateBkSelected:(int)idx
{
    for (PicView* npv in [NSMutableArray arrayWithCapacity:14]) {
        if (npv.theid == idx)
            [npv setCheck:YES];
        else
            [npv setCheck:NO];
    }
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

- (BOOL)isLandscape {
    // 横屏
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    return UIDeviceOrientationIsLandscape(orientation);
}
- (BOOL)getCurrentSound{
    //    获取当前音量
    CGFloat volume = audioSession.outputVolume;
    NSLog(@"volume=  %lf",volume);
    if (volume*100 < 1) { //volum<0.01 means no voice
        return FALSE;
    }else{
        return TRUE;
    }
}
@end
