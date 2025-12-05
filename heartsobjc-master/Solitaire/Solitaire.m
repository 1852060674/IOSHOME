//
//  Solitaire.m
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved. 
//

#import "Solitaire.h"
#import "Card.h"
#import "MoveAction.h"
#import "Config.h"

@implementation Solitaire {
    NSMutableArray *playerscards[NUM_PLAYERS][NUM_SUITS];
    NSMutableArray *heartsgot[NUM_PLAYERS];
}

@synthesize totalscores = _totalscores;
@synthesize currentscores = _currentscores;
@synthesize handcnt = _handcnt;
@synthesize firstplay = _firstplay;
@synthesize currentstate = _currentstate;
@synthesize won = _won;
@synthesize boardId = _boardId;
@synthesize fourcards = _fourcards;
@synthesize broken = _broken;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (int i = 0; i < NUM_PLAYERS; i++) {
        for (int j = 0; j < NUM_SUITS; j++) {
            [aCoder encodeObject:playerscards[i][j] forKey:[NSString stringWithFormat:@"playerscards_%d_%d",i,j]];
        }
    }
    for (int i = 0; i < NUM_PLAYERS; i++) {
        [aCoder encodeObject:heartsgot[i] forKey:[NSString stringWithFormat:@"heartsgot_%d",i]];
    }
    [aCoder encodeObject:_fourcards forKey:@"fourcards"];
    [aCoder encodeObject:_totalscores forKey:@"totalscores"];
    [aCoder encodeObject:_currentscores forKey:@"currentscores"];
    [aCoder encodeInteger:_handcnt forKey:@"handcnt"];
    [aCoder encodeInteger:_firstplay forKey:@"firstplay"];
    [aCoder encodeInteger:_currentstate forKey:@"currentstate"];
    [aCoder encodeBool:_won forKey:@"won"];
    [aCoder encodeInteger:_boardId forKey:@"boardId"];
    [aCoder encodeBool:_broken forKey:@"broken"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        for (int i = 0; i < NUM_PLAYERS; i++) {
            for (int j = 0; j < NUM_SUITS; j++) {
                playerscards[i][j] = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"playerscards_%d_%d",i,j]];
            }
        }
        for (int i = 0; i < NUM_PLAYERS; i++) {
            heartsgot[i] = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"heartsgot_%d",i]];
        }
        _fourcards = [aDecoder decodeObjectForKey:@"fourcards"];
        _totalscores = [aDecoder decodeObjectForKey:@"totalscores"];
        _currentscores = [aDecoder decodeObjectForKey:@"currentscores"];
        _handcnt = [aDecoder decodeIntegerForKey:@"handcnt"];
        _firstplay = [aDecoder decodeIntegerForKey:@"firstplay"];
        _currentstate = [aDecoder decodeIntegerForKey:@"currentstate"];
        _won = [aDecoder decodeBoolForKey:@"won"];
        _boardId = [aDecoder decodeIntegerForKey:@"boardId"];
        _broken = [aDecoder decodeBoolForKey:@"broken"];
    }
    return self;
}

- (id)init:(NSArray*)winboards {
    self = [super init];
    if (self) {
        [self freshGame:winboards];
    }
    return self;

}

