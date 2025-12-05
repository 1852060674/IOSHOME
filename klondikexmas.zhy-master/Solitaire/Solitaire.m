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

@implementation Solitaire {
    NSMutableArray *stock_;
    NSMutableArray *waste_;
    NSMutableArray *foundation_[NUM_FOUNDATIONS];
    NSMutableArray *tableau_[NUM_TABLEAUS];
    
    NSMutableArray *stock_bk;
    NSMutableArray *tableau_bk[NUM_TABLEAUS];
    
    /// move stack for undo
    NSMutableArray *undo_; 
}

@synthesize times = _times;
@synthesize scores = _scores;
@synthesize moves = _moves;
@synthesize tiles = _tiles;
@synthesize undos = _undos;
@synthesize won = _won;
@synthesize draw3 = _draw3;
@synthesize firstAuto = _firstAuto;
@synthesize board1Id = _board1Id;
@synthesize board3Id = _board3Id;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:stock_ forKey:@"stock"];
    [aCoder encodeObject:waste_ forKey:@"waste"];
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        [aCoder encodeObject:foundation_[i] forKey:[NSString stringWithFormat:@"foundation_%d",i]];
    }
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        [aCoder encodeObject:tableau_[i] forKey:[NSString stringWithFormat:@"tableaus_%d",i]];
    }
    [aCoder encodeObject:stock_bk forKey:@"stockbk"];
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        [aCoder encodeObject:tableau_bk[i] forKey:[NSString stringWithFormat:@"tableausbk_%d",i]];
    }
    [aCoder encodeObject:undo_ forKey:@"undo"];
    //[aCoder encodeBool:_draw3 forKey:@"draw3"];
    [aCoder encodeInteger:_times forKey:@"times"];
    [aCoder encodeInteger:_scores forKey:@"scores"];
    [aCoder encodeInteger:_moves forKey:@"moves"];
    [aCoder encodeInteger:_tiles forKey:@"tiles"];
    [aCoder encodeInteger:_undos forKey:@"undos"];
    [aCoder encodeBool:_won forKey:@"won"];
    [aCoder encodeBool:_firstAuto forKey:@"firstauto"];
    [aCoder encodeInteger:_board1Id forKey:@"board1id"];
    [aCoder encodeInteger:_board3Id forKey:@"board3id"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        stock_ = [aDecoder decodeObjectForKey:@"stock"];
        waste_ = [aDecoder decodeObjectForKey:@"waste"];
        for (int i = 0; i < NUM_FOUNDATIONS; i++) {
            foundation_[i] = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"foundation_%d",i]];
        }
        for (int i = 0; i < NUM_TABLEAUS; i++) {
            tableau_[i] = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"tableaus_%d",i]];
        }
        stock_bk = [aDecoder decodeObjectForKey:@"stockbk"];
        for (int i = 0; i < NUM_TABLEAUS; i++) {
            tableau_bk[i] = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"tableausbk_%d",i]];
        }
        undo_ = [aDecoder decodeObjectForKey:@"undo"];
        //_draw3 = [aDecoder decodeBoolForKey:@"draw3"];
        _times = [aDecoder decodeIntegerForKey:@"times"];
        _scores = [aDecoder decodeIntegerForKey:@"scores"];
        _moves = [aDecoder decodeIntegerForKey:@"moves"];
        _tiles = [aDecoder decodeIntegerForKey:@"tiles"];
        _undos = [aDecoder decodeIntegerForKey:@"undos"];
        _won = [aDecoder decodeBoolForKey:@"won"];
        _firstAuto = [aDecoder decodeBoolForKey:@"firstauto"];
        _board1Id = [aDecoder decodeIntegerForKey:@"board1id"];
        _board3Id = [aDecoder decodeIntegerForKey:@"board3id"];
    }
    return self;
}

