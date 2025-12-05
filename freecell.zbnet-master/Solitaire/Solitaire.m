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
    NSMutableArray *stock_[NUM_STOCKS];
    NSMutableArray *foundation_[NUM_FOUNDATIONS];
    NSMutableArray *tableau_[NUM_TABLEAUS];
    
    NSMutableArray *tableau_bk[NUM_TABLEAUS];
    
    /// move stack for undo
    NSMutableArray *undo_;
    
    BOOL firstInn;
}

@synthesize times = _times;
@synthesize scores = _scores;
@synthesize moves = _moves;
@synthesize tiles = _tiles;
@synthesize undos = _undos;
@synthesize won = _won;
@synthesize draw3 = _draw3;
@synthesize firstAuto = _firstAuto;
@synthesize boardId = _boardId;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (int i = 0; i < NUM_STOCKS; i++) {
        [aCoder encodeObject:stock_[i] forKey:[NSString stringWithFormat:@"stock_%d",i]];
    }
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        [aCoder encodeObject:foundation_[i] forKey:[NSString stringWithFormat:@"foundation_%d",i]];
    }
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        [aCoder encodeObject:tableau_[i] forKey:[NSString stringWithFormat:@"tableaus_%d",i]];
    }
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        [aCoder encodeObject:tableau_bk[i] forKey:[NSString stringWithFormat:@"tableausbk_%d",i]];
    }
    [aCoder encodeObject:undo_ forKey:@"undo"];
    [aCoder encodeInteger:_times forKey:@"times"];
    [aCoder encodeInteger:_scores forKey:@"scores"];
    [aCoder encodeInteger:_moves forKey:@"moves"];
    [aCoder encodeInteger:_tiles forKey:@"tiles"];
    [aCoder encodeInteger:_undos forKey:@"undos"];
    [aCoder encodeBool:_won forKey:@"won"];
    [aCoder encodeBool:_firstAuto forKey:@"firstauto"];
    [aCoder encodeInteger:_boardId forKey:@"boardid"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        for (int i = 0; i < NUM_STOCKS; i++) {
            stock_[i] = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"stock_%d",i]];
        }
        for (int i = 0; i < NUM_FOUNDATIONS; i++) {
            foundation_[i] = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"foundation_%d",i]];
        }
        for (int i = 0; i < NUM_TABLEAUS; i++) {
            tableau_[i] = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"tableaus_%d",i]];
        }
        for (int i = 0; i < NUM_TABLEAUS; i++) {
            tableau_bk[i] = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"tableausbk_%d",i]];
        }
        undo_ = [aDecoder decodeObjectForKey:@"undo"];
        _times = [aDecoder decodeIntegerForKey:@"times"];
        _scores = [aDecoder decodeIntegerForKey:@"scores"];
        _moves = [aDecoder decodeIntegerForKey:@"moves"];
        _tiles = [aDecoder decodeIntegerForKey:@"tiles"];
        _undos = [aDecoder decodeIntegerForKey:@"undos"];
        _won = [aDecoder decodeBoolForKey:@"won"];
        _firstAuto = [aDecoder decodeBoolForKey:@"firstauto"];
        _boardId = [aDecoder decodeIntegerForKey:@"boardid"];
        
    }
    firstInn = YES;
    return self;
}

