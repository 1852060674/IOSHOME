//
//  DrawView.m
//  WordSearch
//
//  Created by apple on 13-8-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "DrawView.h"
#import "TheSound.h"
#import "Config.h"
#import "UIImage+Tint.h"
#import "Common.h"
#import "TheSound.h"
#import <list>
#import <iostream>
#import <map>
#import <set>

using namespace std;

// The tile "bodies" information - filled by DetectTileBodies()
// via heuristics on the center pixel of the tile
//
enum TileKind {
    empty    = 0,
    block    = 1,
    prisoner = 2
};

// The board is a list of Blocks:
struct Block {
    static int BlockId; // class-global counter, used to...
    int _id;            // ...uniquely identify each block
    int _y, _x;         // block's top-left tile coordinates
    bool _isHorizontal; // whether the block is Horiz/Vert
    TileKind _kind;     // can only be block or prisoner
    int _length;        // how many tiles long this block is
    Block(int y, int x, bool isHorizontal, TileKind kind, int length):
    _id(BlockId++), _y(y), _x(x), _isHorizontal(isHorizontal),
    _kind(kind), _length(length)
    {}
    Block(){};
    // Since _id, _y and _x fit in 8 bits,
    // a Block hash can be easily obtained via plain shifts:
    unsigned hash() { return _id | (_y << 8) | (_x << 16); }
};
int Block::BlockId = 0;
list<list<Block> > solution;
Block targetPos;

#define MAXN 10

@interface DrawView()
{
    CGPoint touchStart;
    CGPoint startCenter;
    CGFloat blockWidth;
    BlockView* hintView;
    //
    CGFloat SHADOW_WIDTH;
    //
    BlockView* currentTouchView;
}
@end

int g_spaceboard[MAXN][MAXN];

@implementation DrawView
@synthesize allBlockViews;
@synthesize cellsize;
@synthesize moves;
@synthesize undoMoves;
@synthesize succFlag;
@synthesize hintFlag;
@synthesize undoFlag;
@synthesize targetView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        //
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            SHADOW_WIDTH = 4;
        }
        else
        {
            SHADOW_WIDTH = 2;
        }
    }
    return self;
}

- (void)drawRR:(CGRect)rrect angle:(CGFloat)angle lineColor:(UIColor*)lineColor fillColor:(UIColor*)fillColor
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    //
    CGMutablePathRef path = CGPathCreateMutable();
    //
    CGContextSetStrokeColor(context, CGColorGetComponents(lineColor.CGColor));
    CGContextSetLineWidth(context, 3);
    
    // If you were making this as a routine, you would probably accept a rectangle
    // that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
    CGFloat radius = rrect.size.width/2;
    // NOTE: At this point you may want to verify that your radius is no more than half
    // the width and height of your rectangle, as this technique degenerates for those cases.
    
    // In order to draw a rounded rectangle, we will take advantage of the fact that
    // CGContextAddArcToPoint will draw straight lines past the start and end of the arc
    // in order to create the path from the current position and the destination position.
    
    // In order to create the 4 arcs correctly, we need to know the min, mid and max positions
    // on the x and y lengths of the given rectangle.
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    // Next, we will go around the rectangle in the order given by the figure below.
    //       minx    midx    maxx
    // miny    2       3       4
    // midy   1 9              5
    // maxy    8       7       6
    // Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
    // form a closed path, so we still need to close the path to connect the ends correctly.
    // Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
    // You could use a similar tecgnique to create any shape with rounded corners.
    
    // Start at 1
    CGPathMoveToPoint(path, NULL, minx, midy);
    // Add an arc through 2 to 3
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, radius);
    // Close the path
    CGPathCloseSubpath(path);
    //
    CGContextSetFillColor(context, CGColorGetComponents(fillColor.CGColor));
    
    //rotate
    CGPoint center = CGPointMake(rrect.origin.x + radius, rrect.origin.y + radius);
    CGContextTranslateCTM (context, center.x , center.y);
    CGContextRotateCTM (context, angle);
    CGContextTranslateCTM (context, -center.x , -center.y);
    CGContextAddPath(context, path);
    
    // draw the path
    CGContextDrawPath(context, kCGPathFillStroke);
    
    ///
    CGContextRestoreGState(context);
    
    ///
    CGPathRelease(path);
}

