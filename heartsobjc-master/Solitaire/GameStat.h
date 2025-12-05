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
@property (assign, nonatomic) NSInteger worstScore;
@property (assign, nonatomic) NSInteger bestScore;

- (void)updateStat:(NSInteger)time scores:(NSInteger)scores moves:(NSInteger)moves undos:(NSInteger)undos;

- (void)reset;


@end

@interface NameScore : NSObject <NSCoding>

@property (strong, nonatomic) NSString* name;
@property (assign, nonatomic) int score;

- (id)initWithNameScore:(int)socre name:(NSString*)name;

@end

@interface GameStat : NSObject <NSCoding>

@property (strong, nonatomic) DrawStat* freecell;
@property (strong, nonatomic) NSMutableArray* topScores;

- (void)reset;
- (BOOL)addToTop:(NameScore*)ns;
- (BOOL)inTop:(int)score;

@end
