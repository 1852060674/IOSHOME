//
//  PuzzleCell.h
//  WordSearch
//
//  Created by apple on 13-8-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PuzzleCell : UITableViewCell

- (void)selectEffect;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;

@end