- (id)init:(NSArray *)winboards {
    self = [super init];
    if (self) {
        [self freshGame:winboards];
        //_draw3 = YES;
        _board1Id = 0;
        _board3Id = 0;
    }
    return self;

}

- (NSInteger)drawCnt
{
    if (_draw3) {
        return 3;
    }
    else
    {
        return 1;
    }
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

- (NSArray *)foundationWithCard:(Card *)card {
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        if ([foundation_[i] containsObject:card]) {
            return foundation_[i];
        }
    }
    return nil;
}

- (NSArray *)tableauWithCard:(Card *)card {
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([tableau_[i] containsObject:card]) {
            return tableau_[i];
        }
    }
    return nil;
}

// Find the tableau or foundation with the card
- (NSArray *)stackWithCard:(Card *)card {
    NSArray *stack = [self foundationWithCard:card];
    if (nil == stack) {
        stack = [self tableauWithCard:card];
    }
    if (nil == stack && [waste_ lastObject] == card) {
        stack = waste_;
    }
    return stack;
}

- (void)freshGame:(NSArray *)winboards {
    // Get new deck from Card class
    BOOL needFlag = YES;
    NSArray* theBoard = nil;
    if (winboards != nil && _draw3 && _board3Id < [winboards count]/2) {
        needFlag = NO;
        theBoard = [winboards objectAtIndex:_board3Id+[winboards count]/2];
    }
    else if (winboards != nil && _draw3 == NO && _board1Id < [winboards count]/2)
    {
        needFlag = NO;
        theBoard = [winboards objectAtIndex:_board1Id];
    }
    NSMutableArray *deck = (NSMutableArray *) [Card deck:theBoard];
    
    [Solitaire shuffleDeck:deck need:needFlag];
    
    if (_draw3) {
        _board3Id++;
    }
    else
        _board1Id++;
    
    // Initialize Stock, Waste, Foundation
    stock_ = [[NSMutableArray alloc] init];
    waste_ = [[NSMutableArray alloc] init];
    stock_bk = [[NSMutableArray alloc] init];
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        foundation_[i] = [[NSMutableArray alloc] init];
    }
    
    // Initialize Tableau and take cards from the deck to Tableau
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        tableau_[i] = [[NSMutableArray alloc] init];
        tableau_bk[i] = [[NSMutableArray alloc] init];
        for (int j = 0; j <= i; j++) {
            [tableau_[i] addObject:[deck objectAtIndex:0]];
            [tableau_bk[i] addObject:[deck objectAtIndex:0]];
            [deck removeObjectAtIndex:0];
        }
        // Flip top card of Tableaux
        Card *c = [tableau_[i] lastObject];
        c.faceUp = YES;
    }
    
    // Place remaining cards in deck to the stock
    [stock_ addObjectsFromArray:deck];
    [stock_bk addObjectsFromArray:deck];
    
    // undo
    undo_ = [[NSMutableArray alloc] init];
    
    ///
    self.scores = 0;
    self.times = 0;
    self.moves = 0;
    self.tiles = 0;
    self.undos = 0;
    self.won = NO;
    self.firstAuto = YES;
}

- (void)replayGame {
    
    [waste_ removeAllObjects];
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        [foundation_[i] removeAllObjects];
    }
    
    // Initialize Tableau and take cards from the deck to Tableau
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        [tableau_[i] removeAllObjects];
        [tableau_[i] addObjectsFromArray:tableau_bk[i]];
        for (Card* c in tableau_[i]) {
            c.faceUp = NO;
        }
        // Flip top card of Tableaux
        Card *c = [tableau_[i] lastObject];
        c.faceUp = YES;
    }
    
    // Place remaining cards in deck to the stock
    [stock_ removeAllObjects];
    [stock_ addObjectsFromArray:stock_bk];
    for (Card* c in stock_) {
        c.faceUp = NO;
    }
    
    // undo
    [undo_ removeAllObjects];
    
    ///
    self.scores = 0;
    self.times = 0;
    self.moves = 0;
    self.tiles = 0;
    self.won = NO;
    self.firstAuto = YES;
}