+ (void)shuffleDeck:(NSMutableArray *)deck need:(BOOL)need{
    /* http://eureka.ykyuen.info/2010/06/19/objective-c-how-to-shuffle-a-nsmutablearray/ */
    // Shuffle the deck
    srandom(time(NULL));
    //
    if (need) {
        NSUInteger count = [deck count];
        for (NSUInteger i = 0; i < count; ++i) {
            int nElements = count - i;
            int n = (random() % nElements) + i;
            [deck exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
    }
}

- (void)newDeal:(NSArray *)winboards
{
    BOOL needFlag = YES;
    NSArray* theBoard = nil;
    if (winboards != nil && _boardId < [winboards count]) {
        needFlag = NO;
        theBoard = [winboards objectAtIndex:_boardId];
    }
    
    NSMutableArray *deck = (NSMutableArray *) [Card deck:theBoard];
    
    [Solitaire shuffleDeck:deck need:needFlag];
    
    _boardId++;
    
    /// init
    for (int i = 0; i < NUM_PLAYERS; i++) {
        for (int j = 0; j < NUM_SUITS; j++) {
            [playerscards[i][j] removeAllObjects];
        }
    }
    
    for (int i = 0; i < NUM_PLAYERS; i++) {
        [heartsgot[i] removeAllObjects];
    }
    
    [_fourcards removeAllObjects];
    
    int idx = 0;
    for (Card* c in deck) {
        if (c.rank == 2 && c.suit == CLUBS) {
            _firstplay = idx/KING;
        }
        [playerscards[idx/KING][c.suit] addObject:c];
        idx++;
    }
    
    for (int i = 0; i < NUM_SUITS; i++) {
        for (Card* c in playerscards[0][i]) {
            c.faceUp = YES;
        }
    }
    
    ///sort
    [self sortCards];
    
    //[self addCurrentToTotal];
    [self clearCurrentScore];
    _currentstate = STATE_BEGIN;
    _handcnt++;
    _broken = NO;
}

- (void)clearCurrentScore
{
    for (int i = 0; i < NUM_PLAYERS; i++) {
        [_currentscores replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:0]];
    }
}

- (void)addCurrentToTotal
{
    ///
    for (int i = 0; i < NUM_PLAYERS; i++) {
        int curscore = [[_currentscores objectAtIndex:i] integerValue];
        [_totalscores replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:[[_totalscores objectAtIndex:i] integerValue] + curscore]];
        //[_currentscores replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:0]];
    }
}

- (BOOL)check26
{
    BOOL ret = NO;
    for (NSNumber* ns in _currentscores) {
        if ([ns integerValue] == 26) {
            ret = YES;
            break;
        }
    }
    if (ret) {
        for (int i = 0; i < NUM_PLAYERS; i++) {
            int curscore = [[_currentscores objectAtIndex:i] integerValue];
            if (curscore == 26) {
                curscore = 0;
            }
            else
                curscore = 26;
            [_currentscores replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:curscore]];
        }
    }
    return ret;
}

- (void)sortCards
{
    for (int i = 0; i < NUM_PLAYERS; i++) {
        for (int j = 0; j < NUM_SUITS; j++) {
            [playerscards[i][j] sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                Card* c1 = obj1;
                Card* c2 = obj2;
                if (c1.rank == ACE) {
                    return NSOrderedDescending;
                }
                if (c2.rank == ACE) {
                    return NSOrderedAscending;
                }
                if (c1.rank < c2.rank) {
                    return NSOrderedAscending;
                }
                else if (c1.rank > c2.rank)
                {
                    return NSOrderedDescending;
                }
                else
                {
                    return NSOrderedSame;
                }
            }];
        }
    }
}

- (void)freshGame:(NSArray *)winboards {
    // Get new deck from Card class
    BOOL needFlag = YES;
    NSArray* theBoard = nil;
    if (winboards != nil && _boardId < [winboards count]) {
        needFlag = NO;
        theBoard = [winboards objectAtIndex:_boardId];
    }

    NSMutableArray *deck = (NSMutableArray *) [Card deck:theBoard];
    
    [Solitaire shuffleDeck:deck need:needFlag];
    
    _boardId++;
    
    /// init
    for (int i = 0; i < NUM_PLAYERS; i++) {
        for (int j = 0; j < NUM_SUITS; j++) {
            playerscards[i][j] = [[NSMutableArray alloc] init];
        }
    }
    
    for (int i = 0; i < NUM_PLAYERS; i++) {
        heartsgot[i] = [[NSMutableArray alloc] init];
    }
    
    _fourcards = [[NSMutableArray alloc] init];
    
    int idx = 0;
    for (Card* c in deck) {
        if (c.rank == 2 && c.suit == CLUBS) {
            _firstplay = idx/KING;
        }
        [playerscards[idx/KING][c.suit] addObject:c];
        idx++;
    }
    
    for (int i = 0; i < NUM_SUITS; i++) {
        for (Card* c in playerscards[0][i]) {
            c.faceUp = YES;
        }
    }
    
    ///sort
    [self sortCards];
    
    ///
    _totalscores = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], nil];
    _currentscores = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], nil];
    _handcnt = 1;
    _currentstate = STATE_BEGIN;
    self.won = NO;
    _broken = NO;
}

