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
#import "UIApplication+Size.h"
#import "Config.h"
#import "Toast+UIView.h"
#import "TheSound.h"
#import "PicView.h"
#import "Admob.h"

@implementation SolitaireView {
    NSMutableDictionary *cards;
    __weak IBOutlet NSLayoutConstraint *rightOPbarleading;
    __weak IBOutlet UIView *BackView;
    UIImageView* explodeView1;
    UIImageView* explodeView2;
    CardView* matchCard1;
    CardView* matchCard2;
    Card* cd1;
    Card* cd2;
    
    CGFloat _w;
    CGFloat _h;
    CGFloat _ow;
    CGFloat _oh;
    
    Card *touchedCard;
    
    CGFloat MARGINY;
    CGFloat MARGINX;
    
    //
    BOOL startFlag;
    BOOL initHelpFlag;
    
    //
    NSMutableArray* winCards;
    NSMutableArray* youWinLayout;
    //
    NSArray* matchImages;
    
    BOOL hideOp;
    BOOL Liuhai;
    int pianyix;
}

@synthesize game = _game;

@synthesize hinting;
@synthesize topCards;
@synthesize hideOp;
@synthesize hideSettings;
@synthesize sound = _sound;
@synthesize allBackgroundViews;
@synthesize allTilesetViews;
@synthesize overflag;
@synthesize nextlock;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)updateCardBack
{
    for (Card* c in cards) {
        CardView* cv = [cards objectForKey:c];
        [cv updateTheme:c];
        [cv setNeedsDisplay];
    }
    for (CardView* cv in winCards)
    {
        [cv updateTheme:cv.card];
        [cv setNeedsDisplay];
    }
}

- (void)updateAfterShuffle
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self.delegate respondsToSelector:@selector(tapOnDesktop)]) {
        [self.delegate tapOnDesktop];
    }
}

- (void)initHelp
{
    if (initHelpFlag)
        return;
    //
    CGFloat helpheight = self.helpScrollView.frame.size.height*0.95;
    CGFloat helpwidth = helpheight*0.8;
    CGFloat helpspace = helpwidth*0.1;
    for (int i = 0; i < 6; i++)
    {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(i*(helpwidth+helpspace)+helpspace/2, (self.helpScrollView.frame.size.height-helpheight)/2, helpwidth, helpheight)];
        iv.image = [UIImage imageNamed:[NSString stringWithFormat:@"help%d.jpg",i]];
        // zzx
//        [self.helpScrollView addSubview:iv];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.helpScrollView addSubview:iv];
        });
    }
    [self.helpScrollView setContentSize:CGSizeMake(6*(helpwidth+helpspace), self.helpScrollView.frame.size.height)];
    self.helpView.hidden = YES;
    //
    initHelpFlag = YES;
    
//    SolitaireView *solitaireView = (__bridge SolitaireView *)(void *)0x11257590;
//    NSLog(@"%@", NSStringFromClass([solitaireView class]));
}

