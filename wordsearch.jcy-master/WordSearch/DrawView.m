//
//  DrawView.m
//  WordSearch
//
//  Created by apple on 13-8-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "DrawView.h"
#import "TheSound.h"

@interface DrawView()
{
    UIColor* doneLineColor;
    UIColor* doneFillColor;
    UIColor* curLineColor;
    UIColor* curFillColor;
    CharView* preCv;
    BOOL started;
    CGFloat lineWidth;
    NSString* curStr;
}
@end

#define RGB(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];

@implementation DrawView
@synthesize allCharViews;
@synthesize fromArray;
@synthesize toArray;
@synthesize fromCv;
@synthesize toCv;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
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
        [self drawRR:CGRectMake(beginPoint.x - width/2, beginPoint.y - width/2, width, width) angle:0 lineColor:lineColor fillColor:fillColor];
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
    /*
    doneLineColor = RGB(0,0,0,1);
    doneFillColor = RGB(0xff, 0xa5, 0, 1);
    curLineColor = RGB(0,0,0,1);
    curFillColor = RGB(0xff,0xff,0,1);
     */
    doneLineColor = RGB(33,96,174,1);
    doneFillColor = doneLineColor;
    curLineColor = RGB(0,0,0,1);
    curFillColor = RGB(240,159,40,1);
    //
    started = NO;
    lineWidth = self.frame.size.width*0.8/NNUM;
    fromArray = [[NSMutableArray alloc] init];
    toArray = [[NSMutableArray alloc] init];
}

- (void)newDone:(BOOL)flag
{
    if (flag && fromCv != nil && toCv != nil) {
        [fromArray addObject:fromCv];
        [toArray addObject:toCv];
    }
    fromCv = toCv = nil;
    [self setNeedsDisplay];
}

- (void)resetDraw
{
    fromCv = toCv = nil;
    if (fromArray != nil) {
        [fromArray removeAllObjects];
    }
    if (toArray != nil) {
        [toArray removeAllObjects];
    }
    [self setNeedsDisplay];
}

- (void)drawLines
{
    if (fromArray != nil
        && toArray != nil
        && [fromArray count] == [toArray count]) {
        for (int i = 0; i < [fromArray count]; i++) {
            CharView* b = [fromArray objectAtIndex:i];
            CharView* e = [toArray objectAtIndex:i];
            if (b == e) {
                [self drawRR:CGPointMake(b.center.x, b.center.y) endPoint:CGPointMake(e.center.x, e.center.y) width:lineWidth lineColor:doneLineColor fillColor:doneFillColor];
            }
            else
            {
                [self drawRR:CGPointMake(b.center.x, b.center.y) endPoint:CGPointMake(e.center.x, e.center.y) width:lineWidth lineColor:doneLineColor fillColor:doneFillColor];
            }
        }
    }
    if (fromCv != nil) {
        if (fromCv == toCv) {
            [self drawRR:CGPointMake(fromCv.center.x, fromCv.center.y) endPoint:CGPointMake(fromCv.center.x, fromCv.center.y) width:lineWidth lineColor:curLineColor fillColor:curFillColor];
        }
        else
        {
            [self drawRR:CGPointMake(fromCv.center.x, fromCv.center.y) endPoint:CGPointMake(toCv.center.x, toCv.center.y) width:lineWidth lineColor:curLineColor fillColor:curFillColor];
            
        }
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawLines];
}

- (BOOL)canBePlaced:(CharView*)begin endCv:(CharView*)end
{
    if (begin == nil
        || end == nil) {
        return NO;
    }
    if (begin.row == end.row
        || begin.col == end.col
        || begin.row - end.row == begin.col - end.col
        || begin.row - end.row == end.col - begin.col) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSString*)reverse:(NSString*)str
{
    int len = [str length];
    NSMutableString *strs = [NSMutableString stringWithCapacity:len];
    while (len > 0) {
        char c = [str characterAtIndex:--len];
        NSString *temp = [NSString stringWithFormat:@"%c",c];
        [strs appendString:temp];
    }
    return strs;
}

