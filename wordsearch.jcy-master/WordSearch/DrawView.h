//
//  DrawView.h
//  WordSearch
//
//  Created by apple on 13-8-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharView.h"

#define NNUM 11

@interface DrawView : UIView

@property (strong, nonatomic) NSArray* allCharViews;
@property (strong, nonatomic) NSMutableArray* fromArray;
@property (strong, nonatomic) NSMutableArray* toArray;
@property (strong, nonatomic) CharView* fromCv;
@property (strong, nonatomic) CharView* toCv;

- (void)drawRR:(CGRect)rect angle:(CGFloat)angle lineColor:(UIColor*)lineColor fillColor:(UIColor*)fillColor;
- (void)drawRR:(CGPoint)beginPoint endPoint:(CGPoint)endPoint width:(CGFloat)width lineColor:(UIColor*)lineColor fillColor:(UIColor*)fillColor;

- (void)drawLines;

- (BOOL)canBePlaced:(CharView*)begin endCv:(CharView*)end;
- (void)updateFindLabel;
- (CharView*)locationToCharView:(CGPoint)loc;
- (void)newDone:(BOOL)flag;
- (void)resetDraw;

@end