- (void)awakeFromNib {
     self.hinting = NO;
    MARGINY = 0;
    MARGINX = 0;
    self.topCards = nil;
    touchedCard = nil;
    /// tap to hide/display opbar
    self.hideOp = NO;
    self.hideSettings = NO;
    //
    matchImages = [NSArray arrayWithObjects:
     [UIImage imageNamed:@"explode_0"],
     [UIImage imageNamed:@"explode_1"],
     [UIImage imageNamed:@"explode_2"],
     [UIImage imageNamed:@"explode_3"],
     [UIImage imageNamed:@"explode_4"],
     [UIImage imageNamed:@"explode_5"],
     [UIImage imageNamed:@"explode_6"],
     [UIImage imageNamed:@"explode_7"],
     [UIImage imageNamed:@"explode_8"],
     [UIImage imageNamed:@"explode_9"],
     [UIImage imageNamed:@"explode_10"],
     [UIImage imageNamed:@"explode_11"],
     [UIImage imageNamed:@"explode_12"],
     [UIImage imageNamed:@"explode_13"],
     [UIImage imageNamed:@"explode_14"],
     nil];
    //
    [self computeSizes:YES];
    //
    self.allBackgroundViews = [[NSMutableArray alloc] init];
    self.allTilesetViews = [[NSMutableArray alloc] init];
    ///
    self.pauseView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.timeLabel.font = [UIFont fontWithName:@"DS-Digital-Bold" size:20];
    }
    else
        self.timeLabel.font = [UIFont fontWithName:@"DS-Digital-Bold" size:11];
    //
    self.pauseView.hidden = YES;
    self.overView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    self.overView.hidden = YES;
    //
    //[self initHelp];
    self.helpView.hidden = YES;
    //
    cd1 = [[Card alloc] init];
    cd2 = [[Card alloc] init];
    matchCard1 = [[CardView alloc] initWithFrame:CGRectMake(0, 0, _w, _h) andCard:cd1];
    matchCard1.flyflag = YES;
    matchCard2 = [[CardView alloc] initWithFrame:CGRectMake(0, 0, _w, _h) andCard:cd2];
    matchCard2.flyflag = YES;
    //
    youWinLayout = [[NSMutableArray alloc] init];
    [youWinLayout addObject:@"9"];
    [youWinLayout addObject:@"16"];
    [youWinLayout addObject:@"36"];
    for (int i = 0; i < 5; i++)
    {
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"100000001000000010000100000100000001"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"010000010100000100000100000101000001"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"001000100010001000000100000100010001"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000101000001010000000100000100000101"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000010000000100000000100000100000001"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
    }
    for (int i = 0; i < 4; i++)
    {
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
        [youWinLayout addObject:@"000000000000000000000000000000000000"];
    }
    //
    winCards = [[NSMutableArray alloc] init];
    int layer = [[youWinLayout objectAtIndex:0] integerValue];
    int row = [[youWinLayout objectAtIndex:1] integerValue];
    int col = [[youWinLayout objectAtIndex:2] integerValue];
    int cnt = 0;
    for (int i = 0; i < layer; i++)
    {
        for (int j = 0; j < row; j++)
        {
            NSString* line = [youWinLayout objectAtIndex:3 + i * row + j];
            for (int k = 0; k < col; k++)
            {
                if ([line characterAtIndex:k] == '1')
                {
                    Card *cd = [[Card alloc] initWithSeq:31 layer:i row:j col:k state:CARD_STATE_SHOW no:cnt];
                    CardView* cv = [[CardView alloc] initWithFrame:CGRectMake(self.boardView.frame.size.width/2, self.boardView.frame.size.height/2, _w, _h) andCard:cd];
                    cv.flyflag = YES;
                    [winCards addObject:cv];
                    cnt++;
                }
            }
        }
    }
    
    [self.admobView setAlpha:0];
}

- (void)firstInCompute
{
    ///
    [self computeSizes:YES];
}

#pragma mark Initialization

- (void)setGame:(Solitaire *)game {
    //
     Liuhai=NO;
    if ([self isNotchScreen]) {
        Liuhai=YES;
    }
    startFlag = NO;
    initHelpFlag = NO;
    self.overflag = NO;
    
    ///
    _game = game;
    [self firstInCompute];
    cards = [[NSMutableDictionary alloc] init];
    
    /// delete
    for (UIView *view in [self.boardView subviews]) {
        if ([view isKindOfClass:[CardView class]]) {
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
    [self computeCardLayout:0.4 destPos:-1 destIdx:-1];
    
    ///
    [self updateUndoBtn];
    touchedCard = nil;
    ///
    self.timeLabel.text = [NSString stringWithFormat:@"Time : %d:%02d",_game.times/60,_game.times%60];
    //
    if (_game.won || _game.lose)
    {
        for (CardView* cv in winCards) {
            [self.boardView addSubview:cv];
            Card* c = cv.card;
            cv.center = CGPointMake(MARGINX + c.col*(_w-_ow)/2+_w/2-c.layer*_ow, MARGINY + c.row*(_h-_oh)/2+_h/2-c.layer*_oh);
            [cv updateTheme:c];
            [cv setNeedsDisplay];
        }
    }
    else
    {
        for (CardView* cv in winCards) {
            [cv removeFromSuperview];
        }
    }
    //
    if (self.game.layoutid + 1 < [self.game.layoutlocks count]
        && [[self.game.layoutlocks objectAtIndex:self.game.layoutid+1] boolValue]) {
        self.nextlock = YES;
    }
    else
        self.nextlock = NO;
    //
    /// shuffle sound
    [TheSound playShuffleSound];
    //
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hidehud" object:nil];
    NSLog(@"zzx 2222222");
}

- (void)addToSubViewForCard:(Card *)c {
    // If card is not already in our view
    if (![cards objectForKey:c] ) {
        CardView *cv = [[CardView alloc] 
                        initWithFrame:CGRectMake(self.boardView.frame.size.width/2, self.boardView.frame.size.height/2, _w, _h)
                        andCard:c];
        [cards setObject:cv forKey:c];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.boardView addSubview:cv];
            
        });
//        [self.boardView addSubview:cv];
        
        
    }
}

