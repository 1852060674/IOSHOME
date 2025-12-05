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
#import "NewPicView.h"
#import "StatCell.h"
#import "GameStat.h"
#import "DismissibleView.h"
#import "RoundCornerSettingView.h"
#import "RoundCornerRuleView.h"
#import "RoundCornerStatView.h"
#import "RoundCornerThemeView.h"
#import "RoundCornerNewGameView.h"
#import "YouWinView.h"
#import "WinAnimator.h"
#import "OpToolbarCollectionViewCell.h"
#import "Masonry.h"
#import <AVFoundation/AVUtilities.h>
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





@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SolitaireViewDelegate, RoundCornerDialogViewDelegate>
{
    NSTimer *timer;
    BOOL undoFlag;
    NSMutableArray *winBoards;
    BOOL firstIn;
    NSTimer *ptimer;
    BOOL tOri;
    BOOL playGame;
    BOOL gonon;
    UIActionSheet *actionSheett;
    
    UIImagePickerController* bgpc;
    UIImagePickerController* bkpc;
    
    long show_banner;
    BOOL ad_show_last_round_end;


  BOOL isAutoCompleting;
  BOOL isWinAnimating;
  BOOL alreadyWin;

  NSInteger winCount;
    __weak IBOutlet UIView *contentView;
    
}
@property (strong, nonatomic) UICollectionView *opCollectionView;

@property (nonatomic, assign) BOOL winningShowFlag;
@property (strong, nonatomic) UIButton *autoB;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adHeightCon;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewTrailing;
@end

@implementation ViewController
@synthesize game = _game;
@synthesize gameStat = _gameStat;
@synthesize showCongra = _showCongra;

- (void)loadSettings
{
    
    playGame = NO;
    gonon = NO;
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
  self.gameView.stockOnRight = [settings boolForKey:stockOnRight_key];
  self.gameView.freecellOnTop = [settings boolForKey:freecellOnTop_key];
  self.autohintEnabled = [settings boolForKey:@"hints"];
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
    //NSLog(@"full path is %@",boardFile);
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
    [self reset_banner_downcount];
    
    if (self.gameView.hinting) {
        return;
    }
#if 0
    //self.gameView.orienSwitch.on != [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    [self.gameView bringSubviewToFront:self.gameView.shadowImageView];
    self.gameView.shadowImageView.hidden = NO;
    //[self performSegueWithIdentifier:@"setsegue" sender:self];
    [self.gameView bringSubviewToFront:self.gameView.settingsView];
    self.gameView.settingsView.hidden = NO;
#else 
  UIView * view = [self settingView];
  [self.view addSubview:view];
#endif
}


- (void)changeTimePause:(NSNotification *)notice {
  if (notice.userInfo[@"pause"]) {
    BOOL bb = [notice.userInfo[@"pause"] boolValue];
    if (timer) {
      if (bb) {
        [self viewWillDisappear:YES];
        [timer setFireDate:[NSDate distantFuture]];
      } else {
        [timer setFireDate:[NSDate distantPast]];
      }
    }
  }
}


- (void)viewDidLoad
{
  if (IS_IPAD) {
    self.adHeightCon.constant = 90;
  }
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTimePause:) name:pause_time_key object:nil];

    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    [super viewDidLoad];
  [self setBackImage];
  [self addCV];
  self.gameView.opBar = self.opCollectionView;
    [self reset_banner_downcount];
  self.gameView.opDelegate = self;
	// Do any additional setup after loading the view, typically from a nib.
    //
    // splash animate
    /*UIImage *splashImage = [UIImage imageNamed:@"Default"];
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
                     }];*/
    
    /// settings
    [self loadSettings];
    /// game stat
    NSString* pathStat = [NSString stringWithFormat:@"%@/Documents/stat.dat",NSHomeDirectory()];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathStat]) {
        NSData *data = [NSData dataWithContentsOfFile:pathStat];
        self.gameStat = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        //self.gameStat = [[GameStat alloc] init];
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
    self.gameView.hintend = YES;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.game.draw3 = [settings boolForKey:@"draw3"];
    //[self.game freshGame];
    self.gameView.delegate = self;
    //self.gameView.game = _game;
    firstIn = YES;

  timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    ///
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoCompleteDone:) name:@"autoCompleteDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoCompleteActionSheet:) name:@"autoAction" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSettings:) name:@"settings" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBg:) name:@"changebg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBk:) name:@"changebk" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCf:) name:@"changecf" object:nil];

    if (!SHOW_AD) {
        self.gameView.admobView.hidden = YES;
    }
    ///
    undoFlag = NO;
    //load the image
    NSString *retinaStr = @"";
    float scale = [[UIScreen mainScreen] scale];
    if (scale == 2.0)
        retinaStr = @"@2x";
    NSString* bgpath = [NSString stringWithFormat:@"%@/Documents/custombg%@.png",NSHomeDirectory(), retinaStr];
    NSString* bkpath = [NSString stringWithFormat:@"%@/Documents/custombk%@.png",NSHomeDirectory(), retinaStr];
    //NSLog(@"path is %@",imagepath);
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    int idx = [[us objectForKey:@"bg"] integerValue];


    idx = [[us objectForKey:@"bk"] integerValue];
    if (idx >= 0) {
        [CardView setNewBackImage:idx filepath:nil];
        [self.gameView updateCardBack];
    }
    else{
            [CardView setNewBackImage:idx filepath:bkpath];
            [self.gameView updateCardBack];
    }
    bool b = [[us objectForKey:@"classic"] boolValue];
    [Card setClassic:b];
    [self.gameView updateCardForground];
    
    

    ad_show_last_round_end = NO;
  [self.gameView computeSizes:YES];
  [self adjustStatusView];
  [self adjustHintLabel];
  self.gameView.safeBottomHeight = [self safeCardBottomGuide];
  [self toggleAutoCompleteEnable:NO];
}