- (id)init:(NSArray *)winboards {
    self = [super init];
    if (self) {
        [self freshGame:winboards];
        _boardId = 0;
    }
    firstInn = YES;
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

- (NSArray *)stockWithCard:(Card *)card {
    for (int i = 0; i < NUM_STOCKS; i++) {
        if ([stock_[i] containsObject:card]) {
            return stock_[i];
        }
    }
    return nil;
}

// Find the tableau or foundation with the card
- (NSArray *)stackWithCard:(Card *)card {
    NSArray *stack = nil;//[self foundationWithCard:card];
    if (nil == stack) {
        stack = [self tableauWithCard:card];
    }
    if (nil == stack) {
        stack = [self stockWithCard:card];
    }
    return stack;
}

- (void)freshGame:(NSArray *)winboards {
    // Get new deck from Card class
    BOOL needFlag = YES;
    NSArray* theBoard = nil;
//    if (winboards != nil && _boardId < [winboards count]) {
//        needFlag = NO;
//        theBoard = [winboards objectAtIndex:_boardId];
//    }

    NSMutableArray *deck = (NSMutableArray *) [Card deck:theBoard];
    
    [Solitaire shuffleDeck:deck need:needFlag];
    
    _boardId++;
    
    // Initialize Stock, Waste, Foundation
    for (int i = 0; i < NUM_STOCKS; i++) {
        stock_[i] = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        foundation_[i] = [[NSMutableArray alloc] init];
    }
    // Initialize Tableau and take cards from the deck to Tableau
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        tableau_[i] = [[NSMutableArray alloc] init];
        tableau_bk[i] = [[NSMutableArray alloc] init];
    }
    for (int i = 0; i < 7; i++) {
        for (int j = 0; j < NUM_TABLEAUS; j++) {
            if ([deck count] == 0) {
                break;
            }
            [tableau_[j] addObject:[deck objectAtIndex:0]];
            [tableau_bk[j] addObject:[deck objectAtIndex:0]];
            [deck removeObjectAtIndex:0];
        }
    }
    
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
    for (int i = 0; i < NUM_STOCKS; i++) {
        [stock_[i] removeAllObjects];
    }
    
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        [foundation_[i] removeAllObjects];
    }
    
    // Initialize Tableau and take cards from the deck to Tableau
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        [tableau_[i] removeAllObjects];
        [tableau_[i] addObjectsFromArray:tableau_bk[i]];
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
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([tableau_[i] count] > 0)
        {
            Card* firstCard = [tableau_[i] objectAtIndex:0];
            for (int j = 1; j < [tableau_[i] count]; j++) {
                Card* card = [tableau_[i] objectAtIndex:j];
                if (card.rank + j != firstCard.rank
                    || (j%2==1 && [card isSameColor:firstCard])
                    || (j%2==0 && ![card isSameColor:firstCard])) {
                    return NO;
                }
            }
        }
    }
    ///
    return YES;
}

- (NSArray *)stock:(uint)i {
    return stock_[i];
}

- (NSArray *)foundation:(uint)i {
    return foundation_[i];
}

- (NSArray *)tableau:(uint)i {
    return tableau_[i];
}

- (BOOL)checkFanValid:(NSArray*)fans
{
    if (fans == nil
        || [fans count] == 0) {
        return NO;
    }
    else if ([fans count] == 1) {
        return YES;
    }
    else
    {
        Card* beginCard = [fans objectAtIndex:0];
        int rank = beginCard.rank;
        for (int i = 1; i < [fans count]; i++) {
            Card* c = [fans objectAtIndex:i];
            if (c.rank + i != rank
                || (i % 2 == 1 && [c isSameColor:beginCard])
                || (i % 2 == 0 && ![c isSameColor:beginCard])) {
                return NO;
            }
        }
        return YES;
    }
    ///
    return NO;
}

- (NSArray *)fanBeginningWithCard:(Card *)card {
    NSArray *fan = nil;
    NSArray *tab = [self stackWithCard:card];;
    
    // Return nil if card not face up 
    // Get the tableau that contains the card
    if (card.faceUp && nil != tab) {
        int index = [tab indexOfObject:card]; // Get index
        NSRange range = NSMakeRange(index, [tab count] - index); // Get Range from index to end of array
        NSArray* selectFan = [tab subarrayWithRange:range]; // Return array
        if ([self checkFanValid:selectFan]) {
            return selectFan;
        }
        else
            return nil;
    }
    
    // No tableau with card
    return fan;
}