- (BOOL)gameWon {
    /*
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        if ([foundation_[i] count] < NUM_RANKS) {
            return NO;
        }
    }
    return YES;
     */
    if ([stock_ count] > 0) {
        return NO;
    }
    if ([waste_ count] > 1) {
        return NO;
    }
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([tableau_[i] count] > 0
            && ((Card*)[tableau_[i] objectAtIndex:0]).faceUp == NO) {
            return NO;
        }
    }
    ///
    return YES;
}

- (NSArray *)stock {
    return stock_;
}

- (NSArray *)waste {
    return waste_;
}

- (NSArray *)foundation:(uint)i {
    return foundation_[i];
}

- (NSArray *)tableau:(uint)i {
    return tableau_[i];
}

- (NSArray *)fanBeginningWithCard:(Card *)card {
    NSArray *fan = nil;
    NSArray *tab = [self stackWithCard:card];;
    
    // Return nil if card not face up 
    // Get the tableau that contains the card
    if (card.faceUp && nil != tab) {
        int index = [tab indexOfObject:card]; // Get index
        NSRange range = NSMakeRange(index, [tab count] - index); // Get Range from index to end of array
        return [tab subarrayWithRange:range]; // Return array
    }
    
    // No tableau with card
    return fan;
}

- (BOOL)canDropCard:(Card *)card onFoundation:(int)i {
    // Empty Foundation && card == ace
    if ( [card rank] == ACE && [foundation_[i] count] == 0 )
        return YES;
    // Card 1 greater than foundation card && suits match
    if ([foundation_[i] count] > 0 && [card suit] == [[foundation_[i] lastObject] suit] && [card rank] - 1 == [[foundation_[i] lastObject] rank] )
        return YES;
    return NO;
}

- (void)didDropCard:(Card *)card onFoundation:(int)i {
    NSMutableArray *stack = (NSMutableArray *) [self stackWithCard:card];
    [foundation_[i] addObject:card]; // Move to foundation
    [stack removeObject:card]; // Remove from stack
//    if ([stack count] > 0)
//        ((Card *) [stack lastObject]).faceUp = YES;
}

- (BOOL)canDropCard:(Card *)card onTableau:(int)i {
    if (card == nil) {
        return NO;
    }
    // Tableau is empty and card is a king
    if ( [card rank] == KING && [tableau_[i] count] == 0 )
        return YES;
    // Card is one less than last tableau card and suits do not match
    if ( ![card isSameColor:[tableau_[i] lastObject]] && [card rank] + 1 == [[tableau_[i] lastObject] rank] ) 
        return YES;
    return NO;
}

- (void)didDropCard:(Card *)card onTableau:(int)i {
    NSMutableArray *stack = (NSMutableArray *) [self stackWithCard:card]; // Get the stack that contains card
    [tableau_[i] addObject:card]; // Add card to tableau
    [stack removeObject:card]; // remove card from stack
    if ([stack count] > 0)
        ((Card *) [stack lastObject]).faceUp = YES; // Flip last object (waste or tableau)
}

- (BOOL)canDropFan:(NSArray *)cards onTableau:(int)i {
    return [self canDropCard:[cards objectAtIndex:0] onTableau:i];
}

- (void)didDropFan:(NSArray *)cards onTableau:(int)i {
    // Remove fan from old tableau
    NSMutableArray *oldTab =  (NSMutableArray *) [self stackWithCard:[cards objectAtIndex:0]];
    [oldTab removeObjectsInArray:cards];
     
    // Add fan to new tableau
    [tableau_[i] addObjectsFromArray:cards];
}

- (BOOL)canFlipCard:(Card *)card {
    NSArray *tab = [self tableauWithCard:card]; // Get the tableau that contains the card
    if ( nil != tab && [tab lastObject] == card )
        return YES;
    return NO;
}

