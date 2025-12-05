//
//  YouWinView.h
//  Solitaire
//
//  Created by jerry on 2017/8/16.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#define WinDurationKey @"duration"
#define WinMoveKey @"move"
#define WinScoreKey @"score"
#define WinHighScoreKey @"highscore"


@interface YouWinView : UIView<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary * dict;
@property (weak, nonatomic) IBOutlet UIButton *doneB;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableWidthC;
@property (nonatomic, copy) void(^dismissBlock)();
@end