- (BOOL)canDropCard:(Card *)card onFoundation:(int)i {
    // Empty Foundation && card == ace
    if ( [card rank] == ACE && [foundation_[i] count] == 0 )
        return YES;
    // Card 1 greater than foundation card && suits match
    if ( [card suit] == [[foundation_[i] lastObject] suit] && [card rank] - 1 == [[foundation_[i] lastObject] rank] )
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
    if ([tableau_[i] count] == 0) {
        return YES;
    }
    // Card is one less than last tableau card and suits do not match
    if ( ![card isSameColor:[tableau_[i] lastObject]] && [card rank] + 1 == [[tableau_[i] lastObject] rank] ) 
        return YES;
    return NO;
}

- (BOOL)canDropCard:(Card *)card onStock:(int)i
{
    if (card == nil) {
        return NO;
    }
    if ([stock_[i] count] == 0) {
        return YES;
    }
    return NO;
}

- (void)didDropCard:(Card *)card onStock:(int)i
{
    NSMutableArray *stack = (NSMutableArray *) [self stackWithCard:card];
    [stock_[i] addObject:card]; // Move to foundation
    [stack removeObject:card]; // Remove from stack
}

- (void)didDropCard:(Card *)card onTableau:(int)i {
    NSMutableArray *stack = (NSMutableArray *) [self stackWithCard:card]; // Get the stack that contains card
    [tableau_[i] addObject:card]; // Add card to tableau
    [stack removeObject:card]; // remove card from stack
}

- (BOOL)canDropFan:(NSArray *)cards onTableau:(int)i {
    return ([self canDropCard:[cards objectAtIndex:0] onTableau:i]
            && [cards count] <= [self maxMoveCntOnTableau:i]);
}

