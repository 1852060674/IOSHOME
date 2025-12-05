//
//  ViewController.h
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameStat.h"
#import "Solitaire.h"
#import "SolitaireView.h"
#import "Admob.h"

@class Solitaire;
@class SolitaireView;

@interface ViewController : UIViewController <UIActionSheetDelegate,
    UIAlertViewDelegate,
    UITextFieldDelegate,
    AdmobViewControllerDelegate,
    SolitaireDelegate>

@property (strong, nonatomic) IBOutlet SolitaireView *gameView;
@property (weak, nonatomic) IBOutlet UIImageView *scoreBg;
@property (weak, nonatomic) IBOutlet UIImageView *timeBg;
@property (weak, nonatomic) IBOutlet UIImageView *matchBg;
@property (weak, nonatomic) IBOutlet UIImageView *rightBg;
@property (weak, nonatomic) IBOutlet UIImageView *leftBg;
@property (weak, nonatomic) IBOutlet UIImageView *helpBgView;

- (IBAction)newGame:(id)sender;
- (IBAction)showHint:(id)sender; 
- (IBAction)onOverBack:(id)sender;
- (IBAction)onOverNext:(id)sender;

- (void)updateTime;
- (IBAction)undo:(id)sender;
- (void)loadSettings;
- (NSString*)getRealBackImgName:(NSString*)name;
- (void)setBackImage;
- (IBAction)shuffle:(id)sender;
- (IBAction)update:(id)sender;
- (IBAction)replayGame:(id)sender;
- (IBAction)pauseGame:(id)sender;
- (IBAction)mahjongHelp:(id)sender;
- (IBAction)onBack:(id)sender;

@end
