//
//  Solitaire.h
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

#define NUM_PLAYERS 4
#define NUM_SUITS 4
#define NUM_CARDS_EACH 13

enum PLAYSTATE {
    STATE_BEGIN = 0,
    STATE_DEAL,
    STATE_SELECTPASSCARD,
    STATE_SELECTCONFIRM,
    STATE_EXCHANGE,
    STATE_INSERT,
    STATE_DISCARDONE,
    STATE_DISCARDTWO,
    STATE_DISCARDTHREE,
    STATE_DISCARDFOUR,
    STATE_COLLECTCARD,
    STATE_COLLECTDONE,
    STATE_STANDING,
    STATE_DEALEND,
    STATE_GAMEEND,
    STATE_END = 999
    };


@interface Solitaire : NSObject <NSCoding>

///
@property (strong, nonatomic) NSMutableArray *totalscores;
@property (strong, nonatomic) NSMutableArray *currentscores;
@property (strong, nonatomic) NSMutableArray *fourcards;
@property (assign, nonatomic) NSInteger handcnt;
@property (assign, nonatomic) NSInteger firstplay;
@property (assign, nonatomic) NSInteger currentstate;
@property (assign, nonatomic) BOOL won;
@property (assign, nonatomic) BOOL broken;
@property (assign, nonatomic) NSInteger boardId;

- (id)init:(NSArray *)winboards;

+ (void)shuffleDeck:(NSMutableArray *)deck need:(BOOL)need;
- (void)freshGame:(NSArray *)winboards;
- (void)newDeal:(NSArray *)winboards;
- (BOOL)gameWon;

- (NSArray *)playerCards:(uint)i;
- (NSArray *)playerCards:(uint)i suit:(int)suit;
- (BOOL)isYourCard:(Card*)card;
- (int)whoHasClubs2;
- (int)whoCollect;
- (BOOL)isYourTurn;
- (BOOL)aiDiscard;
- (void)discardYourCard:(Card*)card;
- (BOOL)discardingState;
- (NSArray*)yourCanDiscards;
- (void)clearCurrentScore;
- (void)addCurrentToTotal;
- (int)gameOver;
- (BOOL)check26;

- (void)sortCards;
- (void)selectPassCards;
- (void)exchangeCards;
- (void)insertPassCards;

- (void)positionCard:(Card*)card pos:(NSInteger*)pos idx:(NSInteger*)idx;
- (BOOL)alreadyDone;

@end
