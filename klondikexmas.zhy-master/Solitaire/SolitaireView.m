//
//  SolitaireView.m
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved. 
//

#import <QuartzCore/QuartzCore.h>
#import "SolitaireView.h"
#import "Solitaire.h"
#import "CardView.h"
#import "MoveAction.h"
#import "UIApplication+Size.h"
#import "Config.h"
#import "Admob.h"
#import "ZhConfig.h"
#import "ApplovinMaxWrapper.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#define DIFF_TAB_FOUND (NUM_TABLEAUS - NUM_FOUNDATIONS)

#define HITCARDS_NUM 13

@implementation SolitaireView {
    NSMutableDictionary *cards;

    CardView *bottomStock;
    CardView *bottomFoundations[NUM_FOUNDATIONS];
    CardView *bottomTableaux[NUM_TABLEAUS];
    
    CGFloat _s;
    CGFloat _w;
    CGFloat _h;
    CGFloat _d;
    CGFloat _f;
    CGFloat _o;
    CGFloat _fs;
    
    CGPoint touchStartPoint;
    CGPoint startCenter;
    Card *touchedCard;
    NSArray *touchedFan;
    
    CGFloat _sc_width;
    CGFloat _sc_height;
    
    CGFloat MARGINY;
    CGFloat MARGINX;
    CGFloat MARGINFOUNDATIONY;
    CGFloat BUFFER_WIDTH;
    CGFloat WASTE_SPACE;
    CGFloat TABLE_SPACE;
    
    ///
    CardView* _hintViews[HITCARDS_NUM];
    
    /// 
    BOOL moveFlag;
    //
    BOOL moreFlag;
    
    int topMargin;
    int bottomMargin;
    
    BOOL liuhaiScrren;
    BOOL Flag;
    BOOL Flag1;
}

@synthesize game = _game;
@synthesize delegate = _delegate;

@synthesize rightHand;
@synthesize hinting;
@synthesize topCards;
@synthesize anaCnt;
@synthesize anaIdx;
@synthesize autoOn;
@synthesize complete;
@synthesize needAuto;

@synthesize sound = _sound;
@synthesize shuffleSound = _shuffleSound;
@synthesize clickSound = _clickSound;
@synthesize clickQuickSound = _clickQuickSound;

@synthesize savedOri = _savedOri;

AVAudioSession *audioSession;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;  //主要用于alapha
        /// tap to hide/display opbar
        self.hideOp = NO;
    }
    return self;
}

- (void) setLayoutGuideTop:(int) top Bottom:(int)bottom {
    topMargin = top;
    bottomMargin = bottom;
}

- (void)updateCardBack
{
    for (Card* c in cards) {
        [[cards objectForKey:c] setNeedsDisplay];
    }
}

- (void)updateCardForground
{
    for (Card* c in cards) {
        CardView* cv = [cards objectForKey:c];
        [cv updateClassic:c];
        [cv setNeedsDisplay];
    }
}