- (BOOL)gameWon {
    for (NSNumber* s in _totalscores) {
        if ([s integerValue] >= 100) {
            return YES;
        }
    }
    ///
    return NO;
}

- (void)positionCard:(Card*)card pos:(NSInteger*)pos idx:(NSInteger*)idx
{

}

- (BOOL)alreadyDone
{
    return NO;
}

- (int)gameOver
{
    NSArray* finalScore = [_totalscores sortedArrayUsingSelector:@selector(compare:)];
    int maxscore = [[finalScore lastObject] integerValue];
    int minscore = [[finalScore objectAtIndex:0] integerValue];
    if (maxscore >= END_SCORE
        && minscore != [[finalScore objectAtIndex:1] integerValue])
    {
        int idx = 0;
        for (NSNumber* ns in _totalscores) {
            if ([ns integerValue] == minscore) {
                return idx;
            }
            idx++;
        }
    }
    return -1;
}

- (NSArray *)playerCards:(uint)i
{
    NSMutableArray* cards = [[NSMutableArray alloc] init];
    for (int j = 0; j < NUM_SUITS; j++) {
        [cards addObjectsFromArray:playerscards[i][j]];
    }
    return cards;
}

- (NSArray *)playerCards:(uint)i suit:(int)suit
{
    return playerscards[i][suit];
}

- (BOOL)isYourCard:(Card*)card
{
    for (int i = 0; i < NUM_SUITS; i++) {
        if ([playerscards[0][i] containsObject:card]) {
            return YES;
        }
    }
    return NO;
}

- (void)selectPassCards
{
    if (_handcnt%4 == 0) {
        return;
    }
    for (int i = 0; i < NUM_PLAYERS; i++) {
        NSMutableArray* cards = [NSMutableArray arrayWithArray:[self playerCards:i]];
        [cards sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Card* c1 = obj1;
            Card* c2 = obj2;
            if (c1.rank == ACE) {
                return NSOrderedDescending;
            }
            if (c2.rank == ACE) {
                return NSOrderedAscending;
            }
            if (c1.rank < c2.rank) {
                return NSOrderedAscending;
            }
            else if (c1.rank > c2.rank)
            {
                return NSOrderedDescending;
            }
            else
            {
                return NSOrderedSame;
            }
        }];
        for (int j = NUM_CARDS_EACH - 3; j < NUM_CARDS_EACH; j++) {
            ((Card*)[cards objectAtIndex:j]).selected = YES;
        }
    }
}

- (void)exchangeCards
{
    NSMutableArray* sel[NUM_PLAYERS];
    for (int i = 0; i < NUM_PLAYERS; i++) {
        sel[i] = [[NSMutableArray alloc] init];
        for (int j = 0; j < NUM_SUITS; j++)
        {
            for (Card* c in playerscards[i][j]) {
                if (c.selected) {
                    [sel[i] addObject:c];
                }
            }
            for (Card* c in sel[i]) {
                [playerscards[i][j] removeObject:c];
            }
        }
    }
    ///
    switch (_handcnt%4) {
        case 0:
            break;
        case 1:
            for (int i = 0; i < NUM_PLAYERS; i++) {
                for (Card* c in sel[i]) {
                    [playerscards[(i+1)%4][c.suit] addObject:c];
                    if ((i+1)%4 == 0) {
                        c.faceUp = YES;
                    }
                    else
                        c.faceUp = NO;
                }
            }
            break;
        case 2:
            for (int i = 0; i < NUM_PLAYERS; i++) {
                for (Card* c in sel[i]) {
                    [playerscards[(i+4-1)%4][c.suit] addObject:c];
                    if ((i+4-1)%4 == 0) {
                        c.faceUp = YES;
                    }
                    else
                        c.faceUp = NO;
                }
            }
            break;
        case 3:
            for (int i = 0; i < NUM_PLAYERS; i++) {
                for (Card* c in sel[i]) {
                    if (i == 0) {
                        [playerscards[2][c.suit] addObject:c];
                        c.faceUp = NO;
                    }
                    else if (i == 2)
                    {
                        [playerscards[0][c.suit] addObject:c];
                        c.faceUp = YES;
                    }
                    else if (i == 1)
                    {
                        [playerscards[3][c.suit] addObject:c];
                        c.faceUp = NO;
                    }
                    else if (i == 3)
                    {
                        [playerscards[1][c.suit] addObject:c];
                        c.faceUp = NO;
                    }
                }
            }
            break;
        default:
            break;
    }
    ///
    [self sortCards];
}

