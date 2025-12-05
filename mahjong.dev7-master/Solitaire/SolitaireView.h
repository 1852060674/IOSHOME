//
//  SolitaireView.h
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import "CardView.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CustomView.h"
#import "SolitaireDelegate.h"

#define MOVE_TIME 0.7
#define HINTINFO_TIME 0.1
#define CLICK_TIME 0.2

@class Solitaire;

@interface SolitaireView : UIView

@property (weak, nonatomic) IBOutlet UIView *LeftOPBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LeftOPBarTrall;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *RightOPBarTrall;
@property (weak, nonatomic) IBOutlet UIView *RightOPBar;
@property (strong, nonatomic) Solitaire *game;
@property (weak, nonatomic) id <SolitaireDelegate> delegate;
@property (assign, nonatomic) BOOL hideOp;
@property (assign, nonatomic) BOOL hideSettings;
@property (assign, nonatomic) BOOL hinting;
@property (assign, nonatomic) BOOL overflag;
@property (strong, nonatomic) NSArray* topCards;
@property (assign, nonatomic) BOOL sound;
//
@property (strong, nonatomic) NSMutableArray* allBackgroundViews;
@property (strong, nonatomic) NSMutableArray* allTilesetViews;
@property int level ;
- (void)addToSubViewForCard:(Card *)c;
- (void)setGame:(Solitaire *)game;
- (void)addBottomCardsToSubview;
- (void)iterateGameWithBlock:(void (^)(Card *c))block;
- (void)computeSizes:(BOOL)flag;
- (void)computeCardLayout:(float)duation destPos:(int)pos destIdx:(int)idx;
- (void)updateUndoBtn;
- (void)updateCardBack;
- (void)updateAfterShuffle;
- (void)clearSelectedState;
- (Card*)selectedCard;
- (void)firstInCompute;///for ios7
- (void)matchExplode:(CGPoint)point1 point2:(CGPoint)point2;
- (void)hint:(NSArray*)hints;
- (void)undoEffect:(NSArray*)undos;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;

@property (weak, nonatomic) IBOutlet UIImageView *gameBg;
@property (weak, nonatomic) IBOutlet UIView *opBar;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *admobView;
@property (weak, nonatomic) IBOutlet UIButton *shuffleBtn;
@property (weak, nonatomic) IBOutlet UIView *boardView;
@property (weak, nonatomic) IBOutlet UILabel *matchLabel;
@property (weak, nonatomic) IBOutlet UIView *settingsGroup;
@property (weak, nonatomic) IBOutlet UIView *shuffleGroup;
@property (weak, nonatomic) IBOutlet UIView *replayGroup;
@property (weak, nonatomic) IBOutlet UIView *undoGroup;
@property (weak, nonatomic) IBOutlet UIView *hintGroup;
@property (weak, nonatomic) IBOutlet UIView *pauseGroup;
@property (weak, nonatomic) IBOutlet UIView *helpGroup;
@property (weak, nonatomic) IBOutlet UIView *playGroup;
@property (weak, nonatomic) IBOutlet UIView *pauseView;
@property (weak, nonatomic) IBOutlet UIScrollView *helpScrollView;
@property (weak, nonatomic) IBOutlet CustomView *helpView;
@property (weak, nonatomic) IBOutlet UIView *overView;
@property (weak, nonatomic) IBOutlet UIButton *overNextBtn;
@property (weak, nonatomic) IBOutlet UIImageView *starView1;
@property (weak, nonatomic) IBOutlet UIImageView *starView2;
@property (weak, nonatomic) IBOutlet UIImageView *starView3;
@property (weak, nonatomic) IBOutlet UILabel *overScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *overTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *overStarsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *overNextLayoutView;
@property (weak, nonatomic) IBOutlet UIImageView *overNextUnlockHint;
@property (assign, nonatomic) BOOL nextlock;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnShuffle;
@property (weak, nonatomic) IBOutlet UIButton *btnHint;
@property (weak, nonatomic) IBOutlet UIButton *btnReplay;
@property (weak, nonatomic) IBOutlet UIButton *btnPause;
@property (weak, nonatomic) IBOutlet UIButton *btnHelp;
@property (weak, nonatomic) IBOutlet UILabel *overNextUnlockLabel;

- (IBAction)onResume:(id)sender;
- (IBAction)onGotIt:(id)sender;
- (IBAction)onCloseOver:(id)sender;

- (IBAction)showMenu:(id)sender;
- (IBAction)onSound:(id)sender;

- (void)onPause;
- (void)onHelp;
- (void)initHelp;

- (void)showOver;

- (void) hideOrDisplayOpBar;
@end
