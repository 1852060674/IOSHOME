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
#import "admob.h"
#import "UIApplication+Size.h"
#import "Config.h"
#import "UIKit/UIKit.h"
#include "ApplovinMaxWrapper.h"
#import "ZhConfig.h"

#import "DismissibleView.h"
#import "RoundCornerSettingView.h"
#import "RoundCornerRuleView.h"
#import "RoundCornerStatView.h"
#import "RoundCornerThemeView.h"
#import "RoundCornerNewGameView.h"
#import "WinAnimator.h"
enum enum_tagid {
    TAG_PLAY = 1,
    TAG_AUTOCOMPLETE = 2
    };

typedef enum : NSUInteger {
  OpSetting = 0,
  OpTheme,
  OpNewGame,
  OpHint,
  OpUndo
} OpType;

@interface ViewController ()
{
    
    NSTimer *timer;
    BOOL undoFlag;
    NSMutableArray *winBoards;
    int highscore;
    BOOL isAutoCompleting;
    UIAlertView* alert;
    BOOL firstIn;
    BOOL oldman;
    ///
    //
    UIActionSheet *newActionSheet;
    BOOL sheetShowFlag;
   
}
@property (strong, nonatomic) UIButton *autoB;
@end

@implementation ViewController
@synthesize game = _game;
@synthesize gameStat = _gameStat;
@synthesize showCongra = _showCongra;
@synthesize thvc;
@synthesize svc;
@synthesize setshow;