- (void)insertPassCards
{
    for (int i = 0; i < NUM_PLAYERS; i++) {
        for (int j = 0; j < NUM_SUITS; j++) {
            for (Card* c in playerscards[i][j]) {
                c.selected = NO;
            }
        }
    }
}

- (int)whoHasClubs2
{
    for (int i = 0; i < NUM_PLAYERS; i++) {
        if ([playerscards[i][0] count] > 0
            && ((Card*)[playerscards[i][0] objectAtIndex:0]).rank == 2)
        {
            return i;
        }
    }
    return 0;
}

- (int)whoCollect
{
    if ([_fourcards count] != NUM_PLAYERS) {
        return -1;
    }
    int score = 0;
    for (Card* t in _fourcards) {
        if (t.suit == HEARTS) {
            score++;
        }
        else if (t.suit == SPADES
                 && t.rank == QUEEN)
        {
            score += 13;
        }
    }
    Card* firstcard = [_fourcards objectAtIndex:0];
    int maxrank = firstcard.rank;
    int maxi = _firstplay;
    BOOL flag = NO;
    if (maxrank == ACE) {
        int oldscore = [[_currentscores objectAtIndex:_firstplay] integerValue];
        [_currentscores replaceObjectAtIndex:_firstplay withObject:[NSNumber numberWithInt:oldscore+score]];
        return _firstplay;
    }
    for (int i = 1; i < NUM_PLAYERS; i++) {
        Card* c = [_fourcards objectAtIndex:i];
        if (c.suit == firstcard.suit) {
            if (c.rank == ACE)
            {
                int oldscore = [[_currentscores objectAtIndex:(i+_firstplay)%4] integerValue];
                [_currentscores replaceObjectAtIndex:(i+_firstplay)%4 withObject:[NSNumber numberWithInt:oldscore+score]];
                return (i+_firstplay)%4;
            }
            else if (c.rank > maxrank)
            {
                maxrank = c.rank;
                maxi = i;
                flag = YES;
            }
        }
    }
    if (!flag) {
        int oldscore = [[_currentscores objectAtIndex:_firstplay] integerValue];
        [_currentscores replaceObjectAtIndex:_firstplay withObject:[NSNumber numberWithInt:oldscore+score]];
        return _firstplay;
    }
    else
    {
        int oldscore = [[_currentscores objectAtIndex:(maxi+_firstplay)%4] integerValue];
        [_currentscores replaceObjectAtIndex:(maxi+_firstplay)%4 withObject:[NSNumber numberWithInt:oldscore+score]];
        return (maxi+_firstplay)%4;
    }
}

- (BOOL)isYourTurn
{
    if (_firstplay == 0 && _currentstate == STATE_DISCARDONE) {
        return YES;
    }
    else if (_firstplay == 1 && _currentstate == STATE_DISCARDFOUR)
    {
        return YES;
    }
    else if (_firstplay == 2 && _currentstate == STATE_DISCARDTHREE)
    {
        return YES;
    }
    else if (_firstplay == 3 && _currentstate == STATE_DISCARDTWO)
    {
        return YES;
    }
    return NO;
}