- (void)hideOrDisplayOpBar
{
    self.hideOp = !self.hideOp;
    if (self.hideOp) {
        [UIView beginAnimations:@"Hide" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
#ifndef AD_POS_UP
        if(self.adviewBottomConstraint != nil) {
            self.adviewBottomConstraint.constant = bottomMargin;
        } else {
            // 下
            [self.admobView setFrame:CGRectMake(self.admobView.frame.origin.x, self.frame.size.height - self.admobView.frame.size.height-20, self.admobView.frame.size.width, self.admobView.frame.size.height)];
        }
#endif
        if(self.opBarBottomConstraint != nil) {
            self.opBarBottomConstraint.constant = -self.opBar.frame.size.height - bottomMargin;
        } else {
            [self.opBar setFrame:CGRectMake(0.0, self.frame.size.height+20, self.frame.size.width, self.opBar.frame.size.height)];
        }
        self.moreGameBtn.alpha = 0;
        [self layoutIfNeeded];
        [UIView commitAnimations];
        if (moreFlag) {
            [UIView animateWithDuration:0.3 animations:^{
                if(self.moreGameConstraint != nil) {
                    self.moreGameConstraint.constant = -self.moreGamesView.frame.size.width;
                } else {
                    self.moreGamesView.frame = CGRectMake(self.frame.size.width, self.frame.size.height-self.moreGamesView.frame.size.height, self.moreGamesView.frame.size.width, self.moreGamesView.frame.size.height);
                }
            } completion:^(BOOL finished) {
                moreFlag = !moreFlag;
                if (moreFlag) {
                    [self.moreGameBtn setImage:[UIImage imageNamed:@"moreout"] forState:UIControlStateNormal];
                }
                else
                    [self.moreGameBtn setImage:[UIImage imageNamed:@"morein"] forState:UIControlStateNormal];
            }];
        }
    }
    else
    {
        [UIView beginAnimations:@"Display" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
#ifndef AD_POS_UP
        // ipd 20240205 update ipd opbarheight -20
        if(self.adviewBottomConstraint != nil) {
            self.adviewBottomConstraint.constant = 0;
        } else {
            // 上
            [self.admobView setFrame:CGRectMake(self.admobView.frame.origin.x, self.frame.size.height- self.admobView.frame.size.height - self.opBar.frame.size.height - bottomMargin+20, self.admobView.frame.size.width, self.admobView.frame.size.height)];
        }
#endif
        if(self.opBarBottomConstraint != nil) {
            self.opBarBottomConstraint.constant = 0;
        } else {
            // 上
            [self.opBar setFrame:CGRectMake(0.0, self.frame.size.height- self.opBar.frame.size.height - bottomMargin+20, self.opBar.frame.size.width, self.opBar.frame.size.height)];
        }
        self.moreGameBtn.alpha = 1;
        [self layoutIfNeeded];
        [UIView commitAnimations];
    }
    //self.opBar.hidden = self.hideOp;
}

- (void)loadGameUI
{
    Flag=FALSE;
    Flag1=false;
//    self.btnPlay.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.moreGamesView setHidden:YES];
    audioSession= [AVAudioSession sharedInstance];
    [audioSession setActive:YES error:nil];
    /// 根据当前屏幕状态调整ui
    self.hintLabel.alpha = 0;
    //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GreenFelt"]];
    self.gameBg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    //self.gameDecoration.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    //self.gameDecoration.image = [UIImage imageNamed:@"Decoration"];
//    self.opBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    //self.opBar.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height - self.opBar.frame.size.height/2.0);
    //self.admobView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height - self.opBar.frame.size.height - self.admobView.frame.size.height/2.0);
    self.statusView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.admobView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    if(self.moreGameConstraint != nil) {
        self.moreGameConstraint.constant = -self.moreGamesView.frame.size.width;
    } else {
        self.moreGamesView.frame = CGRectMake(self.frame.size.width, self.frame.size.height-self.moreGamesView.frame.size.height, self.moreGamesView.frame.size.width, self.moreGamesView.frame.size.height);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.hinting) {
        [self stopHintAnamiation];
        return;
    }
    if (self.autoOn) {
        [self alphaBack];
    }
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
        [self hideOrDisplayOpBar];
    }
}

- (void)awakeFromNib {
    
    liuhaiScrren = [self isNotchScreen] && (kScreenHeight > 811 || kScreenWidth >811) && kScreenHeight + kScreenWidth < 1500;
    self.rightHand = NO;
    self.hinting = NO;
    moreFlag = NO;
    //self.autoOn = YES;
    self.needAuto = YES;
    self.savedOri = 0;
    MARGINY = 25;
    MARGINX = 5;
    BUFFER_WIDTH = 4;
    self.topCards = nil;
    NSURL *shuffleUrl = [[NSBundle mainBundle] URLForResource:@"shuffle" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)shuffleUrl, &_shuffleSound);
    NSURL *clickUrl = [[NSBundle mainBundle] URLForResource:@"click" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)clickUrl, &_clickSound);
    NSURL *clickQuickUrl = [[NSBundle mainBundle] URLForResource:@"click_quick" withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)clickQuickUrl, &_clickQuickSound);
    ///
    [self loadGameUI];
    /*
    ///
    [self computeSizes:YES];
    ///
    for (int i = 0; i < HITCARDS_NUM; i++) {
        _hintViews[i] = [[CardView alloc] initWithFrame:CGRectMake(0, 0, _w+2*[CardView hintWidth], _h+2*[CardView hintWidth]) andCard:[[Card alloc] initWithRank:1 Suit:1]];
        _hintViews[i].hidden = YES;
        //[self addSubview:_hintViews[i]];
    }
     */
    self.moreGameBtn.hidden = YES;
}

- (void)firstInCompute
{
    ///
    [self computeSizes:YES];
    ///
    for (int i = 0; i < HITCARDS_NUM; i++) {
        _hintViews[i] = [[CardView alloc] initWithFrame:CGRectMake(0, 0, _w+2*[CardView hintWidth], _h+2*[CardView hintWidth]) andCard:[[Card alloc] initWithRank:1 Suit:1]];
        _hintViews[i].hidden = YES;
        //[self addSubview:_hintViews[i]];
    }
}

#pragma mark Initialization

- (void)setGame:(Solitaire *)game {
    
    ///
    _game = game;
    cards = [[NSMutableDictionary alloc] init];
    
    /// delete 
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[CardView class]]) {
            [view removeFromSuperview];
        }
    }
    [self computeSizes:YES];
    /// add bottom cards
    [self addBottomCardsToSubview];
    
    /// add game card
    [self iterateGameWithBlock:^(Card *c) {
        [self addToSubViewForCard:c];
    }];
    
    /// show
    [self computeBottomCardLayout];
    [self computeCardLayout:0.8 destPos:-1 destIdx:-1];
    
    ///
    [self updateUndoBtn];
    [self updateAutoBtn];
    self.winLabel.hidden = YES;
    
    /// shuffle sound
    if (self.sound  && [self getCurrentSound]) {
        AudioServicesPlaySystemSound(_shuffleSound);
    }
}

- (void)addToSubViewForCard:(Card *)c {
    // If card is not already in our view
    if ( ![cards objectForKey:c] ) {
        CardView *cv = [[CardView alloc] 
                        initWithFrame:CGRectMake(MARGINX, MARGINY, _w, _f)
                        andCard:c];
        [cards setObject:cv forKey:c];
        [self addSubview:cv];
    }
}

- (void)addBottomCardsToSubview {
    // Create bottom card images
    bottomStock = [[CardView alloc]
                   initWithFrame:CGRectMake(MARGINX, MARGINY, _w, _h)
                   specialCard:TYPE_STOCK];
    [self addSubview:bottomStock];
    
    for (int i = 0; i < NUM_TABLEAUS; i++) {
         bottomTableaux[i] = [[CardView alloc] initWithFrame:CGRectMake(MARGINX,MARGINY, _w, _h) specialCard:TYPE_EMPTY];
        [self addSubview:bottomTableaux[i]];
    }
    
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        bottomFoundations[i] = [[CardView alloc] initWithFrame:CGRectMake(MARGINX, MARGINY, _w, _h) specialCard:TYPE_FOUNDATION];
        [self addSubview:bottomFoundations[i]];
    }
}