- (void)loadSettings
{
  
    [self isoldman];
    // 加个点击事件
    [self.gameView.themesButton addTarget:self action:@selector(themesButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    /// load
    //cardback
    NSString* backCardName = [settings objectForKey:@"cardback"];
    [CardView setBackImage:backCardName];
    //sound
    self.gameView.sound = [settings boolForKey:@"sound"];
    //speed
    self.gameView.speed = [settings integerForKey:@"speed"];
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
    NSLog(@"cell.sw.on loadsetting0= %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"classic"]);
    if ([settings boolForKey:@"classic"]) {
        [Card setClassic:YES];
    }
    else
        [Card setClassic:NO];
    NSLog(@"cell.sw.on viewwillapp1= %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"classic"]);
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
        if ([seqs count] == 52) {
            [winBoards addObject:seqs];
        }
    }
    
    //11
    // 0328 add oldman show
    if (oldman) {
        // 获取按钮的图片
        UIImage *settingBtnImage = [UIImage imageNamed:@"Settingss"];
        [self.gameView.btnSettings setImage:settingBtnImage forState:UIControlStateNormal];
        UIImage *newgame = [UIImage imageNamed:@"New"];
        [self.gameView.btnPlay setImage:newgame forState:UIControlStateNormal];
    }else{
        // 加载新的图片
        UIImage *settingbutn = [UIImage imageNamed:@"settings"];
        [self.gameView.btnSettings setImage:settingbutn forState:UIControlStateNormal];
        UIImage *newgame = [UIImage imageNamed:@"newgame"];
        [self.gameView.btnPlay setImage:newgame forState:UIControlStateNormal];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //[textField selectAll:self];
    //[UIMenuController sharedMenuController].menuVisible = NO;
    [textField setSelectedTextRange:[textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument]];
}

- (void)showTopHigh
{
    if ([_gameStat inTop:[[self.game.totalscores objectAtIndex:0] integerValue]])
    {
        highscore = [[self.game.totalscores objectAtIndex:0] integerValue];
        alert = [[UIAlertView alloc]initWithTitle:@""
                                          message:@"Congratulations!You have got a better score!"
                                         delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil,nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *tf = [alert textFieldAtIndex:0];
        tf.text = @"anonymous";
        tf.delegate = self;
        [alert show];
    }
}


- (void)themesButtonClicked {
    // 按钮点击事件处理逻辑
    NSLog(@"zzx 按钮被点击了");
    if (self.gameView.hinting) {
        return;
    }
    
    //
    UIView * view = [self themeView];
    [self.gameView.superview addSubview:view];
}
- (IBAction)showSet:(id)sender {
    /// for top high
    
    //    UIView *parentView = self.gameview.superview;
    //    [parentView addSubview:view];
    
    //        UIView * view = [self settingView];
    //        UIView *parentView = self.gameView.superview;
    //        [parentView addSubview:view];
    
    [self showSetByzh];
    //    if (self.gameView.hinting) {
    //        return;
    //    }
    //    self.setshow = NO;
    //    [self performSegueWithIdentifier:@"setsegue" sender:self];
    
    
    //    // add 20240307 20.23
    //    // 使用 `NSUserDefaults` 保存设置
    //    // end 20.23
    //    id obj = [settings1 objectForKey:New_Boy_Comming];
    //    if (obj == nil) {
    //        UIView * view = [self settingView];
    //        [self.view addSubview:view];
    //    }else{
    //        if (self.gameView.hinting) {
    //            return;
    //        }
    //        self.setshow = NO;
    //        [self performSegueWithIdentifier:@"setsegue" sender:self];
    //    }
}
-(void)showSetByzh{
    if (oldman || Open_Old) {
        if (self.gameView.hinting) {
            return;
        }
        self.setshow = NO;
        [self performSegueWithIdentifier:@"setsegue" sender:self];
    }else{
        UIView * view = [self settingView];
        UIView *parentView = self.gameView.superview;
        [parentView addSubview:view];
    }
}

- (void)showRuleView {
  if (self.gameView.hinting) {
    return;
  }
  UIView * view = [self ruleView];
  UIView *parentView = self.gameView.superview;
  [parentView addSubview:view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    self.gameView.delegate = self;
    //self.gameView.game = _game;
    firstIn = YES;
    self.setshow = NO;
    timer = [NSTimer scheduledTimerWithTimeInterval:[self.gameView speedTime] target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    ///
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoCompleteDone:) name:@"autoCompleteDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoCompleteActionSheet:) name:@"autoAction" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSettings:) name:@"settings" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayHigh:) name:@"high" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayStanding:) name:@"standing" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeStanding:) name:@"closestanding" object:nil];
    

    /// admob zzx
    
    if(![[AdmobViewController shareAdmobVC] ifNeedShowNext:self]) {
        [[AdmobViewController shareAdmobVC] decideShowRT:self];
    }
    
    ///
    undoFlag = NO;
    ///
    UIStoryboard *storyboard = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_ipad" bundle:nil];
    }
    else
        storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    self.thvc = [storyboard instantiateViewControllerWithIdentifier:@"TopHigh"];
//    [self.thvc setVC:self];
    self.svc = [storyboard instantiateViewControllerWithIdentifier:@"CurrentStanding"];
    self.svc.close = YES;
    ((UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController]).modalPresentationStyle = UIModalPresentationCurrentContext;
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
}

- (void)updateTime
{
    [self.gameView turn];
}

- (IBAction)undo:(id)sender {
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag)
        return;
    undoFlag = YES;
    undoFlag = NO;
}

- (void)delayShow
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"high" object:@"high"];
}

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 200)
    {
        if (buttonIndex == 1) {
            NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
            [settings setBool:YES forKey:@"rated"];
            [settings synchronize];
            //
            NSString* rate_url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", kAppID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rate_url]];
        }
    }
    else
    {
    //得到输入框
    [timer setFireDate:[NSDate distantFuture]];
    UITextField *tf = [alertView textFieldAtIndex:0];
    [_gameStat addToTop:[[NameScore alloc] initWithNameScore:highscore name:tf.text]];
    [self performSelector:@selector(delayShow) withObject:nil afterDelay:0.3];
    }
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    [alert dismissWithClickedButtonIndex:buttonIndex animated:YES];
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
    [self.gameView rotateLayout:toInterfaceOrientation];
    [self adjustDimView:toInterfaceOrientation];
    [self.gameView updateInfoList];
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
//    //background old
//    NSString* newBack = [self getRealBackImgName:[[NSUserDefaults standardUserDefaults] objectForKey:@"background"]];
//    if ([newBack hasPrefix:@"userdefined"]) {
//        NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(), newBack];
//        self.gameView.gameBg.image = [UIImage imageWithContentsOfFile:imgName];
//    }
//    else
//    {
//        self.gameView.gameBg.image = [UIImage imageNamed:newBack];
//    }
    
    [self isoldman];
    //最垃圾的解决办法，补偿措施
    //background new
    NSString* newBack = [self getRealBackImgName:[[NSUserDefaults standardUserDefaults] objectForKey:@"background"]];
    if ([newBack hasPrefix:@"userdefined"]) {
      NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(), newBack];
      self.gameView.gameBg.image = [UIImage imageWithContentsOfFile:imgName];
    } else {
      UIImage * aim = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[newBack stringByDeletingPathExtension] ofType:[newBack pathExtension]]];
      if (![self isPortrait] && ![newBack containsString:@"-l"]) {
        aim = [[UIImage alloc] initWithCGImage:aim.CGImage scale:aim.scale orientation:UIImageOrientationLeft];
      }
      UIImage * ii = [self scaledImage:aim forScreen:self.view];
      self.gameView.gameBg.image = ii;
    }
    if (self.gameView.gameBg.image == nil) {
        if (oldman || Open_Old) {//后嘛需要改 0312             NSLog(@"test first1 coming im old man");
            if ([newBack isEqualToString:@""]) {
                self.gameView.gameBg.image = [UIImage imageNamed:@"RedFelt"];
            }else{
                //补偿措施。最后的安全措施
                self.gameView.gameBg.image = [UIImage imageNamed:newBack];
//                if ([newBack hasPrefix:@"bg"]) {
//                    self.gameView.gameBg.image = [UIImage imageNamed:@"RedFelt"];
//                }
            }
                
            
        }else{
            if ([newBack isEqualToString:@""]) {
                self.gameView.gameBg.image = [UIImage imageNamed:@"bg0.jpg"];
            }else{
                NSString *imgName = [NSString stringWithFormat:@"%@.jpg",newBack];
                self.gameView.gameBg.image = [UIImage imageNamed:imgName];
//                self.gameView.gameBg.image = [UIImage imageNamed:@"bg0.jpg"];
            }

        }
//        NSString *imgName = [NSString stringWithFormat:@"%@.jpg",newBack];
//       self.gameView.gameBg.image = [UIImage imageNamed:imgName];
        
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[AdmobViewController shareAdmobVC] onOrientationChangeFrom:fromInterfaceOrientation];
    NSLog(@"zzx uiAdjust before1 execute");
    [self.gameView uiAdjust];
    [self setBackImage];
    //
    [self adjustDimView:[[UIApplication sharedApplication] statusBarOrientation]];
    [self reloadInterAd];
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 || [[UIDevice currentDevice] userInterfaceIdiom]) && sheetShowFlag)
    {
        [self performSelectorOnMainThread:@selector(showNewActionSheet) withObject:self waitUntilDone:YES];
    }
}
- (void)reloadInterAd {
  // init_admob_interstitial
  // _interstitial_reload
  id obj = [[AdmobViewController shareAdmobVC] valueForKey:@"adcenter"];
  if ([obj respondsToSelector:@selector(_interstitial_reload)]) {
    [obj performSelector:@selector(_interstitial_reload)];
  }
}

