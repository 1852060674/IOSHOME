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
#import "NewPicView.h"
#import "SoundEffect.h"
#import "Admob.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

#define DIFF_TAB_FOUND (NUM_TABLEAUS - NUM_FOUNDATIONS)

#define HITCARDS_NUM 13

#define BG_CNT 6
#define BK_CNT 14

@implementation SolitaireView {
    NSMutableDictionary <Card*, CardView *>*cards;

    CardView *bottomStock[NUM_STOCKS];
    CardView *bottomFoundations[NUM_FOUNDATIONS];
    CardView *bottomTableaux[NUM_TABLEAUS];
    CardView *bottomReserve;
    
    BOOL expandFlag[NUM_TABLEAUS];
    BOOL userExpand[NUM_TABLEAUS];
    
    CGFloat _s;
    CGFloat _w;
    CGFloat _h;
    CGFloat _d;
    CGFloat _f;
    CGFloat _o;
    CGFloat _fs;
    CGFloat _dimO;


  CGFloat _oColumn[NUM_TABLEAUS];
  CGFloat _dimOColumn[NUM_TABLEAUS];
  CGFloat _fColumn[NUM_TABLEAUS];
  CGFloat _fsColumn[NUM_TABLEAUS];


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
    CGFloat MARGINLANDSCAPEY;
    
    ///
    CardView* _hintViews[HITCARDS_NUM];
  NSTimer * _autohintAdTimer;

    ///
    BOOL moveFlag;    
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

@synthesize savedOri = _savedOri;

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

- (void)updateCardBack
{
    for (Card* c in cards) {
        [(CardView *)[cards objectForKey:c] setNeedsDisplay];
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
    [self.opBar setHidden:self.hideOp];
    [self.admobView setHidden:!self.hideOp];
//    if (self.hideOp) {
//        [UIView beginAnimations:@"Hide" context:nil];
//        [UIView setAnimationDuration:0.4];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//#ifndef AD_POS_UP
//        [self.admobView setFrame:CGRectMake(self.admobView.frame.origin.x, self.frame.size.height - self.admobView.frame.size.height, self.admobView.frame.size.width, self.admobView.frame.size.height)];
//#endif
//        [self.opBar setFrame:CGRectMake(0.0, self.frame.size.height, self.frame.size.width, self.opBar.frame.size.height)];
//        [self.btnHelpView setFrame:CGRectMake(self.frame.size.width, self.btnHelpView.frame.origin.y, self.btnHelpView.frame.size.width, self.btnHelpView.frame.size.height)];
//        [self.btnLHelpView setFrame:CGRectMake(self.frame.size.width, self.btnLHelpView.frame.origin.y, self.btnLHelpView.frame.size.width, self.btnLHelpView.frame.size.height)];
//        [UIView commitAnimations];
//    }
//    else
//    {
//        [UIView beginAnimations:@"Display" context:nil];
//        [UIView setAnimationDuration:0.4];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
//#ifndef AD_POS_UP
//        [self.admobView setFrame:CGRectMake(self.admobView.frame.origin.x, self.frame.size.height- self.admobView.frame.size.height - self.opBar.frame.size.height, self.admobView.frame.size.width, self.admobView.frame.size.height)];
//#endif
//        [self.opBar setFrame:CGRectMake(0.0, self.frame.size.height- self.opBar.frame.size.height, self.opBar.frame.size.width, self.opBar.frame.size.height)];
//        [self.btnHelpView setFrame:CGRectMake(self.frame.size.width - self.btnHelpView.frame.size.width, self.btnHelpView.frame.origin.y, self.btnHelpView.frame.size.width, self.btnHelpView.frame.size.height)];
//        [self.btnLHelpView setFrame:CGRectMake(self.frame.size.width - self.btnLHelpView.frame.size.width, self.btnLHelpView.frame.origin.y, self.btnLHelpView.frame.size.width, self.btnLHelpView.frame.size.height)];
//        [UIView commitAnimations];
//    }
    //self.opBar.hidden = self.hideOp;
}

- (void)loadGameUI
{
    /// 根据当前屏幕状态调整ui
    self.hintLabel.alpha = 0;
    //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"GreenFelt"]];
    self.gameBg.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.gameDecoration.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.gameDecoration.image = [UIImage imageNamed:@"Decoration"];
    self.opBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    //self.opBar.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height - self.opBar.frame.size.height/2.0);
    //self.admobView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height - self.opBar.frame.size.height - self.admobView.frame.size.height/2.0);
    self.statusView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.admobView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.hinting) {
      [UIView performWithoutAnimation:^{
        [self stopHintAnamiation];
      }];
        return;
    }

    //_hintend = YES;
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 1) {
    }

  if([self.delegate respondsToSelector:@selector(tapOnDesktop)]) {
    [self.delegate tapOnDesktop];
  }
}

- (void)awakeFromNib {
  [super awakeFromNib];
    self.rightHand = NO;
    self.hinting = NO;
    //self.autoOn = YES;
    self.needAuto = YES;
    self.savedOri = 0;
    MARGINY = 25;
    MARGINX = 5;
    BUFFER_WIDTH = 4;
    self.topCards = nil;


    
    self.settingsView.hidden = YES;
    self.skinView.hidden = YES;
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
    [self layoutSettingsView];
    [self layoutSkinView];
    //self.gamestatTable.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btnclose2"]];
    self.gamestatView.hidden = YES;
    self.helpView.hidden = YES;
    //NSString *rulespath = [[NSBundle mainBundle] pathForResource:@"rules" ofType:@"txt"];
    //NSString *rulestext = [NSString stringWithContentsOfFile:rulespath encoding:NSUTF8StringEncoding error:nil];
    //self.rulesTextView.text = rulestext;


    for (int i = 0; i < NUM_TABLEAUS; i++) {
        expandFlag[i] = YES;
        userExpand[i] = YES;
    }
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cardwillmovetof:) name:card_will_move_to_f_key object:nil];
//  self.admobView.layer.zPosition = 1000;
  self.hintLabel.layer.zPosition = 1e5;
}

- (void)layoutSettingsView{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    BOOL sw = [[user objectForKey:@"sound"] boolValue];
    self.soundSwitch.on = sw;
    sw = [[user objectForKey:@"orientation"] boolValue];
    self.orienSwitch.on = !sw;
    //[self.orienSwitch setOn:NO];
    sw = [[user objectForKey:@"tapmove"] boolValue];
    self.tapmoveSwitch.on = sw;
    //NSLog(@"allow auto rotate %@",[[user objectForKey:@"orientation"] boolValue]?@"yes":@"no");
}

