//
//  Solitaire.m
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved. 
//

#import "Solitaire.h"
#import "Card.h"

#define MAX_TRY_CNT 20

static NSMutableArray* toBeDeletedLayouts = nil;

@implementation Solitaire {
    NSMutableArray *layoutBoards;
    NSMutableArray *allCards;
    NSMutableArray *allCards_bk;
    BOOL bitboard[MAX_LAYER][MAX_ROW][MAX_COL];
    
    /// move stack for undo
    NSMutableArray *undo_;
}

@synthesize times = _times;
@synthesize scores = _scores;
@synthesize moves = _moves;
@synthesize undos = _undos;
@synthesize won = _won;
@synthesize lose = _lose;
@synthesize level = _level;
@synthesize firstAuto = _firstAuto;
@synthesize boardId = _boardId;
@synthesize groupId;
@synthesize layoutid;
@synthesize layoutlocks;
@synthesize layoutstars;
@synthesize unlockone;

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:layoutBoards forKey:@"layouts"];
    [aCoder encodeObject:allCards forKey:@"allcards"];
    [aCoder encodeObject:allCards_bk forKey:@"allcards_bk"];
    [aCoder encodeObject:undo_ forKey:@"undo"];
    [aCoder encodeInteger:_times forKey:@"times"];
    [aCoder encodeInteger:_scores forKey:@"scores"];
    [aCoder encodeInteger:_moves forKey:@"moves"];
    [aCoder encodeInteger:_undos forKey:@"undos"];
    [aCoder encodeBool:_won forKey:@"won"];
    [aCoder encodeBool:_lose forKey:@"lose"];
    [aCoder encodeBool:_firstAuto forKey:@"firstauto"];
    [aCoder encodeInteger:_boardId forKey:@"boardid"];
    [aCoder encodeInteger:_level forKey:@"level"];
    [aCoder encodeInteger:groupId forKey:@"groupId"];
    [aCoder encodeObject:self.layoutlocks forKey:@"locks"];
    [aCoder encodeObject:self.layoutstars forKey:@"stars"];
}
- (void)updateBitboard:(Card *)m1 mc:(Card *)m2 undo:(BOOL)flag
{
    if (m1 != nil) {
        bitboard[m1.layer][m1.row][m1.col] = flag;
    }
    if (m2 != nil)
    {
        bitboard[m2.layer][m2.row][m2.col] = flag;
    }
    ///update state
    for (Card* c in allCards) {
        BOOL coverflag = NO;
        ///left and right
        if (c.col - 2 >= 0 && c.col + 2 < MAX_COL
            && bitboard[c.layer][c.row][c.col-2]
            && bitboard[c.layer][c.row][c.col+2]) {
            coverflag = YES;
        }
        else if (c.layer+1 < MAX_LAYER)
        {
            if (bitboard[c.layer+1][c.row][c.col]) {
                coverflag = YES;
            }
            else if (c.row-1 >= 0
                     && c.col-1 >= 0
                     && bitboard[c.layer+1][c.row-1][c.col-1])
            {
                coverflag = YES;
            }
            else if (c.row-1 >= 0
                     && bitboard[c.layer+1][c.row-1][c.col])
            {
                coverflag = YES;
            }
            else if (c.row-1 >= 0
                     && c.col+1 < MAX_COL
                     && bitboard[c.layer+1][c.row-1][c.col+1])
            {
                coverflag = YES;
            }
            else if (c.col-1 >= 0
                     && bitboard[c.layer+1][c.row][c.col-1])
            {
                coverflag = YES;
            }
            else if (c.col+1 < MAX_COL
                     && bitboard[c.layer+1][c.row][c.col+1])
            {
                coverflag = YES;
            }
            else if (c.row+1 < MAX_ROW
                     && c.col - 1 >= 0
                     && bitboard[c.layer+1][c.row+1][c.col-1])
            {
                coverflag = YES;
            }
            else if (c.row+1 < MAX_ROW
                     && bitboard[c.layer+1][c.row+1][c.col])
            {
                coverflag = YES;
            }
            else if (c.row+1 < MAX_ROW
                     && c.col + 1 < MAX_COL
                     && bitboard[c.layer+1][c.row+1][c.col+1])
            {
                coverflag = YES;
            }
        }
        ///
        if (coverflag) {
            c.state = CARD_STATE_COVERED;
        }
        else
        {
            if (c.state != CARD_STATE_HIDDEN) {
                c.state = CARD_STATE_SHOW;
            }
        }
    }
}

