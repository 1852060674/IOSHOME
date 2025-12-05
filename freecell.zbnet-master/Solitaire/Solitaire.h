//
//  Solitaire.h
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

#define NUM_TABLEAUS 8
#define NUM_FOUNDATIONS 4
#define NUM_STOCKS 4


@interface Solitaire : NSObject <NSCoding>

///
@property (assign, nonatomic) NSInteger scores;
@property (assign, nonatomic) NSInteger moves;
@property (assign, nonatomic) NSInteger times;
@property (assign, nonatomic) NSInteger tiles;
@property (assign, nonatomic) NSInteger undos;
@property (assign, nonatomic) BOOL won;
@property (assign, nonatomic) BOOL draw3;
@property (assign, nonatomic) BOOL firstAuto;
@property (assign, nonatomic) NSInteger boardId;

- (id)init:(NSArray *)winboards;

+ (void)shuffleDeck:(NSMutableArray *)deck need:(BOOL)need;
- (void)freshGame:(NSArray *)winboards;
- (void)replayGame;
- (BOOL)gameWon;

- (NSArray *)stock:(uint)i;
- (NSArray *)foundation:(uint)i;
- (NSArray *)tableau:(uint)i;

- (NSArray *)fanBeginningWithCard:(Card *)card;

- (BOOL)canDropCard:(Card *)card onFoundation:(int)i;
- (void)didDropCard:(Card *)card onFoundation:(int)i;

- (BOOL)canDropCard:(Card *)card onTableau:(int)i;
- (void)didDropCard:(Card *)card onTableau:(int)i;

- (BOOL)canDropCard:(Card *)card onStock:(int)i;
- (void)didDropCard:(Card *)card onStock:(int)i;

- (BOOL)canDropFan:(NSArray *)cards onTableau:(int)i;
- (void)didDropFan:(NSArray *)cards onTableau:(int)i;

- (NSArray *)canMoveFans:(uint)i;

- (int)inFoundation:(Card*)card;

- (void)pushAction:(NSArray*)action;
- (NSArray*)undoAction;
- (void)positionCard:(Card*)card pos:(NSInteger*)pos idx:(NSInteger*)idx;
- (BOOL)canUndo;
- (NSArray*)hintActions;
- (NSArray*)autoAction:(Card*)card;
- (NSArray*)completeEach;
- (BOOL)alreadyDone;

- (NSInteger)cardsLeftCnt;
- (NSArray *)cannotMoveOnIndex:(NSInteger)index ;

@end