- (void)layoutSkinView{
    _allBgPicViews = [NSMutableArray arrayWithCapacity:BG_CNT];
    _allBkPicViews = [NSMutableArray arrayWithCapacity:BK_CNT];
    _allCfPicViews = [NSMutableArray arrayWithCapacity:2];
    CGFloat whrate = 0.7;
    CGFloat ih = self.bgScroll.frame.size.height;
    CGFloat iw = ih*whrate;
    //bg
    self.bgScroll.contentSize = CGSizeMake(iw*BG_CNT, ih);
    int bgIdx = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bg"] integerValue];
    for (int i=0; i<BG_CNT; i++) {
        NewPicView *pic = [[NewPicView alloc] initWithFrame:CGRectMake(i*iw, 0, iw, ih) imgName:[NSString stringWithFormat:@"bg%d",i] custom:NO idx:i type:kPicTypeGameBack];
        if(i == bgIdx)
            [pic setSelected:YES];
        else
            [pic setSelected:NO];
        [self.bgScroll addSubview:pic];
        [_allBgPicViews addObject:pic];
    }
    //bk
    self.bkScroll.contentSize = CGSizeMake(iw*BK_CNT, ih);
    int bkidx = [[[NSUserDefaults standardUserDefaults] objectForKey:@"bk"] integerValue];
    for (int i = 0; i < BK_CNT; i++)
    {
        NewPicView* npv = [[NewPicView alloc] initWithFrame:CGRectMake(i*iw, 0, iw, ih) imgName:[NSString stringWithFormat:@"bk%d",i] custom:NO idx:i type:kPicTypeCardBack];
        if (i == bkidx)
            [npv setSelected:YES];
        else
            [npv setSelected:NO];
        //
        [self.bkScroll addSubview:npv];
        [_allBkPicViews addObject:npv];
    }
    //cf
    CGFloat cfViewSize = 10 + 2*iw;
    self.cfView.frame = CGRectMake(self.cfView.center.x-cfViewSize/2, self.cfView.frame.origin.y, cfViewSize, self.cfView.frame.size.height);
    self.cardPicker.contentSize = CGSizeMake(2*iw, ih);
    BOOL classicFlag = [[[NSUserDefaults standardUserDefaults] objectForKey:@"classic"] boolValue];
    for (int i = 0; i < 2; i++) {
        NSString *cardname = @"";
        if (i == 0) {
            cardname = @"small-spades-1";
        }
        else
            cardname = @"big-spades-1";
        NewPicView *pic = [[NewPicView alloc] initWithFrame:CGRectMake(i*iw, 0, iw, ih) imgName:cardname custom:NO idx:i type:kPicTypeCardForground];
        if (classicFlag && i == 0)
            [pic setSelected:YES];
        else if (!classicFlag && i == 1)
            [pic setSelected:YES];
        else
            [pic setSelected:NO];
        [self.cardPicker addSubview:pic];
        [_allCfPicViews addObject:pic];
    }
    
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
  [self firstInitAutoHintTimer];
    /// delete
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[CardView class]]) {
            [view.layer removeAllAnimations];
            [view removeFromSuperview];
        }
    }
    
    /// add bottom cards
    [self addBottomCardsToSubview];
    
    /// add game card
    [self iterateGameWithBlock:^(Card *c) {
        [self addToSubViewForCard:c];
    }];
    
    /// show
    [self computeBottomCardLayout];

  self.isLayoutingCardView = YES;
  static int firstIn = 0;

  if (game.moves == 0 && firstIn > 0) {
    [self firstLayoutCardViews];
    [self playShuffleSound];
  } else {
    [self iterateGameWithBlock:^(Card *c) {
      c.faceUp = YES;
      [cards[c] setNeedsDisplay];
    }];
    self.isLayoutingCardView = NO;
    [self computeCardLayout:0 destPos:-1 destIdx:-1];
  }
  firstIn ++;
    ///
    [self updateUndoBtn];
    [self updateAutoBtn];
    self.winLabel.hidden = YES;
    self.winView.hidden = YES;
    if (_sc_width < _sc_height){
        self.btnHelpView.hidden = NO;
        self.btnLHelpView.hidden = YES;
        self.btnHHelp.hidden = YES;
    }
    else{
        self.btnHelpView.hidden = YES;
        self.btnLHelpView.hidden = NO;
        self.btnHHelp.hidden = NO;
    }
    
//    // shuffle sound
//    if (self.sound) {
//        AudioServicesPlaySystemSound(_shuffleSound);
//    }
}

- (CGRect)firstCardFrame {
  if ([self isPortrait]) {
    CGFloat adh = 70;
    return CGRectMake(_sc_width/2-_w/2, _sc_height - adh - _h, _w, _h);
  } else {
    CGFloat adh = 50;
    if (self.freecellOnTop) {
      return CGRectMake(_sc_width/2-_w/2, MARGINY + 4, _w, _h);
    } else {
      return CGRectMake(_sc_width/2-_w/2, _sc_height - adh - _h, _w, _h);
    }
  }
}


- (void)firstLayoutCardViews {
  CGFloat delay = 0;
  int count = 0;
  CardView * lastView = nil;
  for (int row = 0; row < 7; row ++) {
    BOOL leftToRight = (row%2==0);
    for (int column = (leftToRight?0:(NUM_TABLEAUS-1)); (leftToRight?(column < NUM_TABLEAUS):(column >= 0)); column += (leftToRight?1:-1)) {
      NSArray * thisColumn = [_game tableau:column];
      if (row < thisColumn.count) {
        delay += 0.04;
        count ++;

        CGRect bottom = bottomTableaux[column].frame;
        bottom.origin.y += row*_o;
        Card * ccc = thisColumn[row];
        ccc.faceUp = NO;
        CardView * cv = cards[ccc];
        cv.frame = [self firstCardFrame];
        [cv setNeedsDisplay];
        if (lastView == nil) {
          [self bringSubviewToFront:cv];
        } else {
          [self insertSubview:cv belowSubview:lastView];
        }
        lastView = cv;

        NSDictionary * dict = @{@"view":cv,
                                @"frame":[NSValue valueWithCGRect:bottom],
                                @"count":@(count),
                                @"leftToRight":@(leftToRight),
                                };

        [self performSelector:@selector(layoutFirstViewWithDict:) withObject:dict afterDelay:delay];

      }
    }
  }
}