- (void)fillBoard
{
    for (int i = 0; i < MAX_LAYER; i++) {
        for (int j = 0; j < MAX_ROW; j++) {
            for (int k = 0; k < MAX_COL; k++)
            {
                bitboard[i][j][k] = NO;
            }
        }
    }
    ///
    for (Card* c in allCards) {
        if (c.state != 0) {
            bitboard[c.layer][c.row][c.col] = YES;
        }
    }
    ///
    [self updateBitboard:nil mc:nil undo:NO];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        layoutBoards = [aDecoder decodeObjectForKey:[NSString stringWithFormat:@"layouts"]];
        allCards = [aDecoder decodeObjectForKey:@"allcards"];
        allCards_bk = [aDecoder decodeObjectForKey:@"allcards_bk"];
        [self fillBoard];
        undo_ = [aDecoder decodeObjectForKey:@"undo"];
        _times = [aDecoder decodeIntegerForKey:@"times"];
        _scores = [aDecoder decodeIntegerForKey:@"scores"];
        _moves = [aDecoder decodeIntegerForKey:@"moves"];
        _undos = [aDecoder decodeIntegerForKey:@"undos"];
        _won = [aDecoder decodeBoolForKey:@"won"];
        _lose = [aDecoder decodeBoolForKey:@"lose"];
        _firstAuto = [aDecoder decodeBoolForKey:@"firstauto"];
        _boardId = [aDecoder decodeIntegerForKey:@"boardid"];
        _level = [aDecoder decodeIntegerForKey:@"level"];
        self.layoutlocks = [aDecoder decodeObjectForKey:@"locks"];
        self.layoutstars = [aDecoder decodeObjectForKey:@"stars"];
    }
    return self;
}

- (id)init:(NSArray *)winboards {
    self = [super init];
    if (self) {
        ///load layout boards
        NSString *boardFile = [[NSBundle mainBundle] pathForResource:@"layout" ofType:@"board"];
        NSString *boardStr = [NSString stringWithContentsOfFile:boardFile encoding:NSUTF8StringEncoding error:nil];
        NSArray* lines = [boardStr componentsSeparatedByString:@"\n"];
        layoutBoards = [[NSMutableArray alloc] init];
        self.layoutlocks = [[NSMutableArray alloc] init];
        self.layoutstars = [[NSMutableArray alloc] init];
        for (NSString* eachBoard in lines) {
            NSArray* items = [eachBoard componentsSeparatedByString:@";"];
            if ([items count] >= 3 && [items count] == 3 + [[items objectAtIndex:1] integerValue]*[[items objectAtIndex:0] integerValue]) {
                [layoutBoards addObject:items];
                //
                if ([self.layoutlocks count] % GROUP_SIZE == 0) {
                    [self.layoutlocks addObject:[NSNumber numberWithBool:NO]];
                }
                else
                    [self.layoutlocks addObject:[NSNumber numberWithBool:YES]];
                [self.layoutstars addObject:[NSNumber numberWithInt:0]];
            }
        }
        ///
        //[self freshGame:winboards];
        _boardId = 0;
    }
    return self;

}

- (int)availableMatches
{
    int matches = 0;
    NSMutableArray* candidates = [[NSMutableArray alloc] init];
    for (Card* c in allCards)
    {
        if (c.state == CARD_STATE_SHOW || c.state == CARD_STATE_SELECTED)
        {
            [candidates addObject:c];
        }
    }
    ///
    for (int i = 0; i < [candidates count]; i++)
    {
        for (int j = i + 1; j < [candidates count]; j++)
        {
            Card* m1 = [candidates objectAtIndex:i];
            Card* m2 = [candidates objectAtIndex:j];
            if ([m1 match:m2])
            {
                matches++;
            }
        }
    }
    //
    [candidates removeAllObjects];
    ///
    return matches;
}

