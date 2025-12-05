//
//  MoveAction.h
//  Solitaire
//
//  Created by apple on 13-7-3.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {ACTION_MOVE, ACTION_FACEUP};
enum {POS_STOCK, POS_WASTE, POS_TABEAU, POS_FOUNDATION, POS_RESERVE};

@interface MoveAction : NSObject <NSCoding> 

@property (assign, nonatomic) NSInteger act;
@property (assign, nonatomic) NSInteger from;
@property (assign, nonatomic) NSInteger to;
@property (assign, nonatomic) NSInteger cardcnt;
@property (assign, nonatomic) NSInteger fromIdx;
@property (assign, nonatomic) NSInteger toIdx;

- (id)initWithAct:(NSInteger)act from:(NSInteger)f to:(NSInteger)t cardcnt:(NSInteger)c fromIdx:(NSInteger)fi toIdx:(NSInteger)ti;

@end
