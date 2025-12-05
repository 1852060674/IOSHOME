//
//  GameData.m
//  WordSearch
//
//  Created by apple on 13-8-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "GameData.h"
#import "Config.h"

static GameData* singleGD = nil;

@implementation GameData

@synthesize packNames;
@synthesize packCompleted;
@synthesize packCurrent;
@synthesize packPuzzles;
@synthesize packExplaned;
@synthesize section;
@synthesize row;
@synthesize no;
@synthesize version;
@synthesize  levelName;

- (id)init
{
    if (self = [super init])
    {
        section = -1;
        row = -1;
        no = -1;
        version = VERSION_NO;
    }
    if (singleGD == nil) {
        singleGD = self;
    }
    return self;
}

- (void)loadPuzzlesFromFile
{
    section = -1;
    row = -1;
    no = -1;
    packNames = [[NSMutableArray alloc] init];
    packCompleted = [[NSMutableArray alloc] init];
    packCurrent = [[NSMutableArray alloc] init];
    packPuzzles = [[NSMutableArray alloc] init];
    packExplaned = [[NSMutableArray alloc] init];
    NSString *packFile = [[NSBundle mainBundle] pathForResource:@"unblock" ofType:@"puzzle"];
    NSString *ppStr = [NSString stringWithContentsOfFile:packFile encoding:NSUTF8StringEncoding error:nil];
    NSArray* lines = [ppStr componentsSeparatedByString:@"\n"];
    NSString* pre_pack = nil;
    NSMutableArray* thePack = nil;
    for (NSString* puzzle in lines) {
        NSArray* words = [puzzle componentsSeparatedByString:@";"];
        if ([words count] < 4) {
            continue;
        }
        NSString* cur_pack = [words objectAtIndex:0];
        if ([cur_pack isEqualToString:pre_pack]) {
            [thePack addObject:[NSMutableArray arrayWithArray:[words subarrayWithRange:NSMakeRange(1, [words count]-1)]]];
        }
        else
        {
            [packNames addObject:cur_pack];
            [packCompleted addObject:[NSNumber numberWithInt:0]];
            [packCurrent addObject:[NSNumber numberWithInt:0]];
            pre_pack = cur_pack;
            [packExplaned addObject:[NSNumber numberWithBool:YES]];
            if (thePack != nil) {
                [packPuzzles addObject:thePack];
                thePack = [[NSMutableArray alloc] init];
            }
            else
            {
                thePack = [[NSMutableArray alloc] init];
            }
            [thePack addObject:[NSMutableArray arrayWithArray:[words subarrayWithRange:NSMakeRange(1, [words count]-1)]]];
        }
    }
    if (thePack != nil) {
        [packPuzzles addObject:thePack];
    }
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:packNames forKey:@"names"];
    [aCoder encodeObject:packCompleted forKey:@"complete"];
    [aCoder encodeObject:packCurrent forKey:@"current"];
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
        packCompleted = [aDecoder decodeObjectForKey:@"complete"];
        packCurrent = [aDecoder decodeObjectForKey:@"current"];
        packExplaned = [aDecoder decodeObjectForKey:@"explaned"];
        packPuzzles = [aDecoder decodeObjectForKey:@"puzzles"];
        version = [[aDecoder decodeObjectForKey:@"version"] integerValue];
    }
    if (singleGD == nil) {
        singleGD = self;
    }
    return self;
}

+ (GameData*)sharedGD
{
    return singleGD;
}

@end