- (void)addBottomCardsToSubview {
    explodeView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _w*3, _h*3)];
    explodeView2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _w*3, _h*3)];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.boardView addSubview:explodeView1];
        [self.boardView addSubview:explodeView2];
    });
    
//    [self.boardView addSubview:explodeView1];
//    [self.boardView addSubview:explodeView2];
    explodeView1.hidden = YES;
    explodeView2.hidden = YES;
    NSLog(@"explodeView1 wiht=%lf height=%lf ",explodeView1.frame.size.width,explodeView1.frame.size.height);
}

- (void)hint:(NSArray*)hints
{
    if (hints == nil) {
        [self makeToast:@"No matched pairs, tap 'Shuffle' to shuffle the board" duration:0.4 position:@"center"];
    }
    else
    {
        for (Card *c in hints) {
            CardView* cv = [cards objectForKey:c];
            [cv bounce];
        }
    }
}

- (void)clearSelectedState
{
    if (touchedCard != nil) {
        touchedCard.state = CARD_STATE_SHOW;
        touchedCard = nil;
    }
}

- (Card*)selectedCard
{
    return touchedCard;
}

#pragma mark Helper Functions

// Thanks Travis!
- (void)iterateGameWithBlock:(void (^)(Card *c))block {
    for (Card *c in [_game mahjongs])
    {
        block(c);
    }
}

#pragma mark Layout Functions

- (void)computeSizes:(BOOL)flag {
    
    // 逻辑为仅当为非刘海屏的时候改变一下他的高度其余的没什么
    GLfloat width = self.boardView.frame.size.width;
    GLfloat height = self.boardView.frame.size.height;
    CGFloat xShadowRate = 14.0/140;
    CGFloat yShadowRate = 12.0/172;
    int x111=0;
    if (Liuhai) {
        pianyix=7;
    }else{
        pianyix=0;
    }
    if ( ![self isNotchScreen] && ( _game.layoutid==85 || _game.layoutid==138 ) ) {
        x111=5;
        NSLog(@"x11111");
    }
    float pianyiy=pianyix-0.5;
    ////
    if ( width > height ) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            MARGINX = 0;
            MARGINY = 0;
            _w = (width/((MAX_COL+2)*(1-xShadowRate)/2));
            _h = _w*ASPECT_RATIO_Y;
        }
        else
        {
            MARGINX = 0;
            MARGINY = 0;
            _h = (height/((MAX_ROW+2)*(1-yShadowRate)/2))- pianyix-x111;
            _w = _h*ASPECT_RATIO_X;
        }
    } else {
        ;
    }

    _ow = _w*xShadowRate;
    _oh = _h*yShadowRate;
    MARGINX = (width-MAX_COL*(_w-_ow)/2)/2;
    MARGINY = (height - MAX_ROW*(_h-_oh)/2)/2;
}

- (void)computeCardLayout:(float)duation destPos:(int)pos destIdx:(int)idx{
    [UIView animateWithDuration:duation animations:^{
        CardView *cv;
        /// port
        if (NO) {
        }
        /// land
        else
        {
            int x=0;
            if ( Liuhai && _game.layoutid==138) {
                pianyix=3;
            }
            ///
            NSArray* majongs = [_game mahjongs];
            for (Card* c in majongs) {
                x++;
                cv = [cards objectForKey:c];
                cv.center = CGPointMake(MARGINX + c.col*(_w-_ow)/2+_w/2-c.layer*_ow, MARGINY + c.row*(_h-_oh)/2+_h/2-c.layer*_oh-pianyix*2);
                [cv setNeedsDisplay];
                [self.boardView bringSubviewToFront:cv];
                if (x==1) {
                }
            }
           
        }
        /// stat info update
        self.scoreLabel.text = [NSString stringWithFormat:@"Score : %d",self.game.scores];
        ///
        [self updateUndoBtn];
        [self.boardView bringSubviewToFront:matchCard1];
        [self.boardView bringSubviewToFront:matchCard2];
        ///
        [self.boardView  bringSubviewToFront:explodeView1];
        [self.boardView  bringSubviewToFront:explodeView2];
        //
        self.matchLabel.text = [NSString stringWithFormat:@"Available : %d",[self.game availableMatches]];
    } completion:^(BOOL finished){
        if ([self.game alreadyDone]) {
            //
            [[NSNotificationCenter defaultCenter] postNotificationName:@"autoCompleteDone" object:@"done"];
            [self setUserInteractionEnabled:YES];
            self.overflag = YES;
        }
    }];
}

