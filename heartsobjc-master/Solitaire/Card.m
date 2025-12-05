//
//  Card.m
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "Card.h"
#import "Comom.h"
static BOOL classicCard = NO;

@implementation Card

@synthesize rank = _rank;
@synthesize suit = _suit;
@synthesize faceUp = _faceUp;
@synthesize glow = _glow;
@synthesize selected = _selected;
@synthesize hidden = _hidden;
static NSString * _front = nil;
+ (NSString *)frontName {
  return _front;
}

+ (void)setFrontName:(NSString *)frontName {
  _front = frontName;
}
- (id)initWithRank:(uint)r Suit:(uint)s {
    self = [super init];
    if (self) {
      static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
          [Card setFrontName:[[NSUserDefaults standardUserDefaults] objectForKey:@"cardfront"]];
        });
        _rank = r;
        _suit = s;
        _faceUp = NO;
        _glow = NO;
        _selected = NO;
        _hidden = NO;
    }
    return self;
}

- (void)setHidden:(BOOL)hidden {
  _hidden = hidden;
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
    [aCoder encodeBool:_selected forKey:@"selected"];
    [aCoder encodeBool:_hidden forKey:@"hidden"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _rank = [aDecoder decodeIntegerForKey:@"rank"];//排
        _suit = [aDecoder decodeIntegerForKey:@"suit"];//华色
        _faceUp = [aDecoder decodeBoolForKey:@"faceup"];//是否翻开
        _glow = [aDecoder decodeBoolForKey:@"glow"];//是否可选
        _selected = [aDecoder decodeBoolForKey:@"selected"];//是否被选中
        _hidden = [aDecoder decodeBoolForKey:@"hidden"];//是否被隐藏
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
            r = [NSString stringWithFormat:@"%d", _rank];
            break;
    }
    
    // Used for debugging and imageFilename
    //    if ([Card classic] == YES) {
    //        return [NSString stringWithFormat:@"%@%@-104x145-Sharp50-2", s, r];
    //    }
    //    else
    //    {
    //        return [NSString stringWithFormat:@"%@%@-104x145-Sharp50--New3b", s, r];
    //    }
    Comom *Comom1 = [[Comom alloc] init];
    if ([Comom1 Isoladman] ) {
        if ([Card classic] == YES) {
            return [NSString stringWithFormat:@"%@%@-104x145-Sharp50-2", s, r];
        }
        else
        {
            return [NSString stringWithFormat:@"%@%@-104x145-Sharp50--New3b", s, r];
        }
    }else{
        //
        NSString * string = [Card frontName];
        if (!string || ( [string isEqualToString:@"2"] && ![self isbad:r] ) || ( [string isEqualToString:@"3"] &&![self isbad:r] ) || ([string isEqualToString:@"5"] && ![self isbad:r]) ) {
            return [NSString stringWithFormat:@"%@%@_0", s, r];
        }
        else
        {
            return [NSString stringWithFormat:@"%@%@_%@", s, r, string];
        }
    }

}

- (BOOL)isbad:(NSString *) rank {
    return  [rank isEqual:(@"11")] || [rank isEqual:(@"12")] || [rank isEqual:(@"13")] ;
//    [rank isEqual:(@"1")] ||
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

/////////////////
#define     BLACK           0               // COLOUR(card)
#define     RED             1

#define     DEUCE           1

#define     SUIT(card)      ((card) % 4)
#define     VALUE(card)     ((card) / 4)
#define     COLOUR(card)    (SUIT(card) == DIAMOND || SUIT(card) ==HEART)

#define     MAXPOS         21
#define     MAXCOL          9    // includes top row as column 0
int  card[MAXCOL][MAXPOS];    // current layout of cards, CARDs areints

+ (void)genFreeCell
{
    int  i, j;                // generic counters
    int  col, pos;
    int  wLeft = 52;          // cards left to be chosen in shuffle
    int deck[52];            // deck of 52 unique cards
    
    for (col = 0; col < MAXCOL; col++)          // clear the deck
        for (pos = 0; pos < MAXPOS; pos++)
            card[col][pos] = 0;
    
    /* shuffle cards */
    
    for (i = 0; i < 52; i++)      // put unique card in each deck loc.
        deck[i] = i;
    
    srand(5);            // gamenumber is seed for rand()
    for (i = 0; i < 52; i++)
    {
        j = rand() % wLeft;
        card[(i%8)+1][i/8] = deck[j];
        deck[j] = deck[--wLeft];
    }
}

+ (NSArray *)deck:(NSArray *)winboards{
    //[Card genFreeCell];
    NSMutableArray *deck = [[NSMutableArray alloc] init];
    if (winboards == nil) {
        for (int i = CLUBS; i <= HEARTS; i++) {
            for (int j = ACE; j <= KING; j++) {
                [deck addObject:[[Card alloc] initWithRank:j Suit:i]];
            }
        }
    }
    else
    {
        for (NSNumber* num in winboards) {
            NSInteger nnum = [num integerValue];
            [deck addObject:[[Card alloc] initWithRank:nnum%13==0 ? KING : nnum%13 Suit:nnum%13==0 ? nnum/13-1 : nnum/13]];
        }
    }
    /*
     freecell winning deal for test
     26 13 52 39 19 6 32 45 25 12 51 38 18 5 31 44 24 11 50 37 17 4 30 43 23 10 49 36 16 3 29 42 22 9 48 35 15 2 28 41 21 8 47 34 14 1 27 40 20 7 46 33
     */
     return deck;
}

@end
