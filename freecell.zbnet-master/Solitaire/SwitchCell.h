//
//  SwitchCell.h
//  Solitaire
//
//  Created by apple on 13-6-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *sw;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sc; 

@end