#pragma mark Helper Functions

// Thanks Travis!
- (void)iterateGameWithBlock:(void (^)(Card *c))block { 

    for (Card *c in _game.stock) {
        block(c);
    }

    for (Card *c in _game.waste) {
        block(c);
    }

    for (int i = 0; i < NUM_TABLEAUS; i++) {
        for (Card *c in [_game tableau:i]) {
            block(c);
        }
    }

    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        for (Card *c in [_game foundation:i]) {
            block(c);
        }
    }
}

#pragma mark Layout Functions

- (void)rotateLayout:(UIInterfaceOrientation)toInterfaceOrientation{
    CGSize fs = [UIApplication sizeInOrientation:toInterfaceOrientation];
    _sc_width = fs.width;
    _sc_height = fs.height;
    NSLog(@"zzx %lf",_sc_height);
    [self computeSizes:NO];
    [self computeBottomCardLayout];
    [self anamiationDone];
    [self computeCardLayout:0.2 destPos:-1 destIdx:-1];
}

- (void)uiAdjust
{
#ifdef AD_POS_UP
    self.admobView.center = CGPointMake(_sc_width/2, self.admobView.frame.size.height/2-0.1);
    self.statusView.center = CGPointMake(_sc_width/2, (SHOW_AD ? self.admobView.frame.size.height : 0) + self.statusView.frame.size.height/2-0.1);
#else
    if (self.hideOp) {
        self.admobView.center = CGPointMake(_sc_width/2, _sc_height - self.admobView.frame.size.height/2);
    }
    else
    {
        self.opBar.center = CGPointMake(_sc_width/2, _sc_height - self.opBar.frame.size.height/2);
        self.admobView.center = CGPointMake(_sc_width/2, _sc_height - self.opBar.frame.size.height - self.admobView.frame.size.height/2);
    }
    self.statusView.center = CGPointMake(_sc_width/2, self.statusView.frame.size.height/2);
#endif
}

- (void)computeSizes:(BOOL)flag {

    if (flag) {
        CGSize fs = [UIApplication currentSize];
        _sc_width = fs.width;
        _sc_height = fs.height;
    }
    GLfloat width = _sc_width;
    GLfloat height = _sc_height;
    ////
    BOOL landScape= width > height;
    if ( landScape ) {
//        if (IS_IPAD) {
//            MARGINY = 30;
//            _h = (height - 2 * MARGINY)/6;
//        } else {
//            
//            MARGINY = 25;
//            _h = (height - 2 * MARGINY)/4.8;
//        }
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            MARGINX = 140;
            MARGINY = 35;
            //_h = (height - MARGINY) / 5.0;
            _h = ((height - MARGINY - self.admobView.frame.size.height - self.opBar.frame.size.height)/4);
            WASTE_SPACE = 6*BUFFER_WIDTH;
            MARGINFOUNDATIONY = 35;
        }
        else
        {
            MARGINX = 70;
            MARGINY = 20;
            WASTE_SPACE = 3*BUFFER_WIDTH;
            //_h = (height - MARGINY) / 4.5;
            _h = ((height - MARGINY - self.opBar.frame.size.height)/4);
            MARGINFOUNDATIONY = 10;
            if (liuhaiScrren && landScape) {
                _h = ((height - MARGINY - self.opBar.frame.size.height)/4)/1.2;
            }
        }
        _w = _h * ASPECT_RATIO_X;
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            MARGINY = 30+topMargin;
            WASTE_SPACE = 6*BUFFER_WIDTH;
        }
        else
        {
            MARGINY = 25+topMargin;
            WASTE_SPACE = 3*BUFFER_WIDTH;
        }
        MARGINX = 5;
        _w = ((width - 2*MARGINX) / NUM_TABLEAUS) - BUFFER_WIDTH/4;
        _h = _w * ASPECT_RATIO_Y;
    }
// 20240205 add by zh
    
    _s = _h/2.0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        _d = (width - 2*MARGINX - NUM_TABLEAUS*_w) / 8;
    else
        _d = landScape && liuhaiScrren ? (width - 2*MARGINX - NUM_TABLEAUS*_w) / 6 -30 : (width - 2*MARGINX - NUM_TABLEAUS*_w) / 6;
    _f = _h/6.0;
    _o = landScape && liuhaiScrren ? _h/2.7 : _h/3.5;
    _fs = _h/8.0;
#ifdef AD_POS_UP
    MARGINY += (SHOW_AD ? self.admobView.frame.size.height : 0);
#endif
}

