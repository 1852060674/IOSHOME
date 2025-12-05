//
//  ViewController.h
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SolitaireDelegate.h"
#import "GameStat.h"
#import "Solitaire.h"
#import "SolitaireView.h"
#import "TopHighViewController.h"
#import "StandingViewController.h"
#import "admob.h"

@class Solitaire;
@class SolitaireView;

@interface ViewController : UIViewController <SolitaireDelegate, UIActionSheetDelegate,UITextFieldDelegate,AdmobViewControllerDelegate>

@property (strong, nonatomic) Solitaire *game;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *admobHeightt;
@property (strong, nonatomic) IBOutlet SolitaireView *gameView;
@property (strong, nonatomic) GameStat *gameStat;
@property (assign, nonatomic) BOOL showCongra;
@property (strong, nonatomic) TopHighViewController* thvc;
@property (strong, nonatomic) StandingViewController* svc;
@property (assign, nonatomic) BOOL setshow;
@property (weak, nonatomic) IBOutlet UIView *admobView;
@property (nonatomic, assign) BOOL hintUnavailable;
- (IBAction)newGame:(id)sender;
- (IBAction)showHint:(id)sender;

- (void)updateTime; 
- (IBAction)undo:(id)sender;
- (void)cancelDelay;
- (IBAction)autoComplete:(id)sender;
- (IBAction)gameCenter:(id)sender;
- (void)loadSettings;
- (IBAction)showSet:(id)sender;
- (NSString*)getRealBackImgName:(NSString*)name;
- (void)setBackImage;
- (void)showTopHigh;
- (void)delayShow;
- (void)forceRotate;
- (void)showStanding;
-(void)showSetByzh;
-(BOOL)OldMan;
@end