- (void)layoutFirstViewWithDictWithDelayAnimation:(NSDictionary *)dict {
  CardView *cardView = dict[@"view"];
  CGRect frame = [dict[@"frame"] CGRectValue];
  int count = [dict[@"count"] intValue];
  BOOL leftToRight = [dict[@"leftToRight"] boolValue];
  void(^completion)(BOOL finished) = nil;

  if (count == 52) {
    completion = ^(BOOL finished) {
      [self computeCardLayout:0 destPos:-1 destIdx:-1];
      self.isLayoutingCardView = NO;
    };
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:0.15 delay:0 options:0 animations:^{
      cardView.frame = frame;
      [self bringSubviewToFront:cardView];
      [cardView filpCard:YES delay:0.12 duration:0.25 leftToRight:leftToRight];
    } completion:completion];
  });
}


- (void)layoutFirstViewWithDict:(NSDictionary *)dict {
  CardView *cardView = dict[@"view"];
  CGRect frame = [dict[@"frame"] CGRectValue];
  int count = [dict[@"count"] intValue];
  BOOL leftToRight = [dict[@"leftToRight"] boolValue];
  void(^completion)(BOOL finished) = nil;

  if (count == 52) {
    completion = ^(BOOL finished) {
      //[self computeCardLayout:0 destPos:-1 destIdx:-1];
      self.isLayoutingCardView = NO;
    };
  }
  [UIView animateWithDuration:0.15 delay:0 options:0 animations:^{
    cardView.frame = frame;
    [self bringSubviewToFront:cardView];
    [cardView filpCard:YES delay:(0.12) duration:0.25 leftToRight:leftToRight];
  } completion:completion];
}

- (void)addToSubViewForCard:(Card *)c {
    // If card is not already in our view
    if ( ![cards objectForKey:c] ) {
        CardView *cv = [[CardView alloc] 
                        initWithFrame:CGRectMake(MARGINX, MARGINY, _w, _h)
                        andCard:c];
        [cards setObject:cv forKey:c];
        [self addSubview:cv];
    }
}

- (void)addBottomCardsToSubview {
    // Create bottom card images
    for (int i = 0; i < NUM_STOCKS; i++) {
        bottomStock[i] = [[CardView alloc] initWithFrame:CGRectMake(MARGINX,MARGINY, _w, _h) specialCard:TYPE_EMPTY];
        [self addSubview:bottomStock[i]];
    }
    
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        bottomTableaux[i] = [[CardView alloc] initWithFrame:CGRectMake(MARGINX,MARGINY, _w, _h) specialCard:TYPE_EMPTY];
        [self addSubview:bottomTableaux[i]];
    }
    
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        bottomFoundations[i] = [[CardView alloc] initWithFrame:CGRectMake(MARGINX, MARGINY, _w, _h) specialCard:TYPE_FOUNDATION];
        [self addSubview:bottomFoundations[i]];
    }
    
//    bottomReserve = [[CardView alloc]
//                                    initWithFrame:CGRectMake(MARGINX, MARGINY, _w, _h)
//                                    specialCard:TYPE_RESERVE];
//    [self addSubview:bottomReserve];
}

#pragma mark Helper Functions

// Thanks Travis!
- (void)iterateGameWithBlock:(void (^)(Card *c))block { 

    for (int i = 0; i < NUM_STOCKS; i++) {
        for (Card *c in [_game stock:i]) {
            block(c);
        }
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
    if((int)[UIScreen mainScreen].nativeBounds.size.height == 2436) {
        fs = self.frame.size;
    }
    
    _sc_width = fs.width;
    _sc_height = fs.height;
    if (_sc_width < _sc_height){
        self.btnHelpView.hidden = NO;
        self.btnLHelpView.hidden = YES;
        self.btnHHelp.hidden = YES;
    }
    else{
        self.btnHelpView.hidden = YES;
        self.btnLHelpView.hidden = NO;
        self.btnHHelp.hidden = NO;
    }
    [self computeSizes:NO];
    [self computeBottomCardLayout];
    [self anamiationDone];
    [self computeRotateCardLayout:0.2 destPos:-1 destIdx:-1];
    if (self.settingsView.hidden == NO) {
        [self bringSubviewToFront:_settingsView];
    }
    if (_skinView.hidden == NO) {
        [self bringSubviewToFront:_skinView];
    }
    if(_settingsView.hidden == NO)
        [self bringSubviewToFront:_settingsView];
    if(_helpView.hidden == NO)
        [self bringSubviewToFront:_helpView];
    if (_gamestatView.hidden == NO) {
        [self bringSubviewToFront:_gamestatView];
    }
}

- (void)uiAdjust
{


}

- (void)computeSizes:(BOOL)flag {
    if (flag) {
        CGSize fs = self.frame.size;//= [UIApplication currentSize];
        UIInterfaceOrientation ori = [[UIApplication sharedApplication] statusBarOrientation];
        if(UIInterfaceOrientationIsPortrait(ori)){
            _sc_width = fs.width < fs.height?fs.width:fs.height;
            _sc_height = fs.width > fs.height?fs.width:fs.height;
        }
        else{
            _sc_width = fs.width > fs.height?fs.width:fs.height;
            _sc_height = fs.width < fs.height?fs.width:fs.height;
        }
        
    }
    GLfloat width = _sc_width;
    GLfloat height = _sc_height;

    ////
    if (![self isPortrait]) {
        if (IS_IPAD)
        {
          if (self.freecellOnTop) {
            MARGINY = 20;
            MARGINX = 120;
            _w = ((width - 2*MARGINX) / NUM_TABLEAUS) - BUFFER_WIDTH*2.8;
            _d = (width - 2*MARGINX - NUM_TABLEAUS*_w) / (NUM_TABLEAUS - 1);
            _h = _w * ASPECT_RATIO_Y;
          } else {
            MARGINX = 10;
            MARGINY = 35;
            _w = ((width - 2*MARGINX) / (NUM_TABLEAUS+2)) - BUFFER_WIDTH/4;
            _w -= BUFFER_WIDTH;
            _d = (width - 2*MARGINX - (NUM_TABLEAUS+2)*_w) / (NUM_TABLEAUS+1);
            _h = _w * ASPECT_RATIO_Y;
            MARGINLANDSCAPEY = 40;
          }
        }
        else
        {
          if (self.freecellOnTop) {
            MARGINY = 20;
            MARGINX = 80;
            _w = ((width - 2*MARGINX) / NUM_TABLEAUS) - BUFFER_WIDTH*3.6;
            _d = (width - 2*MARGINX - NUM_TABLEAUS*_w) / (NUM_TABLEAUS - 1);
            _d *= 0.75;
            _h = _w * ASPECT_RATIO_Y;
          } else {
            MARGINX = 5;
            MARGINY = 20;
              _h = ((height - MARGINY - [self adViewHeight])/NUM_STOCKS);
            _w = _h*ASPECT_RATIO_X;
            _d = (width - 2*MARGINX - (NUM_TABLEAUS+2)*_w) / (NUM_TABLEAUS+9);
            MARGINLANDSCAPEY = 10;
          }
        }
    } else {
        if (IS_IPAD) {
            MARGINY = 30;
        }
        else
        {
            MARGINY = 25;
        }
        MARGINX = 3;
        _w = ((width - 2*MARGINX) / NUM_TABLEAUS) - BUFFER_WIDTH/2;

        if (IS_IPAD)
        {
            _w -= BUFFER_WIDTH;
            _d = (width - 2*MARGINX - NUM_TABLEAUS*_w) / (NUM_TABLEAUS - 1);
        }
        else
            _d = (width - 2*MARGINX - NUM_TABLEAUS*_w) / (NUM_TABLEAUS - 1);
        _h = _w * ASPECT_RATIO_Y;
    }
    
    _s = _h/3.0;
    _f = _h/36.0;
    _o = _h/3.0;
    _dimO = _o;
    _fs = _h/6.0;
  [self resetColumnCardDistance];
#ifdef AD_POS_UP
    MARGINY += (SHOW_AD ? [self adViewHeight] : 0);
#endif
}

- (void)resetExpand
{
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        expandFlag[i] = YES;
        userExpand[i] = YES;
    }
}