- (void)computeBottomCardLayout {
    [UIView animateWithDuration:0.2 animations:^{
        CardView *cv;
        /// port

        if (_sc_width < _sc_height) {
            bottomStock.frame = CGRectMake(_sc_width - MARGINX - _w, MARGINY, _w, _h);
            for (int i = 0; i < NUM_TABLEAUS; i++) {
                cv = bottomTableaux[i];
                CGFloat tableauX = MARGINX + (i*_w) + (i*_d);
                CGFloat tableauY = MARGINY + _h + _s;
                bottomTableaux[i].frame = CGRectMake(tableauX, tableauY, _w, _h);
            }
            
            CGFloat foundationY = MARGINY;
            for (int i = 0; i < NUM_FOUNDATIONS; i++) {
                CGFloat foundationX = MARGINX + (i*(BUFFER_WIDTH)) + (i*_w);
                //CGFloat foundationX = _sc_width - MARGINX - (i*(BUFFER_WIDTH)) - ((i+1)*_w);
                bottomFoundations[i].frame = CGRectMake(foundationX, foundationY, _w, _h);
            }
        }
        /// land
        else
        {
            int pianyix=0;
            
            if (liuhaiScrren && !Flag) {
                MARGINX +=122;
                pianyix=50;

            }
            
            if (!liuhaiScrren && _sc_width + _sc_height <1500) {
                MARGINX +=7;
            }
            if (IS_IPAD) {
                MARGINX +=25;
            }
            bottomStock.frame = CGRectMake(_sc_width - BUFFER_WIDTH - _w - WASTE_SPACE -pianyix, _sc_height/3.0, _w, _h);
            
            for (int i = 0; i < NUM_TABLEAUS; i++) {
                cv = bottomTableaux[i];
                CGFloat tableauX = MARGINX - MARGINX/5.0 + (i*_w) + (i*_d);
                CGFloat tableauY = MARGINY;
                bottomTableaux[i].frame = CGRectMake(tableauX, tableauY, _w, _h);
            }
            
            CGFloat foundationX = BUFFER_WIDTH + pianyix ;
            for (int i = 0; i < NUM_FOUNDATIONS; i++) {
                CGFloat foundationY = i*_h + i*_fs + MARGINFOUNDATIONY;
                //CGFloat foundationX = _sc_width - MARGINX - (i*(BUFFER_WIDTH)) - ((i+1)*_w);
                bottomFoundations[i].frame = CGRectMake(foundationX, foundationY, _w, _h);
            }
        }
    }];
}