- (void)didFlipCard:(Card *)card {
    ((Card *) [[self tableauWithCard:card] lastObject]).faceUp = YES;
}

- (BOOL)canDealCard { 
    return [stock_ count] > 0;
}

- (void)didDealCard { // Move top card from stock to waste  
    // Move card from stock to waste
    int loopcnt = 1;
    if (_draw3) {
        loopcnt = 3;
    }
    for (int i = 0; i < loopcnt; i++) {
        if (![self canDealCard]) {
            break;
        }
        Card *c = [stock_ objectAtIndex:0];
        c.faceUp = YES;
        [waste_ addObject:c];
        [stock_ removeObject:c];
    }
}

- (void)collectWasteCardsIntoStock {
    if ([self canDealCard]) {
        [NSException raise:@"Stock Not Empty" format:@"Stock pile is not empty"];
    } else {
        // Remove waste card from faceup set
        int cnt = [waste_ count];
        for (int i = 0; i < cnt; i++) {
            Card *c = (Card*)[waste_ objectAtIndex:i];
            c.faceUp = NO;
            [stock_ addObject:c];
            //[waste_ removeObject:c];
        }
        [waste_ removeAllObjects];
    }
}

- (void)pushAction:(NSArray*)action
{
    [undo_ addObject:action];
}

- (NSArray*)undoAction
{
    NSMutableArray* topCards = [[NSMutableArray alloc] init];
    if ([undo_ count] <= 0) {
        return topCards;
    }
    NSArray* lastAction = [undo_ lastObject];
    int count = [lastAction count];
    for (int i = count - 1; i >= 0; i--) {
        MoveAction* action = [lastAction objectAtIndex:i];
        if (action.act == ACTION_FACEUP) {
            if (action.from == POS_TABEAU) {
                [topCards addObject:[tableau_[action.fromIdx] lastObject]];
                ((Card*)[tableau_[action.fromIdx] lastObject]).faceUp = NO;
            }
        }
        else if (action.act == ACTION_MOVE)
        {
            if (action.from == POS_TABEAU) {
                switch (action.to) {
                    case POS_TABEAU:
                        for (int j = 0; j < action.cardcnt; j++) {
                            /// bug fix
                            Card* c = [tableau_[action.toIdx] objectAtIndex:[tableau_[action.toIdx] count] - (action.cardcnt-j)];
                            [topCards addObject:c];
                            [tableau_[action.fromIdx] addObject:c];
                            [tableau_[action.toIdx] removeObject:c];
                            /// bug
                            //[topCards addObject:[tableau_[action.toIdx] lastObject]];
                            //[tableau_[action.fromIdx] addObject:[tableau_[action.toIdx] lastObject]];
                            //[tableau_[action.toIdx] removeLastObject];
                        }
                        break;
                    case POS_FOUNDATION:
                        [topCards addObject:[foundation_[action.toIdx] lastObject]];
                        [tableau_[action.fromIdx] addObject:[foundation_[action.toIdx] lastObject]];
                        [foundation_[action.toIdx] removeLastObject];
                        break;
                    default:
                        break;
                }
            }
            else if (action.from == POS_FOUNDATION)
            {
                switch (action.to) {
                    case POS_FOUNDATION:
                        [topCards addObject:[foundation_[action.toIdx] lastObject]];
                        [foundation_[action.fromIdx] addObject:[foundation_[action.toIdx] lastObject]];
                        [foundation_[action.toIdx] removeLastObject];
                        break;
                    case POS_TABEAU:
                        [topCards addObject:[tableau_[action.toIdx] lastObject]];
                        [foundation_[action.fromIdx] addObject:[tableau_[action.toIdx] lastObject]];
                        [tableau_[action.toIdx] removeLastObject];
                        break;
                    default:
                        break;
                }
            }
            else if (action.from == POS_STOCK)
            {
                switch (action.to) {
                    case POS_WASTE:
                        for (int j = 0; j < action.cardcnt; j++) {
                            [topCards addObject:[waste_ lastObject]];
                            //[stock_ addObject:[waste_ lastObject]];
                            //((Card*)[stock_ lastObject]).faceUp = NO;
                            [stock_ insertObject:[waste_ lastObject] atIndex:0];
                            ((Card*)[stock_ objectAtIndex:0]).faceUp = NO;
                            [waste_ removeLastObject];
                        }
                        break;
                        
                    default:
                        break;
                }
            }
            else if (action.from == POS_WASTE)
            {
                switch (action.to) {
                    case POS_FOUNDATION:
                        [topCards addObject:[foundation_[action.toIdx] lastObject]];
                        [waste_ addObject:[foundation_[action.toIdx] lastObject]];
                        [foundation_[action.toIdx] removeLastObject];
                        break;
                    case POS_TABEAU:
                        [topCards addObject:[tableau_[action.toIdx] lastObject]];
                        [waste_ addObject:[tableau_[action.toIdx] lastObject]];
                        [tableau_[action.toIdx] removeLastObject];
                        break;
                    case POS_STOCK:
                        [topCards addObjectsFromArray:stock_];
                        [waste_ addObjectsFromArray:stock_];
                        [stock_ removeAllObjects];
                        for (Card* c in waste_) {
                            c.faceUp = YES;
                        }
                        break;
                    default:
                        break;
                }
            }
        }
    }
    /// pop action
    [undo_ removeLastObject];
    ///
    _undos++;
    ///
    return topCards;
}