- (void)updateExpand
{
    for (int i = 0; i < NUM_TABLEAUS; i++) {
#if 0
        CGFloat height = 0;
        for (Card* c in [self.game tableau:i])
        {
            if (c.faceUp == NO) {
                height += _f;
            }
            else
            {
                height += _o;
            }
        }
        height += _h;
        if ( _sc_width < _sc_height )
        {
            if (MARGINY + _h + _s + height + (SHOW_AD ? [self adViewHeight] : 0) > _sc_height)
                expandFlag[i] = NO;
            else
                expandFlag[i] = YES;
        }
        else
        {
            if (MARGINY + height + (SHOW_AD ? [self adViewHeight] : 0) > _sc_height)
                expandFlag[i] = NO;
            else
                expandFlag[i] = YES;
        }
#endif
      expandFlag[i] = YES;
        ///user
        if (userExpand[i] == NO)
            expandFlag[i] = NO;
    }
  [self updateAllTable];
  [self updateCardOffsetIfOutOfBounds];
}

- (void)computeBottomCardLayout {
    
    [UIView animateWithDuration:0.2 animations:^{
        BOOL isp = [self isPortrait];
        CardView *cv;
        for (int i = NUM_STOCKS - 1; i >= 0; i--) {
            bottomStock[i].frame = [self frameForBottomStockIndex:i isPortratit:isp];
        }

        for (int i = 0; i < NUM_TABLEAUS; i++) {
            cv = bottomTableaux[i];
            bottomTableaux[i].frame = [self frameForBottomTableauxIndex:i isPortrait:isp];
        }

        for (int i = 0; i < NUM_FOUNDATIONS; i++) {
            bottomFoundations[i].frame =[self frameForBottomFoundationIndex:i isPortrait:isp];
        }
    }];
}

- (void)computeCardLayout:(float)duation destPos:(int)pos destIdx:(int)idx{
  [self computeCardLayout:duation destPos:pos destIdx:idx rotate:NO layoutAllCard:YES];
}

static CGPoint centerForFrame(CGRect rect) {
  return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

- (void)computeCardLayout:(float)duation destPos:(int)pos destIdx:(int)idx rotate:(BOOL)rotate layoutAllCard:(BOOL) layoutAllCard{

    [UIView animateWithDuration:duation animations:^{
        //NSLog(@"%d", [[UIDevice currentDevice] orientation]);
        [self updateExpand];
        CardView *cv;
        /// port
      BOOL isp = [self isPortrait];

      {

          for (int i = NUM_STOCKS - 1; i >= 0; i--) {
              CGRect bottom = [self frameForBottomStockIndex:i isPortratit:isp];

              for (Card* c in [self.game stock:i]) {
                    cv = [cards objectForKey:c];
                    cv.frame = bottom;
                }
                if (pos == POS_STOCK && i == idx) {
                    for (int j = 0; j < HITCARDS_NUM; j++) {
                        if (!_hintViews[j].hidden) {
                          _hintViews[j].center = centerForFrame(bottom);
                            [self bringSubviewToFront:_hintViews[j]];
                        }
                    }
                }
            }
            
            for (int i = 0; i < NUM_TABLEAUS; i++) {

              NSArray* canFans = [self.game canMoveFans:i];

              Card *lastcard = nil;
                for (int j = 0; j < [[_game tableau:i] count]; j++) {
                  Card *c = [[_game tableau:i] objectAtIndex:j];
                  CGRect thisFrm = [self frameForLastCard:lastcard tableauxIndex:i isPortrait:isp];

                  cv = [cards objectForKey:c];
                  lastcard = c;
                  cv.frame = thisFrm;
                  [self bringSubviewToFront:cv];
                }
                if (pos == POS_TABEAU && i == idx) {
                  CGRect lastFrm = [self frameForLastCard:[_game tableau:i].lastObject tableauxIndex:i isPortrait:isp];
                    for (int j = 0; j < HITCARDS_NUM; j++) {
                        if (!_hintViews[j].hidden) {
                          CGRect thisFrm = lastFrm;
                          thisFrm.origin.y += j*_o;
                            _hintViews[j].center = centerForFrame(thisFrm);
                            [self bringSubviewToFront:_hintViews[j]];
                        }
                    }
                }
            }
            

          for (int i = 0; i < NUM_FOUNDATIONS; i++) {
            CGRect bottom = [self frameForBottomFoundationIndex:i isPortrait:isp];
            for (Card *c in [_game foundation:i]) {
                    cv = [cards objectForKey:c];
                    cv.frame = bottom;
                    [self bringSubviewToFront:cv];
                }
                if (pos == POS_FOUNDATION && i == idx) {
                    for (int j = 0; j < HITCARDS_NUM; j++) {
                        if (!_hintViews[j].hidden) {
                            _hintViews[j].center = centerForFrame(bottom);
                            [self bringSubviewToFront:_hintViews[j]];
                        }
                    }
                }
            }
        }
        /// land



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
    } completion:^(BOOL finished){
        if (pos != -1) {
            self.anaIdx++;
            if (self.anaIdx < self.anaCnt) {
                [self anamiationDone];
            }
            else
                [self stopHintAnamiation];

        }
        else if (!rotate)
        {
            [self updateAutoBtn];
            [self setUserInteractionEnabled:YES];
            if ([self.game alreadyDone]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"autoCompleteDone" object:@"done"];
            } else {

            }
        }
    }];
}