- (void)viewWillAppear:(BOOL)animated
{   
    [AdmobViewController shareAdmobVC].rootViewController = self;
    
    
    
    [[AdmobViewController shareAdmobVC] show_admob_banner:self.gameView.admobView placeid:@"gamepage"];
    _admobHeightt.constant=admobHeight1;
    // hide navigate bar
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    /// start timer
    [timer setFireDate:[NSDate distantPast]];
    ///ios7

    if (firstIn) {
        [self.gameView firstInCompute];
        self.gameView.game = _game;
        firstIn = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.svc != nil
        && self.svc.close == NO
        && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
        && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0
        )
    {
        self.svc.close = YES;
        return;
    }
    if (self.setshow
        && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        self.setshow = NO;
        return;
    }
    [self.gameView rotateLayout:[[UIApplication sharedApplication] statusBarOrientation]];
    [self.gameView uiAdjust];
    [self setBackImage];
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
    //sound
    [settings setBool:self.gameView.sound forKey:@"sound"];
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
    NSLog(@"cell.sw.on viewwillapp0= %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"classic"]);
    [settings setBool:[Card classic] forKey:@"classic"];
    ///
    [settings synchronize];
    NSLog(@"cell.sw.on viewwillapp= %d",[[NSUserDefaults standardUserDefaults] boolForKey:@"classic"]);
}

#pragma mark game protocal

- (void)viewDidUnload {
    [self setGameView:nil];
    [super viewDidUnload];
}

- (IBAction)newGame:(id)sender {
    ///
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag)
        return;
    //
    if (oldman) {
        [self showNewActionSheet];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        //
        isAutoCompleting = NO;
        UIView * view = [self newGameView];
        [self.gameView.superview addSubview:view];
    }
    
}

