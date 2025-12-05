//
//  TopHighViewController.h
//  Golf
//
//  Created by apple on 13-9-9.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameStat.h"

@interface TopHighViewController : UIViewController
- (IBAction)dismiss:(id)sender; 
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *name1;
@property (weak, nonatomic) IBOutlet UILabel *name2;
@property (weak, nonatomic) IBOutlet UILabel *name3;
@property (weak, nonatomic) IBOutlet UILabel *name4;
@property (weak, nonatomic) IBOutlet UILabel *name5;
@property (weak, nonatomic) IBOutlet UILabel *score1;
@property (weak, nonatomic) IBOutlet UILabel *score2;
@property (weak, nonatomic) IBOutlet UILabel *score3;
@property (weak, nonatomic) IBOutlet UILabel *score4;
@property (weak, nonatomic) IBOutlet UILabel *score5;
@property (assign, nonatomic) UIInterfaceOrientation ori;

- (void)setTopNameScore:(NSArray*)topscores;
- (void)setVC:(id)vc;

@end
