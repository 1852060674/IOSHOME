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

@implementation GameStat

@synthesize draw1 = _draw1;
@synthesize draw3 = _draw3;

- (id)init
{
    if (self = [super init]) {
        _draw1 = [[DrawStat alloc] init];
        _draw3 = [[DrawStat alloc] init];
        _freecell = [[DrawStat alloc] init];
    }
    return self;
}

- (void)reset
{
    [_draw1 reset];
    [_draw3 reset];
    [_freecell reset];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_draw1 forKey:@"draw1"];
    [aCoder encodeObject:_draw3 forKey:@"draw3"];
    [aCoder encodeObject:_freecell forKey:@"freecell"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _draw1 = [aDecoder decodeObjectForKey:@"draw1"];
        _draw3 = [aDecoder decodeObjectForKey:@"draw3"];
        _freecell = [aDecoder decodeObjectForKey:@"freecell"];
    }
    return self;
}

@end