- (void)showNewActionSheet
{
    newActionSheet = [[UIActionSheet alloc]
                      initWithTitle:nil
                      delegate:self
                      cancelButtonTitle:nil
                      destructiveButtonTitle:nil
                      otherButtonTitles:@"New Game", @"Cancel", nil];
    newActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    newActionSheet.tag = TAG_PLAY;
    [newActionSheet showInView:self.view];
    sheetShowFlag = YES;
}

- (void)cancelDelay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)eachCompleteMove
{
    /*
    self.gameView.topCards = [self.game completeEach];
    if (self.gameView.sound)
        AudioServicesPlaySystemSound(self.gameView.clickQuickSound);
    [self.gameView computeCardLayout:HINTINFO_TIME destPos:-1 destIdx:-1];
     */
}

- (IBAction)autoComplete:(id)sender {
    /*
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
     */
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
    /*
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
        NSString* hintInfo = [NSString stringWithFormat:@"No useful moves detected"];
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
                default:
                    break;
            }
            NSArray* param = [[NSArray alloc] initWithObjects:cards, [NSNumber numberWithInt:pos], [NSNumber numberWithInt:idx], [NSNumber numberWithInt:i+1], [NSNumber numberWithInt:total], nil];
            [self performSelector:@selector(eachHintMove:) withObject:param afterDelay:(MOVE_TIME+HINTINFO_TIME*2)*i];
        }
    }
     */
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == TAG_PLAY) {
        if (buttonIndex == 0) {
            ///update gamestat
            if (self.game.won == NO) {
                self.gameStat.freecell.lostCnt++;
            }
            ///
            [self.game freshGame:winBoards];
            self.gameView.game = _game;
        }
        //
        sheetShowFlag = NO;
    }
    else if (actionSheet.tag == TAG_AUTOCOMPLETE)
    {
        if (buttonIndex == 0) {
            [self autoComplete:self];
        }
    }
}

- (void)autoCompleteDone:(NSNotification*)notifacation
{
    if (self.game.won) {
        return;
    }
    /// update stat
    if (self.game.won == NO) {
        if ([self.game gameOver] != 0) {
            self.gameView.winLabel.text = @"You Lost!";
            self.gameStat.freecell.lostCnt++;
        }
        else
        {
            self.gameView.winLabel.text = @"You Won!";
            [self.gameStat.freecell updateStat:0 scores:[[self.game.totalscores objectAtIndex:0] integerValue] moves:0 undos:0];
            //[self showTopHigh];
        }
    }
    ///
    self.game.won = YES;
    self.gameView.winLabel.hidden = NO;
    //self.gameView.btnUndo.hidden = YES;
    //self.gameView.btnWin.hidden = YES;
    NSString* path = [NSString stringWithFormat:@"%@/Documents/stat.dat",NSHomeDirectory()];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.gameStat];
    [data writeToFile:path atomically:YES];
}

- (void)autoCompleteActionSheet:(NSNotification*)notifacation
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Auto Complete The Game", @"Cancel", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = TAG_AUTOCOMPLETE;
    [actionSheet showInView:self.view];
}

- (void)displayHigh:(NSNotification*)notifacation
{
    NSString* object = notifacation.object;
    if ([object isEqualToString:@"high"]) {
        ((UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController]).modalPresentationStyle = UIModalPresentationCurrentContext;
        self.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//        [self.thvc setTopNameScore:_gameStat.topScores];
//        self.thvc.ori = [[UIApplication sharedApplication] statusBarOrientation];
//        self.thvc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//        [self presentModalViewController:self.thvc animated:YES];
    }
}

- (void)displayStanding:(NSNotification*)notifacation
{
    NSString* object = notifacation.object;
    if ([object isEqualToString:@"standing"]) {
        [self showStanding];
    }
}

