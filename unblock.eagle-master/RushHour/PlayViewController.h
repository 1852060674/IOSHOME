//
//  PlayViewController.h
//  WordSearch
//
//  Created by apple on 13-8-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameData.h"
#import "DrawView.h"
#import "Admob.h"

@interface PlayViewController : UIViewController<AdmobViewControllerDelegate,RewardAdWrapperDelegate>
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UILabel *levelDescLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) IBOutlet UIImageView *stateView;
@property (weak, nonatomic) IBOutlet UIView *statView;
@property (weak, nonatomic) IBOutlet UILabel *flowLabel;
@property (weak, nonatomic) IBOutlet UILabel *movesLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestLabel;
@property (weak, nonatomic) IBOutlet UILabel *pipeLabel;
@property (weak, nonatomic) IBOutlet DrawView *cellView;
@property (weak, nonatomic) IBOutlet UIView *opView;
@property (weak, nonatomic) IBOutlet UILabel *packLabel;
@property (weak, nonatomic) IBOutlet UIButton *prevBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIView *completeView;
@property (weak, nonatomic) IBOutlet UIImageView *targetView;

- (IBAction)replay:(id)sender;
- (IBAction)hint:(id)sender;
- (IBAction)prev:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)close:(id)sender;

- (IBAction)undo:(id)sender;
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *nextLevelBtn;
@property (weak, nonatomic) IBOutlet UILabel *nextPackLevel;
@property (weak, nonatomic) IBOutlet UILabel *winDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *winTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *undoBtn;
@property (weak, nonatomic) IBOutlet UILabel *hintBadge;

///
- (void)removeNotification;
- (void)timeDo;
- (void)layoutFlows;
- (void)updatePreNext;
- (void)updateState;

@end