- (void)viewDidLayoutSubviews {
    if (firstIn) {
        [self.gameView firstInCompute];
        self.gameView.game = _game;
        firstIn = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
  // hide navigate bar
  self.navigationController.navigationBarHidden = YES;

  [self tapOnDesktop];

  /// start timer
  [timer setFireDate:[NSDate distantPast]];

  [self.opCollectionView reloadData];

  if (self.presentedViewController) {
    UIInterfaceOrientation curr = [[UIApplication sharedApplication] statusBarOrientation];
    [self adjustDimView:curr];
    [self.gameView firstInitAutoHintTimer];

    if (UIInterfaceOrientationIsPortrait(curr) != [self isPortrait]) {
      [self reloadInterAd];
      [self.gameView rotateLayout:0];
      [self didRotateFromInterfaceOrientation:0];
    }
  }
    
    [_gameView.admobView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([_gameView adViewHeight]);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self setBackImage];
    [[AdmobViewController shareAdmobVC] show_admob_banner:0 posy:0 view:self.gameView.admobView];
    
    firstIn = NO;
}

- (void)reloadInterAd {
  // init_admob_interstitial
  // _interstitial_reload
  id obj = [[AdmobViewController shareAdmobVC] valueForKey:@"adcenter"];
  if ([obj respondsToSelector:@selector(_interstitial_reload)]) {
    [obj performSelector:@selector(_interstitial_reload)];
  }
}

-(void)popNewgame
{
  playGame = YES;
  NSString *cancel = NSLocalizedStringFromTable(@"cancel", @"Language", nil);
  actionSheett = [[UIActionSheet alloc] initWithTitle:nil
                                             delegate:self
                                    cancelButtonTitle:cancel destructiveButtonTitle:nil
                                    otherButtonTitles: NSLocalizedStringFromTable(@"newgame", @"Language", nil), NSLocalizedStringFromTable(@"replay", @"Language", nil), nil];

  actionSheett.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
  //actionSheett.actionSheetStyle = UIActionSheetStyleDefault;
  actionSheett.tag = TAG_PLAY;
  [actionSheett showInView:self.gameView];
}


- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  NSUserDefaults *usr = [NSUserDefaults standardUserDefaults];
  [usr setBool:[usr boolForKey:@"orientation"] forKey:@"tempori"];
  //    [usr setBool:NO forKey:@"orientation"];
  [usr synchronize];

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
  //[settings setBool:[settings boolForKey:@"orientation"] forKey:@"orientation"];
  ///
  [settings synchronize];
}



-(void)adMobVCDidCloseInterstitialAd:(AdmobViewController *)adMobVC
{
//
//    [self.game freshGame:winBoards];
//    self.gameView.game = _game;
}

- (void)newShowFullAds
{
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    int timecnt = (int)[settings integerForKey:@"cnt"];
    timecnt++;
    [settings setInteger:timecnt forKey:@"cnt"];
    [settings synchronize];
    
    BOOL flag = [settings boolForKey:@"rated"];
    if (!flag && !ad_show_last_round_end && timecnt % TIMECNT_FOR_AD == 0) {
        if(![self show_ad]) {
            [[AdmobViewController shareAdmobVC] show_admob_interstitial:self placeid:1];
        }
    }


  [self.game freshGame:winBoards];
    self.gameView.game = _game;
    
    ad_show_last_round_end = NO;
}



-(void) winShowFullAd {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    BOOL flag = [settings boolForKey:@"rated"];
    if (flag) {
        return;
    }
    
    ad_show_last_round_end = [[AdmobViewController shareAdmobVC] show_admob_interstitial:self placeid:2];
}

- (void)updateTime
{
    [self update_admob_banner_status];
    
    if (self.game.won) {
        return;
    }
    ///
  if (self.gameView.isLayoutingCardView) {
    self.gameView.timeLabel.text = [NSString stringWithFormat:@"%@ %ld:%02ld",NSLocalizedStringFromTable(@"time", @"Language", nil),self.game.times/60,self.game.times%60];
    return;
  }
    self.game.times++;
    self.gameView.timeLabel.text = [NSString stringWithFormat:@"%@ %ld:%02ld",NSLocalizedStringFromTable(@"time", @"Language", nil),self.game.times/60,self.game.times%60];
    if (self.game.times%10 == 0) {
        self.game.scores -= 2;
        if (self.game.scores < 0) {
            self.game.scores = 0;
        }
        self.gameView.scoreLabel.text = [NSString stringWithFormat:@"%@ %ld", NSLocalizedStringFromTable(@"score", @"Language", nil),(long)self.game.scores];
    }
}

- (IBAction)undo:(id)sender {
    [self reset_banner_downcount];
    
    if (self.gameView.hinting) {
        return;
    }
  if (self.gameView.isLayoutingCardView) {
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
  [self toggleUndoEnable:[self.game canUndo]];


    undoFlag = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated. 
}



- (NSString*)getRealBackImgName:(NSString*)name
{
  if ([name hasPrefix:@"userdefined"])
    return name;

  NSString* landscapeBack = [name stringByAppendingString:@"-l"];
  if (![self isPortrait]
      && ([[NSBundle mainBundle] pathForResource:landscapeBack ofType:@"jpg"])) {
    return [landscapeBack stringByAppendingString:@".jpg"];
  }
  else
  {
    return [name stringByAppendingString:@".jpg"];
  }
  ///
  return [name stringByAppendingString:@".jpg"];
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
}


- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        [self.popOver dismissPopoverAnimated:YES];
//    }
//    else
        [self dismissViewControllerAnimated:YES completion:nil];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    ///
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        [self.popOver dismissPopoverAnimated:YES];
//    }
//    else
    
           [self dismissViewControllerAnimated:YES completion:nil];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    ///
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    float scale = [[UIScreen mainScreen] scale];
    UIImage* scaleImage = nil;
    if (picker == bgpc)
    {
        scaleImage = [self reSizeImage:image toSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width*scale, [[UIScreen mainScreen] bounds].size.height*scale)];
    }
    else
    {
        scaleImage = [self reSizeImage:image toSize:CGSizeMake(106*scale, 150*scale)];
    }
    NSString *retinaStr = @"";
    if (scale == 2.0)
        retinaStr = @"@2x";
    /// update
    if (picker == bgpc)
    {
        NSString* path = [NSString stringWithFormat:@"%@/Documents/custombg%@.png",NSHomeDirectory(), retinaStr];
        [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"selectbg"];
        [UIImagePNGRepresentation(scaleImage) writeToFile:path atomically:YES];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        int idx = [[userDefaults objectForKey:@"bg"] integerValue];
        if(idx >= 0){
            [self.gameView hideShadow:0 picIdx:idx ishide:YES];
            //[[(NewPicView *)[self.gameView.bgScroll.subviews objectAtIndex:idx] shadowView] setHidden:YES];
        }
        [userDefaults setObject:[NSNumber numberWithInt:-1] forKey:@"bg"];
        [userDefaults synchronize];
        self.gameView.gameBg.image = [UIImage imageWithContentsOfFile:path];
        [self.gameView updateBgSelected:-1];
    }
    else if (picker == bkpc)
    {
        NSString* pathh = [NSString stringWithFormat:@"%@/Documents/custombk%@.png",NSHomeDirectory(), retinaStr];
        [[NSUserDefaults standardUserDefaults] setObject:pathh forKey:@"selectbk"];
        [UIImagePNGRepresentation(scaleImage) writeToFile:pathh atomically:YES];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        int idx = [[userDefaults objectForKey:@"bk"] integerValue];
        if(idx >= 0)
            //[[(NewPicView *)[self.gameView.bkScroll.subviews objectAtIndex:idx] shadowView] setHidden:YES];
            [self.gameView hideShadow:1 picIdx:idx ishide:YES];
        [userDefaults setObject:[NSNumber numberWithInt:-1] forKey:@"bk"];
        [userDefaults synchronize];
        [CardView setNewBackImage:-1 filepath:pathh];
        //[CardView setNewBackImage:-1 image:scaleImage];
        //self.gameView
        [self.gameView updateCardBack];
        [self.gameView updateBkSelected:-1];
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



- (void)setBackImage
{
    //background
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
    self.gameView.gameBg.image = [UIImage imageNamed:@"bg0.jpg"];
  }
}