- (void)updateUndoBtn
{
    ///
    if ([self.game canUndo]) {
        self.btnUndo.enabled = YES;
    }
    else
    {
        self.btnUndo.enabled = NO;
    }
}

- (void)heartDone
{
    //for debug
    /*
    for (Card* c in cards) {
        CardView* cv = [cards objectForKey:c];
        cv.card.state = CARD_STATE_HIDDEN;
        [cv setNeedsDisplay];
    }
    self.overflag = YES;
    */
    //
    [matchCard1 removeFromSuperview];
    [matchCard2 removeFromSuperview];
    explodeView1.hidden = YES;
    explodeView2.hidden = YES;
    //
    if (self.overflag)
    {
        [TheSound playWinSound];
        //
        for (CardView* cv in winCards) {
            cv.center = CGPointMake(rand()%(int)self.boardView.frame.size.width, rand()%(int)self.boardView.frame.size.height);
            [cv updateTheme:cv.card];
            [cv setNeedsDisplay];
            [self.boardView addSubview:cv];
        }
        [UIView animateWithDuration:0.75 animations:^{
            for (CardView* cv in winCards) {
                Card* c = cv.card;
                cv.center = CGPointMake(MARGINX + c.col*(_w-_ow)/2+_w/2-c.layer*_ow, MARGINY + c.row*(_h-_oh)/2+_h/2-c.layer*_oh);
                [cv setNeedsDisplay];
            }
        } completion:^(BOOL finished){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gameWin" object:nil];
            //[self showOver];
            //
            //[self performSelector:@selector(gameOver) withObject:self afterDelay:0.5];
        }];
        //
        
        [[AdmobViewController shareAdmobVC] recordValidUseCount];
    }
}

- (int)judgeStars
{
    int ss = 1;
    int cmpscore = 100 * [cards count] / 2;
    if (self.game.scores > cmpscore * 0.67)
    {
        ss = 3;
    }
    else if (self.game.scores > cmpscore * 0.33)
    {
        ss = 2;
    }
    else
        ss = 1;
    return ss;
}


- (void)showOver
{
    // zzx awin
    
    [self.LeftOPBar setAlpha:0];
    [self.RightOPBar setAlpha:0];
    int ss = [self judgeStars];
    [self.game.layoutstars replaceObjectAtIndex:self.game.layoutid withObject:[NSNumber numberWithInteger:ss]];
    if (self.game.layoutid + 1 < [self.game.layoutlocks count])
        [self.game.layoutlocks replaceObjectAtIndex:self.game.layoutid+1 withObject:[NSNumber numberWithBool:NO]];
    switch (ss)
    {
        case 0:
        case 1:
            self.overStarsImageView.image = [UIImage imageNamed:@"onestar"];
            break;
        case 2:
            self.overStarsImageView.image = [UIImage imageNamed:@"twostar"];
            break;
        case 3:
            self.overStarsImageView.image = [UIImage imageNamed:@"threestar"];
            break;
    }
    
    if ((self.game.layoutid + 1) % GROUP_SIZE == 0)
    {
        self.overNextBtn.enabled = NO;
        self.overNextLayoutView.hidden = YES;
    }
    else
    {
        NSLog(@" next zzx 10");
        self.overNextBtn.enabled = YES;
        self.overNextLayoutView.image = [UIImage imageNamed:[NSString stringWithFormat:@"layout%d.jpg",self.game.layoutid+1]];
        self.overNextLayoutView.hidden = NO;
    }
    self.overScoreLabel.text = [NSString stringWithFormat:@"%d",self.game.scores];
    self.overTimeLabel.text = [NSString stringWithFormat:@"%d:%02d",self.game.times/60,self.game.times%60];
    if (self.nextlock)
        self.overNextUnlockHint.hidden = NO;
    else
        self.overNextUnlockHint.hidden = YES;
    //
    if ((self.game.layoutid + 1) % GROUP_SIZE == 0) {
        self.overNextBtn.enabled = NO;
        self.overNextLayoutView.hidden = YES;
        self.overNextUnlockHint.hidden = YES;
    }
    //
    self.overView.hidden = NO;
    self.admobView.layer.zPosition = 1;
}

