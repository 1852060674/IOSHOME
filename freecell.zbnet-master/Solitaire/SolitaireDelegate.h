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
 
- (BOOL)movedFan:(NSArray *)f toTableau:(uint)t;
- (BOOL)movedCard:(Card *)c toFoundation:(uint)f;
- (BOOL)movedCard:(Card *)c toStock:(uint)f;
- (void)cancelDelay;

- (void) tapOnDesktop;

@end