- (IBAction)onChange:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.gameView.sound = sw.on;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setBool:sw.on forKey:@"sound"];
    [user synchronize];
}

- (IBAction)onDifficuty:(id)sender {
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setInteger:segment.selectedSegmentIndex forKey:@"level"];
    [settings synchronize];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                   message:@"Difficulty Level Setting Will Take Effect on Next New Game!"
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil,nil];
    [alert show];
}

- (IBAction)onOrientation:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setBool:!sw.on forKey:@"orientation"];
    //NSLog(@"--------%@",[user boolForKey:@"orientation"]?@"yes":@"no");
    NSInteger curor = [[UIApplication sharedApplication] statusBarOrientation];
    [user setInteger:curor forKey:@"currentori"];
    [user synchronize];
}

- (IBAction)onTapmove:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    self.gameView.autoOn = sw.on;
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setBool:sw.on forKey:@"tapmove"];
    [user synchronize];
}

- (IBAction)closeSettings:(id)sender {
    [self reset_banner_downcount];
    
    self.gameView.settingsView.hidden = YES;
    self.gameView.shadowImageView.hidden = YES;
}

- (IBAction)closeSkin:(id)sender {
    [self reset_banner_downcount];
    
    self.gameView.skinView.hidden = YES;
    self.gameView.shadowImageView.hidden = YES;
}

- (IBAction)selectBg:(id)sender {
    bgpc = [[UIImagePickerController alloc] init];
    bgpc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    bgpc.delegate = self;
    [self presentModalViewController:bgpc animated:YES];
}

- (IBAction)selectBk:(id)sender {
    bkpc = [[UIImagePickerController alloc] init];
    bkpc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    bkpc.delegate = self;

    [self presentModalViewController:bkpc animated:YES];
}

- (IBAction)skinPicker:(id)sender {
    [self reset_banner_downcount];
    
    if (self.gameView.hinting) {
        return;
    }
#if 0
    [self.gameView bringSubviewToFront:self.gameView.shadowImageView];
    self.gameView.shadowImageView.hidden = NO;
    [self.gameView bringSubviewToFront:self.gameView.skinView];
    self.gameView.skinView.hidden = NO;
#else 
  UIView * view = [self themeView];
  [self.view addSubview:view];
#endif
}



- (IBAction)statData:(id)sender {
    [self reset_banner_downcount];
    
    if (self.gameView.hinting) {
        return;
    }
    [self.gameView.gamestatTable reloadData];
    [self.gameView bringSubviewToFront:self.gameView.shadowImageView];
    self.gameView.shadowImageView.hidden = NO;
    self.gameView.gamestatView.hidden = NO;
    [self.gameView bringSubviewToFront:self.gameView.gamestatView];
}

- (IBAction)showHelp:(id)sender {
    if (self.gameView.hinting) {
        return;
    }
    self.gameView.helpView.hidden = NO;
    [self.gameView bringSubviewToFront:self.gameView.shadowImageView];
    self.gameView.shadowImageView.hidden = NO;
    [self.gameView bringSubviewToFront:self.gameView.helpView];
}

- (IBAction)resetStastics:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset" message:@"Determin to reset stastics?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self.gameStat reset];
        NSString* path = [NSString stringWithFormat:@"%@/Documents/stat.dat",NSHomeDirectory()];
        NSData *data = [NSKeyedArchiver  archivedDataWithRootObject:self.gameStat];
        [data writeToFile:path atomically:YES];
        [self.gameView.gamestatTable reloadData];
    }
}

- (IBAction)closeGameStat:(id)sender {
    [self reset_banner_downcount];
    
    self.gameView.gamestatView.hidden = YES;
    self.gameView.shadowImageView.hidden = YES;
}

- (IBAction)closeHelpView:(id)sender {
    [self reset_banner_downcount];
    
    self.gameView.helpView.hidden = YES;
    self.gameView.shadowImageView.hidden = YES;
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
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
   // return UIInterfaceOrientationMaskAll;
    BOOL rotateFlag = [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    if (rotateFlag) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else
    {
        int ori = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentori"];
        return (1 << ori);
    }
}

- (BOOL)shouldAutorotate
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"orientation"];
    //return  NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[AdmobViewController shareAdmobVC] willOrientationChangeTo:toInterfaceOrientation];
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (playGame || actionSheett.visible) {
            [actionSheett dismissWithClickedButtonIndex:10 animated:NO];
            gonon = YES;
        }
        else
            gonon = NO;
    }
    
    UIInterfaceOrientation ori = [[UIApplication sharedApplication] statusBarOrientation];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setInteger:toInterfaceOrientation forKey:@"currentori"];
    [user synchronize];
    if((int)[UIScreen mainScreen].nativeBounds.size.height != 2436) {
        [self.gameView rotateLayout:toInterfaceOrientation];
        [self adjustDimView:toInterfaceOrientation];
    }

    BOOL isp = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    CGPoint p = [self.gameView statusLeadingPortrait:isp];
    self.statusViewLeading.constant = p.x;
    self.statusViewTrailing.constant = p.y;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [[AdmobViewController shareAdmobVC] onOrientationChangeFrom:fromInterfaceOrientation];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if((int)[UIScreen mainScreen].nativeBounds.size.height == 2436) {
        UIInterfaceOrientation ori = [[UIApplication sharedApplication] statusBarOrientation];
        
        [self.gameView rotateLayout:ori];
        [self adjustDimView:ori];
    }
    
    [self.gameView computeSizes:YES];
    
    [_gameView.admobView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([_gameView adViewHeight]);
    }];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.opCollectionView performBatchUpdates:^{
          [self.opCollectionView reloadData];
        } completion:^(BOOL finished) {

        }];

        self.gameView.safeBottomHeight = [self safeCardBottomGuide];


        [self setBackImage];

        [self adjustStatusView];
        [self adjustHintLabel];
        [self reloadInterAd];
        [self.gameView computeCardLayout:0 destPos:-1 destIdx:-1];
    });
}

- (CGFloat)safeCardBottomGuide {
  return 5;
}

- (void)adjustStatusView {
  CGPoint p = [self.gameView statusLeading];
  self.statusViewLeading.constant = p.x;
  self.statusViewTrailing.constant = p.y;


}

- (void)adjustHintLabel {
  CGRect frm = self.autoB.frame;
  if (self.autoB.hidden) {
    frm = self.opCollectionView.frame;
  }
  CGRect hintframe = CGRectMake(0, 0, screen_width, 34);
  CGPoint center = CGPointMake(screen_width/2, CGRectGetMinY(frm)-CGRectGetHeight(hintframe)/2-2);
  self.gameView.hintLabel.frame = hintframe;
  self.gameView.hintLabel.center = center;
}

