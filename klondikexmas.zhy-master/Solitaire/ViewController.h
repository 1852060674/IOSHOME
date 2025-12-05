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

@class Solitaire;
@class SolitaireView;

@interface ViewController : UIViewController <SolitaireDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) Solitaire *game;
@property (strong, nonatomic) IBOutlet SolitaireView *gameView;
@property (strong, nonatomic) GameStat *gameStat;
@property (assign, nonatomic) BOOL showCongra;
@property (assign, nonatomic) BOOL setshow;
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AdmobHeightt;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SpanlishMoveX;
@property (weak, nonatomic) IBOutlet UILabel *itStatusSizeCtr;
@property (weak, nonatomic) IBOutlet UILabel *itStatusSizeCtr1;
@property (weak, nonatomic) IBOutlet UILabel *itStatusSizeCtr2;

@end
