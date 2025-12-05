//
//  SolitaireDelegate.h
//  Mahjong
//
//  Created by 昭 陈 on 2017/8/17.
//  Copyright © 2017年 apple. All rights reserved.
//

#ifndef SolitaireDelegate_h
#define SolitaireDelegate_h

@protocol SolitaireDelegate <NSObject>


- (void) afterCloseOverView;
- (void) tapOnDesktop;

@end

#endif /* SolitaireDelegate_h */
