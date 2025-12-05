//
//  RoundCornerNewGameView.m
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "RoundCornerNewGameView.h"
#import "NewGameTableViewCell.h"
#import "Config.h"
enum {OptNewRandomDeal = 0,
//  OptNewWinDeal,
  OptReplay,
  OptStat};

@implementation RoundCornerNewGameView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
  [super layoutSubviews];
  [self.tableView reloadData];
}

- (void)awakeFromNib {
  [super awakeFromNib];
  [self.tableView registerNib:[UINib nibWithNibName:@"NewGameTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
  self.titleLabel.text = LocalizedGameStr(newgame);
  [self.closeButton setTitle:LocalizedGameStr(cancel) forState:(UIControlStateNormal)];
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return OptStat+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return CGRectGetHeight(tableView.bounds)/(OptStat+1);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NewGameTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  if (indexPath.row == OptNewRandomDeal) {
    cell.nameL.text = LocalizedGameStr(newgame);
  }
//  else if (indexPath.row == OptNewWinDeal) {
//    cell.nameL.text = LocalizedGameStr(pl2);
//  }
  else if (indexPath.row == OptReplay) {
    cell.nameL.text = LocalizedGameStr(replay);
  } else if (indexPath.row == OptStat) {
    cell.nameL.text = LocalizedGameStr(stat);
  }
  cell.sep.hidden = (indexPath.row == 0);
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  if (indexPath.row == OptNewWinDeal && [self.delegate respondsToSelector:@selector(startNewWinDeal)]) {
//      [self.delegate startNewWinDeal];
//  } else

    if (indexPath.row == OptReplay &&[self.delegate respondsToSelector:@selector(replayThisGame)]) {
    [self.delegate replayThisGame];
  }  else if (indexPath.row == OptNewRandomDeal &&[self.delegate respondsToSelector:@selector(startNewRandomDeal)]) {
    [self.delegate startNewRandomDeal];
  } else if (indexPath.row == OptStat &&[self.delegate respondsToSelector:@selector(showStatView)]) {
    [self.delegate showStatView];
  }
  if (indexPath.row < OptStat && [self.delegate respondsToSelector:@selector(toggleIsRoundDrawMove:)]) {
    [self.delegate toggleIsRoundDrawMove:NO];
  }
  [self close:nil];
}

@end