- (void)gameOver
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gameWin" object:nil];
}

- (void)matchExplode:(CGPoint)point1 point2:(CGPoint)point2
{
    [self.boardView  bringSubviewToFront:explodeView1];
    [self.boardView  bringSubviewToFront:explodeView2];
    explodeView1.center = point1;
    explodeView2.center = point2;
    explodeView1.hidden = NO;
    explodeView2.hidden = NO;
    explodeView1.animationImages = matchImages;
    [explodeView1 setAnimationDuration:0.4f];
    [explodeView1 setAnimationRepeatCount:1];
    [explodeView1 startAnimating];
    explodeView2.animationImages = matchImages;
    [explodeView2 setAnimationDuration:0.4f];
    [explodeView2 setAnimationRepeatCount:1];
    [explodeView2 startAnimating];
    [self performSelector:@selector(heartDone) withObject:nil afterDelay:0.4];
}

- (void)undoEffect:(NSArray*)undos
{
    if (undos != nil) {
        for (Card* c in undos) {
            CardView* cv = [cards objectForKey:c];
            [cv leftright];
        }
    }
}

- (void)matchAnimation:(CardView*)c1 theother:(CardView*)c2
{
    [cd1 assignWithCard:c1.card];
    cd1.state = CARD_STATE_SHOW;
    [cd2 assignWithCard:c2.card];
    cd2.state = CARD_STATE_SHOW;
    matchCard1.frame = c1.frame;
    [matchCard1 setNewCard:cd1];
    matchCard2.frame = c2.frame;
    [matchCard2 setNewCard:cd2];
    [self.boardView addSubview:matchCard1];
    [self.boardView addSubview:matchCard2];
    //NSLog(@"%f-%f,%f-%f", self.boardView.frame.origin.x, self.boardView.frame.origin.y, self.boardView.frame.size.width, self.boardView.frame.size.height);
    matchCard1.center = c1.center;
    matchCard2.center = c2.center;
    CGFloat dstPosX = (c1.center.x+c2.center.x)/2;
    CGFloat dstPosY = (c1.center.y+c2.center.y)/2;
    CGFloat offsetX = c1.frame.size.width*2;
    //NSLog(@"%f-%f,%f-%f", matchCard1.frame.origin.x, matchCard1.frame.origin.y, matchCard1.frame.size.width, matchCard1.frame.size.height);
    //NSLog(@"%f-%f,%f-%f", matchCard2.frame.origin.x, matchCard2.frame.origin.y, matchCard2.frame.size.width, matchCard2.frame.size.height);
    [UIView animateWithDuration:0.15 animations:^{
        matchCard1.center = CGPointMake(c1.center.x-offsetX, dstPosY);
        matchCard2.center = CGPointMake(c2.center.x+offsetX, dstPosY);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            matchCard1.center = CGPointMake(dstPosX-c1.frame.size.width/2, dstPosY);
            matchCard2.center = CGPointMake(dstPosX+c2.frame.size.width/2, dstPosY);
        } completion:^(BOOL finished) {
            //[matchCard1 removeFromSuperview];
            //[matchCard2 removeFromSuperview];
            [self matchExplode:matchCard1.center point2:matchCard2.center];
            [TheSound playMatchSound];
        }];
    }];
}

