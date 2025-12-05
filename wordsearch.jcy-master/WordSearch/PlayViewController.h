//
//  PlayViewController.h
//  WordSearch
//
//  Created by apple on 13-8-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameData.h"
#import "DrawView.h"
#import "Admob.h"

#define NEEDTOFOUND 8

@interface PlayViewController : UIViewController<AdmobViewControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *wordLabel1;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel2;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel3;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel4;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel5;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel6;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel7;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel8;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel9;

@property (weak, nonatomic) IBOutlet UIView *wordsView;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet DrawView *puzzleView;
@property (weak, nonatomic) IBOutlet UILabel *currentWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *foundLabel;
@property (weak, nonatomic) IBOutlet UILabel *Label1;
@property (weak, nonatomic) IBOutlet UILabel *Label2;
@property (weak, nonatomic) IBOutlet UILabel *Label3;
@property (weak, nonatomic) IBOutlet UILabel *Label4;
@property (weak, nonatomic) IBOutlet UILabel *Label5;
@property (weak, nonatomic) IBOutlet UILabel *Label6;
@property (weak, nonatomic) IBOutlet UILabel *Label7;
@property (weak, nonatomic) IBOutlet UILabel *Label8;

///
- (void)layoutAnswerWords;
- (void)layoutCharViews;
- (void)randomPuzzleBoard:(NSArray*)puzzles;
- (BOOL)forceSearchForTest;
- (void)setGameData:(GameData*)data;
- (void)updateTime;
- (void)updateFound;

- (void)newGame;
- (IBAction)pause:(id)sender;
- (IBAction)showAd:(id)sender;
- (void)saveGameData;
- (void)removeNotification;
- (IBAction)onHint:(id)sender;

@end
