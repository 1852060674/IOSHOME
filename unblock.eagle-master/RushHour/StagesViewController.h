//
//  StagesViewController.h
//  Flow
//
//  Created by yysdsyl on 13-10-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_NUM 7

@interface StagesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *stageName;
@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (nonatomic, assign) int seq;

- (void)layoutLevelsViews;
- (void)updateStates;

@end
