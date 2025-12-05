//
//  GameStat.h
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DrawStat : NSObject <NSCoding>

@property (assign, nonatomic) NSInteger wonCnt;
@property (assign, nonatomic) NSInteger lostCnt;
@property (assign, nonatomic) NSInteger shortestWonTime;
@property (assign, nonatomic) NSInteger longestWonTime;
@property (assign, nonatomic) NSInteger averageWonTime;
@property (assign, nonatomic) NSInteger totalWonTime;
@property (assign, nonatomic) NSInteger fewestWonMoves;
@property (assign, nonatomic) NSInteger mostWonMoves;
@property (assign, nonatomic) NSInteger wonWithoutUndoCnt;
@property (assign, nonatomic) NSInteger highestSocre;

- (void)updateStat:(NSInteger)time scores:(NSInteger)scores moves:(NSInteger)moves undos:(NSInteger)undos;

- (void)reset;


@end

@interface NameScore : NSObject <NSCoding>

@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) int score;

- (id)initWithNameScore:(int)socre name:(NSString*)name;

@end

@interface GameStat : NSObject <NSCoding>

@property (strong, nonatomic) DrawStat* easy;
@property (strong, nonatomic) DrawStat* hard;
@property (strong, nonatomic) NSMutableArray* topScores;

- (void)reset;
- (BOOL)addToTop:(NameScore*)ns;
- (BOOL)inTop:(int)score;

@end
