//
//  DrawView.h
//  WordSearch
//
//  Created by apple on 13-8-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlockView.h"

enum MOVE_DIRECTION {
    MOVE_LEFT = 0,
    MOVE_RIGHT = 1,
    MOVE_UP = 2,
    MOVE_DOWN = 3
    };

@interface BlockMove : NSObject

@property (assign, nonatomic) int seq;
@property (assign, nonatomic) int step;
@property (assign, nonatomic) int dir;

- (id)initWith:(int)_seq step:(int)_step dir:(int)_dir;

@end

@interface DrawView : UIView

@property (strong, nonatomic) NSArray* allBlockViews;
@property (nonatomic, assign) int cellsize;
@property (nonatomic, assign) int moves;
@property (strong, nonatomic) NSMutableArray* undoMoves;
@property (assign, nonatomic) BOOL succFlag;
@property (assign, nonatomic) BOOL hintFlag;
@property (assign, nonatomic) BOOL undoFlag;
@property (strong, nonatomic) UIImageView* targetView;

- (void)drawRR:(CGRect)rect angle:(CGFloat)angle lineColor:(UIColor*)lineColor fillColor:(UIColor*)fillColor;
- (void)drawRR:(CGPoint)beginPoint endPoint:(CGPoint)endPoint width:(CGFloat)width lineColor:(UIColor*)lineColor fillColor:(UIColor*)fillColor;

- (void)spaceBoard;
- (void)updateSpaceBoard:(BlockView*)bv newx:(int)newx newy:(int)newy undo:(BOOL)undo;
- (void)getMoveRange:(BlockView*)bv begin:(float*)begin end:(float*)end;
- (void)layoutBoard;

- (BlockView*)locationToBlockView:(CGPoint)loc;
- (void)resetDraw;
- (void)statAndReport:(int)type;
- (void)undo;
- (void)hint;
- (BOOL)getNextStep;
- (void)compareTwo;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(BlockView*)bv;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(BlockView*)bv;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event view:(BlockView*)bv;

@end