- (void)positionCard:(Card*)card pos:(NSInteger*)pos idx:(NSInteger*)idx
{
    if ([waste_ containsObject:card]) {
        *pos = POS_WASTE;
        *idx = 0;
    }
    else if ([stock_ containsObject:card])
    {
        *pos = POS_STOCK;
        *idx = 0;
    }
    else
    {
        for (int i = 0; i < NUM_FOUNDATIONS; i++) {
            if ([foundation_[i] containsObject:card]) {
                *pos = POS_FOUNDATION;
                *idx = i;
                break;
            }
        }
        for (int i = 0; i < NUM_TABLEAUS; i++) {
            if ([tableau_[i] containsObject:card]) {
                *pos = POS_TABEAU;
                *idx = i;
                break;
            }
        }
    }
}

- (BOOL)canUndo
{
    if ([undo_ count] > 0) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSArray*)hintActions
{
    NSMutableArray* hints = [[NSMutableArray alloc] init];
    /// A
    if ([waste_ count] > 0
        && ((Card*)[waste_ lastObject]).rank == ACE) {
        for (int i = 0; i < NUM_FOUNDATIONS; i++) {
            if ([foundation_[i] count] > 0) {
                continue;
            }
            [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_WASTE to:POS_FOUNDATION cardcnt:1 fromIdx:0 toIdx:i]];
            break;
        }
    }
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([tableau_[i] count] == 0) {
            continue;
        }
        Card* t = [tableau_[i] lastObject];
        if (t.rank == ACE) {
            for (int j = 0; j < NUM_FOUNDATIONS; j++) {
                if ([foundation_[i] count] > 0) {
                    continue;
                }
                [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_TABEAU to:POS_FOUNDATION cardcnt:1 fromIdx:i toIdx:j]];
                break;
            }
        }
    }
    /// to foundation
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        if ([foundation_[i] count] == 0) {
            continue;
        }
        else
        {
            Card* c = [foundation_[i] lastObject];
            if ([waste_ count] > 0) {
                Card* w = [waste_ lastObject];
                if (w.suit == c.suit && w.rank == c.rank+1) {
                    [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_WASTE to:POS_FOUNDATION cardcnt:1 fromIdx:0 toIdx:i]];
                }
            }
            for (int j = 0; j < NUM_TABLEAUS; j++) {
                if ([tableau_[j] count] <= 0) {
                    continue;
                }
                Card* t = [tableau_[j] lastObject];
                if (t.suit == c.suit && t.rank == c.rank+1) {
                    [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_TABEAU to:POS_FOUNDATION cardcnt:1 fromIdx:j toIdx:i]];
                }
            }
        }
    }
    /// to tabeau
    for (int i = 0; i < NUM_TABLEAUS; i++)
    {
        if ([tableau_[i] count] == 0)
        {
            if ([waste_ count] > 0
                && ((Card*)[waste_ lastObject]).rank == KING)
            {
                [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_WASTE to:POS_TABEAU cardcnt:1 fromIdx:0 toIdx:i]];
            }
            for (int j = 0; j < NUM_TABLEAUS; j++)
            {
                if (i == j) {
                    continue;
                }
                for (int k = 0; k < [tableau_[j] count]; k++)
                {
                    Card* t = [tableau_[j] objectAtIndex:k];
                    if (k != 0
                        && t.faceUp
                        && t.rank == KING)
                    {
                        [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_TABEAU to:POS_TABEAU cardcnt:[tableau_[j] count]-k fromIdx:j toIdx:i]];
                    }
                }
            }
        }
        else
        {
            Card* c = [tableau_[i] lastObject];
            if ([waste_ count] > 0)
            {
                Card* w = [waste_ lastObject];
                if (w.rank + 1 == c.rank
                    && ![w isSameColor:c])
                {
                    [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_WASTE to:POS_TABEAU cardcnt:1 fromIdx:0 toIdx:i]];
                }
            }
            for (int j = 0; j < NUM_TABLEAUS; j++)
            {
                if (i == j) {
                    continue;
                }
                for (int k = 0; k < [tableau_[j] count]; k++)
                {
                    Card* t = [tableau_[j] objectAtIndex:k];
                    if (t.faceUp
                        && t.rank + 1 == c.rank
                        && ![t isSameColor:c])
                    {
                        [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_TABEAU to:POS_TABEAU cardcnt:[tableau_[j] count]-k fromIdx:j toIdx:i]];
                    }
                }
            }
        }
    }
    ///
    return hints;
}

