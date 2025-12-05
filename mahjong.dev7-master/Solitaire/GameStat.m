//
//  GameStat.m
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GameStat.h"

@implementation DrawStat

@synthesize wonCnt = _wonCnt;
@synthesize lostCnt = _lostCnt;
@synthesize shortestWonTime = _shortestWonTime;
@synthesize longestWonTime = _longestWonTime;
@synthesize averageWonTime = _averageWonTime;
@synthesize totalWonTime = _totalWonTime;
@synthesize fewestWonMoves = _fewestWonMoves;
@synthesize mostWonMoves = _mostWonMoves;
@synthesize wonWithoutUndoCnt = _wonWithoutUndoCnt;
@synthesize highestSocre = _highestSocre;

- (id)init
{
    if (self = [super init]) {
        _wonCnt = 0;
        _lostCnt = 0;
        _shortestWonTime = 0;
        _longestWonTime = 0;
        _averageWonTime = 0;
        _totalWonTime = 0;
        _fewestWonMoves = 0;
        _mostWonMoves = 0;
        _wonWithoutUndoCnt = 0;
        _highestSocre = 0;
    }
    return self;
}

- (void)reset
{
    _wonCnt = 0;
    _lostCnt = 0;
    _shortestWonTime = 0;
    _longestWonTime = 0;
    _averageWonTime = 0;
    _totalWonTime = 0;
    _fewestWonMoves = 0;
    _mostWonMoves = 0;
    _wonWithoutUndoCnt = 0;
    _highestSocre = 0;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_wonCnt forKey:@"wonCnt"];
    [aCoder encodeInteger:_lostCnt forKey:@"lostCnt"];
    [aCoder encodeInteger:_shortestWonTime forKey:@"shortestWonTime"];
    [aCoder encodeInteger:_longestWonTime forKey:@"longestWonTime"];
    [aCoder encodeInteger:_averageWonTime forKey:@"averageWonTime"];
    [aCoder encodeInteger:_totalWonTime forKey:@"totalWonTime"];
    [aCoder encodeInteger:_fewestWonMoves forKey:@"fewestWonMoves"];
    [aCoder encodeInteger:_mostWonMoves forKey:@"mostWonMoves"];
    [aCoder encodeInteger:_wonWithoutUndoCnt forKey:@"wonWithoutUndoCnt"];
    [aCoder encodeInteger:_highestSocre forKey:@"highestSocre"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _wonCnt = [aDecoder decodeIntegerForKey:@"wonCnt"];
        _lostCnt = [aDecoder decodeIntegerForKey:@"lostCnt"];
        _shortestWonTime = [aDecoder decodeIntegerForKey:@"shortestWonTime"];
        _longestWonTime = [aDecoder decodeIntegerForKey:@"longestWonTime"];
        _averageWonTime = [aDecoder decodeIntegerForKey:@"averageWonTime"];
        _totalWonTime = [aDecoder decodeIntegerForKey:@"totalWonTime"];
        _fewestWonMoves = [aDecoder decodeIntegerForKey:@"fewestWonMoves"];
        _mostWonMoves = [aDecoder decodeIntegerForKey:@"mostWonMoves"];
        _wonWithoutUndoCnt = [aDecoder decodeIntegerForKey:@"wonWithoutUndoCnt"];
        _highestSocre = [aDecoder decodeIntegerForKey:@"highestSocre"];
    }
    return self;
}

- (void)updateStat:(NSInteger)time scores:(NSInteger)scores moves:(NSInteger)moves undos:(NSInteger)undos
{
    _wonCnt++;
    _totalWonTime += time;
    if (_shortestWonTime == 0
        || _shortestWonTime > time) {
        _shortestWonTime = time;
    }
    if (_longestWonTime < time) {
        _longestWonTime = time;
    }
    _averageWonTime = _totalWonTime*1.0/_wonCnt;
    if (_fewestWonMoves == 0
        || _fewestWonMoves > moves)
    {
        _fewestWonMoves = moves;
    }
    if (_mostWonMoves < moves ) {
        _mostWonMoves = moves;
    }
    if (undos == 0) { 
        _wonWithoutUndoCnt++;
    }
    if (_highestSocre == 0
        || _highestSocre < scores)
    {
        _highestSocre = scores;
    }
}

@end

@implementation NameScore

@synthesize score = _score;
@synthesize name = _name;

- (id)initWithNameScore:(int)socre name:(NSString*)name
{
    self = [super init];
    if (self) {
        _score = socre;
        _name = name;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_score forKey:@"score"];
    [aCoder encodeObject:_name forKey:@"name"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _score = [aDecoder decodeIntegerForKey:@"score"];
        _name = [aDecoder decodeObjectForKey:@"name"];
    }
    return self;
}

@end

@implementation GameStat

@synthesize easy = _easy;
@synthesize hard = _hard;
@synthesize topScores = _topScores;

- (id)init
{
    if (self = [super init]) {
        _easy = [[DrawStat alloc] init];
        _hard = [[DrawStat alloc] init];
        _topScores = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)reset
{
    [_easy reset];
    [_hard reset];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_easy forKey:@"easy"];
    [aCoder encodeObject:_hard forKey:@"hard"];
    [aCoder encodeObject:_topScores forKey:@"topscores"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _easy = [aDecoder decodeObjectForKey:@"easy"];
        _hard = [aDecoder decodeObjectForKey:@"hard"];
        _topScores = [aDecoder decodeObjectForKey:@"topscores"];
    }
    return self;
}

#define TOPN 5

- (BOOL)inTop:(int)score
{
    if ([_topScores count] < TOPN) {
        return YES;
    }
    else
    {
        NameScore* minns = [_topScores lastObject];
        if (score > minns.score) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)addToTop:(NameScore*)ns
{
    BOOL ret = NO;
    if ([_topScores count] < TOPN) {
        [_topScores addObject:ns];
        ret = YES;
    }
    else
    {
        NameScore* minns = [_topScores lastObject];
        if (ns.score > minns.score) {
            [_topScores removeLastObject];
            [_topScores addObject:ns];
            ret = YES;
        }
    }
    if (ret) {
        [_topScores sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NameScore* c1 = obj1;
            NameScore* c2 = obj2;
            if (c1.score > c2.score) {
                return NSOrderedAscending;
            }
            else if (c1.score < c2.score)
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedSame;
            }
        }];
    }
    return ret;
}

@end