- (void)computeCardLayout:(float)duation destPos:(int)pos destIdx:(int)idx{
    [UIView animateWithDuration:duation animations:^{
        //NSLog(@"%d", [[UIDevice currentDevice] orientation]);
        CardView *cv;
        int draw_cnt = [_game drawCnt];
        /// port
        if (_sc_width < _sc_height) {
            for (Card *c in _game.stock) {
                cv = [cards objectForKey:c];
                cv.frame = CGRectMake(_sc_width - MARGINX - _w, MARGINY, _w, _h);
                [self bringSubviewToFront:cv];
                [self bringSubviewToFront:self.admobView];
            }
            
            CGFloat wasteX = _sc_width - MARGINX - 2*_w - NUM_TABLEAUS*BUFFER_WIDTH;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                wasteX = _sc_width - MARGINX - 2*_w - 2*NUM_TABLEAUS*BUFFER_WIDTH;
            }
            if (draw_cnt == 1) {
                wasteX += WASTE_SPACE;
            }
            CGFloat wasteY = MARGINY;
            int wastecnt = [_game.waste count];
            int beginidx = wastecnt - draw_cnt;
            for (int i = 0; i < beginidx; i++) {
                cv = [cards objectForKey:_game.waste[i]];
                cv.frame = CGRectMake(wasteX, wasteY, _w, _h);
                [self bringSubviewToFront:cv];
                [self bringSubviewToFront:self.admobView];
            }
            if (beginidx < 0) {
                beginidx = 0;
            }
            for (int i = beginidx; i - beginidx < draw_cnt && i < wastecnt; i++) {
                cv = [cards objectForKey:_game.waste[i]];
                cv.frame = CGRectMake(wasteX + (i - beginidx)*WASTE_SPACE, wasteY, _w, _h);
                [self bringSubviewToFront:cv];
                [self bringSubviewToFront:self.admobView];
            }
            
            for (int i = 0; i < NUM_TABLEAUS; i++) {
                CGFloat tableauX = MARGINX + (i*_w) + (i*_d);
                CGFloat tableauY = MARGINY + _h + _s;
                CGFloat offsetY = 0;
                for (int j = 0; j < [[_game tableau:i] count]; j++) {
                    Card *c = [[_game tableau:i] objectAtIndex:j];
                    tableauY = MARGINY + _h + _s + offsetY;
                    if (c.faceUp) {
                        offsetY += _o;
                    }
                    else
                    {
                        offsetY += _f;
                    }
                    cv = [cards objectForKey:c];
                    cv.frame = CGRectMake(tableauX, tableauY, _w, _h);
                    [self bringSubviewToFront:cv];
                    [self bringSubviewToFront:self.admobView];
                }
                if (pos == POS_TABEAU && i == idx) {
                    for (int j = 0; j < HITCARDS_NUM; j++) {
                        if (!_hintViews[j].hidden) {
                            tableauY = MARGINY + _h + _s + offsetY;
                            offsetY += _o;
                            //_hintViews[j].frame = CGRectMake(tableauX, tableauY, _w, _h);
                            _hintViews[j].center = CGPointMake(tableauX + _w/2, tableauY + _h/2);
                            [self bringSubviewToFront:_hintViews[j]];
                        }
                    }
                }
            }
            
            CGFloat foundationY = MARGINY;
            for (int i = 0; i < NUM_FOUNDATIONS; i++) {
                //        CGFloat foundationX = MARGIN + ((i+DIFF_TAB_FOUND)*_w) + ((i+DIFF_TAB_FOUND+2)*_d);
                CGFloat foundationX = MARGINX + (i*(BUFFER_WIDTH)) + (i*_w);
                for (Card *c in [_game foundation:i]) {
                    cv = [cards objectForKey:c];
                    cv.frame = CGRectMake(foundationX, foundationY, _w, _h);
                    [self bringSubviewToFront:cv];
                    [self bringSubviewToFront:self.admobView];
                }
                if (pos == POS_FOUNDATION && i == idx) {
                    for (int j = 0; j < HITCARDS_NUM; j++) {
                        if (!_hintViews[j].hidden) {
                            _hintViews[j].center = CGPointMake(foundationX + _w/2, foundationY + _h/2);
                            [self bringSubviewToFront:_hintViews[j]];
                        }
                    }
                }
            }
        }
        /// land
        else
        { // update by zzx 横评刘海-50测试
            int pianyix= 0;
            if (liuhaiScrren) {
                pianyix =50;//  会导致牌库的牌移动
            }
            for (Card *c in _game.stock) {
                cv = [cards objectForKey:c];
                cv.frame = CGRectMake(_sc_width - BUFFER_WIDTH - _w - WASTE_SPACE-pianyix, _sc_height/3.0, _w, _h);
                [self bringSubviewToFront:cv];
                [self bringSubviewToFront:self.admobView];
            }
            
            CGFloat wasteX = _sc_width - NUM_TABLEAUS*BUFFER_WIDTH - _w -pianyix;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                wasteX = _sc_width - 2*NUM_TABLEAUS*BUFFER_WIDTH - _w  -pianyix;
            }
            if (draw_cnt == 1) {
                wasteX = _sc_width - BUFFER_WIDTH - _w - WASTE_SPACE  -pianyix;
            }
            CGFloat wasteY = 8*BUFFER_WIDTH;
            int wastecnt = [_game.waste count];
            int beginidx = wastecnt - draw_cnt;
            for (int i = 0; i < beginidx; i++) {
                cv = [cards objectForKey:_game.waste[i]];
                cv.frame = CGRectMake(wasteX, wasteY, _w, _h);
                [self bringSubviewToFront:cv];
                [self bringSubviewToFront:self.admobView];
            }
            if (beginidx < 0) {
                beginidx = 0;
            }
            for (int i = beginidx; i - beginidx < draw_cnt && i < wastecnt; i++) {
                cv = [cards objectForKey:_game.waste[i]];
                cv.frame = CGRectMake(wasteX + (i - beginidx)*WASTE_SPACE, wasteY, _w, _h);
                [self bringSubviewToFront:cv];
                [self bringSubviewToFront:self.admobView];
            }
            
            for (int i = 0; i < NUM_TABLEAUS; i++) {
                CGFloat tableauX = MARGINX  - MARGINX/5.0 + (i*_w) + (i*_d);
                CGFloat tableauY = MARGINY;
                CGFloat offsetY = 0;
                for (int j = 0; j < [[_game tableau:i] count]; j++) {
                    Card *c = [[_game tableau:i] objectAtIndex:j];
                    tableauY = MARGINY + offsetY;
                    if (c.faceUp) {
                        offsetY += _o;
                    }
                    else
                    {
                        offsetY += _f;
                    }
                    cv = [cards objectForKey:c];
                    cv.frame = CGRectMake(tableauX, tableauY, _w, _h);
                    [self bringSubviewToFront:cv];
                    [self bringSubviewToFront:self.admobView];
                }
                if (pos == POS_TABEAU && i == idx) {
                    for (int j = 0; j < HITCARDS_NUM; j++) {
                        if (!_hintViews[j].hidden) {
                            tableauY = MARGINY + offsetY;
                            offsetY += _o;
                            //_hintViews[j].frame = CGRectMake(tableauX, tableauY, _w, _h);
                            _hintViews[j].center = CGPointMake(tableauX + _w/2, tableauY + _h/2);
                            [self bringSubviewToFront:_hintViews[j]];
                        }
                    }
                }
            }
            
            CGFloat foundationX = BUFFER_WIDTH - pianyix;
            for (int i = 0; i < NUM_FOUNDATIONS; i++) {
                //        CGFloat foundationX = MARGIN + ((i+DIFF_TAB_FOUND)*_w) + ((i+DIFF_TAB_FOUND+2)*_d);
                CGFloat foundationY = i*_h + i*_fs + MARGINFOUNDATIONY;
                for (Card *c in [_game foundation:i]) {
                    cv = [cards objectForKey:c];
                    cv.frame = CGRectMake(foundationX, foundationY, _w, _h);
                    [self bringSubviewToFront:cv];
                    [self bringSubviewToFront:self.admobView];
                }
                if (pos == POS_FOUNDATION && i == idx) {
                    for (int j = 0; j < HITCARDS_NUM; j++) {
                        if (!_hintViews[j].hidden) {
                            _hintViews[j].center = CGPointMake(foundationX + _w/2, foundationY + _h/2);
                            [self bringSubviewToFront:_hintViews[j]];
                        }
                    }
                }
            }
        }
        /// surface
        if (self.topCards != nil) {
            for (Card* card in self.topCards) {
                [[cards objectForKey:card] setNeedsDisplay];
                [self bringSubviewToFront:[cards objectForKey:card]];
            }
        }
        self.topCards = nil;
        for (int j = 0; j < HITCARDS_NUM; j++) {
            if (!_hintViews[j].hidden) {
                [self bringSubviewToFront:_hintViews[j]];
            }
        }
        /// stat info update
        self.movesLabel.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedStringFromTable(@"moves", @"Language", nil),self.game.moves];
        self.scoreLabel.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedStringFromTable(@"score", @"Language", nil),self.game.scores];
        /// opbar to top
        [self bringSubviewToFront:self.opBar];
        [self bringSubviewToFront:self.admobView];
        //
        [self bringSubviewToFront:self.moreGamesView];
        [self bringSubviewToFront:self.moreGameBtn];
    } completion:^(BOOL finished){
        if (pos != -1) {
            self.anaIdx++;
            if (self.anaIdx < self.anaCnt) {
                [self anamiationDone];
            }
            else
                [self stopHintAnamiation];
            [UIView animateWithDuration:HINTINFO_TIME
                             animations:^{
                                 self.hintLabel.alpha = 0.0;
         }];
        }
        else
        {
            [self updateAutoBtn];
            if ([self.game alreadyDone]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"autoCompleteDone" object:@"done"];
                [self setUserInteractionEnabled:YES];
            }
        }
    }];
}