- (void)computeRotateCardLayout:(float)duation destPos:(int)pos destIdx:(int)idx {
  [self computeCardLayout:duation destPos:pos destIdx:idx rotate:YES layoutAllCard:NO];
}

- (void)updateAutoBtn
{
  [self.opDelegate toggleAutoCompleteEnable:[self.game gameWon]];
  return;
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
  [self.opDelegate toggleUndoEnable:[self.game canUndo]];
  return;
    ///
    if ([self.game canUndo]) {
        //self.btnUndo.hidden = NO;
        self.btnUndo.enabled = YES;
        self.btnUndo.alpha = 1;
    }
    else
    {
        //self.btnUndo.hidden = YES;
        self.btnUndo.enabled = NO;
        self.btnUndo.alpha = 0.5;
    }
    
    if ([self.game alreadyDone]) {
        self.btnUndo.enabled = NO;
        self.btnUndo.alpha = 0.5;
    }

}

#pragma mark Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView {
  [self resetAutohintTimer];
    if (self.game.won) {
        return;
    }
    _hintend = YES;
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
    CGPoint newCenter = CGPointMake(startCenter.x + delta.x, startCenter.y + delta.y); //reflash the start point
    
    NSArray *fan = [_game fanBeginningWithCard:[cardView card]];
    // Card is on the waste
    if (fan != nil) {    // Card is in a fan
        for (int i = 0; i < [fan count]; i++) {
            CardView *cv = [cards objectForKey:[fan objectAtIndex:i]];
            cv.center = CGPointMake(newCenter.x, newCenter.y + (i * _o));
            [self bringSubviewToFront:cv];
        }
    }
    
    
    float distance = delta.x*delta.x+delta.y*delta.y;
    if(!moveFlag && distance > 10)
        moveFlag = YES;
    //NSLog(@"%f",distance);
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView {
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView  {
    if (self.game.won) {
        return;
    }
    //    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (((UITouch*)[touches anyObject]).tapCount == 1 && moveFlag == NO) {
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
              [self playClickSound];


                self.game.moves++;
                [self updateUndoBtn];
                [self computeCardLayout:0.2 destPos:-1 destIdx:-1];
                return;
            }
            else
            {

              CALayer *viewlayer = cardView.layer;
              CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
              [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
              animation.toValue = @(M_PI/18);
              animation.fromValue = @(-M_PI/18);
              [animation setAutoreverses:YES];
              [animation setDuration:0.05];
              [animation setRepeatCount:1];
              [viewlayer addAnimation:animation forKey:nil];
              [self playErrorSound];
            }
        }
    }
    
    if ([self.game inFoundation:cardView.card] >= 0) {
        return;
    }
    
    ///expand
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([[self.game tableau:i] containsObject:[cardView card]]) {
            int faceCnt = 0;
            int succCnt = 0;
            for (int j = 0; j < [[self.game tableau:i] count]; j++) {
                if (((Card*)[[self.game tableau:i] objectAtIndex:j]).faceUp == YES) {
                    faceCnt++;
                }
            }
            NSArray* lastFans = [self.game canMoveFans:i];
            if (lastFans != nil) {
                succCnt = [lastFans count];
            }
            if (lastFans != nil && [lastFans containsObject:[cardView card]]) {
                ;
            }
            else
            {
                if (faceCnt != succCnt) {
                    userExpand[i] = !userExpand[i];
                    break;
                }
            }
        }
    }
    
    Card *c = [cardView card];
    BOOL clickSoundFlag = NO;
    NSMutableArray* moveActions = [[NSMutableArray alloc] init];
    
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
                        self.game.moves++;
                        [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:pos to:POS_FOUNDATION cardcnt:[fan count] fromIdx:idx toIdx:i]];
                        if (pos != POS_FOUNDATION) {
                            self.game.scores += 10;
                        }
                        break;
                    }
                }
            }
            if (didFlag == NO) {
                for (int i = 0; i < NUM_STOCKS; i++) { // Iterate through stocks
                    CardView *cvFound = bottomStock[i];
                    if ( CGRectIntersectsRect(cvFound.frame, fanRect) ) {// See if foundation intersects with card
                        didFlag = [_delegate movedCard:[cardView card] toStock:i]; // Move card
                        /// need break
                        if (didFlag) {
                            [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:pos to:POS_STOCK cardcnt:[fan count] fromIdx:idx toIdx:i]];
                            self.game.moves++;      //------------
                            break;
                        }
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
                        self.game.moves++;      //------------
                        break;
                    }
                }
            }
        }
    }
    /// land
    else
    {
        if ([fan count] == 1 && cardView.center.x < MARGINX + _w + _w/2) { // Check Foundation
            for (int i = 0; i < NUM_FOUNDATIONS; i++) { // Iterate through foundations
                CardView *cvFound = bottomFoundations[i];
                if ( CGRectIntersectsRect(cvFound.frame, fanRect) ) {// See if foundation intersects with card
                    didFlag = [_delegate movedCard:[cardView card] toFoundation:i]; // Move card
                    if (didFlag) {
                        self.game.moves++;
                        [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:pos to:POS_FOUNDATION cardcnt:[fan count] fromIdx:idx toIdx:i]];
                        if (pos != POS_FOUNDATION) {
                            self.game.scores += 10;
                        }
                        break;
                    }
                }
            }
        }
        else if ([fan count] == 1 && cardView.center.x > (_sc_width - MARGINX - _w - _w/2))
        {
            for (int i = 0; i < NUM_STOCKS; i++) { // Iterate through stocks
                CardView *cvFound = bottomStock[i];
                if ( CGRectIntersectsRect(cvFound.frame, fanRect) ) {// See if foundation intersects with card
                    didFlag = [_delegate movedCard:[cardView card] toStock:i]; // Move card
                    if (didFlag) {
                        [moveActions addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:pos to:POS_STOCK cardcnt:[fan count] fromIdx:idx toIdx:i]];
                        self.game.moves++;      //------------
                        break;
                    }
                }
            }
        }
        else { // May intersect with tableau
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
                        self.game.moves++;      //------------
                        break;
                    }
                }
            }
        }
    }
    
    if (clickSoundFlag) {

      [self playClickSound];
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

- (void)displayHint:(NSArray<Card *>*)fan toPos:(int)pos toIdx:(int)idx seq:(int)seq total:(int)total
{
    NSString* hintInfo = [NSString stringWithFormat:@"%@ %d / %d",NSLocalizedStringFromTable(@"hintmove", @"Language", nil),seq,total];
    self.hintLabel.alpha = 1;
    self.hintLabel.text = hintInfo;
    [UIView animateWithDuration:0.1 delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        self.hintLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
      if (fan.count == 1 && fan.firstObject.rank == -1 && fan.firstObject.suit == -1 && pos == POS_STOCK) {
        for (int kk = 0; kk < NUM_STOCKS; kk++) {
          if ([_game stock:kk].count > 0) {
            continue;
          }
          Card* copyOne = [[Card alloc] initWithRank:-1 Suit:-1];
          copyOne.glow = YES;
          copyOne.faceUp = YES;
          CardView *glowOne = _hintViews[kk];
          CGRect reee =  bottomStock[kk].frame;
          reee = CGRectInset(reee, -[CardView hintWidth], -[CardView hintWidth]);
          reee.origin.y -= 0.2;
          glowOne.frame = reee;
          [glowOne setNewCard:copyOne];
          glowOne.hidden = NO;
          glowOne.center = centerForFrame(reee);
          [self addSubview:glowOne];
          [glowOne setNeedsDisplay];

        }
        [self performSelector:@selector(stopHintAnamiation) withObject:nil afterDelay:MOVE_TIME];


      } else {
        for (int i = 0; i < [fan count]; i++) {
          Card* card = fan[i];
          Card* copyOne = [[Card alloc] initWithRank:card.rank Suit:card.suit];
          copyOne.glow = YES;
          copyOne.faceUp = YES;
          CardView *glowOne = _hintViews[i];
          if (card.rank != -1) {
            glowOne.frame = CGRectMake(0, 0, _w+2*[CardView hintWidth], _h+2*[CardView hintWidth]);
          } else if (pos == POS_STOCK){
            CGRect reee =  bottomStock[idx].frame;
            reee = CGRectInset(reee, -[CardView hintWidth], -[CardView hintWidth]);
            reee.origin.y -= 0.2;
            glowOne.frame = reee;
          }
          [glowOne setNewCard:copyOne];
          glowOne.hidden = NO;
          if (cards[card]) {
            glowOne.center = cards[card].center;
          }
          [self addSubview:glowOne];
          [glowOne setNeedsDisplay];
          [self computeCardLayout:MOVE_TIME destPos:pos destIdx:idx];

        }
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
  [UIView animateWithDuration:HINTINFO_TIME
                   animations:^{
                     self.hintLabel.alpha = 0.0;
                   }];
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

- (void)updateBgSelected:(int)idx
{
    for (NewPicView* npv in _allBgPicViews) {
        if (npv.theid == idx){
            //npv.shadowView.hidden = NO;
            [npv setSelected:YES];
        }
        else{
            //npv.shadowView.hidden = YES;
            [npv setSelected:NO];
        }
    }
}

- (void)updateBkSelected:(int)idx
{
    for (NewPicView* npv in _allBkPicViews) {
        if (npv.theid == idx)
            [npv setSelected:YES];
        else
            [npv setSelected:NO];
    }
}

- (void)updateCfSelected:(int)idx
{
    for (NewPicView* npv in _allCfPicViews) {
        if (npv.theid == idx) {
            [npv setSelected:YES];
        }
        else
            [npv setSelected:NO];
    }
}

- (void)hideShadow:(int)scrollIdx picIdx:(int)picIdx ishide:(BOOL)hide{
    switch (scrollIdx) {
        case 0:
            for (NewPicView *npc in _allBgPicViews) {
                if(npc.theid == picIdx){
                    npc.shadowView.hidden = hide;
                }
            }
            //[[(NewPicView *)[self.bgScroll.subviews objectAtIndex:picIdx] shadowView] setHidden:hide];
            break;
        case 1:
            for (NewPicView *npc in _allBkPicViews) {
                if(npc.theid == picIdx){
                    npc.shadowView.hidden = hide;
                }
            }
            //[[(NewPicView *)[allBkPicViews objectAtIndex:picIdx] shadowView] setHidden:hide];
            break;
        case 2:
            for (NewPicView *npc in _allCfPicViews) {
                if(npc.theid == picIdx){
                    npc.shadowView.hidden = hide;
                }
            }
            //[[(NewPicView *)[allCfPicViews objectAtIndex:picIdx] shadowView] setHidden:hide];
            break;
        default:
            break;
    }
}


- (void)playClickSound {
  if (self.sound) {
    [SoundEffect playSoundEffect:@"click.mp3" alert:YES];
  }
}

- (void)playQuickClickSound {
  if (self.sound) {

    [SoundEffect playSoundEffect:@"click_quick.wav" alert:YES];
  }
}

- (void)playShuffleSound {
  if (self.sound) {
    [SoundEffect playSoundEffect:@"shuffle.wav" alert:YES];
  }
}

- (void)playErrorSound {
  if (self.sound) {
    [SoundEffect playSoundEffect:@"error.wav" alert:YES];
  }
}

- (BOOL)isPortrait {
  return _sc_width < _sc_height;
}

- (void)resetAutohintTimer {
  [_autohintAdTimer invalidate];
  _autohintAdTimer = nil;
  _autohintAdTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(autohintpls:) userInfo:nil repeats:NO];
}

- (void)autohintpls:(NSTimer *)timer {
  NSLog(@"autohinttimer");
  [self.opDelegate showTheHint];
}


- (void)firstInitAutoHintTimer {
  dispatch_async(dispatch_get_main_queue(), ^{
    [_autohintAdTimer invalidate];
    _autohintAdTimer = nil;
    _autohintAdTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(autohintpls:) userInfo:nil repeats:NO];
  });
}


#pragma mark - frame

- (CGRect)frameForLastCard:(Card *)lastCard tableauxIndex:(NSInteger)index isPortrait:(BOOL)portrait
{
  return [self frameForLastCard:lastCard tableauxIndex:index isPortrait:portrait referenceFrame:CGRectZero];
}

- (CGRect)frameForLastCard:(Card *)lastCard tableauxIndex:(NSInteger)index isPortrait:(BOOL)portrait referenceFrame:(CGRect)referenceFrame
{

  CGRect refRect = CGRectZero;
  if (lastCard) {
    refRect = cards[lastCard].frame;
  } else {
    refRect = [self frameForBottomTableauxIndex:index isPortrait:portrait];
  }

  if (!CGRectIsEmpty(referenceFrame)) {
    refRect = referenceFrame;
  }

  BOOL isCompact = (expandFlag[index] == NO);

  if (lastCard) {
    switch (lastCard.status) {
      case CardStatusDim: {
        CGFloat delta = isCompact?(_fsColumn[index]):(_oColumn[index]);
        refRect.origin.y += delta;
      }
        break;

      case CardStatusMovable: {
        refRect.origin.y += _oColumn[index];
      }
        break;

      default:
        break;
    }
  }
  return refRect;
}





- (BOOL)foundationOnRHS {
  return !self.stockOnRight;
}

- (BOOL)stockOnRHS {
  return self.stockOnRight;
}

- (CGRect)frameForBottomStockIndex:(NSInteger)index isPortratit:(BOOL)portrait {
  if ([self stockOnRHS]) {
    return portrait?[self frameForBottomRightPileInPortrait:index]:[self frameForBottomRightPileInLandscape:index];
  } else {
    return portrait?[self frameForBottomLeftPileInPortrait:index]:[self frameForBottomLeftPileInLandscape:index];
  }
}


- (CGRect)frameForBottomFoundationIndex:(NSInteger)index isPortrait:(BOOL)portrait {
  if ([self foundationOnRHS]) {
    return portrait?[self frameForBottomRightPileInPortrait:index]:[self frameForBottomRightPileInLandscape:index];
  } else {
    return portrait?[self frameForBottomLeftPileInPortrait:index]:[self frameForBottomLeftPileInLandscape:index];
  }
}

- (CGRect)frameForBottomTableauxIndex:(NSInteger)index isPortrait:(BOOL)portrait {
  return portrait?[self frameForBottomTableauxInPortrait:index]:[self frameForBottomTableauxInLandscape:index];
}





#pragma mark - port start

#define marg_top (BUFFER_WIDTH*0.75)

- (CGRect)frameForBottomRightPileInPortrait:(NSInteger)index {
  CGFloat stockY = MARGINY;
  CGFloat stockX = _sc_width - ((NUM_STOCKS - 1 - index)*_d/1.5) - ((NUM_STOCKS - 1 - index)*_w) - _w-marg_top;
  CGRect rect = CGRectMake(stockX, stockY, _w, _h);
  return rect;
}

- (CGRect)frameForBottomLeftPileInPortrait:(NSInteger)index {
  NSInteger i = index;
  CGFloat foundationY = MARGINY;
  CGFloat foundationX = (i*_d/1.5) + (i*_w)+marg_top;
  CGRect rect = CGRectMake(foundationX, foundationY, _w, _h);
  return rect;
}

- (CGRect)frameForBottomTableauxInPortrait:(NSInteger)index {
  NSInteger i = index;
  CGFloat tableauX = MARGINX + (i*_w) + (i*_d);
  CGFloat tableauY = MARGINY + _h + _s;
  CGRect rect = CGRectMake(tableauX, tableauY, _w, _h);
  return rect;
}



#pragma mark port end -


#pragma mark - land start

#define dis_x_land 2
- (CGRect)frameForBottomRightPileInLandscape:(NSInteger)index {
  NSInteger i = index;
  if (self.freecellOnTop) {
    CGFloat stockY = MARGINY;
    CGFloat stockX = _sc_width - ((NUM_STOCKS - 1 - i)*dis_x_land) - ((NUM_STOCKS - 1 - i)*_w) - _w-MARGINX;
    CGRect rect = CGRectMake(stockX, stockY, _w, _h);
    return rect;
  } else {
    CGFloat stockX = _sc_width - _w - MARGINX;
    CGFloat stockY = i*_h + i*_f + MARGINLANDSCAPEY;
    CGRect rect = CGRectMake(stockX, stockY, _w, _h);
    return rect;
  }
}

- (CGRect)frameForBottomLeftPileInLandscape:(NSInteger)index {
  NSInteger i = index;
  if (self.freecellOnTop) {
    CGFloat foundationY = MARGINY;
    CGFloat foundationX = (i*dis_x_land) + (i*_w)+MARGINX;
    CGRect rect = CGRectMake(foundationX, foundationY, _w, _h);
    return rect;
  } else {
    CGFloat foundationX = MARGINX;
    CGFloat foundationY = i*_h + i*_f + MARGINLANDSCAPEY;
    CGRect rect = CGRectMake(foundationX, foundationY, _w, _h);
    return rect;
  }
}



- (CGRect)frameForBottomTableauxInLandscape:(NSInteger)index {
  NSInteger i = index;
  CGFloat half = (NUM_TABLEAUS)/2.0;
  if (self.freecellOnTop) {
    CGFloat tableauX = (_sc_width/2-(half*(_w+_d)-0.5*_d)) + (i*_w) + (i*_d);
    CGFloat tableauY = MARGINY + _h + BUFFER_WIDTH * 2;
    CGRect rect = CGRectMake(tableauX, tableauY, _w, _h);
    return rect;
  } else {
    CGFloat tableauX = (_sc_width/2-(half*(_w+_d)-0.5*_d)) + (i*_w) + (i*_d);
    CGFloat tableauY = MARGINY;
    CGRect rect = CGRectMake(tableauX, tableauY, _w, _h);
    return rect;
  }
}


- (void)updateAllTable {
  for (int i = 0; i < NUM_TABLEAUS; i++) {
    NSArray <Card *>* thisColumn = [_game tableau:i];

    NSArray * dims = [_game cannotMoveOnIndex:i];
    for (Card * c in thisColumn) {
      if ([dims containsObject:c]) {
        c.status = CardStatusDim;
      } else {
        c.status = CardStatusMovable;
      }
    }
    thisColumn.lastObject.status = CardStatusMovable;
  }
}



- (NSArray *)allCardViews {
  NSMutableArray * array = [NSMutableArray array];
  for (NSInteger i = 0; i < NUM_FOUNDATIONS; i++) {
    NSArray * sub = [_game foundation:(int)i];
    for (Card * card in sub) {
      CardView * view = cards[card];
      if (view) {
        [array addObject:view];
      }
    }
  }
  return array;
}


- (CGSize)cardViewSize {
  return CGSizeMake(_w, _h);
}

- (CGSize)screenSize {
  return CGSizeMake(_sc_width, _sc_height);
}

- (NSMutableArray *)emitters {
  static NSMutableArray * emitters = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    emitters = [@[@1,@1,@1,@1] mutableCopy];
  });
  return emitters;
}