#pragma mark game protocal
-(BOOL)movedFan:(NSArray *)f toTableau:(uint)t {
//    if (([[self.game tableau:t] count] + [f count]) > 13) {
//        return NO;
//    }
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

- (BOOL)movedCard:(Card *)c toStock:(uint)f
{
    if ([_game canDropCard:c onStock:f])
    {
        [_game didDropCard:c onStock:f];
        return YES;
    }
    return NO;
}

- (void)viewDidUnload {
    [self setGameView:nil];
    [super viewDidUnload];
}

- (IBAction)newGame:(id)sender {
    [self reset_banner_downcount];
    
    if (self.gameView.hinting) {
        return;
    }

  if (self.gameView.isLayoutingCardView) {
    return;
  }

    if (undoFlag)
        return;
    playGame = YES;


#if 0
    [actionSheett dismissWithClickedButtonIndex:2 animated:NO];
    actionSheett = nil;
    NSString *cancel = NSLocalizedStringFromTable(@"cancel", @"Language", nil);
    actionSheett = [[UIActionSheet alloc] initWithTitle:nil
                                               delegate:self
                                      cancelButtonTitle:cancel destructiveButtonTitle:nil
                                      otherButtonTitles: NSLocalizedStringFromTable(@"newgame", @"Language", nil), NSLocalizedStringFromTable(@"replay", @"Language", nil), nil];

    //actionSheett.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheett.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheett.tag = TAG_PLAY;
    [actionSheett showInView:self.gameView];
#else
  isAutoCompleting = NO;
  UIView * view = [self newGameView];
  [self.view addSubview:view];
#endif
}

- (void)cancelDelay
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)eachCompleteMove
{
  if (self.game.won) {
    return;
  }
    self.gameView.topCards = [self.game completeEach];

    [self.gameView computeCardLayout:HINTINFO_TIME destPos:-1 destIdx:-1];
}

- (IBAction)autoComplete:(id)sender {
    [self reset_banner_downcount];
    
    if (self.gameView.hinting) {
        return;
    }
    if (undoFlag)
        return;
    int cnt = 0;
    //[self.view setUserInteractionEnabled:NO];
  CGFloat soundDur = 0.2;
  int leftcount = [self.game cardsLeftCnt];
    for (int i = 0; i < leftcount; i++)
    {
        [self performSelector:@selector(eachCompleteMove) withObject:nil afterDelay:cnt*HINTINFO_TIME];
      CGFloat sounddelay = cnt*soundDur;
      if (sounddelay < leftcount*HINTINFO_TIME) {
        [self.gameView performSelector:@selector(playClickSound) withObject:nil afterDelay:sounddelay];
      }
        self.game.moves++;
        cnt++;
    }
}

- (IBAction)gameCenter:(id)sender {
    [self reset_banner_downcount];
    
    if (self.gameView.hinting) {
        return;
    }
    
    //[self performSegueWithIdentifier:@"winsegue" sender:self];
}

- (void)eachHintMove:(NSArray*)param
{
    if(!self.gameView.hintend)
    [self.gameView displayHint:[param objectAtIndex:0] toPos:[[param objectAtIndex:1] intValue] toIdx:[[param objectAtIndex:2] intValue] seq:[[param objectAtIndex:3] intValue] total:[[param objectAtIndex:4] intValue]];
}

- (IBAction)showHint:(id)sender {
    [self reset_banner_downcount];
    
    //NSLog(@"first card is %@, last card is %@",(Card *)[[self.game waste] firstObject],(Card *)[[self.game waste] lastObject]);
    if (self.game.won) {
        return;
    }
    if (self.gameView.hinting) {
        return;
    }
  if (self.gameView.isLayoutingCardView) {
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
        self.gameView.hintend = NO;
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
              case POS_STOCK: {
                if (ma.to == POS_STOCK) {
                  [cards addObject:[[Card alloc] initWithRank:-1 Suit:-1]];
                } else {
                  [cards addObject:[[_game stock:ma.fromIdx] lastObject]];
                }
              }
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
                    self.gameStat.freecell.lostCnt++;
                }
                else
                {
                    self.gameStat.freecell.lostCnt++;
                }
            }
            playGame = NO;
            actionSheett = nil;
            [self.gameView resetExpand];
            //[self.game freshGame:winBoards];
            //self.gameView.game = _game;
            // shuffle sound


            if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
                if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                    self.gameView.btnHelpView.hidden = NO;
                }
                else
                    self.gameView.btnLHelpView.hidden = NO;
            }
            self.gameView.shadowImageView.hidden = YES;
            
            [[AdmobViewController shareAdmobVC] ifNeedShowNext:self];
            [[AdmobViewController shareAdmobVC] checkConfigUD];
            //show full ads
            [self newShowFullAds];
        }
        else if (buttonIndex == 1)
        {
            ///update gamestat
            if (self.game.won == NO) {
                if (self.game.draw3) {
                    self.gameStat.freecell.lostCnt++;
                }
                else
                {
                    self.gameStat.freecell.lostCnt++;
                }
            }
            playGame = NO;
            actionSheett = nil;
            [self.gameView resetExpand];
            [self.game replayGame];


            self.gameView.game = _game;
            if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
                if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
                    self.gameView.btnHelpView.hidden = NO;
                }
                else
                    self.gameView.btnLHelpView.hidden = NO;
            }
            self.gameView.shadowImageView.hidden = YES;
        }
    }
    else if (actionSheet.tag == TAG_AUTOCOMPLETE)
    {
        if (buttonIndex == 0) {
            [self autoComplete:self];
        }
    }
    
    playGame = NO;
}

- (void)autoCompleteDone:(NSNotification*)notifacation
{
  if (self.game.won) {
    return;
  }
    /// update stat
    if (self.game.won == NO) {
        if (self.game.draw3) {
            [self.gameStat.freecell updateStat:self.game.times scores:self.game.scores moves:self.game.moves undos:self.game.undos];
        }
        else
        {
            [self.gameStat.freecell updateStat:self.game.times scores:self.game.scores moves:self.game.moves undos:self.game.undos];
        }
    }
    ///
    self.game.won = YES;
    self.gameView.winLabel.hidden = NO;
    //self.gameView.btnUndo.hidden = YES;
//    self.gameView.btnUndo.enabled = NO;
//    self.gameView.btnUndo.alpha = 0.5;
//    self.gameView.btnWin.hidden = YES;
  [self toggleUndoEnable:NO];
    if (firstIn || [self.gameView.winLabel.text isEqualToString:@"first"]) {
        self.gameView.winLabel.text = NSLocalizedStringFromTable(@"wonhint", @"Language", nil);
        return;
    }
    self.gameView.winView.hidden = NO;
    self.gameView.btnHelpView.hidden = YES;
    self.gameView.btnLHelpView.hidden = YES;
    [self performSelector:@selector(displayWonAnimation) withObject:nil];
    NSString* path = [NSString stringWithFormat:@"%@/Documents/stat.dat",NSHomeDirectory()];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.gameStat];
    [data writeToFile:path atomically:YES];
    
  if ([[NSUserDefaults standardUserDefaults] boolForKey:win_animate_key]) {
    [self toggleAutoCompleteEnable:NO];
    [self toggleWinAnimation:YES];
    return;
  } else {
    [self showInterAndVictory];
  }

}

