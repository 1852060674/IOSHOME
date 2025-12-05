//
//  Card.h
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUM_TILE 42
#define MAX_ROW 16
#define MAX_COL 36
#define MAX_LAYER 9

enum CARD_STATE {
    CARD_STATE_HIDDEN = 0,
    CARD_STATE_SHOW = 1,
    CARD_STATE_SELECTED = 2,
    CARD_STATE_COVERED = 3
    };

@interface Card : NSObject <NSCopying, NSCoding>

@property (assign, nonatomic) NSInteger seq;
@property (assign, nonatomic) NSInteger no;
@property (assign, nonatomic) NSInteger layer;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSInteger col;
@property (assign, nonatomic) NSInteger state;

- (id)initWithSeq:(int)theSeq layer:(int)z row:(int)y col:(int)x state:(int)st no:(int)n;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;
- (BOOL)match:(Card*)other;
- (void)swapXYZ:(Card*)other;
- (NSString *)description;
- (void)assignWithCard:(Card*)other;

- (id)copyWithZone:(NSZone *)zone;

@end