- (void)didDropFan:(NSArray *)cards onTableau:(int)i {
    // Remove fan from old tableau
    NSMutableArray *oldTab =  (NSMutableArray *) [self stackWithCard:[cards objectAtIndex:0]];
    [oldTab removeObjectsInArray:cards];
     
    // Add fan to new tableau
    [tableau_[i] addObjectsFromArray:cards];
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
    if (action.act == ACTION_MOVE) {
      if (action.from == POS_TABEAU) {
        switch (action.to) {
          case POS_TABEAU:{
            for (int j = 0; j < action.cardcnt; j++) {
              ///
              Card* c = [tableau_[action.toIdx] objectAtIndex:[tableau_[action.toIdx] count] - (action.cardcnt-j)];
              [topCards addObject:c];
              [tableau_[action.fromIdx] addObject:c];
              [tableau_[action.toIdx] removeObject:c];
            }
          }
            break;
          case POS_FOUNDATION: {
            self.scores -= 10;
            [topCards addObject:[foundation_[action.toIdx] lastObject]];
            [tableau_[action.fromIdx] addObject:[foundation_[action.toIdx] lastObject]];
            [foundation_[action.toIdx] removeLastObject];
          }
            break;
          case POS_STOCK:{
            [topCards addObject:[stock_[action.toIdx] lastObject]];
            [tableau_[action.fromIdx] addObject:[stock_[action.toIdx] lastObject]];
            [stock_[action.toIdx] removeLastObject];
          }
            break;
          default:
            break;
        }
      }
      else if (action.from == POS_STOCK)
      {
        switch (action.to) {
          case POS_TABEAU:{
            [topCards addObject:[tableau_[action.toIdx] lastObject]];
            [stock_[action.fromIdx] addObject:[tableau_[action.toIdx] lastObject]];
            [tableau_[action.toIdx] removeLastObject];
          }
            break;
          case POS_FOUNDATION:{
            self.scores -= 10;
            [topCards addObject:[foundation_[action.toIdx] lastObject]];
            [stock_[action.fromIdx] addObject:[foundation_[action.toIdx] lastObject]];
            [foundation_[action.toIdx] removeLastObject];}
            break;
          case POS_STOCK:{
            [topCards addObject:[stock_[action.toIdx] lastObject]];
            [stock_[action.fromIdx] addObject:[stock_[action.toIdx] lastObject]];
            [stock_[action.toIdx] removeLastObject];
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
    for (int i = 0; i < NUM_STOCKS; i++) {
        if ([stock_[i] containsObject:card]) {
            *pos = POS_STOCK;
            *idx = i;
            return;
        }
    }
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        if ([foundation_[i] containsObject:card]) {
            *pos = POS_FOUNDATION;
            *idx = i;
            return;
        }
    }
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([tableau_[i] containsObject:card]) {
            *pos = POS_TABEAU;
            *idx = i;
            return;
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

- (int)maxMoveCntOnTableau:(int) tabidx {
    return [self maxMoveCnt:([tableau_[tabidx] count] == 0)];
}

- (int)maxMoveCnt:(BOOL) useempty
{
    int stockcnt = 0;
    for (int i = 0; i < NUM_STOCKS; i++) {
        if ([stock_[i] count] == 0) {
            stockcnt++;
        }
    }
    int tableaumulti = 1;
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([tableau_[i] count] == 0) {
            tableaumulti*=2;
        }
    }
    if(useempty) {
        tableaumulti /= 2;
    }
    
    return (stockcnt+1) * tableaumulti;
}

- (NSArray *)canMoveFans:(uint)i
{
    NSMutableArray* fans = [[NSMutableArray alloc] init];
    if ([tableau_[i] count] > 0) {
        Card* preCard = [tableau_[i] lastObject];
        [fans addObject:preCard];
        for (int j = [tableau_[i] count] - 2; j >= 0; j--) {
            Card* c = [tableau_[i] objectAtIndex:j];
            if (![c isSameColor:preCard]
                && c.rank == preCard.rank+1) {
                [fans insertObject:c atIndex:0];
                preCard = c;
            }
            else
            {
                break;
            }
        }
    }
    return fans;
}

- (NSArray*)hintActions
{
    int maxCnt = [self maxMoveCnt:NO];
    int maxCntUseEmptyTab = [self maxMoveCnt:YES];
    NSMutableArray* hints = [[NSMutableArray alloc] init];
    /// A
    for (int i = 0; i < NUM_STOCKS; i++) {
        if ([stock_[i] count] == 0) {
            continue;
        }
        Card* t = [stock_[i] lastObject];
        if (t.rank == ACE) {
            for (int j = 0; j < NUM_FOUNDATIONS; j++) {
                if ([foundation_[j] count] > 0) {
                    continue;
                }
                [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_STOCK to:POS_FOUNDATION cardcnt:1 fromIdx:i toIdx:j]];
                break;
            }
        }
    }
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([tableau_[i] count] == 0) {
            continue;
        }
        Card* t = [tableau_[i] lastObject];
        if (t.rank == ACE) {
            for (int j = 0; j < NUM_FOUNDATIONS; j++) {
                if ([foundation_[j] count] > 0) {
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
            for (int j = 0; j < NUM_STOCKS; j++) {
                if ([stock_[j] count] <= 0) {
                    continue;
                }
                Card* t = [stock_[j] lastObject];
                if (t.suit == c.suit && t.rank == c.rank+1) {
                    [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_STOCK to:POS_FOUNDATION cardcnt:1 fromIdx:j toIdx:i]];
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
        if ([tableau_[i] count] > 0)
        {
            Card* c = [tableau_[i] lastObject];
            for (int j = 0; j < NUM_STOCKS; j++) {
                if ([stock_[j] count] <= 0) {
                    continue;
                }
                Card* t = [stock_[j] lastObject];
                if (![t isSameColor:c] && t.rank + 1 == c.rank) {
                    [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_STOCK to:POS_TABEAU cardcnt:1 fromIdx:j toIdx:i]];
                }
            }
            for (int j = 0; j < NUM_TABLEAUS; j++)
            {
                if (i == j) {
                    continue;
                }
                NSArray* fans = [self canMoveFans:j];
                if ([fans count] == 0 || [fans count] > maxCnt) {
                    continue;
                }

                Card* t = [fans objectAtIndex:0];
                if (t.rank + 1 == c.rank
                    && ![t isSameColor:c])
                {
                    [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_TABEAU to:POS_TABEAU cardcnt:[fans count] fromIdx:j toIdx:i]];
                }
            }
        }
    }
    for (int i = 0; i < NUM_TABLEAUS; i++)
    {
        if ([tableau_[i] count] == 0)
        {
            for (int j = 0; j < NUM_TABLEAUS; j++)
            {
                if (i == j) {
                    continue;
                }
                NSArray* fans = [self canMoveFans:j];
                if ([fans count] == 0 || [fans count] > maxCntUseEmptyTab) {
                    continue;
                }
                [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_TABEAU to:POS_TABEAU cardcnt:[fans count] fromIdx:j toIdx:i]];
            }
        }
    }
    ///

  if (hints.count == 0) {
    for (int i = 0; i < NUM_STOCKS; i++) {
      if ([stock_[i] count] == 0) {
        [hints addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_STOCK to:POS_STOCK cardcnt:1 fromIdx:i toIdx:i]];
        return hints;
      }
    }
  }
  return hints;
}

- (int)inFoundation:(Card*)card
{
    int ret = -1;
    for (int i = 0; i < NUM_FOUNDATIONS; i++) {
        if ([foundation_[i] containsObject:card]) {
            return i;
        }
    }
    return ret;
}

- (NSArray*)autoAction:(Card*)card
{
    NSMutableArray* topcards = [[NSMutableArray alloc] init];
    NSArray* fan = [self fanBeginningWithCard:card];
    int maxCnt = [self maxMoveCnt:NO];
    if (fan == nil) {
        return topcards;
    }
    if ([self inFoundation:card] >= 0) {
        return topcards;
    }
    if ([fan count] > maxCnt) {
        return topcards;
    }
    
    int from = -1;
    int fromIdx = -1;
    
    for (int i = 0; i < NUM_STOCKS; i++) {
        if ([stock_[i] containsObject:card]) {
            from = POS_STOCK;
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
              if (theAction.count > 0) {
                MoveAction * action = theAction.firstObject;
                if (action.to == POS_FOUNDATION) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:card_will_move_to_f_key object:nil userInfo:@{@"toIdx":@(i)}];

                }
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
        if ([tableau_[i] count] > 0) {
            if ([self canDropFan:fan onTableau:i]) {
                [self didDropFan:fan onTableau:i];
                [theAction addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:from to:POS_TABEAU cardcnt:[fan count] fromIdx:fromIdx toIdx:i]];
                [topcards addObjectsFromArray:fan];
                [undo_ addObject:theAction];
                return topcards;
            }
        }
    }
    for (int i = 0; i < NUM_TABLEAUS; i++) {
        if ([tableau_[i] count] == 0) {
            if ([self canDropFan:fan onTableau:i]) {
                [self didDropFan:fan onTableau:i];
                [theAction addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:from to:POS_TABEAU cardcnt:[fan count] fromIdx:fromIdx toIdx:i]];
                [topcards addObjectsFromArray:fan];
                [undo_ addObject:theAction];
                return topcards;
            }
        }
    }
    if ([fan count] == 1)
    {
        for (int i = 0; i < NUM_STOCKS; i++) {
            if ([stock_[i] count] == 0) {
                if ([self canDropCard:[fan lastObject] onStock:i]) {
                    [self didDropCard:[fan lastObject] onStock:i];
                    [theAction addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:from to:POS_STOCK cardcnt:1 fromIdx:fromIdx toIdx:i]];
                    [topcards addObjectsFromArray:fan];
                    [undo_ addObject:theAction];
                    return topcards;
                }
            }
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
              [[NSNotificationCenter defaultCenter] postNotificationName:card_will_move_to_f_key object:nil userInfo:@{@"toIdx":@(toIdx)}];

                [undo_ addObject:theAction];
                [self didDropCard:t onFoundation:toIdx];
                self.scores += 10;
                [topcards addObject:t];
                return topcards;
            }
        }
    }
    for (int i = 0; i < NUM_STOCKS; i++) {
        if ([stock_[i] count] > 0) {
            Card* t = [stock_[i] lastObject];
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
                [theAction addObject:[[MoveAction alloc] initWithAct:ACTION_MOVE from:POS_STOCK to:POS_FOUNDATION cardcnt:1 fromIdx:i toIdx:toIdx]];
              [[NSNotificationCenter defaultCenter] postNotificationName:card_will_move_to_f_key object:nil userInfo:@{@"toIdx":@(toIdx)}];

                [undo_ addObject:theAction];
                [self didDropCard:t onFoundation:toIdx];
                self.scores += 10;
                [topcards addObject:t];
                return topcards;
            }
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
        if (firstInn) {
            firstInn = NO;
//            return NO;
        }
    }
    return YES;
}