- (void)drawRR:(CGPoint)beginPoint endPoint:(CGPoint)endPoint width:(CGFloat)width lineColor:(UIColor*)lineColor fillColor:(UIColor*)fillColor
{
    if (beginPoint.x == endPoint.x
        && beginPoint.y == endPoint.y) {
        //[self drawRR:CGRectMake(beginPoint.x - width/2, beginPoint.y - width/2, width, width) angle:0 lineColor:lineColor fillColor:fillColor];
    }
    else
    {
        CGFloat angle = atan((endPoint.y - beginPoint.y)/(endPoint.x - beginPoint.x));
        if (endPoint.x >= beginPoint.x) {
            angle -= M_PI_2;
        }
        else
        {
            angle += M_PI_2;
        }
        CGFloat height = sqrtf((endPoint.y - beginPoint.y)*(endPoint.y - beginPoint.y)+(endPoint.x - beginPoint.x)*(endPoint.x - beginPoint.x))+width;
        [self drawRR:CGRectMake(beginPoint.x - width/2, beginPoint.y - width/2, width, height) angle:angle lineColor:lineColor fillColor:fillColor];
    }
}

- (void)awakeFromNib {
    cellsize = 6;
    undoMoves = [[NSMutableArray alloc] init];
}

- (void)resetDraw
{
    moves = 0;
    hintFlag = NO;
    succFlag = NO;
    undoFlag = NO;
    hintView = nil;
    targetView.alpha = 0;
    [undoMoves removeAllObjects];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self layoutBoard];
}

- (BlockView *)locationToBlockView:(CGPoint)loc
{
    CGFloat width = self.frame.size.width/cellsize;
    int row = (int)(loc.y/width);
    int col = (int)(loc.x/width);
    if (row == cellsize) {
        row -= 1;
    }
    if (col == cellsize) {
        col -= 1;
    }
    if (row*cellsize+col >= cellsize*cellsize
        || row*cellsize+col < 0) {
        return nil;
    }
    return [self.allBlockViews objectAtIndex:row*cellsize+col];
}

- (void)statAndReport:(int)type
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatestat" object:[NSNumber numberWithInt:type]];
}

- (void)spaceBoard
{
    for (int i = 0; i < MAXN; i++) {
        for (int j = 0; j < MAXN; j++) {
            g_spaceboard[i][j] = -1;
        }
    }
    for (BlockView* bv in allBlockViews) {
        int x_span = bv.hor ? bv.len : 1;
        int y_span = bv.hor ? 1 : bv.len;
        for (int i = bv.y; i < bv.y + y_span; i++) {
            for (int j = bv.x; j < bv.x + x_span; j++) {
                g_spaceboard[i][j] = bv.seq;
            }
        }
    }
    blockWidth = self.frame.size.width/cellsize;
    ///
    /*
    for (int i = 0; i < cellsize; i++) {
        printf("\n");
        for (int j = 0; j < cellsize; j++) {
            printf("%d\t",g_spaceboard[i][j]);
        }
    }
    */
}

