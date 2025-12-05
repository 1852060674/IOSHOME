//
//  Solitaire.h
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

#define GROUP_SIZE 42

@interface Solitaire : NSObject <NSCoding>

///
@property (assign, nonatomic) NSInteger scores;
@property (assign, nonatomic) NSInteger moves;
@property (assign, nonatomic) NSInteger times;
@property (assign, nonatomic) NSInteger undos;
@property (assign, nonatomic) BOOL won;
@property (assign, nonatomic) BOOL lose;
@property (assign, nonatomic) NSInteger level;
@property (assign, nonatomic) BOOL firstAuto;
@property (assign, nonatomic) NSInteger boardId;
@property (assign, nonatomic) NSInteger groupId;
@property (assign, nonatomic) NSInteger layoutid;
@property (strong, nonatomic) NSMutableArray* layoutlocks;
@property (strong, nonatomic) NSMutableArray* layoutstars;
@property (assign, nonatomic) NSInteger unlockone;

- (id)init:(NSArray *)winboards;
- (void)fillBoard;

- (void)shuffleDeck:(NSMutableArray *)deck need:(BOOL)need;
- (void)freshGame:(NSArray *)winboards;
- (void)replayGame;
- (BOOL)gameWon;
- (NSMutableArray*)deck;
- (NSArray*)mahjongs;
- (void)updateBitboard:(Card*)m1 mc:(Card*)m2 undo:(BOOL)flag;
- (void)shuffleCurrent;
- (int)availableMatches;

- (void)pushAction:(NSArray*)action;
- (void)insertToLastAction:(NSArray*)action;
- (NSArray*)undoAction;
- (BOOL)canUndo;
- (NSArray*)hintActions:(Card*)card;
- (BOOL)alreadyDone;
@end