- (void)cardwillmovetof:(NSNotification *)notice {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSInteger i = [notice.userInfo[@"toIdx"] integerValue];
    [self addEffectTo:i];
  });
}


- (void)addEffectTo:(NSInteger)idx {
  if (idx >= NUM_FOUNDATIONS) {
    return;
  }
  UIView * view = bottomFoundations[idx];

  Card * card = [_game foundation:idx].firstObject;
  if (!card) {
    return;
  }

  CAEmitterLayer *emitter = [self emitters][idx];

  if (![emitter isKindOfClass:[CAEmitterLayer class]]) {
    emitter = [CAEmitterLayer layer];
    [self emitters][idx] = emitter;
  }

  CGRect frm = [self convertRect:view.frame toView:self.superview];
  emitter.frame = self.superview.bounds;

  [self.superview.layer addSublayer:emitter];

  CGPoint position = CGPointMake(CGRectGetMidX(frm), CGRectGetMidY(frm));
  // configure emitter
  emitter.renderMode = kCAEmitterLayerAdditive;
  emitter.emitterPosition = position;
  emitter.birthRate = 1;

  NSDictionary * imageNames = @{
                                @(SPADES):@"heitao_40",
                                @(HEARTS):@"aixin_40",
                                @(DIAMONDS):@"fang_40",
                                @(CLUBS):@"meihua_40",
                                };

  // create a particle template
  CAEmitterCell *cell = [[CAEmitterCell alloc] init];
  cell.contents = (__bridge id)[UIImage imageNamed:imageNames[@(card.suit)]].CGImage;


  cell.birthRate = 4.f;
  cell.lifetime = 1.f;
  cell.alphaSpeed = -0.1f;
  cell.velocity = 50.f;
  cell.velocityRange = 20.f;
  cell.emissionRange = 2*M_PI;
  cell.scale = 0.5;

  // add particle template to emitter
  emitter.emitterCells = @[cell];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    emitter.birthRate = 0;
  });
}