- (void)shuffleDeck:(NSMutableArray *)deck need:(BOOL)need{
    /* http://eureka.ykyuen.info/2010/06/19/objective-c-how-to-shuffle-a-nsmutablearray/ */
    // Shuffle the deck
    srandom(time(NULL));
    //
    if (need) {
        NSUInteger count = [deck count];
        int trycnt = 0;
        while (trycnt < MAX_TRY_CNT)
        {
            for (NSUInteger i = 0; i < count; ++i) {
                int nElements = count - i;
                int n = (random() % nElements) + i;
                Card* c1 = [deck objectAtIndex:i];
                Card* c2 = [deck objectAtIndex:n];
                int seq = c1.seq;
                c1.seq = c2.seq;
                c2.seq = seq;
                //[deck exchangeObjectAtIndex:i withObjectAtIndex:n];
            }
            //
            [self fillBoard];
            //
            trycnt++;
            //
            if ([self availableMatches] != 0)
                break;
        }
        ///sort by col for layout shadow
        [deck sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Card* cv1 = obj1;
            Card* cv2 = obj2;
            if (cv1.layer == cv2.layer)
            {
                if (cv1.row + 1 < cv2.row)
                {
                    return NSOrderedAscending;
                }
                else if (cv2.row + 1 < cv1.row)
                {
                    return NSOrderedDescending;
                }
                else
                {
                    if (cv1.col < cv2.col)
                        return NSOrderedAscending;
                    else if (cv2.col < cv1.col)
                        return NSOrderedDescending;
                    else
                        return NSOrderedSame;
                }
            }
            else if (cv1.layer < cv2.layer)
            {
                return NSOrderedAscending;
            }
            else
            {
                return NSOrderedDescending;
            }
        }];
        //
        //////////////////////////////////////////////////////////////////////////////////////////////
        //try to mini shuffle cnt
        while (YES)
        {
            NSArray* hints = [self hintActions:nil];
            if ([hints count] > 0)
            {
                int leftcnt = 0;
                for (Card* cd in deck) {
                    if (cd.state != CARD_STATE_HIDDEN)
                        leftcnt++;
                }
                //
                Card* cv1 = [hints objectAtIndex:0];
                Card* cv2 = [hints objectAtIndex:1];
                // avoid dead deal
                if (leftcnt == 4)
                {
                    Card* leftCv1 = nil;
                    Card* leftCv2 = nil;
                    for (Card* cd in deck) {
                        if (cd.state != CARD_STATE_HIDDEN && cd != cv1 && cd != cv2)
                        {
                            if (leftCv1 == nil)
                                leftCv1 = cd;
                            else
                            {
                                leftCv2 = cd;
                                break;
                            }
                        }
                    }
                    if (leftCv1 != nil && leftCv2 != nil && leftCv1.row == leftCv2.row && leftCv1.col == leftCv2.col)
                    {
                        Card* topone = leftCv1.layer > leftCv2.layer ? leftCv1 : leftCv2;
                        //
                        int tts = topone.seq;
                        topone.seq = cv1.seq;
                        cv1.seq = tts;
                        //
                        break;
                    }
                }
                cv1.state = CARD_STATE_HIDDEN;
                cv2.state = CARD_STATE_HIDDEN;
                //
                [self updateBitboard:cv1 mc:cv2 undo:NO];
            }
            else
            {
                NSMutableArray* candidates = [[NSMutableArray alloc] init];
                for (Card* cd in deck) {
                    if (cd.state != CARD_STATE_HIDDEN)
                        [candidates addObject:cd];
                }
                ///
                int count = [candidates count];
                if (count <= 2)
                    break;
                trycnt = 0;
                while (trycnt < MAX_TRY_CNT)
                {
                    for (int i = 0; i < count; ++i)
                    {
                        int nElements = count - i;
                        int n = (rand() % nElements) + i;
                        Card* cv1 = [candidates objectAtIndex:i];
                        Card* cv2 = [candidates objectAtIndex:n];
                        int tempseq = cv1.seq;
                        cv1.seq = cv2.seq;
                        cv2.seq = tempseq;
                    }
                    trycnt++;
                    [self fillBoard];
                    int availcnt = [self availableMatches];
                    if (availcnt != 0)
                        break;
                }
                //
                if ([self availableMatches] <= 0)
                {
                    break;
                }
            }
        }
        for (Card* cv in deck)
        {
            cv.state = CARD_STATE_SHOW;
        }
    }
}