- (void)updateAutoBtn
{
    if ([self.game gameWon]) {
        if (self.game.firstAuto) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"autoAction" object:@"done"];
            self.game.firstAuto = NO;
        }
        self.btnWin.hidden = NO;
    }
    else
    {
        self.btnWin.hidden = YES;
    }
}

- (void)updateUndoBtn
{
    ///
    if ([self.game canUndo]) {
        self.btnUndo.hidden = NO;
    }
    else
    {
        self.btnUndo.hidden = YES;
    }
}

#pragma mark Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView {
    if (self.game.won) {
        return;
    }
    touchStartPoint = [[touches anyObject] locationInView:self];
    startCenter = cardView.center;
    moveFlag = NO;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView {
    if (self.game.won) {
        return;
    }
    if (self.autoOn) {
        [self alphaBack];
    }
    if (self.hinting) {
        [self stopHintAnamiation];
        return;
    }
    // Pick up the fan and move it
    CGPoint touchPoint = [[touches anyObject] locationInView:self]; 
    CGPoint delta = CGPointMake(touchPoint.x - touchStartPoint.x, touchPoint.y - touchStartPoint.y);
    CGPoint newCenter = CGPointMake(startCenter.x + delta.x, startCenter.y + delta.y);
    
    NSArray *fan = [_game fanBeginningWithCard:[cardView card]];
    // Card is on the waste
    if (nil == fan && [_game.waste containsObject:[cardView card]]) {
        cardView.center = newCenter;
    } else {    // Card is in a fan        
        for (int i = 0; i < [fan count]; i++) {
            CardView *cv = [cards objectForKey:[fan objectAtIndex:i]];
            cv.center = CGPointMake(newCenter.x, newCenter.y + (i * _o));
            [self bringSubviewToFront:cv];
            [self bringSubviewToFront:self.admobView];
        }
    }
    moveFlag = YES;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView  {
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView  {
    if (self.game.won) {
        return;
    }
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    CGPoint delta = CGPointMake(touchPoint.x - touchStartPoint.x, touchPoint.y - touchStartPoint.y);
//    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (((UITouch*)[touches anyObject]).tapCount == 1 && (moveFlag == NO || (fabsf(delta.x) < 0.2f*_w && fabsf(delta.y) < 0.15f*_h))) {
        ///
        if (self.hinting) {
            [self stopHintAnamiation];
            return;
        }
        ///
        if (self.autoOn) {
            BOOL oldFlag = (cardView.alpha < 1);
            [self alphaBack];
            self.topCards = [self.game autoAction:cardView.card];
            if ([self.topCards count] > 0) {
                if (self.sound  && [self getCurrentSound])
                    AudioServicesPlaySystemSound(_clickSound);
                self.game.moves++;
                [self updateUndoBtn];
                [self computeCardLayout:0.2 destPos:-1 destIdx:-1];
            }
            else
            {
                NSArray* fan = [self.game fanBeginningWithCard:cardView.card];
                if (!oldFlag) {
                    for (Card* c in fan) {
                        CardView* cv = [cards objectForKey:c];
                        cv.alpha = 0.8;
                    }
                }
                [self computeCardLayout:0.2 destPos:-1 destIdx:-1];
            }
        }
        if ([[self.game stock] containsObject:cardView.card] == NO
            && cardView != bottomStock) {
            return;
        }
    }
    Card *c = [cardView card];
    BOOL clickSoundFlag = NO;
    NSMutableArray* moveActions = [[NSMutableArray alloc] init];
    if ([_game.stock containsObject:c] ) {
        [_delegate moveStockToWaste];
        [[cards objectForKey:[_game.stock lastObject]] setNeedsDisplay]; // Redraw top of Stock
        /// redraw waste top 3
        for (int i = 0; i < [_game.waste count]; i++) {
            if (i + 3 >= [_game.waste count]) {
                [[cards objectForKey:_game.waste[i]] setNeedsDisplay];
            }
        }
        //[[cards objectForKey:[_game.waste lastObject]] setNeedsDisplay]; // Redraw new waste card
        clickSoundFlag = YES;
        [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_STOCK to:POS_WASTE cardcnt:[self.game drawCnt] fromIdx:0 toIdx:0]];
    } else if ( cardView == bottomStock ) {
        if ([_game.waste count] > 0) {
            [_delegate moveStockToWaste];
            /// redraw waste top 3
            for (int i = 0; i < [_game.waste count]; i++) {
                if (i + 3 >= [_game.waste count]) {
                    [[cards objectForKey:_game.waste[i]] setNeedsDisplay];
                }
            }
            //[[cards objectForKey:[_game.waste lastObject]] setNeedsDisplay]; // Redraw new waste card
            [[cards objectForKey:[_game.stock lastObject]] setNeedsDisplay]; // Redraw top of Stock
            clickSoundFlag = YES;
            [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_WASTE to:POS_STOCK cardcnt:[_game.stock count] fromIdx:0 toIdx:0]];
            self.game.tiles++;
            if ([self.game drawCnt] == 3) {
                if (self.game.tiles%3 == 0) {
                    self.game.scores -= 20;
                }
            }
            else
            {
                self.game.scores -= 100;
            }
            if (self.game.scores < 0) {
                self.game.scores = 0;
            }
        }
    } else if (!c.faceUp) {
        if ([_delegate flipCard:c]) {
            [[cards objectForKey:c] setNeedsDisplay];
            clickSoundFlag = YES;
            if (self.sound  && [self getCurrentSound])
                AudioServicesPlaySystemSound(_clickSound);
            return; // Break early 'cause we're just flipping
        }
    }
    
    NSArray *fan = [_game fanBeginningWithCard:c];
    CGFloat fanHeight = _h + ([fan count] - 1) * _o;
    CGRect fanRect = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, _w, fanHeight);
    
    BOOL didFlag = NO;
    
    NSInteger pos = 0;
    NSInteger idx = 0;
    [self.game positionCard:[cardView card] pos:&pos idx:&idx];
    
    /// port
    if (_sc_width < _sc_height)
    {
        if ([fan count] == 1 && cardView.center.y < MARGINY + _h + (_s/2)) { // Check Foundation
            for (int i = 0; i < NUM_FOUNDATIONS; i++) { // Iterate through foundations
                CardView *cvFound = bottomFoundations[i];
                if ( CGRectIntersectsRect(cvFound.frame, fanRect) ) {// See if foundation intersects with card
                    didFlag = [_delegate movedCard:[cardView card] toFoundation:i]; // Move card
                    /// need break
                    if (didFlag) {
                        [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:pos to:POS_FOUNDATION cardcnt:[fan count] fromIdx:idx toIdx:i]];
                        if (pos != POS_FOUNDATION) {
                            self.game.scores += 10;
                        }
                        break;
                    }
                }
            }
        } else { // May intersect with tableau
            for (int i = 0; i < NUM_TABLEAUS; i++) {
                NSArray *tab = [_game tableau:i];
                CardView *cvTab = [cards objectForKey:[tab lastObject]];
                if ( cvTab == [cards objectForKey:[fan lastObject]] ) continue; // If touched CardView == lastCardView in Tableau
                
                if ( [tab count] == 0 )
                    cvTab = bottomTableaux[i]; // Empty tableau
                
                //CGFloat tabHeight = _h + [tab count] * (_f - 1);
                //CGFloat tabHeight = _h + offset;
                CGRect tabRect = CGRectMake(cvTab.frame.origin.x, cvTab.frame.origin.y, _w, _h);
                if ( CGRectIntersectsRect(tabRect, fanRect) ) {
                    didFlag = [_delegate movedFan:fan toTableau:i];
                    /// need break
                    if (didFlag) {
                        [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:pos to:POS_TABEAU cardcnt:[fan count] fromIdx:idx toIdx:i]];
                        if (pos == POS_FOUNDATION) {
                            self.game.scores -= 15;
                            if (self.game.scores < 0) {
                                self.game.scores = 0;
                            }
                        }
                        else
                            self.game.scores += 5;
                        break;
                    }
                }
            }
        }
    }
    /// land
    else
    {
        if ([fan count] == 1 && cardView.center.x < BUFFER_WIDTH + _w + _w/2) { // Check Foundation
            for (int i = 0; i < NUM_FOUNDATIONS; i++) { // Iterate through foundations
                CardView *cvFound = bottomFoundations[i];
                if ( CGRectIntersectsRect(cvFound.frame, fanRect) ) {// See if foundation intersects with card
                    didFlag = [_delegate movedCard:[cardView card] toFoundation:i]; // Move card
                    if (didFlag) {
                        [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:pos to:POS_FOUNDATION cardcnt:[fan count] fromIdx:idx toIdx:i]];
                        if (pos != POS_FOUNDATION) {
                            self.game.scores += 10;
                        }
                        break;
                    }
                }
            }
        } else { // May intersect with tableau
            for (int i = 0; i < NUM_TABLEAUS; i++) {
                NSArray *tab = [_game tableau:i];
                CardView *cvTab = [cards objectForKey:[tab lastObject]];
                if ( cvTab == [cards objectForKey:[fan lastObject]] ) continue; // If touched CardView == lastCardView in Tableau
                
                if ( [tab count] == 0 )
                    cvTab = bottomTableaux[i]; // Empty tableau
                
                //CGFloat tabHeight = _h + [tab count] * (_f - 1);
                //CGFloat tabHeight = _h + offset;
                CGRect tabRect = CGRectMake(cvTab.frame.origin.x, cvTab.frame.origin.y, _w, _h);
                if ( CGRectIntersectsRect(tabRect, fanRect) ) {
                    didFlag = [_delegate movedFan:fan toTableau:i];
                    if (didFlag) {
                        [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:pos to:POS_TABEAU cardcnt:[fan count] fromIdx:idx toIdx:i]];
                        if (pos == POS_FOUNDATION) {
                            self.game.scores -= 15;
                            if (self.game.scores < 0) {
                                self.game.scores = 0;
                            }
                        }
                        else
                            self.game.scores += 5;
                        break;
                    }
                }
            }
        }
    }
    
    /// face up the top one
    if (didFlag) {
        clickSoundFlag = YES;
        for (int i = 0; i < NUM_TABLEAUS; i++) {
            NSArray *tab = [_game tableau:i];
            Card* card = [tab lastObject];
            if (card != nil && !card.faceUp) {
                card.faceUp = YES;
                [[cards objectForKey:card] setNeedsDisplay];
                [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_FACEUP from:pos to:pos cardcnt:1 fromIdx:idx toIdx:idx]];
                break;
            }
        }
    }

    if (clickSoundFlag) {
        if (self.sound  && [self getCurrentSound])
            AudioServicesPlaySystemSound(_clickSound);
        ///
        self.game.moves++;
    }
    /// avoid coverd
    self.topCards = fan;
    /// push actions
    if ([moveActions count] > 0) {
        [self.game pushAction:moveActions];
    }
    [self updateUndoBtn];
    ///
    [self computeCardLayout:0.2 destPos:-1 destIdx:-1];
}