- (void)updateFindLabel
{
    if (fromCv == nil
        || toCv == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"displayword" object:@""];
    }
    NSMutableString* findstr = [[NSMutableString alloc] init];
    BOOL needReverse = NO;
    if (fromCv.row == toCv.row) {
        int row = fromCv.row;
        int minCol,maxCol;
        if (fromCv.col <= toCv.col) {
            minCol = fromCv.col;
            maxCol = toCv.col;
        }
        else
        {
            minCol = toCv.col;
            maxCol = fromCv.col;
            needReverse = YES;
        }
        for (int col = minCol; col <= maxCol; col++) {
            char c = ((CharView*)[allCharViews objectAtIndex:row*NNUM+col]).c;
            if (col == minCol) {
                [findstr appendFormat:@"%c",c];
            }
            else
            {
                [findstr appendFormat:@"  %c",c];
            }
        }
    }
    else if (fromCv.col == toCv.col)
    {
        int col = fromCv.col;
        int minRow,maxRow;
        if (fromCv.row <= toCv.row)
        {
            minRow = fromCv.row;
            maxRow = toCv.row;
        }
        else
        {
            minRow = toCv.row;
            maxRow = fromCv.row;
            needReverse = YES;
        }
        for (int row = minRow; row <= maxRow; row++) {
            char c = ((CharView*)[allCharViews objectAtIndex:row*NNUM+col]).c;
            if (row == minRow) {
                [findstr appendFormat:@"%c",c];
            }
            else
            {
                [findstr appendFormat:@"  %c",c];
            }
        }
    }
    else if (fromCv.col < toCv.col
             && fromCv.row < toCv.row)
    {
        for (int n = fromCv.row; n <= toCv.row; n++) {
            char c = ((CharView*)[allCharViews objectAtIndex:n*NNUM+fromCv.col+n-fromCv.row]).c;
            if (n == fromCv.row) {
                [findstr appendFormat:@"%c",c];
            }
            else
            {
                [findstr appendFormat:@"  %c",c];
            }
        }
    }
    else if (fromCv.col > toCv.col
             && fromCv.row > toCv.row)
    {
        for (int n = toCv.row; n <= fromCv.row; n++) {
            char c = ((CharView*)[allCharViews objectAtIndex:n*NNUM+toCv.col + n-toCv.row]).c;
            if (n == toCv.row) {
                [findstr appendFormat:@"%c",c];
            }
            else
            {
                [findstr appendFormat:@"  %c",c];
            }
        }
        needReverse = YES;
    }
    else if (fromCv.col < toCv.col
             && fromCv.row > toCv.row)
    {
        for (int n = toCv.row; n <= fromCv.row; n++) {
            char c = ((CharView*)[allCharViews objectAtIndex:n*NNUM+toCv.col - (n-toCv.row)]).c;
            if (n == toCv.row) {
                [findstr appendFormat:@"%c",c];
            }
            else
            {
                [findstr appendFormat:@"  %c",c];
            }
        }
        needReverse = YES;
    }
    else if (fromCv.col > toCv.col
             && fromCv.row < toCv.row)
    {
        for (int n = fromCv.row; n <= toCv.row; n++) {
            char c = ((CharView*)[allCharViews objectAtIndex:n*NNUM+fromCv.col - (n-fromCv.row)]).c;
            if (n == fromCv.row) {
                [findstr appendFormat:@"%c",c];
            }
            else
            {
                [findstr appendFormat:@"  %c",c];
            }
        }
    }
    curStr = needReverse ? [self reverse:findstr] : findstr;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"displayword" object:curStr];
}

- (CharView*)locationToCharView:(CGPoint)loc
{
    ///*
    CGFloat width = self.frame.size.width/NNUM;
    int row = (int)(loc.y/width);
    int col = (int)(loc.x/width);
    if (row == NNUM) {
        row -= 1;
    }
    if (col == NNUM) {
        col -= 1;
    }
    if (row*NNUM+col >= NNUM*NNUM
        || row*NNUM+col < 0) {
        return nil;
    }
    return [self.allCharViews objectAtIndex:row*NNUM+col];
     //*/
    /*
    CGFloat width = self.frame.size.width/(NNUM*4);
    int row = (int)(loc.y/width);
    int col = (int)(loc.x/width);
    if (row == NNUM*4) {
        row -= 1;
    }
    if (col == NNUM*4) {
        col -= 1;
    }
    if (row*NNUM*4+col >= NNUM*NNUM*4*4
        || row*NNUM*4+col < 0) {
        return nil;
    }
    if (row%4 == 0 || row%4 == 3 || col%4 == 0 || col%4 == 3) {
        return nil;
    }
    return [self.allCharViews objectAtIndex:(row/4)*NNUM+col/4];
     */
}

#pragma touchenvent
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CharView* cv = [self locationToCharView:[[touches anyObject] locationInView:self]];
    if (cv == nil) {
        return;
    }
    [cv bounce];
    preCv = cv;
    fromCv = cv;
    toCv = cv;
    started = YES;
    [self updateFindLabel];
    [self setNeedsDisplay];
    [TheSound playSlideSound];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    /*
    if (pos.x < 0
        || pos.y < 0
        || pos.x > self.frame.size.width
        || pos.y > self.frame.size.height) {
        fromCv = nil;
        toCv = nil;
        [self setNeedsDisplay];
        [self updateFindLabel];
        return;
    }
     */
    CharView* cv = [self locationToCharView:pos];
    if (cv == nil) {
        return;
    }
    if (cv != preCv) {
        [cv bounce];
    }
    if (![self canBePlaced:fromCv endCv:cv]) {
        return;
    }
    if (cv == preCv) {
        ;
    }
    else
    {
        preCv = cv;
        toCv = cv;
        [self updateFindLabel];
    }
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    /*
    if (pos.x < 0
        || pos.y < 0
        || pos.x > self.frame.size.width
        || pos.y > self.frame.size.height) {
        fromCv = nil;
        toCv = nil;
        [self setNeedsDisplay];
        [self updateFindLabel];
        return;
    }
     */
    CharView* cv = [self locationToCharView:pos];
    if (cv == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"judgedone" object:curStr];
        return;
    }
    if (![self canBePlaced:fromCv endCv:cv]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"judgedone" object:curStr];
        return;
    }
    if (cv == preCv) {
        ;
    }
    else
    {
        preCv = cv;
        toCv = cv;
        [self updateFindLabel];
    }
    [self setNeedsDisplay];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"judgedone" object:curStr];
}

@end