- (void)displayWonAnimation{
    //NSLog(@"animatio over");
    [self.gameView bringSubviewToFront:self.gameView.winView];
    for(int i = 0;i < 10;i++){
        int j =9 - i;
        [self performSelector:@selector(changewen:) withObject:[NSNumber numberWithInt:i] afterDelay:0.2*(i)];
    }
    for(int i = 0;i < 10;i++){
        int j =9 - i;
        [self performSelector:@selector(changewen:) withObject:[NSNumber numberWithInt:i] afterDelay:0.2*(i + 10)];
    }
    for(int i = 0;i < 10;i++){
        int j =9 - i;
        [self performSelector:@selector(changewen:) withObject:[NSNumber numberWithInt:i] afterDelay:0.2*(i + 20)];
    }
    for(int i = 1;i < 35;i++){
        int j =35 - i;
        [self performSelector:@selector(changewin:) withObject:[NSNumber numberWithInt:j] afterDelay:0.04*(i)];
    }
    for(int i = 1;i < 35;i++){
        int j = 35 - i;
        [self performSelector:@selector(changewon:) withObject:[NSNumber numberWithInt:j] afterDelay:0.04*(i+17)];
    }
    for(int i = 0;i < 10;i++){
        int j = 9 - i;
        [self performSelector:@selector(changewan:) withObject:[NSNumber numberWithInt:i] afterDelay:0.2*(i+5)];
    }
    for(int i = 0;i < 10;i++){
        int j = 9 - i;
        [self performSelector:@selector(changewbn:) withObject:[NSNumber numberWithInt:i] afterDelay:0.2*(i+5)];
    }
    for(int i = 1;i < 35;i++){
        int j = 35 - i;
        [self performSelector:@selector(changewin:) withObject:[NSNumber numberWithInt:j] afterDelay:0.04*(i + 34)];
    }
    for(int i = 0;i < 35;i++){
        int j = 35 - i;
        [self performSelector:@selector(changewon:) withObject:[NSNumber numberWithInt:j] afterDelay:0.04*(i + 52)];
    }
    for(int i = 1;i < 35;i++){
        int j = 35 - i;
        [self performSelector:@selector(changewin:) withObject:[NSNumber numberWithInt:j] afterDelay:0.04*(i + 69)];
    }
    for(int i = 0;i < 35;i++){
        int j = 35 - i;
        [self performSelector:@selector(changewon:) withObject:[NSNumber numberWithInt:j] afterDelay:0.04*(i + 86)];
    }
    for(int i = 0;i < 10;i++){
        int j = 9 - i;
        [self performSelector:@selector(changewan:) withObject:[NSNumber numberWithInt:i] afterDelay:0.2*(i+15)];
    }
    for(int i = 0;i < 10;i++){
        int j = 9 - i;
        [self performSelector:@selector(changewbn:) withObject:[NSNumber numberWithInt:i] afterDelay:0.2*(i+15)];
    }
    
    [[AdmobViewController shareAdmobVC] recordValidUseCount];
}

- (void)changewin:(id)sec{
    NSNumber *num = sec;
    int x = [num intValue];
    self.gameView.wanIv.image  =[UIImage imageNamed:[NSString stringWithFormat:@"won (%d)",x]];
}
- (void)changewon:(id)sec{
    NSNumber *num = sec;
    int x = [num intValue];
    self.gameView.wbnIv.image  =[UIImage imageNamed:[NSString stringWithFormat:@"won (%d)",x]];
}
- (void)changewan:(id)sec{
    NSNumber *num = sec;
    int x = [num intValue];
    self.gameView.wcnIv.image  =[UIImage imageNamed:[NSString stringWithFormat:@"win (%d)",x]];
}
- (void)changewbn:(id)sec{
    NSNumber *num = sec;
    int x = [num intValue];
    self.gameView.wdnIv.image  =[UIImage imageNamed:[NSString stringWithFormat:@"win (%d)",x]];
}
- (void)changewen:(id)sec{
    NSNumber *num = sec;
    int x = [num intValue];
    self.gameView.wenIv.image  =[UIImage imageNamed:[NSString stringWithFormat:@"win (%d)",x]];
}

- (void)autoCompleteActionSheet:(NSNotification*)notifacation
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
otherButtonTitles:NSLocalizedStringFromTable(@"autohint", @"Language", nil), NSLocalizedStringFromTable(@"cancel", @"Language", nil), nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = TAG_AUTOCOMPLETE;
    [actionSheet showInView:self.view];
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
}

- (void)changeBg:(NSNotification *)notification{
    int bgidx = [[notification object] integerValue];
    //NSLog(@"index is %d",bgidx);
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    int lastidx = [[settings objectForKey:@"bg"] integerValue];
    [settings setObject:[NSNumber numberWithInt:bgidx] forKey:@"bg"];
    [settings synchronize];
    self.gameView.gameBg.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg%d.jpg",bgidx]];
    if(lastidx >= 0)
        //[(NewPicView *)[self.gameView.bgScroll.subviews objectAtIndex:lastidx] hideShadow:YES];
        [self.gameView hideShadow:0 picIdx:lastidx ishide:YES];
        
    //[(NewPicView *)[self.gameView.bgScroll.subviews objectAtIndex:bgidx] hideShadow:NO];
        [self.gameView hideShadow:0 picIdx:bgidx ishide:NO];
    [self.gameView updateBgSelected:bgidx];
}

- (void)changeBk:(NSNotification*)notifacation
{
    int bkidx = [[notifacation object] integerValue];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    int lastidx = [[settings objectForKey:@"bk"] integerValue];
    [settings setObject:[NSNumber numberWithInt:bkidx] forKey:@"bk"];
    [settings synchronize];
    if(lastidx >= 0){
//        NewPicView *np = (NewPicView *)[self.gameView.bkScroll.subviews objectAtIndex:lastidx];
//        np.shadowView.hidden = YES;
        [self.gameView hideShadow:1 picIdx:lastidx ishide:YES];
    }
    [CardView setNewBackImage:[[[NSUserDefaults standardUserDefaults] objectForKey:@"bk"] integerValue] filepath:nil];
    [self.gameView hideShadow:1 picIdx:bkidx ishide:NO];
    [self.gameView updateCardBack];
    ///
    [self.gameView updateBkSelected:bkidx];
}

