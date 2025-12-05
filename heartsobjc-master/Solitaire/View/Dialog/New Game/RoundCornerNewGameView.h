//
//  RoundCornerNewGameView.h
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "RoundCornerDialogView.h"



@interface RoundCornerNewGameView : RoundCornerDialogView<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forceViewH;
@property (weak, nonatomic) IBOutlet UILabel *forceMessageL;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
