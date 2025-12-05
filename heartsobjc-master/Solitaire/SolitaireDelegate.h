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
  
- (void)cancelDelay;

@end