- (void)showStanding
{
    ((UINavigationController*)[[[UIApplication sharedApplication] keyWindow] rootViewController]).modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.svc setSocres:_game.currentscores totalScores:_game.totalscores handCnt:_game.handcnt];
    self.svc.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.svc.modalPresentationStyle = UIModalPresentationOverFullScreen;//UIModalPresentationFullScreen;
    //[self presentModalViewController:self.svc animated:YES];
    ///
    self.svc.close = YES;
    [self presentViewController:self.svc animated:YES completion:^{
        self.svc.view.superview.backgroundColor = [UIColor clearColor];
    }];
}

- (void)closeStanding:(NSNotification*)notifacation
{
    if (notifacation.object != nil)
    {//zzx end
        //[self performSelectorOnMainThread:@selector(showFullAds) withObject:self waitUntilDone:1];
        [self showFullAds];
        return;
        //
    }
    //[self performSelector:@selector(showFullAds) withObject:self afterDelay:1];
    //[self showFullAds];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
        && [[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
        return;
    //
    [self.gameView rotateLayout:[[UIApplication sharedApplication] statusBarOrientation]];
    [self.gameView uiAdjust];
    [self setBackImage];
}

- (void)adMobVCDidCloseInterstitialAd:(AdmobViewController*)adMobVC
{
    [self.gameView newDeal];
    NSLog(@"zzx  admob isclose");
}

- (void)changeSettings:(NSNotification*)notifacation
{
    NSString* object = notifacation.object;
    if (![object isKindOfClass:[NSString class]]) {
      return;
    }
    if ([object containsString:@"cardback"]) {
      NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
      NSString* newBack = [settings objectForKey:@"cardback"];
      [CardView setBackImage:newBack];
      [self.gameView updateCardBack];
    }
    if ([object containsString:@"cardfront"]) {
      NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
      NSString* newFront = [settings objectForKey:@"cardfront"];
      [Card setFrontName:newFront];
      [self.gameView updateCardForground];
    }
    if ([object containsString:@"background"]) {
      [self setBackImage];
    }
//    NSString* object = notifacation.object;
//    if ([object isEqualToString:@"cardback"]) {
//        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//        NSString* newBack = [settings objectForKey:@"cardback"];
//        [CardView setBackImage:newBack];
//        [self.gameView updateCardBack];
//    }
//    else if ([object isEqualToString:@"classic"])
//    {
//        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//        BOOL classic = [settings boolForKey:@"classic"];
//        [Card setClassic:classic];
//        [self.gameView updateCardForground];
//    }
//    else if ([object isEqualToString:@"background"]) {
//        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//        NSString* newBack = [settings objectForKey:@"background"];
//        if ([newBack hasPrefix:@"userdefined"]) {
//            NSString *retinaStr = @"";
//            if ([[UIScreen mainScreen] scale] == 2.0) {
//                retinaStr = @"@2x";
//            }
//            NSString *imgName = [NSString stringWithFormat:@"%@/Documents/%@%@.png",NSHomeDirectory(), newBack, retinaStr];
//            self.gameView.gameBg.image = [UIImage imageWithContentsOfFile:imgName];
//        }
//        else{
//            NSString *imgName = [NSString stringWithFormat:@"%@.jpg",newBack];
//            self.gameView.gameBg.image = [UIImage imageNamed:imgName];
//        }
//           
//    }
//    //zzx
//    if ([object containsString:@"cardfront"]) {
//        // 0401 import
//      NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//      NSString* newFront = [settings objectForKey:@"cardfront"];
//      [Card setFrontName:newFront];
//      [self.gameView updateCardForground];
//    }
}

/////ad




- (void)rateForRemoveFullAds
{
    UIAlertView *rateDlg = [[UIAlertView alloc] initWithTitle:@""
                                                      message:@"Would you like to rate us 5 stars to remove fullscreen ADS?"
                                                     delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Rate Us", nil];
    rateDlg.tag = 200;
    [rateDlg show];
}//...

// zzx 全屏
- (void)showFullAds
{
    ///cnt for show ad
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    int timecnt = (int)[settings integerForKey:@"cnt"];
    timecnt++;
    [settings setInteger:timecnt forKey:@"cnt"];
    [settings synchronize];
    if (timecnt % TIMECNT_FOR_AD == 0) {
        if ([[AdmobViewController shareAdmobVC] try_show_admob_interstitial:self placeid:2 ignoreTimeInterval:NO]) {
        }
        else
        {
            [self.gameView newDeal];
        }
    }
    else
    {
        [self.gameView newDeal];
    }
   
//    
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//    long timecnt = [[settings objectForKey:@"cnt"] integerValue];
//    timecnt++;
//    [settings setObject:[NSNumber numberWithLong:timecnt] forKey:@"cnt"];
//    if(timecnt >= 2) {
//        [[AdmobViewController shareAdmobVC] try_show_admob_interstitial:self placeid:2 ignoreTimeInterval:NO];
}

    
/// 20240306 add by zzx
- (DismissibleView *)settingView {
    RoundCornerSettingView * settingview = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerSettingView" owner:nil options:nil].firstObject;
    settingview.delegate = self;
    
    settingview.frame = [self frameForSettingView:[self isPortrait]];
	settingview.viewHeig = settingview.frame.size.height - 100;
    [settingview prepareForPortrait:[NSNumber numberWithBool:[self isPortrait]]];
    return [self dismissibleViewWithView:settingview];
}

- (BOOL)isPortrait {
  return [self.gameView isPortrait];;
}

- (CGRect)frameForSettingView:(BOOL)isp {

  CGRect rect = [self defaultBoundsForDialogViewPortrait:isp];
  if (isp) {
    rect.size.height *= 0.7;
  } else {
    rect.size.width *= 0.5;
  }
  return rect;
}

- (CGRect)defaultBoundsForDialogViewPortrait:(BOOL)port {
  CGRect rect = [[UIScreen mainScreen] bounds];
  CGFloat height = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect));
  if (port) {
    CGRect val = CGRectMake(0, 0, height*(IS_IPAD?0.6:0.715), height*(IS_IPAD?0.8:1));
    if (height<376) {
      CGFloat scale = 400/height;
      val = CGRectApplyAffineTransform(val, CGAffineTransformMakeScale(scale, (port?scale:1)));
    }
    return val;
  } else {
    if (IS_IPAD) {
      return CGRectMake(0, 0, 640, 480);
    } else {
      CGFloat width = MAX(CGRectGetHeight(rect), CGRectGetWidth(rect));
      CGRect val = CGRectMake(0, 0, width*0.96, height*0.96);
      return val;
    }

  }
}

- (DismissibleView *)dismissibleViewWithView:(UIView *)view {
  DismissibleView * dview = [[DismissibleView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  dview.contentSize = view.frame.size;
  [dview addContentView:view];
  return dview;
}

- (IBAction)skinPicker:(id)sender {
//  [self reset_banner_downcount];

  if (self.gameView.hinting) {
    return;
  }

//
//  UIView * view = [self themeView];
//  [self.view addSubview:view];
}

- (DismissibleView *)themeView {
  RoundCornerThemeView * themeV = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerThemeView" owner:nil options:nil].firstObject;
  CGRect rect = [self frameForThemeViewPortrait:[self isPortrait]];
  themeV.frame = rect;
  [themeV prepareForPortrait:[NSNumber numberWithBool:[self isPortrait]]];
  return [self dismissibleViewWithView:themeV];
}

- (DismissibleView *)ruleView {
  RoundCornerRuleView * ruleview = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerRuleView" owner:nil options:nil].firstObject;

  ruleview.frame = [self defaultBoundsForDialogViewPortrait:[self isPortrait]];
  [ruleview prepareForPortrait:[NSNumber numberWithBool:[self isPortrait]]];

  return [self dismissibleViewWithView:ruleview];
}

- (CGRect)frameForThemeViewPortrait:(BOOL)port {
  CGRect rect = [[UIScreen mainScreen] bounds];
  CGFloat height = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect));
  if (port) {
    CGRect val = IS_IPAD?CGRectMake(0, 0, height*0.6, height*0.8):CGRectMake(0, 0, height*0.715, height*(port?1.1:1));
    if (fabs(height-320)<1) {
      CGFloat scale = 1.25;
      val = CGRectApplyAffineTransform(val, CGAffineTransformMakeScale(scale, port?scale:1));
    }
    return val;
  } else {
    if (IS_IPAD) {
      return CGRectMake(0, 0, 720, 480);
    } else {
      CGFloat width = MAX(CGRectGetHeight(rect), CGRectGetWidth(rect));
      CGRect val = CGRectMake(0, 0, width*0.96, height*0.96);
      return val;
    }
  }
}


- (UIImage *)scaledImage:(UIImage *)image forScreen:(UIView *)view {
  if (image == nil) {
    return nil;
  }
  CGRect rect1 = view.bounds;
  CGRect rect = AVMakeRectWithAspectRatioInsideRect(image.size, rect1);
  CGFloat scale = MAX(CGRectGetWidth(rect1)/CGRectGetWidth(rect), CGRectGetHeight(rect1)/CGRectGetHeight(rect));
  CGRect rect0 = CGRectZero;
  rect0.size.width = CGRectGetWidth(rect)*scale;
  rect0.size.height = CGRectGetHeight(rect)*scale;
  rect0.origin.x = CGRectGetMidX(rect1)-rect0.size.width/2;
  rect0.origin.y = CGRectGetMidY(rect1)-rect0.size.height/2;
  rect0 = CGRectIntegral(rect0);
  rect1 = CGRectIntegral(rect1);
  UIGraphicsBeginImageContext(rect1.size);
  [image drawInRect:rect0];
  UIImage * val = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return val;
}

- (void)adjustDimView:(UIInterfaceOrientation)toInterfaceOrientation {
  NSArray <DismissibleView *>* dviews = [self.gameView.superview.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    return [evaluatedObject isKindOfClass:[DismissibleView class]];
  }]];

  for (DismissibleView * view in dviews) {

    UIView * cv = view.contentView;
    if (cv == nil) {
      return;
    }
    CGSize size = [UIApplication sizeInOrientation:toInterfaceOrientation];

    NSInteger type = 0;

#define CV_IS_YOUWIN 1
#define CV_IS_NEWGAME 2
#define CV_IS_THEME 3
#define CV_IS_SET 4
//      [cv isKindOfClass:[YouWinView class]]

    if (0) {
      type = CV_IS_YOUWIN;
    } else if ([cv isKindOfClass:[RoundCornerNewGameView class]]) {
      type = CV_IS_NEWGAME;
    } else if ([cv isKindOfClass:[RoundCornerThemeView class]]) {
      type = CV_IS_THEME;
    } else if ([cv isKindOfClass:[RoundCornerSettingView class]] || [cv isKindOfClass:[RoundCornerStatView class]]) {
      type = CV_IS_SET;
    }


    //  CGRect frm = view.contentView.frame;
    BOOL isp = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);

    [UIView animateWithDuration:0.2 animations:^{
      view.frame = CGRectMake(0, 0, size.width, size.height);
      if (type == CV_IS_YOUWIN) {
//        view.contentSize = [self victoryFramePortrait:isp].size;
//        YouWinView * vview = (YouWinView *)view.contentView;
//        if (IS_IPAD && [vview isKindOfClass:[YouWinView class]]) {
//          vview.tableWidthC.constant = (isp)?150:100;
//        }
      } else if (type == CV_IS_NEWGAME) {
        //      view.contentSize = frm.size;
      } else if (type == CV_IS_THEME) {
        view.contentSize = [self frameForThemeViewPortrait:isp].size;
      } else if (type == CV_IS_SET) {
        view.contentSize = [self frameForSettingView:isp].size;
      } else {
        view.contentSize = [self defaultBoundsForDialogViewPortrait:isp].size;
      }
      if ([view.contentView respondsToSelector:@selector(prepareForPortrait:)]) {
        [view.contentView performSelector:@selector(prepareForPortrait:) withObject:[NSNumber numberWithBool:isp]];
      }
      cv.center = CGPointMake(size.width/2, size.height/2);
    }];
  }


}

