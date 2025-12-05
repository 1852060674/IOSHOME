//
//  StandingViewController.h
//  Hearts
//
//  Created by yysdsyl on 13-9-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StandingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *name1;
@property (weak, nonatomic) IBOutlet UILabel *nam2;
@property (weak, nonatomic) IBOutlet UILabel *name3;
@property (weak, nonatomic) IBOutlet UILabel *name4;
@property (weak, nonatomic) IBOutlet UILabel *hand1;
@property (weak, nonatomic) IBOutlet UILabel *hand2;
@property (weak, nonatomic) IBOutlet UILabel *hand3;
@property (weak, nonatomic) IBOutlet UILabel *hand4;
@property (weak, nonatomic) IBOutlet UILabel *total1;
@property (weak, nonatomic) IBOutlet UILabel *total2;
@property (weak, nonatomic) IBOutlet UILabel *total3;
@property (weak, nonatomic) IBOutlet UILabel *total4;
@property (weak, nonatomic) IBOutlet UILabel *handplayed;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (assign, nonatomic) BOOL close;
- (IBAction)dismiss:(id)sender;

- (void)setSocres:(NSArray*)curScores totalScores:(NSArray*)totalScores handCnt:(int)handCnt;

@end