- (NSMutableArray*)deck
{
    NSMutableArray* cards = [[NSMutableArray alloc] init];
    int seq = 0;
    int cnt = 0;
    srandom(time(NULL));
    int randomlayout = self.layoutid;
    NSArray* layout = [layoutBoards objectAtIndex:randomlayout];
    int layer = [[layout objectAtIndex:0] integerValue];
    int row = [[layout objectAtIndex:1] integerValue];
    int col = [[layout objectAtIndex:2] integerValue];
    for (int i = 0; i < layer; i++) {
        for (int j = 0; j < row; j++) {
            NSString* line = [layout objectAtIndex:3+i*row+j];
            for (int k = 0; k < col; k++) {
                if ([line characterAtIndex:k] == '1') {
                    [cards addObject:[[Card alloc] initWithSeq:seq%NUM_TILE layer:i row:j col:k state:CARD_STATE_SHOW no:cnt]];
                    cnt++;
                    if (cnt%2==0) {
                        seq++;
                    }
                }
            }
        }
    }
    //
    if ([cards count] % 2 != 0) {
        [cards removeLastObject];
    }
    ///
    return cards;
}

- (void)shuffleCurrent
{
    NSMutableArray* candidates = [[NSMutableArray alloc] init];
    for (Card* c in allCards) {
        if (c.state != CARD_STATE_HIDDEN) {
            [candidates addObject:c];
        }
    }
    ///
    srand(time(NULL));
    ///
    NSUInteger count = [candidates count];
    int trycnt = 0;
    while (trycnt < MAX_TRY_CNT)
    {
        for (NSUInteger i = 0; i < count; ++i) {
            int nElements = count - i;
            int n = (random() % nElements) + i;
            Card* c1 = [candidates objectAtIndex:i];
            Card* c2 = [candidates objectAtIndex:n];
            [c1 swapXYZ:c2];
            //int tmpseq = c1.seq;
            //c1.seq = c2.seq;
            //c2.seq = tmpseq;
        }
        //
        [self fillBoard];
        //
        trycnt++;
        if ([self availableMatches] != 0)
            break;
    }
    
    ///sort by col for layout shadow
    [allCards sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Card* cv1 = obj1;
        Card* cv2 = obj2;
        if (cv1.layer == cv2.layer)
        {
            if (cv1.row + 1 < cv2.row)
            {
                return NSOrderedAscending;
            }
            else if (cv2.row + 1 < cv1.row)
            {
                return NSOrderedDescending;
            }
            else
            {
                if (cv1.col < cv2.col)
                    return NSOrderedAscending;
                else if (cv2.col < cv1.col)
                    return NSOrderedDescending;
                else
                    return NSOrderedSame;
            }
        }
        else if (cv1.layer < cv2.layer)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedDescending;
        }
    }];
    ///
    [undo_ removeAllObjects];
}

- (void)freshGame:(NSArray *)winboards{
    ///level
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.level = [settings integerForKey:@"level"];
    NSLog(@"--levelx111-----%ld", self.level);
    // Get new deck from Card class
    BOOL needFlag = YES;
    NSArray* theBoard = nil;
    if (winboards != nil && _boardId < [winboards count]) {
        needFlag = NO;
        theBoard = [winboards objectAtIndex:_boardId];
        _boardId++;
    }
    
    allCards = [self deck];
    [self shuffleDeck:allCards need:needFlag];
    
    ///
    allCards_bk = [[NSMutableArray alloc] init];
    for (Card* c in allCards) {
        [allCards_bk addObject:[c copy]];
    }
    
    ///
    [self fillBoard];
    
    // undo
    undo_ = [[NSMutableArray alloc] init];
    
    ///
    self.scores = 0;
    self.times = 0;
    self.moves = 0;
    self.undos = 0;
    self.won = NO;
    self.lose = NO;
    self.firstAuto = YES;
}