- (BOOL)aiDiscard
{
    if ([self isYourTurn]) {
        return NO;
    }
    Card* c;
    int idx = (_firstplay+_currentstate-STATE_DISCARDONE)%4;
    srandom(time(NULL));
    ///
    switch (_currentstate) {
        case STATE_DISCARDONE:
            /// clubs 2
            if ([playerscards[idx][CLUBS] count] > 0
                && (c = [playerscards[idx][CLUBS] objectAtIndex:0]).rank == 2)
            {
                c.faceUp = YES;
                [_fourcards addObject:c];
                [playerscards[idx][CLUBS] removeObject:c];
            }
            ///
            else
            {
                NSMutableArray* candidates = [[NSMutableArray alloc] init];
                for (int i = CLUBS; i <= SPADES; i++) {
                    [candidates addObjectsFromArray:playerscards[idx][i]];
                }
                if (_broken || [candidates count] == 0) {
                    [candidates addObjectsFromArray:playerscards[idx][HEARTS]];
                }
                int cnt = [candidates count];
                c = [candidates objectAtIndex:random()%cnt];
                c.faceUp = YES;
                [_fourcards addObject:c];
                for (int i = 0; i < NUM_SUITS; i++) {
                    if ([playerscards[idx][i] containsObject:c]) {
                        [playerscards[idx][i] removeObject:c];
                        break;
                    }
                }
            }
            _currentstate = STATE_DISCARDTWO;
            break;
        case STATE_DISCARDTWO:
        {
            Card* firstcard = [_fourcards objectAtIndex:0];
            if ([playerscards[idx][firstcard.suit] count] == 0) {
                if ([[self playerCards:idx] count] == KING) {
                    NSMutableArray* candidates = [[NSMutableArray alloc] init];
                    [candidates addObjectsFromArray:playerscards[idx][DIAMONDS]];
                    for (Card* s in playerscards[idx][SPADES]) {
                        if (s.rank != QUEEN) {
                            [candidates addObject:s];
                        }
                    }
                    if ([candidates count] == 0) {
                        [candidates addObjectsFromArray:playerscards[idx][HEARTS]];
                    }
                    int cnt = [candidates count];
                    c = [candidates objectAtIndex:random()%cnt];
                    c.faceUp = YES;
                    [_fourcards addObject:c];
                    for (int i = 0; i < NUM_SUITS; i++) {
                        if ([playerscards[idx][i] containsObject:c]) {
                            [playerscards[idx][i] removeObject:c];
                            break;
                        }
                    }
                    if (c.suit == HEARTS) {
                        _broken = YES;
                    }
                }
                else
                {
                    BOOL queen = NO;
                    for (Card* t in playerscards[idx][SPADES]) {
                        if (t.rank == QUEEN) {
                            c = t;
                            queen = YES;
                            break;
                        }
                    }
                    if (queen && [[_currentscores objectAtIndex:idx] integerValue] < 3) {
                        c.faceUp = YES;
                        [_fourcards addObject:c];
                        [playerscards[idx][SPADES] removeObject:c];
                    }
                    else if ([playerscards[idx][HEARTS] count] > 0
                             && [[_currentscores objectAtIndex:idx] integerValue] < 3)
                    {
                        c = [playerscards[idx][HEARTS] lastObject];
                        c.faceUp = YES;
                        [_fourcards addObject:c];
                        [playerscards[idx][HEARTS] removeObject:c];
                        if (!_broken) {
                            _broken = YES;
                        }
                    }
                    else
                    {
                        NSArray* cs = [self playerCards:idx];
                        c = [cs objectAtIndex:random()%[cs count]];
                        c.faceUp = YES;
                        [_fourcards addObject:c];
                        for (int i = 0; i < NUM_SUITS; i++) {
                            if ([playerscards[idx][i] containsObject:c]) {
                                [playerscards[idx][i] removeObject:c];
                                break;
                            }
                        }
                    }
                }
            }
            else
            {
                if ([[_currentscores objectAtIndex:idx] integerValue] == 0) {
                    c = [playerscards[idx][firstcard.suit] objectAtIndex:0];
                }
                else if ([[_currentscores objectAtIndex:idx] integerValue] > 10) {
                    c = [playerscards[idx][firstcard.suit] lastObject];
                }
                else
                {
                    c = [playerscards[idx][firstcard.suit] objectAtIndex:random()%[playerscards[idx][firstcard.suit] count]];
                }
                c.faceUp = YES;
                [_fourcards addObject:c];
                [playerscards[idx][firstcard.suit] removeObject:c];
            }
            _currentstate = STATE_DISCARDTHREE;
        }
            break;
        case STATE_DISCARDTHREE:
        {
            Card* firstcard = [_fourcards objectAtIndex:0];
            if ([playerscards[idx][firstcard.suit] count] == 0) {
                if ([[self playerCards:idx] count] == KING) {
                    NSMutableArray* candidates = [[NSMutableArray alloc] init];
                    [candidates addObjectsFromArray:playerscards[idx][DIAMONDS]];
                    for (Card* s in playerscards[idx][SPADES]) {
                        if (s.rank != QUEEN) {
                            [candidates addObject:s];
                        }
                    }
                    if ([candidates count] == 0) {
                        [candidates addObjectsFromArray:playerscards[idx][HEARTS]];
                    }
                    int cnt = [candidates count];
                    c = [candidates objectAtIndex:random()%cnt];
                    c.faceUp = YES;
                    [_fourcards addObject:c];
                    for (int i = 0; i < NUM_SUITS; i++) {
                        if ([playerscards[idx][i] containsObject:c]) {
                            [playerscards[idx][i] removeObject:c];
                            break;
                        }
                    }
                    if (c.suit == HEARTS) {
                        _broken = YES;
                    }
                }
                else
                {
                    BOOL queen = NO;
                    for (Card* t in playerscards[idx][SPADES]) {
                        if (t.rank == QUEEN) {
                            c = t;
                            queen = YES;
                            break;
                        }
                    }
                    if (queen
                        && [[_currentscores objectAtIndex:idx] integerValue] < 3) {
                        c.faceUp = YES;
                        [_fourcards addObject:c];
                        [playerscards[idx][SPADES] removeObject:c];
                    }
                    else if ([playerscards[idx][HEARTS] count] > 0
                             && [[_currentscores objectAtIndex:idx] integerValue] < 3)
                    {
                        c = [playerscards[idx][HEARTS] lastObject];
                        c.faceUp = YES;
                        [_fourcards addObject:c];
                        [playerscards[idx][HEARTS] removeObject:c];
                        if (!_broken) {
                            _broken = YES;
                        }
                    }
                    else
                    {
                        NSArray* cs = [self playerCards:idx];
                        c = [cs objectAtIndex:random()%[cs count]];
                        c.faceUp = YES;
                        [_fourcards addObject:c];
                        for (int i = 0; i < NUM_SUITS; i++) {
                            if ([playerscards[idx][i] containsObject:c]) {
                                [playerscards[idx][i] removeObject:c];
                                break;
                            }
                        }
                    }
                }
            }
            else
            {
                if ([[_currentscores objectAtIndex:idx] integerValue] == 0) {
                    c = [playerscards[idx][firstcard.suit] objectAtIndex:0];
                }
                else if ([[_currentscores objectAtIndex:idx] integerValue] > 10) {
                    c = [playerscards[idx][firstcard.suit] lastObject];
                }
                else
                {
                    c = [playerscards[idx][firstcard.suit] objectAtIndex:random()%[playerscards[idx][firstcard.suit] count]];
                }
                c.faceUp = YES;
                [_fourcards addObject:c];
                [playerscards[idx][firstcard.suit] removeObject:c];
            }
            _currentstate = STATE_DISCARDFOUR;
        }
            break;
        case STATE_DISCARDFOUR:
        {
            Card* firstcard = [_fourcards objectAtIndex:0];
            if ([playerscards[idx][firstcard.suit] count] == 0) {
                if ([[self playerCards:idx] count] == KING) {
                    NSMutableArray* candidates = [[NSMutableArray alloc] init];
                    [candidates addObjectsFromArray:playerscards[idx][DIAMONDS]];
                    for (Card* s in playerscards[idx][SPADES]) {
                        if (s.rank != QUEEN) {
                            [candidates addObject:s];
                        }
                    }
                    if ([candidates count] == 0) {
                        [candidates addObjectsFromArray:playerscards[idx][HEARTS]];
                    }
                    int cnt = [candidates count];
                    c = [candidates objectAtIndex:random()%cnt];
                    c.faceUp = YES;
                    [_fourcards addObject:c];
                    for (int i = 0; i < NUM_SUITS; i++) {
                        if ([playerscards[idx][i] containsObject:c]) {
                            [playerscards[idx][i] removeObject:c];
                            break;
                        }
                    }
                    if (c.suit == HEARTS) {
                        _broken = YES;
                    }
                }
                else
                {
                    BOOL queen = NO;
                    for (Card* t in playerscards[idx][SPADES]) {
                        if (t.rank == QUEEN) {
                            c = t;
                            queen = YES;
                            break;
                        }
                    }
                    if (queen
                        && [[_currentscores objectAtIndex:idx] integerValue] < 3) {
                        c.faceUp = YES;
                        [_fourcards addObject:c];
                        [playerscards[idx][SPADES] removeObject:c];
                    }
                    else if ([playerscards[idx][HEARTS] count] > 0
                             && [[_currentscores objectAtIndex:idx] integerValue] < 3)
                    {
                        c = [playerscards[idx][HEARTS] lastObject];
                        c.faceUp = YES;
                        [_fourcards addObject:c];
                        [playerscards[idx][HEARTS] removeObject:c];
                        if (!_broken) {
                            _broken = YES;
                        }
                    }
                    else
                    {
                        NSArray* cs = [self playerCards:idx];
                        c = [cs objectAtIndex:random()%[cs count]];
                        c.faceUp = YES;
                        [_fourcards addObject:c];
                        for (int i = 0; i < NUM_SUITS; i++) {
                            if ([playerscards[idx][i] containsObject:c]) {
                                [playerscards[idx][i] removeObject:c];
                                break;
                            }
                        }
                    }
                }
            }
            else
            {
                if ([[_currentscores objectAtIndex:idx] integerValue] == 0) {
                    c = [playerscards[idx][firstcard.suit] objectAtIndex:0];
                }
                else if ([[_currentscores objectAtIndex:idx] integerValue] > 10) {
                    c = [playerscards[idx][firstcard.suit] lastObject];
                }
                else
                {
                    c = [playerscards[idx][firstcard.suit] objectAtIndex:random()%[playerscards[idx][firstcard.suit] count]];
                }
                c.faceUp = YES;
                [_fourcards addObject:c];
                [playerscards[idx][firstcard.suit] removeObject:c];
            }
            _currentstate = STATE_COLLECTCARD;
        }
            break;
        default:
            break;
    }
    return YES;
}