- (void)changeCf:(NSNotification*)notifacation
{
    int cfidx = [[notifacation object] integerValue];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    //BOOL idx = [[settings objectForKey:@"classic"] boolValue];
    int ii = cfidx?1:0;
//    [[(NewPicView *)[self.gameView.cardPicker.subviews objectAtIndex:0] shadowView] setHidden:YES];
//    [[(NewPicView *)[self.gameView.cardPicker.subviews objectAtIndex:1] shadowView] setHidden:YES];
//    [[(NewPicView *)[self.gameView.cardPicker.subviews objectAtIndex:ii] shadowView] setHidden:NO];
    [self.gameView hideShadow:2 picIdx:0 ishide:YES];
    [self.gameView hideShadow:2 picIdx:1 ishide:YES];
    [self.gameView hideShadow:2 picIdx:ii ishide:NO];
    BOOL classicflag = YES;
    if (cfidx == 0)
    {
        classicflag = YES;
    }
    else{
        classicflag = NO;
    }
    [settings setObject:[NSNumber numberWithBool:classicflag] forKey:@"classic"];
    [settings synchronize];
    [Card setClassic:classicflag];
    [self.gameView updateCardForground];
    //
    [self.gameView updateCfSelected:cfidx];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"StatCell";
     StatCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[StatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    //DrawStat *ds = self.gameStat.draw1;
    DrawStat *ds = self.gameStat.freecell;
    switch (indexPath.row) {
        case 0:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"gamewon", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%ld(%0.1f%%)",ds.wonCnt,100.0*ds.wonCnt/(ds.wonCnt+ds.lostCnt+0.000001)];
            return cell;
            break;
        case 1:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"gamelost", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%ld",ds.lostCnt];
            return cell;
            break;
        case 2:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"shortesttime", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld",ds.shortestWonTime/60,ds.shortestWonTime%60];
            return cell;
            break;
        case 3:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"longesttime", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld",ds.longestWonTime/60,ds.longestWonTime%60];
            return cell;
            break;
        case 4:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"avgtime", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%ld:%02ld",ds.averageWonTime/60,ds.averageWonTime%60];
            return cell;
            break;
        case 5:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"fewestmoves", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%ld",ds.fewestWonMoves];
            return cell;
            break;
        case 6:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"mostmoves", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%ld",ds.mostWonMoves];
            return cell;
            break;
        case 7:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"noundo", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%ld",ds.wonWithoutUndoCnt];
            return cell;
            break;
        case 8:
            cell.keyLabel.text = NSLocalizedStringFromTable(@"highscore", @"Language", nil);
            cell.valueLabel.text = [NSString stringWithFormat:@"%ld",ds.highestSocre];
            return cell;
            break;
            
        default:
            break;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 9;
}

#pragma mark -
#pragma mark show admob banner

- (void) reset_banner_downcount {
    show_banner = time(NULL);
  [self.gameView resetAutohintTimer];
}

- (void)tapOnDesktop {
    [self reset_banner_downcount];
    if(self.gameView.hideOp) {
        [self.gameView hideOrDisplayOpBar];
    }
}

- (void) update_admob_banner_status {
    if(show_banner > 0) {
        long now = time(NULL);
        if(now - show_banner > 3.8) {
            
            if(!self.gameView.hideOp) {
                [self.gameView hideOrDisplayOpBar];
            }
            
            if(self.gameView.hideOp){
                show_banner = 0;
            }
        }
    }
}

-(BOOL) show_ad {
    AdmobViewController* admobview = [AdmobViewController shareAdmobVC];
    if([admobview hasInAppPurchased]) {
        return false;
    }
    
    GRTService* service = (GRTService*)admobview.rtService;
    if([service isRT] || [service isGRT]) {
        return false;
    }
    
    NSString* msg = @"remove all full-screen ads";
    NSInteger language = [service getCurrentLanguageType];
    if(language == 1) {
        msg = @"去除所有全屏广告";
    }
    
    return [admobview getRT:self isLock:false rd:msg cb:^() {
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        [settings setBool:YES forKey:@"rated"];
        [settings synchronize];
    }];
}




- (CGRect)frameForThemeViewPortrait:(BOOL)port {
    CGRect rect = _gameView.frame;
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


- (BOOL)isPortrait {
  return [self.gameView isPortrait];;
}


- (DismissibleView *)themeView {
  RoundCornerThemeView * themeV = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerThemeView" owner:nil options:nil].firstObject;
  CGRect rect = [self frameForThemeViewPortrait:[self isPortrait]];
  themeV.frame = rect;
  [themeV prepareForPortrait:[NSNumber numberWithBool:[self isPortrait]]];
  return [self dismissibleViewWithView:themeV];
}

- (DismissibleView *)dismissibleViewWithView:(UIView *)view {
  DismissibleView * dview = [[DismissibleView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  dview.contentSize = view.frame.size;
  [dview addContentView:view];
  return dview;
}


- (CGFloat)heightForToolbar {
    CGSize size = _gameView.frame.size;//[UIApplication currentSize];
  CGFloat minW = MIN(size.width, size.height);
  if (IS_IPAD) {
    return 100;
  } else {
    return floor(50*minW/320.0);
  }
}


- (void)addCV {
  UICollectionViewFlowLayout * f = [[UICollectionViewFlowLayout alloc] init];
  f.scrollDirection = UICollectionViewScrollDirectionHorizontal;
  _opCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:f];
  [self.view addSubview:_opCollectionView];
  _opCollectionView.delegate = self;
  _opCollectionView.dataSource = self;
  _opCollectionView.backgroundColor = [UIColor clearColor];
  [_opCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(_gameView.mas_left);
    make.bottom.equalTo(_gameView.mas_bottom);
    make.right.equalTo(_gameView.mas_right);
    make.height.mas_equalTo([self heightForToolbar]);
  }];
  [self.opCollectionView registerNib:[UINib nibWithNibName:@"OpToolbarCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];

}




#pragma mark - uicollection view

- (CGSize)opButtonSize {
    CGRect rect = _gameView.frame;
  CGFloat width = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect));
  return CGSizeMake(width/5-1, [self heightForToolbar]);
}

- (UIEdgeInsets)opButtonInsets {
  CGSize size = _gameView.frame.size;//[UIApplication currentSize];
  return (size.height > size.width)?UIEdgeInsetsMake(0, 0, 0, 0):UIEdgeInsetsMake(0, 60, 0, 60);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  return [self opButtonInsets];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self opButtonSize];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  CGFloat num = [collectionView numberOfItemsInSection:0];
  UIEdgeInsets insets = [self opButtonInsets];
  CGSize size = [self opButtonSize];
  CGFloat  w = (_gameView.frame.size.width-insets.left-insets.right-size.width * num)/(num-1)-1;
  return w;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return [self datasource].count;
}

#define iconImageName @"imageName"
#define opName @"name"

- (NSArray <NSDictionary *>*)datasource {
  NSArray <NSDictionary *>* ds = @[@{opName:LocalizedGameStr2(setting), iconImageName:@"settings"},
                                   @{opName:LocalizedGameStr2(theme), iconImageName:@"cardback"},
                                   @{opName:LocalizedGameStr2(newgame), iconImageName:@"newgame"},
                                   @{opName:LocalizedGameStr(hint), iconImageName:_hintUnavailable?@"hint_disable":@"hint"},
                                   @{opName:LocalizedGameStr2(undo), iconImageName:_undoEnabled?@"undo":@"undo_disable"},
                                   ];
  return ds;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  OpToolbarCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
  NSString * imgName = [self datasource][indexPath.item][iconImageName];
  NSString * name = [self datasource][indexPath.item][opName];
  cell.iconIV.image = [UIImage imageNamed:imgName];
  cell.nameL.text = name;
  if ((indexPath.item == OpUndo && !_undoEnabled) || (indexPath.item == OpHint && _hintUnavailable)) {
    cell.nameL.textColor = [UIColor colorWithRed:0.45 green:0.45 blue:0.45 alpha:1];
  } else {
    cell.nameL.textColor = [UIColor whiteColor];
  }
  return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  [self reset_banner_downcount];
  [self.gameView stopHintAnamiation];
  OpType type = indexPath.item;
  switch (type) {
    case OpSetting: {
      [self showSet:nil];
    }
      break;

    case OpTheme: {
      [self skinPicker:nil];
    }
      break;

    case OpNewGame: {
      [self newGame:nil];
    }
      break;


    case OpHint: {
      if (!_hintUnavailable) {

        [self showHint:nil];
      }
    }
      break;

    case OpUndo: {
      if (_undoEnabled) {
        [self undo:nil];
      }
    }
      break;


    default:
      break;
  }
}


- (void)disableHintForAMoment:(BOOL)disable {
  if (_hintUnavailable == disable) {
    return;
  }
  _hintUnavailable = disable;
  if ([_opCollectionView numberOfItemsInSection:0] > OpUndo) {
    [_opCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:OpHint inSection:0]]];
  }
}