- (void)replayGame {
    
    ///
    for (int i = 0; i < [allCards_bk count]; i++) {
        Card* c = [allCards objectAtIndex:i];
        Card* c_bk = [allCards_bk objectAtIndex:i];
        [c assignWithCard:c_bk];
    }
    
    ///
    [self fillBoard];
    
    // undo
    [undo_ removeAllObjects];
    
    ///
    self.scores = 0;
    self.times = 0;
    self.moves = 0;
    self.won = NO;
    self.lose = NO;
    self.firstAuto = YES;
}

- (BOOL)gameWon {
    for (Card* c in allCards) {
        if (c.state != 0) {
            return NO;
        }
    }
    ///
    return YES;
}

- (void)pushAction:(NSArray*)action
{
    [undo_ addObject:action];
}

- (void)insertToLastAction:(NSArray*)action
{
    if ([undo_ count] == 0) {
        [self pushAction:action];
    }
    else
    {
        NSMutableArray* forAdd = [[NSMutableArray alloc] initWithArray:[undo_ lastObject]];
        [forAdd addObjectsFromArray:action];
        [undo_ removeLastObject];
        [undo_ addObject:forAdd];
    }
}

- (NSArray*)undoAction
{
    NSArray* lastAction = [undo_ lastObject];
    Card* m1 = nil, *m2 = nil;
    if (lastAction != nil && [lastAction count] == 2) {
        m1 = [lastAction objectAtIndex:0];
        m2 = [lastAction objectAtIndex:1];
        m1.state = CARD_STATE_SHOW;
        m2.state = CARD_STATE_SHOW;
        [self updateBitboard:m1 mc:m2 undo:YES];
    }
    /// pop action
    [undo_ removeLastObject];
    ///
    _undos++;
    ///
    return [[NSArray alloc] initWithObjects:m1,m2, nil];
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

- (NSArray*)hintActions:(Card *)card
{
    NSMutableArray* candidates = [[NSMutableArray alloc] init];
    for (Card* c in allCards) {
        if (c.state == CARD_STATE_SHOW) {
            [candidates addObject:c];
        }
    }
    ///
    if (card != nil)
    {
        for (Card* c in candidates) {
            if (c != card && [c match:card]) {
                return [[NSArray alloc] initWithObjects:c,card, nil];
            }
        }
    }
    ///
    for (int i = 0; i < [candidates count]; i++) {
        for (int j = i+1; j < [candidates count]; j++) {
            Card* m1 = [candidates objectAtIndex:i];
            Card* m2 = [candidates objectAtIndex:j];
            if ([m1 match:m2]) {
                return [[NSArray alloc] initWithObjects:m1,m2, nil];
            }
        }
    }
    ///
    return nil;
}

+(void) appString:(NSString *)path str:(NSString*)str
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSString *s = [NSString stringWithFormat:@""];
        [s writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    NSFileHandle *outFile;
    NSData *buffer;
    outFile = [NSFileHandle fileHandleForWritingAtPath:path];
    //找到并定位到outFile的末尾位置(在此后追加文件)
    [outFile seekToEndOfFile];
    //读取inFile并且将其内容写到outFile中
    NSString *bs = [NSString stringWithFormat:@"%@",str];
    buffer = [bs dataUsingEncoding:NSUTF8StringEncoding];
    [outFile writeData:buffer];
    //关闭读写文件
    [outFile closeFile];
}

- (BOOL)alreadyDone
{
    //for debug
    //if (self.scores > 0)
    //    return YES;
    //
    for (Card* c in allCards) {
        if (c.state != 0) {
            return NO;
        }
    }
    ///
    return YES;
}

- (NSArray*)mahjongs
{
    return allCards;
}

@end