- (void)displayHint:(NSArray*)fan toPos:(int)pos toIdx:(int)idx seq:(int)seq total:(int)total
{
    NSString* hintInfo = [NSString stringWithFormat:@"%@ %d / %d",NSLocalizedStringFromTable(@"hintmove", @"Language", nil),seq,total];
    self.hintLabel.alpha = 1;
    self.hintLabel.text = hintInfo;
    [UIView animateWithDuration:0.1 delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        self.hintLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        for (int i = 0; i < [fan count]; i++) {
            Card* card = fan[i];
            Card* copyOne = [[Card alloc] initWithRank:card.rank Suit:card.suit];
            copyOne.glow = YES;
            copyOne.faceUp = YES;
            CardView *glowOne = _hintViews[i];
            glowOne.frame = CGRectMake(0, 0, _w+2*[CardView hintWidth], _h+2*[CardView hintWidth]);
            [glowOne setNewCard:copyOne];
            glowOne.hidden = NO;
            glowOne.center = ((CardView*)[cards objectForKey:card]).center;
            [self addSubview:glowOne];
            [glowOne setNeedsDisplay];
            [self computeCardLayout:MOVE_TIME destPos:pos destIdx:idx];
        }
    }];
}

- (void)anamiationDone
{
    for (int j = 0; j < HITCARDS_NUM; j++) {
        if (!_hintViews[j].hidden) {
            [_hintViews[j] removeFromSuperview];
            [_hintViews[j].layer removeAllAnimations];
            _hintViews[j].hidden = YES;
        }
    }
    self.hintLabel.alpha = 0;
}

