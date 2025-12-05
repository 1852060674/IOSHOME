//
//  Card.h
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUM_SUITS 4
#define NUM_RANKS 13

enum {CLUBS, DIAMONDS, HEARTS, SPADES};
enum {ACE=1, JACK=11, QUEEN=12, KING=13};
enum {TYPE_EMPTY=1, TYPE_STOCK=2, TYPE_FOUNDATION=3};

@interface Card : NSObject <NSCopying, NSCoding>

@property (assign, nonatomic) NSUInteger suit;
@property (assign, nonatomic) NSUInteger rank;
@property (assign, nonatomic) BOOL faceUp;
@property (assign, nonatomic) BOOL glow;

- (id)initWithRank:(uint)r Suit:(uint)s;
- (NSUInteger)hash;
- (BOOL)isEqual:(id)other;
- (NSString *)description;

- (id)copyWithZone:(NSZone *)zone;

- (BOOL)isBlack;
- (BOOL)isRed;
- (BOOL)isSameColor:(Card *)other;

+ (NSArray *)deck:(NSArray *)winboards;
+ (void)setClassic:(BOOL)flag;
+ (BOOL)classic;

@end
