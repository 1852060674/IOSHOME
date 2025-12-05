//
//  SolitaireDelegate.h
//  Solitaire
//
//  Created by apple on 13-6-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@protocol SolitaireDelegate <NSObject>
 
- (BOOL)flipCard:(Card *)c;
- (BOOL)movedFan:(NSArray *)f toTableau:(uint)t;
- (BOOL)movedCard:(Card *)c toFoundation:(uint)f;
- (void)moveStockToWaste;
- (void)cancelDelay;

@end