- (void)toggleUndoEnable:(BOOL)enabled {
  if (self.undoEnabled == enabled) {
    return;
  }

  self.undoEnabled = enabled;
  if ([_opCollectionView numberOfItemsInSection:0] > OpUndo) {
    [_opCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:OpUndo inSection:0]]];
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
  _autoB.frame = CGRectMake(CGRectGetMidX(self.view.bounds)-width/2, CGRectGetHeight(self.view.bounds)-MAX([self heightForToolbar], [_gameView adViewHeight])-height*2, width, height);
  return _autoB;
}


- (void)autoBAction {
  [self autoComplete:self];
  isAutoCompleting = YES;
  [self toggleAutoCompleteEnable:NO];
}

- (DismissibleView *)settingView {
  RoundCornerSettingView * settingview = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerSettingView" owner:nil options:nil].firstObject;
  settingview.delegate = self;

  settingview.frame = [self defaultBoundsForDialogViewPortrait:[self isPortrait]];
  [settingview prepareForPortrait:[NSNumber numberWithBool:[self isPortrait]]];
  return [self dismissibleViewWithView:settingview];
}


- (DismissibleView *)ruleView {
  RoundCornerRuleView * ruleview = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerRuleView" owner:nil options:nil].firstObject;

  ruleview.frame = [self defaultBoundsForDialogViewPortrait:[self isPortrait]];
  [ruleview prepareForPortrait:[NSNumber numberWithBool:[self isPortrait]]];

  return [self dismissibleViewWithView:ruleview];
}



#ifdef debug_victory

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
  if ([[UIDevice currentDevice].systemVersion floatValue] > 8) {
    if (self.game.won) {
      return;
    }
    UIAlertController * jumpToWin = [UIAlertController alertControllerWithTitle:@"debug" message:@"do you want to debug win" preferredStyle:(UIAlertControllerStyleAlert)];
    [jumpToWin addAction:[UIAlertAction actionWithTitle:@"cancel" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {

    }]];

    [jumpToWin addAction:[UIAlertAction actionWithTitle:@"win" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
      NSString* path = [[NSBundle mainBundle] pathForResource:@"allmostwin" ofType:@"dat"];
      if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        self.game = [NSKeyedUnarchiver unarchiveObjectWithData:data];
      } else {
        [self.game freshGame:winBoards];
      }
      self.gameView.game = _game;
      [self.gameView computeCardLayout:0 destPos:-1 destIdx:-1];
    }]];

    [self.navigationController presentViewController:jumpToWin animated:YES completion:nil];
  }

}

#endif

- (void)tryInter {
  static int wonCnt = 0;
  wonCnt++;
  [[AdmobViewController shareAdmobVC] checkConfigUD];
  if (wonCnt == 1) {
    [[AdmobViewController shareAdmobVC] decideShowRT:self];
  } else {
    if (![[AdmobViewController shareAdmobVC] decideShowRT:self]) {
      [self winShowFullAd];
    }
  }
}



- (DismissibleView *)victoryView {
  YouWinView * vview = [[NSBundle mainBundle] loadNibNamed:@"YouWinView" owner:nil options:nil].firstObject;
  if (IS_IPAD) {
    vview.tableWidthC.constant = ([self isPortrait])?150:100;
  }
  vview.frame = [self victoryFramePortrait:[self isPortrait]];
  __weak typeof(self) weakSelf = self;
  vview.dismissBlock = ^{
    [weakSelf tryInter];
    [weakSelf newGame:nil];
    weakSelf.winningShowFlag = NO;
  };
  vview.dict = @{WinDurationKey:[NSString stringWithFormat:@"%ld:%02ld", \
                                 (long)self.game.times/60,(long)self.game.times%60],
                 WinScoreKey:[NSString stringWithFormat:@"%ld",(long)self.game.scores],
                 WinMoveKey:[NSString stringWithFormat:@"%ld", (long)self.game.moves],
                 WinHighScoreKey:[NSString stringWithFormat:@"%ld", \
                                  (long)(self.gameStat.freecell.highestSocre)]};
  return [self dismissibleViewWithView:vview];
}


- (CGRect)victoryFramePortrait:(BOOL)port {
    CGRect rect = _gameView.frame;
  CGFloat height = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect));
  CGRect rect0 = \
  port?\
  (IS_IPAD?\
   CGRectIntegral(CGRectMake(0, 0, 0.8*height, 1.2*height)):\
   CGRectMake(0, 0, 0.98*height, 1.4*height)):\
  (IS_IPAD?\
   CGRectMake(0, 0, 0.66*height, 1*height):\
   CGRectMake(0, 0, 0.8*height, 1*height));
  return rect0;
}


- (CGRect)newGameFrame {
    CGRect rect = _gameView.frame;
  CGFloat width = MIN(CGRectGetHeight(rect), CGRectGetWidth(rect));
  CGRect rect0 = IS_IPAD?CGRectMake(0, 0, width*0.75, width*0.51):CGRectMake(0, 0, width*0.9, width*0.88);
  return CGRectIntegral(rect0);
}