- (NSArray *)cannotMoveOnIndex:(NSInteger)index {
  if (index >= NUM_TABLEAUS) {
    return @[];
  }
  NSMutableArray* notcan = [[NSMutableArray alloc] init];
  NSInteger i = index;
  NSArray <Card *>* thisColumn = tableau_[i];
  BOOL alwaysCannot = NO;
  if ([thisColumn count] > 0) {
    Card * lastCard = thisColumn.lastObject;
//    lastCard.canmove = YES;



    for (NSInteger j = thisColumn.count - 2; j >= 0; j--) {
      Card* c = [thisColumn objectAtIndex:j];

      if (c.faceUp) {
        if (!alwaysCannot && ![lastCard isSameColor:c] && (lastCard.rank == c.rank-1)) {
          lastCard = c;

          //          c.canmove = YES;
        } else {
//          c.canmove = NO;
          alwaysCannot = YES;
          [notcan insertObject:c atIndex:0];
        }
      } else {
        break;
      }
    }
  }

  return notcan;
  
}


- (void)debugvictory {



  [undo_ removeAllObjects];


  NSMutableArray * allCards = [@[] mutableCopy];
  for (int i = 0; i < NUM_TABLEAUS; i++) {
    [allCards addObjectsFromArray:tableau_[i]];
  }
  NSMutableArray * suit1 = [[allCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Card *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    return evaluatedObject.suit == DIAMONDS;
  }]] mutableCopy];
  [suit1 sortUsingComparator:^NSComparisonResult(Card *  _Nonnull obj1, Card *  _Nonnull obj2) {
    return obj1.rank > obj2.rank;
  }];
  NSMutableArray * suit2 = [[allCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Card *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    return evaluatedObject.suit == CLUBS;
  }]] mutableCopy];
  [suit2 sortUsingComparator:^NSComparisonResult(Card *  _Nonnull obj1, Card *  _Nonnull obj2) {
    return obj1.rank > obj2.rank;
  }];
  NSMutableArray * suit3 = [[allCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Card *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    return evaluatedObject.suit == SPADES;
  }]] mutableCopy];
  [suit3 sortUsingComparator:^NSComparisonResult(Card *  _Nonnull obj1, Card *  _Nonnull obj2) {
    return obj1.rank > obj2.rank;
  }];
  NSMutableArray * suit4 = [[allCards filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(Card *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
    return evaluatedObject.suit == HEARTS;
  }]] mutableCopy];
  [suit4 sortUsingComparator:^NSComparisonResult(Card *  _Nonnull obj1, Card *  _Nonnull obj2) {
    return obj1.rank > obj2.rank;
  }];
  for (int i = 0; i < NUM_TABLEAUS; i++) {
    [tableau_[i] removeAllObjects];
  }
  [tableau_[0] addObject:suit4.lastObject];
  [suit4 removeLastObject];
  [foundation_[0] addObjectsFromArray:suit1];
  [foundation_[1] addObjectsFromArray:suit2];
  [foundation_[2] addObjectsFromArray:suit3];
  [foundation_[3] addObjectsFromArray:suit4];

}

@end
