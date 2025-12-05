//
//  YouWinView.m
//  Solitaire
//
//  Created by jerry on 2017/8/16.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "YouWinView.h"
#import "YouWinTableViewCell.h"
#import "Config.h"
@implementation YouWinView
- (void)awakeFromNib {
  [super awakeFromNib];
  self.bgImageView.clipsToBounds = YES;
//  self.bgImageView.layer.cornerRadius = 5;
//  self.bgImageView.layer.borderColor = nil;
//  self.bgImageView.layer.borderWidth = 0;
  [self.doneB setTitle:LocalizedGameStr2(done) forState:(UIControlStateNormal)];
  [self.tableView registerNib:[UINib nibWithNibName:@"YouWinTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];

  self.bgImageView.backgroundColor = [UIColor colorWithRed:0.2 green:0.4 blue:0.2 alpha:1];
  self.bgImageView.layer.borderWidth = 1;
  self.bgImageView.layer.borderColor = [UIColor colorWithRed:0.7 green:0.4 blue:0.1 alpha:1].CGColor;
  self.bgImageView.layer.cornerRadius = 3;

  
}
- (IBAction)close:(id)sender {
  if (self.dismissBlock) {
    self.dismissBlock();
  }
  [self.superview removeFromSuperview];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self.tableView reloadData];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

*/

- (void)setDict:(NSDictionary *)dict {
  _dict = dict;
  [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return floor(CGRectGetHeight(tableView.bounds)/self.dict.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.dict.count;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  YouWinTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  switch (indexPath.row) {
    case 0: {
      cell.keyL.text = LocalizedGameStr2(time_label);
      cell.valueL.text = self.dict[WinDurationKey];
    }
      break;

    case 1: {
      cell.keyL.text = LocalizedGameStr2(move_label);
      cell.valueL.text = self.dict[WinMoveKey];

    }
      break;


    case 2: {
      cell.keyL.text = LocalizedGameStr2(score_label);
      cell.valueL.text = self.dict[WinScoreKey];

    }
      break;

    case 3: {
      cell.keyL.text = LocalizedGameStr2(stat_highest_score);
      cell.valueL.text = self.dict[WinHighScoreKey];


    }
      break;

    default:
      break;
  }

  return cell;

}

@end