#pragma mark Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView {
    if (self.game.won || self.game.lose) {
        return;
    }
    if (!startFlag)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"controlTimer" object:[NSNumber numberWithBool:YES]];
        startFlag = YES;
    }
    ///
    [TheSound playClickSound];
    Card* selectCard = cardView.card;
    switch (selectCard.state) {
        case CARD_STATE_SHOW:
            if (touchedCard == nil || ![selectCard match:touchedCard]) {
                selectCard.state = CARD_STATE_SELECTED;
                if (touchedCard != nil) {
                    touchedCard.state = CARD_STATE_SHOW;
                }
                touchedCard = selectCard;
            }
            else
            {
                touchedCard.state = CARD_STATE_HIDDEN;
                selectCard.state = CARD_STATE_HIDDEN;
                CardView* cv = [cards objectForKey:touchedCard];
                //
                //[self matchExplode:cv.center point2:cardView.center];
                if (cv.center.x < cardView.center.x)
                    [self matchAnimation:cv theother:cardView];
                else
                    [self matchAnimation:cardView theother:cv];
                ///
                [_game updateBitboard:touchedCard mc:selectCard undo:NO];
                [_game pushAction:[[NSArray alloc] initWithObjects:touchedCard, selectCard, nil]];
                self.game.scores += 100;
                touchedCard = nil;
            }
            break;
        case CARD_STATE_SELECTED:
            if (touchedCard == selectCard) {
                selectCard.state = CARD_STATE_SHOW;
                touchedCard = nil;
            }
            break;
        case CARD_STATE_COVERED:
            [cardView leftright];
            break;
        case CARD_STATE_HIDDEN:
            ;
            break;
        default:
            break;
    }
    ///
    [self computeCardLayout:0.2 destPos:-1 destIdx:-1];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView {
    
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView  {
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event withCardView:(CardView *)cardView  {
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

- (void)onPause
{
    self.pauseView.hidden = NO;
    for (CardView* cv in [cards allValues]) {
        [cv pauseChange];
    }
}

- (void)onHelp
{
    self.helpView.hidden = NO;
    NSLog(@"help execute");
}

- (IBAction)onResume:(id)sender {
    for (CardView* cv in [cards allValues]) {
        [cv setNeedsDisplay];
    }
    self.pauseView.hidden = YES;
    if (startFlag)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"controlTimer" object:[NSNumber numberWithBool:YES]];
    [TheSound playTapSound];
    [self.LeftOPBar setAlpha:1];
    [self.RightOPBar setAlpha:1];
}

- (IBAction)onGotIt:(id)sender {
    [TheSound playTapSound];
    self.helpView.hidden = YES;
    NSLog(@"help execute");
    [self.LeftOPBar setAlpha:1];
    [self.RightOPBar setAlpha:1];
    [self.admobView setAlpha:1];
    [BackView setAlpha:1];
}

- (IBAction)onCloseOver:(id)sender {
    [TheSound playTapSound];
    self.overView.hidden = YES;
    self.admobView.layer.zPosition = 0;
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(afterCloseOverView)]) {
        [self.delegate afterCloseOverView];
    }
}

- (IBAction)showMenu:(id)sender {
    //[TheSound playTapSound];
    //[self hideOrDisplayOpBar];
}

- (IBAction)onSound:(id)sender {

}

- (void) hideOrDisplayOpBar {
    NSLog(@"test zzx hidden ");
    GLfloat safeViewHeight = self.safeAreaLayoutGuide.layoutFrame.size.height;
    [self.LeftOPBar setAlpha:1];
    [self.RightOPBar setAlpha:1];
    [self.opBar setAlpha:0];
    self.hideOp = !self.hideOp;
    int y1=0;
    y1=self.frame.size.height-self.LeftOPBar.frame.size.height-self.admobView.frame.size.height;
    if (self.frame.size.width+self.frame.size.width>1500) {
        y1=y1-20;
    }
    if (self.hideOp) {
       
        [UIView beginAnimations:@"Hide" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        rightOPbarleading.constant=0;
        [self.LeftOPBar setFrame:CGRectMake(self.gameBg.frame.size.width, y1, self.LeftOPBar.frame.size.width, self.LeftOPBar.frame.size.height)];
        [self.admobView setAlpha:1];
        
        [self.RightOPBar setFrame:CGRectMake(-self.RightOPBar.frame.size.width, y1, self.RightOPBar.frame.size.width, self.RightOPBar.frame.size.height)];
        [UIView commitAnimations];
        NSLog(@"LeftOPBar = %lf",self.LeftOPBar.frame.size.height);
        NSLog(@"self.with=%lf",self.frame.size.height);
        self.LeftOPBarTrall.constant=-self.RightOPBar.frame.size.width;
        self.RightOPBarTrall.constant=-self.RightOPBar.frame.size.width;
    }
    else
    {
        [UIView beginAnimations:@"Display" context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [self.admobView setAlpha:1];
        [self.LeftOPBar setFrame:CGRectMake(self.frame.size.width-self.LeftOPBar.frame.size.width, y1, self.LeftOPBar.frame.size.width, self.LeftOPBar.frame.size.height)];
        [self.RightOPBar setFrame:CGRectMake(0.0, y1, self.RightOPBar.frame.size.width, self.RightOPBar.frame.size.height)];
        [UIView commitAnimations];
        self.LeftOPBarTrall.constant=0;
        self.RightOPBarTrall.constant=0;
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
@end