- (void)stopHintAnamiation
{
    [_delegate cancelDelay];
    [self anamiationDone];
    self.hinting = NO;
}

- (void)alphaBack
{
    for (Card* c in cards) {
        ((CardView*)[cards objectForKey:c]).alpha = 1;
    }
}

//- (void)layoutSubviews {
//
//}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}

- (void)openAppById:(NSString*)appid
{
    NSString *iTunesLink = [NSString stringWithFormat:@"itms://itunes.apple.com/us/app/apple-store/id%@?mt=8",appid];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}

- (IBAction)onMore1:(id)sender {
    [self openAppById:MORE_APPID_1];
}

- (IBAction)onMore2:(id)sender {
    [self openAppById:MORE_APPID_2];
}

- (IBAction)onMore3:(id)sender {
    [self openAppById:MORE_APPID_3];
}

- (IBAction)onMore4:(id)sender {
    [self openAppById:MORE_APPID_4];
}

- (IBAction)onMore5:(id)sender {
    [self openAppById:MORE_APPID_5];
}

- (IBAction)onMore6:(id)sender {
    [self openAppById:MORE_APPID_6];
}

- (IBAction)onMore7:(id)sender {
    [self openAppById:MORE_APPID_7];
}

- (IBAction)onMore:(id)sender {
    //
    moreFlag = !moreFlag;
    if (moreFlag) {
        [self.moreGameBtn setImage:[UIImage imageNamed:@"moreout"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            if(self.moreGameConstraint != nil) {
                self.moreGameConstraint.constant = 0;
            } else {
                self.moreGamesView.frame = CGRectMake(self.frame.size.width-self.moreGamesView.frame.size.width, self.frame.size.height-self.moreGamesView.frame.size.height, self.moreGamesView.frame.size.width, self.moreGamesView.frame.size.height);
            }
        }];
    }
    else
    {
        [self.moreGameBtn setImage:[UIImage imageNamed:@"morein"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.3 animations:^{
            if(self.moreGameConstraint != nil) {
                self.moreGameConstraint.constant = -self.moreGamesView.frame.size.width;
            } else {
                self.moreGamesView.frame = CGRectMake(self.frame.size.width, self.frame.size.height-self.moreGamesView.frame.size.height, self.moreGamesView.frame.size.width, self.moreGamesView.frame.size.height);
            }
        }];
    }
}

- (BOOL)isNotchScreen {
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeAreaInsets = UIApplication.sharedApplication.windows.firstObject.safeAreaInsets;
        if (safeAreaInsets.left>0) {
            NSLog(@"这是safeAreaInsets.left>0屏");
            return YES;
        }
        if (safeAreaInsets.right>0) {
            NSLog(@"这是safeAreaInsets.right>0屏");
            return YES;
        }
        if (safeAreaInsets.bottom>0) {
            NSLog(@"这是safeAreaInsets.bottom>0屏");
            return YES;
        }
        if (safeAreaInsets.top > 0) {
            // 是刘海屏
            NSLog(@"这是刘海屏");
            return YES;
        }
    }
    NSLog(@"zzx have not hair");
    return NO;
}


- (BOOL)getCurrentSound{
    //    获取当前音量
    CGFloat volume = audioSession.outputVolume;
    NSLog(@"volume=  %lf",volume);
    if (volume*100 < 1) { //volum<0.01 means no voice
        return FALSE;
    }else{
        return TRUE;
    }
}
@end
