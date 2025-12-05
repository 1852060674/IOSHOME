//
//  StatCell.h
//  Solitaire
//
//  Created by apple on 13-7-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@end