- (CGRect)defaultBoundsForDialogViewPortrait:(BOOL)port {
    CGRect rect = _gameView.frame;
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



- (DismissibleView *)statView {
  RoundCornerStatView * statview = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerStatView" owner:nil options:nil].firstObject;

  statview.frame = [self defaultBoundsForDialogViewPortrait:[self isPortrait]];
  [statview prepareForPortrait:[NSNumber numberWithBool:[self isPortrait]]];
  return [self dismissibleViewWithView:statview];
}


- (DismissibleView *)newGameView {
  RoundCornerNewGameView * newgameview = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerNewGameView" owner:nil options:nil].firstObject;
  newgameview.delegate = self;
  newgameview.frame = [self newGameFrame];
  return [self dismissibleViewWithView:newgameview];
}

- (DismissibleView *)forceNewGameView {
  RoundCornerNewGameView * newgameview = [[NSBundle mainBundle] loadNibNamed:@"RoundCornerNewGameView" owner:nil options:nil].firstObject;
  newgameview.delegate = self;
  CGFloat h = 60;
  newgameview.forceViewH.constant = h;
  newgameview.forceMessageL.text = LocalizedGameStr(nomoves);
  CGRect rect = [self newGameFrame];
    CGRect screenb = _gameView.frame;
  rect.size.height = MIN(rect.size.height+h, MIN(CGRectGetWidth(screenb), CGRectGetHeight(screenb)));
  newgameview.frame = rect;
  DismissibleView * dview = [self dismissibleViewWithView:newgameview];
  dview.useAutoL = YES;
  [self.view addSubview:dview];
  [dview mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];
  __weak typeof(dview) weakView = dview;

  [newgameview mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.mas_equalTo(weakView.mas_centerX);
    make.centerY.mas_equalTo(weakView.mas_centerY);
    make.width.mas_equalTo(rect.size.width);
    make.height.mas_equalTo(rect.size.height);
  }];
  return dview;
}


- (NSString *)currentVer {
  return [NSString stringWithFormat:@"winCount%@",[NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]];
}




- (void)showVictory:(id)sender {
  if (self.gameView.hinting) {
    return;
  }
  if (_winningShowFlag) {
    return;
  }

  [NSObject cancelPreviousPerformRequestsWithTarget:self];

  [self toggleAutoCompleteEnable:NO];
  winCount ++;
  NSInteger wonCount = [[NSUserDefaults standardUserDefaults] integerForKey:[self currentVer]];
  wonCount ++;
  [[NSUserDefaults standardUserDefaults] setInteger:wonCount forKey:[self currentVer]];
  [[NSUserDefaults standardUserDefaults] synchronize];
  _winningShowFlag = YES;
  DismissibleView * view = [self victoryView];
  view.disableTapToDismiss = YES;
  [self.view addSubview:view];
}




- (void)adjustDimView:(UIInterfaceOrientation)toInterfaceOrientation {
  NSArray <DismissibleView *>* dviews = [self.view.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
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

    if ([cv isKindOfClass:[YouWinView class]]) {
      type = CV_IS_YOUWIN;
    } else if ([cv isKindOfClass:[RoundCornerNewGameView class]]) {
      type = CV_IS_NEWGAME;
    } else if ([cv isKindOfClass:[RoundCornerThemeView class]]) {
      type = CV_IS_THEME;
    }


    //  CGRect frm = view.contentView.frame;

    [UIView animateWithDuration:0.2 animations:^{
      view.frame = CGRectMake(0, 0, size.width, size.height);
      BOOL isp = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
      if (type == CV_IS_YOUWIN) {
        view.contentSize = [self victoryFramePortrait:isp].size;
        YouWinView * vview = (YouWinView *)view.contentView;
        if (IS_IPAD && [vview isKindOfClass:[YouWinView class]]) {
          vview.tableWidthC.constant = (isp)?150:100;
        }
      } else if (type == CV_IS_NEWGAME) {
        //      view.contentSize = frm.size;
      } else if (type == CV_IS_THEME) {
        view.contentSize = [self frameForThemeViewPortrait:isp].size;
      }  else {
        view.contentSize = [self defaultBoundsForDialogViewPortrait:isp].size;
      }
      if ([view.contentView respondsToSelector:@selector(prepareForPortrait:)]) {
        [view.contentView performSelector:@selector(prepareForPortrait:) withObject:[NSNumber numberWithBool:isp]];
      }
      cv.center = CGPointMake(size.width/2, size.height/2);
    }];
  }
  
  
}


- (void)showTheHint {
  if (_autohintEnabled) {
    _autohinting = YES;
    [self showHint:nil];
  }
}


- (void)showRuleView {
  if (self.gameView.hinting) {
    return;
  }
  UIView * view = [self ruleView];
  [self.view addSubview:view];
}


- (void)showStatView {
  if (self.gameView.hinting) {
    return;
  }
  UIView * view = [self statView];
  [self.view addSubview:view];
}


- (void)startNewRandomDeal {
  [self suiji:nil];

  [self disableHintForAMoment:NO];
  [timer setFireDate:[NSDate distantPast]];

}
- (void)startNewWinDeal {

  [self huoju:nil];

  [self disableHintForAMoment:NO];
  [timer setFireDate:[NSDate distantPast]];


}

- (void)replayThisGame {
  [self reStart:nil];

  [self disableHintForAMoment:NO];

  [timer setFireDate:[NSDate distantPast]];
  
}

- (void)suiji:(id)sender {
  if (self.game.won == NO) {
    if (self.game.draw3) {
      self.gameStat.freecell.lostCnt++;
    }
    else
    {
      self.gameStat.freecell.lostCnt++;
    }
  }
  playGame = NO;
  actionSheett = nil;
  [self.gameView resetExpand];
  //[self.game freshGame:winBoards];
  //self.gameView.game = _game;
  // shuffle sound

  if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
      self.gameView.btnHelpView.hidden = NO;
    }
    else
      self.gameView.btnLHelpView.hidden = NO;
  }
  self.gameView.shadowImageView.hidden = YES;

  [[AdmobViewController shareAdmobVC] ifNeedShowNext:self];
  [[AdmobViewController shareAdmobVC] checkConfigUD];
  //show full ads
  [self newShowFullAds];

}

- (void)huoju:(id)sender {
  [self suiji:sender];
}



- (void)reStart:(id)sender {
  ///update gamestat
  if (self.game.won == NO) {
    if (self.game.draw3) {
      self.gameStat.freecell.lostCnt++;
    }
    else
    {
      self.gameStat.freecell.lostCnt++;
    }
  }
  playGame = NO;
  actionSheett = nil;
  [self.gameView resetExpand];
  [self.game replayGame];


  self.gameView.game = _game;
  if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
      self.gameView.btnHelpView.hidden = NO;
    }
    else
      self.gameView.btnLHelpView.hidden = NO;
  }
  self.gameView.shadowImageView.hidden = YES;

}



- (void)showInterAndVictory {
  alreadyWin = NO;
  [self disableHintForAMoment:YES];
  [self showVictory:nil];
}


- (void)toggleWinAnimation:(BOOL)begin {
  if (isWinAnimating == begin) {
    return;
  }
  isWinAnimating = begin;
  if (begin) {


    [self reset_banner_downcount];
    __weak typeof(self) weakSelf = self;

    CGSize scsize = [self.gameView screenSize];
    CGSize cardsize = [self.gameView cardViewSize];
    NSArray * array = [self.gameView allCardViews];
    NSInteger iii = 0;
    for (UIView * view in array) {
      iii ++;
      [self.gameView bringSubviewToFront:view];
      [view.layer removeAllAnimations];
    }
    [[WinAnimator randomAnimator] playAnimations:array cardWidth:cardsize.width cardHeight:cardsize.height screenWidth:scsize.width screenHeight:scsize.height completion:^{
      [self toggleWinAnimation:NO];
      [weakSelf showInterAndVictory];
    }];
  } else {

  }
}


@end
