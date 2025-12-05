//
//  Card.m 
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "Card.h"

static BOOL classicCard = NO;

@implementation Card

@synthesize rank = _rank;
@synthesize suit = _suit;
@synthesize faceUp = _faceUp;
@synthesize glow = _glow;

static NSString * _front = nil;
+ (NSString *)frontName {
  return _front;
}

+ (void)setFrontName:(NSString *)frontName {
  _front = frontName;
}


- (id)initWithRank:(NSInteger)r Suit:(NSInteger)s {
    self = [super init];
    if (self) {
      static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
        [Card setFrontName:[[NSUserDefaults standardUserDefaults] objectForKey:@"cardfront"]];
      });
        _rank = r;
        _suit = s;
        _faceUp = YES;
        _glow = NO;
        _type = TYPE_EMPTY;
    }
    return self;
}

+ (void)setClassic:(BOOL)flag
{
    classicCard = flag;
}

+ (BOOL)classic;
{
    return classicCard;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_rank forKey:@"rank"];
    [aCoder encodeInteger:_suit forKey:@"suit"];
    [aCoder encodeBool:_faceUp forKey:@"faceup"];
    [aCoder encodeBool:_glow forKey:@"glow"];
    [aCoder encodeInt:_type forKey:@"type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _rank = [aDecoder decodeIntegerForKey:@"rank"];
        _suit = [aDecoder decodeIntegerForKey:@"suit"];
        _faceUp = [aDecoder decodeBoolForKey:@"faceup"];
        _glow = [aDecoder decodeBoolForKey:@"glow"];
        _type = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}

- (NSUInteger)hash {
    return (_suit - 1)*NUM_RANKS + _rank; // Returns 0 to 51
}

- (BOOL)isEqual:(id)other {
    return _rank == [other rank] && _suit == [other suit];
}

- (NSString *)description {
  NSString *s;
  NSString *r;
  if (_rank ==  -1 || _suit == -1) {
    return @"CardBack-GreenPattern";
  }

  switch (_suit) {
    case SPADES:
      s = @"s";
      break;
    case CLUBS:
      s = @"c";
      break;
    case DIAMONDS:
      s = @"d";
      break;
    case HEARTS:
      s = @"h";
      break;
    default:
      s = @"Unknown";
      break;
  }
  switch (_rank) {
    case ACE:
      r = @"1";
      break;
    case JACK:
      r = @"11";
      break;
    case QUEEN:
      r = @"12";
      break;
    case KING:
      r = @"13";
      break;
    default:
      r = [NSString stringWithFormat:@"%lu", (unsigned long)_rank];
      break;
  }

  //    return [NSString stringWithFormat:@"small-%@-%@", s, r];
  //    // Used for debugging and imageFilename
  //    if ([Card classic] == YES) {
  //        return [NSString stringWithFormat:@"small-%@-%@", s, r];
  //    }
  //    else
  //    {
  //        return [NSString stringWithFormat:@"big-%@-%@", s, r];
  //    }

  NSString * string = [Card frontName];
  if (!string) {
    return [NSString stringWithFormat:@"%@%@_0", s, r];
  }
  else
  {
    return [NSString stringWithFormat:@"%@%@_%@", s, r, string];
  }
}

- (id)copyWithZone:(NSZone *)zone {
    Card *copy = [[Card allocWithZone:zone] initWithRank:_rank Suit:_suit];
    return copy;
}

- (BOOL)isBlack {
    return _suit == SPADES || _suit == CLUBS;    
}

- (BOOL)isRed {
    return _suit == DIAMONDS || _suit == HEARTS;
}

- (BOOL)isSameColor:(Card *)other {
    return ([self isRed] && [other isRed]) || ([self isBlack] && [other isBlack]);
}

+ (NSArray *)deck:(NSArray *)winboards{
    NSMutableArray *deck = [[NSMutableArray alloc] init];
//    if (winboards == nil) {
//        for (int i = CLUBS; i <= SPADES; i++) {
//            for (int j = ACE; j <= KING; j++) {
//                [deck addObject:[[Card alloc] initWithRank:j Suit:i]];
//            }
//        }
//    }
//    else
//    {
//        for (NSNumber* num in winboards) {
//            NSInteger nnum = [num integerValue];
//            [deck addObject:[[Card alloc] initWithRank:nnum%13==0 ? KING : nnum%13 Suit:nnum%13==0 ? nnum/13-1 : nnum/13]];
//        }
//    }
    for (int i = CLUBS; i <= SPADES; i++) {
        for (int j = ACE; j <= KING; j++) {
            [deck addObject:[[Card alloc] initWithRank:j Suit:i]];
        }
    }
     /* a winning deal for test
     //A: SPADES, B: DIAMONDS, C: CLUBS, D: HEARTS
    [deck addObject:[[Card alloc] initWithRank:1 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:1 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:2 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:3 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:1 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:2 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:4 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:2 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:3 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:6 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:9 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:8 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:7 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:6 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:5 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:5 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:4 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:13 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:12 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:11 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:10 Suit:SPADES]];
    [deck addObject:[[Card alloc] initWithRank:12 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:11 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:10 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:9 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:8 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:7 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:6 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:3 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:3 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:2 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:5 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:4 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:4 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:1 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:6 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:5 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:8 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:7 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:7 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:9 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:9 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:8 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:11 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:10 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:10 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:13 Suit:DIAMONDS]];
    [deck addObject:[[Card alloc] initWithRank:12 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:11 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:13 Suit:CLUBS]];
    [deck addObject:[[Card alloc] initWithRank:12 Suit:HEARTS]];
    [deck addObject:[[Card alloc] initWithRank:13 Suit:HEARTS]];
    */
    return deck; 
}

@end