- (NSArray*)autoAction:(Card*)card
{
    NSMutableArray* topcards = [[NSMutableArray alloc] init];
    NSArray* fan = [self fanBeginningWithCard:card];
    if (fan == nil) {
        return topcards;
    }
    if ([stock_ containsObject:card]) {
        return topcards;
    }
    int from = -1;
    int fromIdx = -1;
    if ([waste_ containsObject:card]) {
        from = POS_WASTE;
        fromIdx = 0;
    }
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        if ([foundation_[i] containsObject:card]) {
            from = POS_FOUNDATION;
            fromIdx = i;
        }
    }
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([tableau_[i] containsObject:card])
        {
            from = POS_TABEAU;
            fromIdx = i;
        }
    }
    if (fromIdx == -1
        || from == -1) {
        return topcards;
    }
    ///
    NSMutableArray* theAction = [[NSMutableArray alloc] init];
    ///
    if ([fan count] == 1) {
        for (int i = 0; i < NUM_FOUNDATIONS; i++) {
            if ([self canDropCard:card onFoundation:i]) {
                [self didDropCard:card onFoundation:i];
                [theAction addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:from to:POS_FOUNDATION cardcnt:[fan count] fromIdx:fromIdx toIdx:i]];
                if (from == POS_TABEAU
                    && [tableau_[fromIdx] count] > 0
                    && !((Card*)[tableau_[fromIdx] lastObject]).faceUp) {
                    ((Card*)[tableau_[fromIdx] lastObject]).faceUp = YES;
                    [theAction addObject:[[MoveAction alloc] initWithAct:ACTION_FACEUP from:from to:from cardcnt:1 fromIdx:fromIdx toIdx:fromIdx]];
                    [topcards addObject:[tableau_[fromIdx] lastObject]];
                }
                [topcards addObjectsFromArray:fan];
                [undo_ addObject:theAction];
                if (from != POS_FOUNDATION) {
                    self.scores += 10;
                }
                return topcards;
            }
        }
    }
    ///
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([self canDropFan:fan onTableau:i]) {
            [self didDropFan:fan onTableau:i];
            [theAction addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:from to:POS_TABEAU cardcnt:[fan count] fromIdx:fromIdx toIdx:i]];
            if (from == POS_TABEAU
                && [tableau_[fromIdx] count] > 0
                && !((Card*)[tableau_[fromIdx] lastObject]).faceUp) {
                ((Card*)[tableau_[fromIdx] lastObject]).faceUp = YES;
                [theAction addObject:[[MoveAction alloc] initWithAct:ACTION_FACEUP from:from to:from cardcnt:1 fromIdx:fromIdx toIdx:fromIdx]];
                [topcards addObject:[tableau_[fromIdx] lastObject]];
            }
            [topcards addObjectsFromArray:fan];
            [undo_ addObject:theAction];
            if (from == POS_FOUNDATION) {
                self.scores -= 15;
            }
            else
                self.scores += 5;
            return topcards;
        }
    }
    ///
    return topcards;
}