- (void)discardYourCard:(Card*)card
{
    if (!_broken && card.suit == HEARTS) {
        _broken = YES;
    }
    [_fourcards addObject:card];
    for (int i = 0; i < NUM_SUITS; i++) {
        if ([playerscards[0][i] containsObject:card]) {
            [playerscards[0][i] removeObject:card];
            break;
        }
    }
    if (_currentstate == STATE_DISCARDFOUR)
    {
        _currentstate = STATE_COLLECTCARD;
    }
    else
    {
        _currentstate += 1;
    }
}

- (NSArray*)yourCanDiscards
{
    NSMutableArray* candidates = [[NSMutableArray alloc] init];
    if (_firstplay == 0)
    {
        if ([[self playerCards:0] count] == KING)
            [candidates addObject:[playerscards[0][CLUBS] objectAtIndex:0]];
        else
        {
            for (int i = CLUBS; i <= SPADES; i++) {
                [candidates addObjectsFromArray:playerscards[0][i]];
            }
            if (_broken) {
                [candidates addObjectsFromArray:playerscards[0][HEARTS]];
            }
        }
    }
    else
    {
        Card* fc = [_fourcards objectAtIndex:0];
        if ([playerscards[0][fc.suit] count] > 0) {
            [candidates addObjectsFromArray:playerscards[0][fc.suit]];
        }
        else
        {
            if ([[self playerCards:0] count] == KING) {
                for (Card* t in [self playerCards:0]) {
                    if (t.suit == HEARTS
                        || (t.suit == SPADES && t.rank == QUEEN)) {
                        ;
                    }
                    else
                        [candidates addObject:t];
                }
                if ([candidates count] == 0) {
                    [candidates addObjectsFromArray:[self playerCards:0]];
                }
            }
            else
            {
                for (int i = CLUBS; i <= HEARTS; i++) {
                    [candidates addObjectsFromArray:playerscards[0][i]];
                }
            }
        }
    }
    return candidates;
}

- (BOOL)discardingState
{
    if (_currentstate >= STATE_DISCARDONE
        && _currentstate <= STATE_DISCARDFOUR) {
        return YES;
    }
    return NO;
}

@end
