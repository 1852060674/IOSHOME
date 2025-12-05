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


@protocol SolitaireViewDelegate <NSObject>
- (void)toggleAdViewHidden:(BOOL)hidden;

- (void)toggleUndoEnable:(BOOL)enabled;
- (void)toggleHintEnable:(BOOL)enabled;
- (void)toggleAutoCompleteEnable:(BOOL)enabled;
- (void)showTheHint;
- (void)tryCancelWinAnimation;
- (void)toggleIsRoundDrawMove:(BOOL)Moved;
@end


@interface SolitaireView : UIView

@property (strong, nonatomic) Solitaire *game;
@property (weak, nonatomic) id <SolitaireViewDelegate> opDelegate;
@property (weak, nonatomic) id <SolitaireDelegate> delegate;
@property (assign, nonatomic) BOOL hideOp;
@property (assign, atomic) BOOL hinting;
@property (assign, nonatomic) int anaCnt;
@property (assign, nonatomic) int anaIdx;
@property (strong, nonatomic) NSArray* topCards;
@property (assign, nonatomic) BOOL autoOn;
@property (assign, nonatomic) BOOL complete;
@property (assign, nonatomic) BOOL needAuto;
@property (weak, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *orienSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *tapmoveSwitch;
@property (assign,atomic) BOOL hintend;
/// sound
@property (assign, nonatomic) BOOL sound;

@property (nonatomic, assign) BOOL stockOnRight;
@property (nonatomic, assign) BOOL freecellOnTop;


/// settings
@property (assign, nonatomic) BOOL rightHand;
@property (assign, nonatomic) UIDeviceOrientation savedOri;

@property (strong, nonatomic) NSMutableArray* allBgPicViews;
@property (strong, nonatomic) NSMutableArray* allBkPicViews;
@property (strong, nonatomic) NSMutableArray* allCfPicViews;

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

- (void)updateExpand;
- (void)resetExpand;

- (void)updateAutoBtn;
- (void)updateUndoBtn;

- (void)updateCardBack;
- (void)updateCardForground;

- (void)firstInCompute;///for ios7

- (void)layoutSkinView;

- (void)updateBgSelected:(int)idx;
- (void)updateBkSelected:(int)idx;
- (void)updateCfSelected:(int)idx;

- (void)hideShadow:(int) scrollIdx picIdx:(int)picIdx ishide:(BOOL) hide;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView;
@property (weak, nonatomic) IBOutlet UIImageView *gameBg;
@property (weak, nonatomic) IBOutlet UIImageView *gameDecoration;
@property (strong, nonatomic) UIView *opBar;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnHint;
@property (weak, nonatomic) IBOutlet UIButton *btnUndo;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *movesLabel;
@property (weak, nonatomic) IBOutlet UIView *statusView;
@property (weak, nonatomic) IBOutlet UIView *gamestatView;
@property (weak, nonatomic) IBOutlet UIButton *btnGC;
@property (weak, nonatomic) IBOutlet UIButton *btnWin;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *winLabel;
@property (weak, nonatomic) IBOutlet UIView *admobView;
@property (weak, nonatomic) IBOutlet UIView *skinView;
@property (weak, nonatomic) IBOutlet UIView *cfView;
@property (weak, nonatomic) IBOutlet UIScrollView *bgScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *bkScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *cardPicker;
@property (weak, nonatomic) IBOutlet UITableView *gamestatTable;
@property (weak, nonatomic) IBOutlet UIView *helpView;
@property (weak, nonatomic) IBOutlet UITextView *rulesTextView;
@property (weak, nonatomic) IBOutlet UIView *btnHelpView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowImageView;
@property (weak, nonatomic) IBOutlet UIView *winView;
@property (weak, nonatomic) IBOutlet UIImageView *wanIv;
@property (weak, nonatomic) IBOutlet UIImageView *wbnIv;
@property (weak, nonatomic) IBOutlet UIImageView *wcnIv;

@property (weak, nonatomic) IBOutlet UIImageView *wdnIv;
@property (weak, nonatomic) IBOutlet UIImageView *wenIv;
@property (weak, nonatomic) IBOutlet UIView *btnLHelpView;
@property (weak, nonatomic) IBOutlet UIButton *btnHHelp;

@property (nonatomic, assign) BOOL isLayoutingCardView;

- (void)playClickSound ;

- (void)playQuickClickSound ;

- (void)playShuffleSound ;

- (BOOL)isPortrait ;

- (void)firstInitAutoHintTimer;


- (NSArray *)allCardViews ;


- (CGSize)cardViewSize ;

- (CGSize)screenSize ;

@property (nonatomic, assign) CGFloat safeBottomHeight;
- (CGPoint)statusLeading ;

- (CGPoint)statusLeadingPortrait:(BOOL)port ;
- (void)resetAutohintTimer;

- (CGFloat)adViewHeight;

@end