- (NSInteger)cardsLeftCnt
{
    int cnt = 0;
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        cnt += [foundation_[i] count];
    }
    return 52 - cnt;
}

- (NSArray*)completeEach
{
    NSMutableArray* topcards = [[NSMutableArray alloc] init];
    NSMutableArray* theAction = [[NSMutableArray alloc] init];
    int toIdx = -1;
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([tableau_[i] count] > 0) {
            Card* t = [tableau_[i] lastObject];
            if (t.rank == ACE) {
                for (int j = 0; j < NUM_FOUNDATIONS; j++) {
                    if ([foundation_[j] count] == 0) {
                        toIdx = j;
                        break;
                    }
                }
            }
            else
            {
                for (int j = 0; j < NUM_FOUNDATIONS; j++) {
                    if ([foundation_[j] count] > 0) {
                        Card* f = [foundation_[j] lastObject];
                        if (f.rank + 1 == t.rank && f.suit == t.suit) {
                            toIdx = j;
                            break;
                        }
                    }
                }
            }
            if (toIdx != -1) {
                [theAction addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_TABEAU to:POS_FOUNDATION cardcnt:1 fromIdx:i toIdx:toIdx]];
                [undo_ addObject:theAction];
                [self didDropCard:t onFoundation:toIdx];
                self.scores += 10;
                [topcards addObject:t];
                return topcards;
            }
        }
    }
    if ([waste_ count] > 0) {
        Card* w = [waste_ lastObject];
        if (w.rank == ACE) {
            for (int j = 0; j < NUM_FOUNDATIONS; j++) {
                if ([foundation_[j] count] == 0) {
                    toIdx = j;
                    break;
                }
            }
        }
        else
        {
            for (int j = 0; j < NUM_FOUNDATIONS; j++) {
                if ([foundation_[j] count] > 0) {
                    Card* f = [foundation_[j] lastObject];
                    if (f.rank + 1 == w.rank && f.suit == w.suit) {
                        toIdx = j;
                        break;
                    }
                }
            }
        }
        if (toIdx != -1) {
            [theAction addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_WASTE to:POS_FOUNDATION cardcnt:1 fromIdx:0 toIdx:toIdx]];
            [undo_ addObject:theAction];
            [self didDropCard:w onFoundation:toIdx];
            self.scores += 10;
            [topcards addObject:w];
            return topcards;
        }
    }
    ///
return topcards;
}

- (BOOL)alreadyDone
{
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        if ([foundation_[i] count] == 0) {
            return NO;
        }
        else if (((Card*)[foundation_[i] lastObject]).rank != KING)
        {
            return NO;
        }
    }
    return YES;
}

@end
