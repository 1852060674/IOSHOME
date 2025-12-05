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
enum {TYPE_EMPTY=1, TYPE_STOCK=2, TYPE_FOUNDATION=3, TYPE_RESERVE=4};
typedef NS_ENUM(NSUInteger, CardStatus) {
  CardStatusUnkown,
  CardStatusFacedown,
  CardStatusDim,
  CardStatusMovable,
};
@interface Card : NSObject <NSCopying, NSCoding>
@property (assign, nonatomic) CardStatus status;

@property (assign, nonatomic) NSInteger suit;
@property (assign, nonatomic) NSInteger rank;
@property (assign, nonatomic) BOOL faceUp;
@property (assign, nonatomic) BOOL glow;
@property (assign, nonatomic) int type;
@property (class, nonatomic, copy) NSString * frontName;

- (id)initWithRank:(NSInteger)r Suit:(NSInteger)s;
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
