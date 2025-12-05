//
//  OpViewController.h
//  WordSearch
//
//  Created by apple on 13-8-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

enum { OP_PAUSE=0, OP_NEXT};

@interface OpViewController : UIViewController<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *pauseLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)toHome:(id)sender;
- (IBAction)nextGame:(id)sender;
- (IBAction)continueGame:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar1;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar2;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar3;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar4;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar5;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar6;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar7;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar8;
@property (weak, nonatomic) IBOutlet UIImageView *imageStar9;
@property (weak, nonatomic) IBOutlet UIImageView *imageBottom;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (assign, nonatomic) NSInteger opType;
@property (assign, nonatomic) NSInteger bestTime;

- (void)showStar;
- (void)setType:(NSInteger)type;
- (void)setTime:(NSInteger)time;

@end
