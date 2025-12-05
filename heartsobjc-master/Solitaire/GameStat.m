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
@synthesize worstScore = _worstScore;
@synthesize bestScore = _bestScore;

- (id)init
{
    if (self = [super init]) {
        _wonCnt = 0;
        _lostCnt = 0;
        _worstScore = 0;
        _bestScore = 0;
    }
    return self;
}

- (void)reset
{
    _wonCnt = 0;
    _lostCnt = 0;
    _worstScore = 0;
    _bestScore = 0;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_wonCnt forKey:@"wonCnt"];
    [aCoder encodeInteger:_lostCnt forKey:@"lostCnt"];
    [aCoder encodeInteger:_worstScore forKey:@"worstScore"];
    [aCoder encodeInteger:_bestScore forKey:@"bestScore"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _wonCnt = [aDecoder decodeIntegerForKey:@"wonCnt"];
        _lostCnt = [aDecoder decodeIntegerForKey:@"lostCnt"];
        _worstScore = [aDecoder decodeIntegerForKey:@"worstScore"];
        _bestScore = [aDecoder decodeIntegerForKey:@"bestScore"];
    }
    return self;
}

- (void)updateStat:(NSInteger)time scores:(NSInteger)scores moves:(NSInteger)moves undos:(NSInteger)undos
{
    _wonCnt++;
    if (_bestScore <= scores)
    {
        _bestScore = scores;
    }
    if (_worstScore > scores) {
        _worstScore = scores;
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

@synthesize freecell = _freecell;
@synthesize topScores = _topScores;

- (id)init
{
    if (self = [super init]) {
        _freecell = [[DrawStat alloc] init];
        _topScores = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)reset
{
    [_freecell reset];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_freecell forKey:@"freecell"];
    [aCoder encodeObject:_topScores forKey:@"topscores"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _freecell = [aDecoder decodeObjectForKey:@"freecell"];
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
        if (score < minns.score) {
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
        if (ns.score < minns.score) {
            [_topScores removeLastObject];
            [_topScores addObject:ns];
            ret = YES;
        }
    }
    if (ret) {
        [_topScores sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NameScore* c1 = obj1;
            NameScore* c2 = obj2;
            if (c1.score < c2.score) {
                return NSOrderedAscending;
            }
            else if (c1.score > c2.score)
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
