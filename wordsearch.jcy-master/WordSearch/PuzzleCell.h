//
//  PuzzleCell.h
//  WordSearch
//
//  Created by apple on 13-8-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PuzzleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelBestTime;
@property (weak, nonatomic) IBOutlet UIImageView *imageBottom;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar1;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar2;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar3;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar4;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar7;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar5;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar8;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar6;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar9;

- (void)setTime:(NSInteger)time;

@end
