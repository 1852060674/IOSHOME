//
//  GameData.m
//  WordSearch
//
//  Created by apple on 13-8-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GameData.h"
#import "Config.h"

@implementation GameData

@synthesize packNames;
@synthesize packPuzzles;
@synthesize packExplaned;
@synthesize section;
@synthesize row;
@synthesize version;

- (id)init
{
    if (self = [super init])
    {
        section = -1;
        row = -1;
        version = VERSION_NO;
    }
    return self;
}

- (void)loadPuzzlesFromFile
{
    section = -1;
    row = -1;
    packNames = [[NSMutableArray alloc] init];
    packPuzzles = [[NSMutableArray alloc] init];
    packExplaned = [[NSMutableArray alloc] init];
    NSString *packFile = [[NSBundle mainBundle] pathForResource:@"puzzle" ofType:@"pack"];
    NSString *ppStr = [NSString stringWithContentsOfFile:packFile encoding:NSUTF8StringEncoding error:nil];
    NSArray* lines = [ppStr componentsSeparatedByString:@"\n"];
    NSString* pre_pack = nil;
    NSMutableDictionary* thePack = nil;
    for (NSString* puzzle in lines) {
        NSArray* words = [puzzle componentsSeparatedByString:@","];
        if ([words count] < 12) {
            continue;
        }
        NSString* cur_pack = [words objectAtIndex:0];
        if ([cur_pack isEqualToString:pre_pack]) {
            [thePack setObject:[NSMutableArray arrayWithArray:[words subarrayWithRange:NSMakeRange(1, [words count]-1)]] forKey:[words objectAtIndex:1]];
        }
        else
        {
            [packNames addObject:cur_pack];
            pre_pack = cur_pack;
            [packExplaned addObject:[NSNumber numberWithBool:YES]];
            if (thePack != nil) {
                [packPuzzles addObject:thePack];
                thePack = [[NSMutableDictionary alloc] init];
            }
            else
            {
                thePack = [[NSMutableDictionary alloc] init];
            }
            [thePack setObject:[NSMutableArray arrayWithArray:[words subarrayWithRange:NSMakeRange(1, [words count]-1)]] forKey:[words objectAtIndex:0]];
        }
    }
    if (thePack != nil) {
        [packPuzzles addObject:thePack];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:packNames forKey:@"names"];
    [aCoder encodeObject:packExplaned forKey:@"explaned"];
    [aCoder encodeObject:packPuzzles forKey:@"puzzles"];
    [aCoder encodeObject:[NSNumber numberWithInteger:version] forKey:@"version"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        section = -1;
        row = -1;
        version = 0;
        packNames = [aDecoder decodeObjectForKey:@"names"];
        packExplaned = [aDecoder decodeObjectForKey:@"explaned"];
        packPuzzles = [aDecoder decodeObjectForKey:@"puzzles"];
        version = [[aDecoder decodeObjectForKey:@"version"] integerValue];
    }
    return self;
}

@end