-(void)isoldman{
    // New_Boy_Comming 是判断第一次是老用户还是薪用户
    NSUserDefaults* settings1 = [NSUserDefaults standardUserDefaults];
    id obj = [settings1 objectForKey:New_Boy_Comming];
    id obj1 = [settings1 objectForKey:@"changetoNewMan"];
    BOOL NewMan =[settings1 boolForKey:@"changetoNewMan"];
    if (obj == nil) {
        // 说嘛此前已经进入过了是老用户
        oldman =true;
    }
    if (obj1 == nil) {
        // 说明此前没有改变新老用户状态
        return;
    }
    if (NewMan) {
        oldman =false;
        return;
    }else{
        oldman =true;
        return;
    }
   
}
-(BOOL)OldMan{
    return oldman;
}
- (UIButton *)autoB {
  if (!_autoB) {
    _autoB = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [_autoB setTitle:LocalizedGameStr2(auto_complete_title) forState:(UIControlStateNormal)];
    [_autoB setBackgroundImage:[UIImage imageNamed:@"win_close"] forState:(UIControlStateNormal)];
    [_autoB addTarget:self action:@selector(autoBAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:_autoB];
  }
  CGFloat width = 200;
  CGFloat height = 60;
  [self.view insertSubview:_autoB aboveSubview:_gameView];
  //  _autoB.alpha = 0;
  _autoB.frame = CGRectMake(CGRectGetMidX(self.view.bounds)-width/2, CGRectGetHeight(self.view.bounds)-MAX([self heightForToolbar], admobHeight1)-height, width, height);
  return _autoB;
}

- (CGFloat)heightForToolbar {
  CGSize size = [UIApplication currentSize];
  CGFloat minW = MIN(size.width, size.height);
  if (IS_IPAD) {
    return floor(90*minW/768.0);
  } else {
    return floor(50*minW/320.0);
  }
}

- (void)toggleAutoCompleteEnable:(BOOL)enabled {
  self.autoB.hidden = !enabled;
  if (self.game.won) {
    self.autoB.hidden = YES;
  }
  if (isAutoCompleting) {
    self.autoB.hidden = YES;
  }
  [self adjustHintLabel];
}

- (void)adjustHintLabel {
  CGRect frm = self.autoB.frame;
  if (self.autoB.hidden) {
    frm = self.gameView.opBar.frame;
  }
  CGRect hintframe = CGRectMake(0, 0, kScreenWidth, 34);
  CGPoint center = CGPointMake(kScreenWidth/2, CGRectGetMinY(frm)-CGRectGetHeight(hintframe)/2-2);
  self.gameView.hintLabel.frame = hintframe;
  self.gameView.hintLabel.center = center;
}

- (void)autoBAction {
  [self autoComplete:self];
  isAutoCompleting = YES;
  [self toggleAutoCompleteEnable:NO];
}

- (DismissibleView *)newGameView {
  RoundCornerNewGameView * newgameview = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerNewGameView" owner:nil options:nil].firstObject;
  newgameview.delegate = self;
  newgameview.frame = [self newGameFrame];
  return [self dismissibleViewWithView:newgameview];
}

- (CGRect)newGameFrame {
  CGRect rect = [[UIScreen mainScreen] bounds];
  CGFloat width = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect));
  CGRect rect0 = IS_IPAD?CGRectMake(0, 0, width*0.75, width*0.41):CGRectMake(0, 0, width*0.9, width*0.7);
  return CGRectIntegral(rect0);
}