- (CGPoint)statusLeading {

  return [self statusLeadingPortrait:[self isPortrait]];
}

- (CGPoint)statusLeadingPortrait:(BOOL)port {
  CGPoint point = CGPointZero;
  if (port) {
    point.x = [self frameForBottomLeftPileInPortrait:0].origin.x;
    point.y = _sc_width-CGRectGetMaxX([self frameForBottomRightPileInPortrait:NUM_STOCKS-1]);
  } else {
    CGFloat ra = 0.2;
    point.x = _sc_width*ra;
    point.y = _sc_width*ra;
  }
  return point;
}



- (void)setFreecellOnTop:(BOOL)freecellOnTop {
  _freecellOnTop = freecellOnTop;
  [self computeSizes:NO];
}

- (CGFloat)safeBottomGuideline {
  if (![self isPortrait]) {
    return 30;
    if (self.freecellOnTop) {
    } else {
      return kAdHeight+2;
    }
  } else {
    return self.safeBottomHeight;
  }
}

- (void)updateCardOffsetIfOutOfBounds {
  BOOL isp = [self isPortrait];
  [self computeSizes:NO];
  if (isp && !IS_IPAD) {
    return;
  }

  for (NSInteger i = 0; i < NUM_TABLEAUS; i++) {
    CGFloat lastDimO = _o;
    CGFloat lastO = _o;
    CGFloat minDimO = _f;
    NSArray * thisColumn = [[_game tableau:(int)i] copy];
    if (thisColumn.count == 0) {
      //      @throw [NSException exceptionWithName:@"table empty" reason:@"table empty" userInfo:nil];
      continue;
    }
    NSMutableArray * facedown = [[thisColumn filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status == %d", CardStatusFacedown]] mutableCopy];
    [facedown removeObject:thisColumn.lastObject];
    NSArray * dims = [thisColumn filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status == %d", CardStatusDim]];
    NSMutableArray * movables = [[thisColumn filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status == %d", CardStatusMovable]] mutableCopy];
    if (![movables containsObject:thisColumn.lastObject]) {
      [movables addObject:thisColumn.lastObject];
    }

    if (dims.count + movables.count > 6) {
      CGRect lowRect0 = [self frameForBottomTableauxIndex:i isPortrait:isp];
      lowRect0.origin.y += facedown.count * _f;
      CGRect lowRect = lowRect0;
      CGFloat distanceDim = lastDimO*dims.count;
      CGFloat distanceMovable = lastO * (movables.count-1);
      lowRect.origin.y += distanceDim+distanceMovable;

      CGFloat maxOy = _sc_height - [self safeBottomGuideline] - _h;
      if (lowRect.origin.y > maxOy)
#if 1
      {
        CGFloat aa = lastO - (lowRect.origin.y - maxOy)/(movables.count+dims.count-1);
        lastO = aa;
        _oColumn[i] = lastO;
        _fsColumn[i] = lastO*0.6;
      }
#else
//      {
//        if (lowRect.origin.y - MAX(distanceDim, distanceMovable) < maxOy) {
//          if (distanceDim >= distanceMovable) {
//            CGFloat tempDimO1 = lastDimO - (lowRect.origin.y - maxOy)/dims.count;
//            lastDimO = tempDimO1;
//            _dimOColumn[i] = lastDimO;
//            _fsColumn[i] = lastDimO*0.6;
//          } else {
//            if (movables.count > 1) {
//              CGFloat tempDimO = lastDimO - (lowRect.origin.y - maxOy)/dims.count;
//              if (tempDimO > minDimO) {
//                lastDimO = tempDimO;
//                _dimOColumn[i] = lastDimO;
//                _fsColumn[i] = lastDimO*0.6;
//              } else {
//                tempDimO = minDimO;
//                _dimOColumn[i] = tempDimO;
//                _fsColumn[i] = tempDimO*0.6;
//                CGFloat delta = lastDimO - tempDimO;
//                lowRect.origin.y -= delta*dims.count;
//                CGFloat aa = lastO - (lowRect.origin.y - maxOy)/(movables.count-1);
//                lastO = aa;
//                _oColumn[i] = lastO;
//              }
//            }
//          }
//        } else {
//          CGFloat tempDimO = minDimO;
//          _dimOColumn[i] = tempDimO;
//          _fsColumn[i] = tempDimO*0.6;
//          CGFloat delta = lastDimO - tempDimO;
//          lowRect.origin.y -= delta*dims.count;
//          if (lowRect.origin.y > maxOy) {
//            CGFloat tempO = lastO - (lowRect.origin.y - maxOy)/(movables.count-1);
//            lastO = MIN(lastO, tempO);
//            _oColumn[i] = lastO;
//          }
//        }
//      }
#endif
    }
  }
}

- (void)resetColumnCardDistance {
  for (int i = 0; i < NUM_TABLEAUS; i++) {
    _fColumn[i] = _f;
    _fsColumn[i] = _fs;
    _dimOColumn[i] = _dimO;
    _oColumn[i] = _o;
  }
}

- (CGFloat)adViewHeight {
    BOOL isp = [self isPortrait];
    return isp?kAdHeight:CGSizeFromGADAdSize(kGADAdSizeSmartBannerLandscape).height;
}

@end
