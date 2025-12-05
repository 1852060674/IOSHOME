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
#import "SolitaireDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

#define MOVE_TIME 0.7
#define HINTINFO_TIME 0.1
#define CLICK_TIME 0.2

@class Solitaire;

@interface SolitaireView : UIView

@property (strong, nonatomic) Solitaire *game;
@property (weak, nonatomic) id <SolitaireDelegate> delegate;
@property (assign, nonatomic) BOOL hideOp;
@property (assign, nonatomic) BOOL hinting;
@property (assign, nonatomic) int anaCnt;
@property (assign, nonatomic) int anaIdx;
@property (strong, nonatomic) NSArray* topCards;
@property (assign, nonatomic) BOOL autoOn;
@property (assign, nonatomic) BOOL complete;
@property (assign, nonatomic) BOOL needAuto;
@property (assign, nonatomic) int speed;

@property (strong, nonatomic) UIButton *themesButton;

/// sound
@property (assign, nonatomic) BOOL sound;
@property (assign, nonatomic) SystemSoundID shuffleSound;
@property (assign, nonatomic) SystemSoundID clickSound;
@property (assign, nonatomic) SystemSoundID clickQuickSound;

/// settings
@property (assign, nonatomic) BOOL rightHand;
@property (assign, nonatomic) UIDeviceOrientation savedOri;

- (void)hideOrDisplayOpBar;

- (void)addToSubViewForCard:(Card *)c;

- (void)setGame:(Solitaire *)game;
- (void)addBottomCardsToSubview; 

- (void)iterateGameWithBlock:(void (^)(Card *c))block;

- (void)rotateLayout:(UIInterfaceOrientation)toInterfaceOrientation;
- (void)uiAdjust;
- (void)computeSizes:(BOOL)flag;
- (void)computeBottomCardLayout;
- (void)computeCardLayout:(float)duation destPos:(int)pos destIdx:(int)idx;

- (void)loadGameUI;

- (void)displayHint:(NSArray*)fan toPos:(int)pos toIdx:(int)idx seq:(int)seq total:(int)total;
- (void)stopHintAnamiation;
- (void)anamiationDone;

- (void)alphaBack;

- (void)updateCardBack;
- (void)updateCardForground;

- (void)updatePassBtn;
- (CGPoint)pos2CollectPos:(int)pos;
- (void)updateScoresDisplay;

- (void)turn;
- (void)heartBroken;
- (CGFloat)speedTime;

- (void)firstInCompute;///for ios7
-(void)updateThemesButtonStatus;
-(void)updateInfoList;
- (void) IsOldman;
@property (weak, nonatomic) IBOutlet UIView *IpdownBackView;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
@property (weak, nonatomic) IBOutlet UIImageView *gameBg;
@property (weak, nonatomic) IBOutlet UIImageView *gameDecoration;
@property (weak, nonatomic) IBOutlet UIView *opBar;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnHint;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UIButton *btnGC;
@property (weak, nonatomic) IBOutlet UIButton *btnWin;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *winLabel;
@property (weak, nonatomic) IBOutlet UIView *admobView;
@property (weak, nonatomic) IBOutlet UIImageView *heartView;
@property (weak, nonatomic) IBOutlet UIButton *btnPass;
- (IBAction)passConfirm:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *dealBtn;
- (IBAction)newHand:(id)sender;

- (void)newDeal;
- (BOOL)isPortrait;
@end
