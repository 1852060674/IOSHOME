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

@interface GameStat : NSObject <NSCoding>

@property (strong, nonatomic) DrawStat* draw1;
@property (strong, nonatomic) DrawStat* draw3;

- (void)reset;

@end