- (void)showStatView {
  if (self.gameView.hinting) {
    return;
  }
  UIView * view = [self statView];
  [self.gameView.superview addSubview:view];
}

- (DismissibleView *)statView {
  RoundCornerStatView * statview = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerStatView" owner:nil options:nil].firstObject;

  statview.frame = [self frameForSettingView:[self isPortrait]];
  [statview prepareForPortrait:[NSNumber numberWithBool:[self isPortrait]]];
  return [self dismissibleViewWithView:statview];
}

- (void)startNewRandomDeal {
  [self suiji:nil];

  [self disableHintForAMoment:NO];
  [timer setFireDate:[NSDate distantPast]];

}

- (void)suiji:(id)sender {
  ///update gamestat
  if (self.game.won == NO) {
    self.gameStat.freecell.lostCnt++;
  }
  ///
  [self.game freshGame:winBoards];
  self.gameView.game = _game;
  //
  [self delayShowAd];


}

- (void)delayShowAd
{
    [[AdmobViewController shareAdmobVC] try_show_admob_interstitial:self ignoreTimeInterval:NO];
    [AdmobViewController shareAdmobVC].delegate = nil;
}

- (void)disableHintForAMoment:(BOOL)disable {
  if (_hintUnavailable == disable) {
    return;
  }
  _hintUnavailable = disable;
//  if ([_opCollectionView numberOfItemsInSection:0] > OpUndo) {
//    [_opCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:OpHint inSection:0]]];
//  }
}
// 不知道什么用阶段
@end