- (void)updateSpaceBoard:(BlockView*)bv newx:(int)newx newy:(int)newy undo:(BOOL)undo
{
    if (!undo) {
        if (newx != bv.x) {
            int step = newx - bv.x;
            if (step > 0) {
                [undoMoves addObject:[[BlockMove alloc] initWith:bv.seq step:step dir:MOVE_RIGHT]];
            }
            else
            {
                [undoMoves addObject:[[BlockMove alloc] initWith:bv.seq step:-step dir:MOVE_LEFT]];
            }
        }
        else if (newy != bv.y)
        {
            int step = newy - bv.y;
            if (step > 0) {
                [undoMoves addObject:[[BlockMove alloc] initWith:bv.seq step:step dir:MOVE_DOWN]];
            }
            else
                [undoMoves addObject:[[BlockMove alloc] initWith:bv.seq step:-step dir:MOVE_UP]];
        }
    }
    ///
    if (bv.hor) {
        for (int i = bv.x; i < bv.x + bv.len; i++) {
            g_spaceboard[bv.y][i] = -1;
        }
        for (int i = newx; i < newx + bv.len; i++) {
            g_spaceboard[bv.y][i] = bv.seq;
        }
    }
    else
    {
        for (int i = bv.y; i < bv.y + bv.len; i++) {
            g_spaceboard[i][bv.x] = -1;
        }
        for (int i = newy; i < newy + bv.len; i++) {
            g_spaceboard[i][bv.x] = bv.seq;
        }
    }
    //
    bv.x = newx;
    bv.y = newy;
}

