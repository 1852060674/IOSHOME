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
#import "Admob.h"

@class Solitaire;
@class SolitaireView;

@interface ViewController : UIViewController <SolitaireDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate,AdmobViewControllerDelegate>


@property (nonatomic, assign) BOOL autohintEnabled;
@property (nonatomic, assign) BOOL autohinting;
@property (nonatomic, assign) BOOL hintUnavailable;

@property (nonatomic, assign) BOOL undoEnabled;

@property (strong, nonatomic) Solitaire *game;
@property (strong, nonatomic) IBOutlet SolitaireView *gameView;
@property (strong, nonatomic) GameStat *gameStat;
@property (strong, nonatomic) UIPopoverController* popOver;
@property (assign, nonatomic) BOOL showCongra;
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
- (IBAction)onChange:(id)sender;
- (IBAction)onDifficuty:(id)sender;
- (IBAction)onOrientation:(id)sender;
- (IBAction)onTapmove:(id)sender;
- (IBAction)closeSettings:(id)sender;
- (IBAction)closeSkin:(id)sender;
- (IBAction)selectBg:(id)sender;
- (IBAction)selectBk:(id)sender;
- (IBAction)skinPicker:(id)sender;
- (IBAction)statData:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)resetStastics:(id)sender;
- (IBAction)closeGameStat:(id)sender;
- (IBAction)closeHelpView:(id)sender;

@end