- (void)getMoveRange:(BlockView*)bv begin:(float *)begin end:(float *)end
{
    if (bv.hor) {
        int beginidx = bv.x;
        for (; beginidx - 1 >= 0 && g_spaceboard[bv.y][beginidx-1] == -1; beginidx--) {
            ;
        }
        int endidx = bv.x + bv.len;
        for (; endidx < cellsize && g_spaceboard[bv.y][endidx] == -1; endidx++) {
            ;
        }
        if (bv.type && endidx == cellsize) {
            endidx = cellsize+1;
        }
        *begin = beginidx*blockWidth+bv.frame.size.width/2;
        *end = (endidx-bv.len)*blockWidth+bv.frame.size.width/2;
    }
    else
    {
        int beginidx = bv.y;
        for (; beginidx - 1 >= 0 && g_spaceboard[beginidx - 1][bv.x] == -1; beginidx--) {
            ;
        }
        int endidx = bv.y + bv.len;
        for (; endidx < cellsize && g_spaceboard[endidx][bv.x] == -1; endidx++) {
            ;
        }
        *begin = beginidx*blockWidth+bv.frame.size.height/2;
        *end = (endidx-bv.len)*blockWidth+bv.frame.size.height/2;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(BlockView*)bv
{
    if ((hintFlag && hintView != bv) || succFlag) {
        return;
    }
    touchStart = [[touches anyObject] locationInView:self];
    startCenter = bv.center;
    currentTouchView = bv;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(BlockView*)bv
{
    if ((hintFlag && hintView != bv) || succFlag || bv != currentTouchView) {
        return;
    }
    CGPoint movePoint = [[touches anyObject] locationInView:self];
    float begin,end;
    [self getMoveRange:bv begin:&begin end:&end];
    if (bv.hor) {
        movePoint.y = touchStart.y;
        CGFloat delta = movePoint.x-touchStart.x;
        CGFloat newcenterx = startCenter.x + delta;
        if (newcenterx >= begin && newcenterx <= end)
        {
            bv.center = CGPointMake(newcenterx, startCenter.y);
        }
        else if (newcenterx < begin)
        {
            bv.center = CGPointMake(begin, startCenter.y);
        }
        else if (newcenterx > end)
        {
            bv.center = CGPointMake(end, startCenter.y);
        }
    }
    else
    {
        movePoint.x = touchStart.x;
        CGFloat delta = movePoint.y-touchStart.y;
        CGFloat newcentery = startCenter.y + delta;
        if (newcentery >= begin && newcentery <= end)
        {
            bv.center = CGPointMake(startCenter.x,newcentery);
        }
        else if (newcentery < begin)
        {
            bv.center = CGPointMake(startCenter.x,begin);
        }
        else if (newcentery > end)
        {
            bv.center = CGPointMake(startCenter.x,end);
        }
    }

    /*
    int newx = bv.x,newy = bv.y;
    if (bv.hor) {
        movePoint.y = touchStart.y;
        CGFloat delta = movePoint.x-touchStart.x;
        if ([self canMove:bv delta:delta newx:&newx newy:&newy]) {
            bv.center = CGPointMake(startCenter.x+delta,startCenter.y);
        }
    }
    else
    {
        movePoint.x = touchStart.x;
        CGFloat delta = movePoint.y-touchStart.y;
        if ([self canMove:bv delta:delta newx:&newx newy:&newy]) {
            bv.center = CGPointMake(startCenter.x,startCenter.y+delta);
        }
    }
     */
}

- (void)layoutBoard
{
    [UIView animateWithDuration:0.2 animations:^{
        for (BlockView* bv in allBlockViews) {
            bv.center = CGPointMake(bv.x*blockWidth+bv.frame.size.width/2, bv.y*blockWidth+bv.frame.size.height/2);
        }
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event view:(BlockView*)bv
{
    if ((hintFlag && hintView != bv) || succFlag || bv != currentTouchView) {
        return;
    }
    ///
    int newx = (int)(bv.frame.origin.x/blockWidth);
    if ((int)bv.frame.origin.x%(int)blockWidth > blockWidth/2) {
        newx++;
    }
    if (bv.type && bv.frame.size.width+bv.frame.origin.x > self.frame.size.width) {
        newx = cellsize;
    }
    int newy = (int)(bv.frame.origin.y/blockWidth);
    if ((int)bv.frame.origin.y%(int)blockWidth > blockWidth/2) {
        newy++;
    }
    if (newx != bv.x || newy != bv.y) {
        self.moves++;
        [TheSound playMoveSound];
        [self updateSpaceBoard:bv newx:newx newy:newy undo:NO];
    }
    ///
    if (hintFlag
        && hintView == bv
        )
    {
        if (bv.x == targetPos._x
        && bv.y == targetPos._y) {
            solution.pop_front();
            if (![self getNextStep]) {
                hintFlag = NO;
                hintView = nil;
            }
        }
        else
        {
            [self compareTwo];
        }
    }
    ///
    [self layoutBoard];
    ///
    if (bv.type && bv.frame.size.width+bv.frame.origin.x > self.frame.size.width) {
        succFlag = YES;
        [self statAndReport:1];
    }
    else
    {
        [self statAndReport:0];
    }
}

- (void)undo
{
    if (undoFlag) {
        return;
    }
    undoFlag = YES;
    if ([undoMoves count] == 0) {
        return;
    }
    ///
    BlockMove* bm = [undoMoves lastObject];
    BlockView* bv = [allBlockViews objectAtIndex:bm.seq];
    int newx = bv.x,newy = bv.y;
    switch (bm.dir) {
        case MOVE_RIGHT:
            newx -= bm.step;
            break;
        case MOVE_LEFT:
            newx += bm.step;
            break;
        case MOVE_UP:
            newy += bm.step;
            break;
        case MOVE_DOWN:
            newy -= bm.step;
            break;
        default:
            break;
    }
    [self updateSpaceBoard:bv newx:newx newy:newy undo:YES];
    ///
    [undoMoves removeLastObject];
    ///
    [self layoutBoard];
    self.moves--;
    [self statAndReport:0];
    ///
    undoFlag = NO;
}

///////////////////////////////////////////
///////////////////////open source
// The board is SIZE x SIZE tiles
#define SIZE 6

// A board is indeed represented as a list of Blocks.
// However, when we move Blocks around, we need to be able
// to detect if a tile is empty or not - so a 2D representation
// (for quick tile access) is required.
struct Board {
    TileKind _data[SIZE*SIZE];
    
    // UPDATE, Jan 26, 2013:
    // Connor Duggan correctly reported that just using tile state
    // is not enough to represent a board - what if we have a different
    // arrangement of vertical and horizontal blocks that cover
    // the same tiles?  e.g.
    //
    //             AA AA          AA BB
    //             BB BB    vs    AA BB
    //
    // if we just compare tile data, the two boards will seem identical
    // when we check the 'visited' set in the main loop - but they aren't!
    //
    // We therefore store a hash per block, formed by combining the
    // block index, and the block coordinates (simple shifts, since
    // all 3 numbers easily fit in 8 bits - see Block::hash() above)
    //
    // How much space to reserve for these hashes? Since blocks are
    // at least 2-tile sized:
    unsigned _hashes[SIZE*SIZE/2];
    
    // 2D access operator
    // i.e. instead of 'arr[y][x]' you do 'arr(y,x)'
    inline TileKind& operator()(int y, int x) {
        return _data[y*SIZE+x];
    }
    // This type is also used in both sets and maps as a key -
    // so it needs a comparison operator. Using the block
    // _hashes instead of the tile _data, we avoid misidentifying
    // a board state as identical when different block arrangements
    // end up covering the same tiles.
    bool operator<(const Board& r) const {
        return memcmp(_hashes, r._hashes, sizeof(_hashes)) < 0;
    }
    // Initial state: set all tiles to empty
    Board() {
        memset(&_data, empty, sizeof(_data));
        memset(&_hashes, 0, sizeof(_hashes));
    }
};
// This function takes a list of blocks, and 'renders' them
// into a Board - for quick tile access. It also stores
// the block hashes into the Board.
Board renderBlocks(list<Block>& blocks)
{
    unsigned idx=0;
    Board tmp;
    for(list<Block>::iterator it=blocks.begin(); it!=blocks.end(); it++) {
        Block& p = *it;
        if (p._isHorizontal)
            for(int i=0; i<p._length; i++)
                tmp(p._y, p._x+i) = p._kind;
        else
            for(int i=0; i<p._length; i++)
                tmp(p._y+i, p._x) = p._kind;
        assert(idx < SIZE*SIZE/2);
        tmp._hashes[idx++] = p.hash();
    }
    return tmp;
}
// This function pretty-prints a list of blocks
void printBoard(const list<Block>& blocks)
{
    unsigned char tmp[SIZE][SIZE];
    // start from an empty buffer
    memset(tmp, ' ', sizeof(tmp));
    list<Block>::const_iterator it=blocks.begin();
    for(; it!=blocks.end(); it++) {
        const Block& block = *it;
        char c=' '; // character emitted for this tile
        switch (block._kind) {
            case empty:
                break;
            case prisoner:
                c = 'Z'; // Our Zorro tile :-)
                break;
                // ... and use a different letter for each block
            case ::block:
                c = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[block._id];
                break;
        }
        if (block._isHorizontal)
            for(int i=0; i<block._length; i++)
                tmp[block._y][block._x+i] = c;
        else
            for(int i=0; i<block._length; i++)
                tmp[block._y+i][block._x] = c;
    }
    
    cout << "+------------------+\n|";
    for(int i=0; i<36; i++) {
        char c = tmp[i/SIZE][i%SIZE];
        cout << c << c << " ";
        if (5 == (i%SIZE)) {
            if (i == 17) cout << " \n|"; // Freedom path
            else         cout << "|\n|"; // walls
        }
    }
    cout << "\b+------------------+\n";
}
// When we find the solution, we also need to backtrack
// to display the moves we used to get there...
//
// "Move" stores what block moved and to what direction
struct Move {
    int _blockId;
    int _distance;
    enum Direction {left, right, up, down} _move;
    Move(int blockID, Direction d, int steps):
    _blockId(blockID),
    _distance(steps),
    _move(d) {}
};
// Utility function - we need to be able to "deep copy"
// a list of Blocks, to form alternate board states (see SolveBoard)
list<Block> copyBlocks(const list<Block>& blocks)
{
    list<Block> copied;
    for(list<Block>::const_iterator it=blocks.begin(); it!=blocks.end(); it++)
        copied.push_back(*it);
    return copied;
}

void SolveBoard(list<Block>& blocks,list<list<Block> >& solution)
{
    // We need to store the last move that got us to a specific
    // board state - that way we can backtrack from a final board
    // state to the list of moves we used to achieve it.
    typedef pair<Board, int> BoardAndLevel;
    map<BoardAndLevel, Move> previousMoves;
    // Start by storing a "sentinel" value, for the initial board
    // state - we used no Move to achieve it, so store a block id
    // of -1 to mark it:
    int oldLevel = 0;
    BoardAndLevel key(renderBlocks(blocks), oldLevel);
    previousMoves.insert(
                         pair<BoardAndLevel, Move>(
                                                   key,
                                                   Move(-1, Move::left, 1)));
    
    // We must not revisit board states we have already examined,
    // so we need a 'visited' set:
    set<Board> visited;
    
    // Now, to implement Breadth First Search, all we need is a Queue
    // storing the states we need to investigate - so it needs to
    // be a list of board states... We'll also be maintaining
    // the depth we traversed to reach this board state, and the
    // move to perform - so we end up with a tuple of
    // int (depth), Move, list of blocks (state).
    list<int> queueDepth;
    list<Move> queueMove;
    list<list<Block>> queueState;
    
    // Start with our initial board state, and playedMoveDepth set to 1
    queueDepth.push_back(1);
    queueMove.push_back(Move(-1, Move::left, 0 ));
    queueState.push_back(blocks);
    
    while(!queueState.empty()) {
        
        // Extract first element of the queue
        int level = *queueDepth.begin();
        Move move = *queueMove.begin();
        list<Block> blocks = *queueState.begin();
        queueDepth.pop_front();
        queueMove.pop_front();
        queueState.pop_front();
        
        // Report depth increase when it happens
        if (level > oldLevel) {
            oldLevel = level;
        }
        
        // Create a Board for fast 2D access to tile state
        Board board = renderBlocks(blocks);
        
        // Have we seen this board before?
        if (visited.find(board) != visited.end())
            // Yep - skip it
            continue;
        
        // No, we haven't - store it so we avoid re-doing
        // the following work again in the future...
        visited.insert(board);
        
        /* Store board and move, so we can backtrack later */ \
        BoardAndLevel key(board, oldLevel);
        previousMoves.insert(pair<BoardAndLevel, Move>(key, move));
        
        // Check if this board state is a winning state:
        // Find prisoner block...
        list<Block>::iterator it=blocks.begin();
        for(; it!=blocks.end(); it++) {
            Block& block = *it;
            if (block._kind == prisoner)
                break;
        }
        assert(it != blocks.end()); // The prisoner is always there!
        
        // Can he escape? Check to his right!
        bool allClear = true;
        for (int x=it->_x+it->_length; x<SIZE ; x++) {
            allClear = allClear && !board(it->_y, x);
            if (!allClear)
                break;
        }
        if (allClear) {
            // Yes, he can escape - we did it!
            
            // To print the Moves we used in normal order, we will
            // backtrack through the board states to print
            // the Move we used at each one...
            solution.push_front(copyBlocks(blocks));
            
            map<BoardAndLevel,Move>::iterator itMove = previousMoves.find(
                                                                          BoardAndLevel(board, level));
            while (itMove != previousMoves.end()) {
                if (itMove->second._blockId == -1)
                    // Sentinel - reached starting board
                    break;
                // Find the block we moved, and move it
                // (in reverse direction - we are going back)
                for(it=blocks.begin(); it!=blocks.end(); it++) {
                    if (it->_id == itMove->second._blockId) {
                        switch(itMove->second._move) {
                            case Move::left:
                                it->_x+=itMove->second._distance; break;
                            case Move::right:
                                it->_x-=itMove->second._distance; break;
                            case Move::up:
                                it->_y+=itMove->second._distance; break;
                            case Move::down:
                                it->_y-=itMove->second._distance; break;
                        }
                        break;
                    }
                }
                assert(it != blocks.end());
                // Add this board to the front of the list...
                solution.push_front(copyBlocks(blocks));
                board = renderBlocks(blocks);
                level--;
                itMove = previousMoves.find(BoardAndLevel(board, level));
            }
            return;
            // Now that we have the full list, emit it in order
            //for(list<list<Block> >::iterator itState=solution.begin();
            //    itState != solution.end(); itState++)
            //{
            //    printBoard(*itState);
            //    cin.get();
            //}
            //cout << "Run free, prisoner, run! :-)\n";
        }
        
        // Nope, the prisoner is still trapped.
        //
        // Add all potential states arrising from immediate
        // possible moves to the end of the queue.
        for(it=blocks.begin(); it!=blocks.end(); it++) {
            Block& block = *it;
            
#define COMMON_BODY(direction)                                \
list<Block> copiedBlocks = copyBlocks(blocks);            \
Board candidateBoard = renderBlocks(copiedBlocks);        \
if (visited.find(candidateBoard) == visited.end()) {      \
/* Add to the end of the queue for further study */   \
queueDepth.push_back(level+1);                       \
queueMove.push_back(Move(block._id,Move::direction,distance));  \
queueState.push_back(copiedBlocks);                     \
}
            
            if (block._isHorizontal) {
                // Can the block move to the left?
                int blockStartingX = block._x;
                for(int distance=1; distance<SIZE; distance++) {
                    int testX = blockStartingX-distance;
                    if (testX>=0 && empty==board(block._y, testX)) {
                        block._x = testX;
                        COMMON_BODY(left)
                    } else
                        break;
                }
                // Can the block move to the right?
                for(int distance=1; distance<SIZE; distance++) {
                    int testX = blockStartingX+distance-1+block._length;
                    if (testX<SIZE && empty==board(block._y, testX)) {
                        block._x = blockStartingX+distance;
                        COMMON_BODY(right)
                    } else
                        break;
                }
                block._x = blockStartingX;
            } else {
                // Can the block move up?
                int blockStartingY = block._y;
                for(int distance=1; distance<SIZE; distance++) {
                    int testY = blockStartingY-distance;
                    if (testY>=0 && empty==board(testY, block._x)) {
                        block._y = testY;
                        COMMON_BODY(up)
                    } else
                        break;
                }
                // Can the block move down?
                for(int distance=1; distance<SIZE; distance++) {
                    int testY = blockStartingY+distance-1+block._length;
                    if (testY<SIZE && empty==board(testY, block._x)) {
                        block._y = blockStartingY+distance;
                        COMMON_BODY(down)
                    } else
                        break;
                }
                block._y = blockStartingY;
            }
        }
        // and go recheck the queue, from the top!
    }
}

//#define SHADOW_WIDTH 4

- (void)compareTwo
{
    if (hintView.x != targetPos._x) {
        [hintView moveTopLeft:targetPos._x < hintView.x ? 1 : 0];
        if (targetPos._x < hintView.x) {
            self.targetView.image = [UIImage imageNamed:@"target_left"];
            self.targetView.center = CGPointMake(targetPos._x*blockWidth+blockWidth/2, targetPos._y*blockWidth+blockWidth/2-SHADOW_WIDTH);
        }
        else
        {
            self.targetView.image = [UIImage imageNamed:@"target_right"];
            if (targetPos._x >= self.cellsize) {
                CGFloat margin = 15;
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    margin = 70;
                }
                self.targetView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width-blockWidth/2-margin, targetPos._y*blockWidth+blockWidth/2-SHADOW_WIDTH);
            }
            else
                self.targetView.center = CGPointMake((targetPos._x+targetPos._length-1)*blockWidth+blockWidth/2, targetPos._y*blockWidth+blockWidth/2-SHADOW_WIDTH);
        }
    }
    else if (hintView.y != targetPos._y)
    {
        [hintView moveTopLeft:targetPos._y < hintView.y ? 1 : 0];
        if (targetPos._y < hintView.y) {
            self.targetView.image = [UIImage imageNamed:@"target_up"];
            self.targetView.center = CGPointMake(targetPos._x*blockWidth+blockWidth/2, targetPos._y*blockWidth+blockWidth/2);
        }
        else
        {
            self.targetView.image = [UIImage imageNamed:@"target_down"];
            self.targetView.center = CGPointMake(targetPos._x*blockWidth+blockWidth/2, (targetPos._y+targetPos._length-1)*blockWidth+blockWidth/2);
        }
    }
}

- (BOOL)getNextStep
{
    if (hintView != nil) {
        [hintView moveTopLeft:-1];
    }
    ///
    if (solution.empty()) {
        ///
        self.targetView.alpha = 0;
        return NO;
    }
    else
    {
        list<Block> state = *solution.begin();
        for(list<Block> ::iterator it=state.begin();
            it != state.end(); it++)
        {
            Block bk = *it;
            BlockView* bv = [self.allBlockViews objectAtIndex:bk._id];
            if (bv.x != bk._x) {
                hintView = bv;
                targetPos = bk;
                [hintView moveTopLeft:bk._x < bv.x ? 1 : 0];
                if (bk._x < bv.x) {
                    self.targetView.image = [UIImage imageNamed:@"target_left"];
                    self.targetView.center = CGPointMake(bk._x*blockWidth+blockWidth/2, bk._y*blockWidth+blockWidth/2-SHADOW_WIDTH);
                }
                else
                {
                    self.targetView.image = [UIImage imageNamed:@"target_right"];
                    if (targetPos._x >= self.cellsize) {
                        CGFloat margin = 15;
                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                            margin = 70;
                        }
                        self.targetView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width-blockWidth/2-margin, targetPos._y*blockWidth+blockWidth/2-SHADOW_WIDTH);
                    }
                    else
                        self.targetView.center = CGPointMake((bk._x+bk._length-1)*blockWidth+blockWidth/2, bk._y*blockWidth+blockWidth/2-SHADOW_WIDTH);
                }
                self.targetView.alpha = 1;
                break;
            }
            else if (bv.y != bk._y)
            {
                hintView = bv;
                targetPos = bk;
                [hintView moveTopLeft:bk._y < bv.y ? 1 : 0];
                if (bk._y < bv.y) {
                    self.targetView.image = [UIImage imageNamed:@"target_up"];
                    self.targetView.center = CGPointMake(bk._x*blockWidth+blockWidth/2, bk._y*blockWidth+blockWidth/2);
                }
                else
                {
                    self.targetView.image = [UIImage imageNamed:@"target_down"];
                    self.targetView.center = CGPointMake(bk._x*blockWidth+blockWidth/2, (bk._y+bk._length-1)*blockWidth+blockWidth/2);
                }
                self.targetView.alpha = 1;
                break;
            }
            else
                continue;
        }
        [self setNeedsDisplay];
        return YES;
    }
}

- (void)hint
{
    if (hintFlag) {
        return;
    }
    hintFlag = YES;
    [self bringSubviewToFront:self.targetView];
    ///
    Block::BlockId = 0;
    ///
    list<Block> puzzle;
    for (BlockView* bv in self.allBlockViews) {
        puzzle.push_back(Block(bv.y, bv.x, bv.hor, bv.type ? prisoner : block, bv.len));
    }
    solution.clear();
    SolveBoard(puzzle, solution);
    ///
    list<Block> laststate = *solution.rbegin();
    for (list<Block>::iterator it = laststate.begin(); it != laststate.end(); it++)
    {
        if (it->_kind == prisoner) {
            it->_x = self.cellsize;
            break;
        }
    }
    solution.push_back(laststate);
    //pop current level stat
    solution.pop_front();
    [self getNextStep];
    ///
    //for(list<list<Block> >::iterator itState=solution.begin();
    //    itState != solution.end(); itState++)
    //{
    //    printBoard(*itState);
    //}
    ///
    //hintFlag = NO;
}

@end

@implementation BlockMove
@synthesize seq;
@synthesize step;
@synthesize dir;

- (id)initWith:(int)_seq step:(int)_step dir:(int)_dir;
{
    self = [super init];
    if (self) {
        self.seq = _seq;
        self.step = _step;
        self.dir = _dir;
    }
    return self;
}

@end
