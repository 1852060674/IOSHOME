//
//  RoundCornerDialogView.h
//  Solitaire
//
//  Created by jerry on 2017/8/15.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"

@protocol RoundCornerDialogViewDelegate<NSObject>
@optional
- (void)showStatView;
- (void)showRuleView;
- (void)startNewWinDeal;
- (void)startNewRandomDeal;
- (void)replayThisGame;
- (void)toggleIsRoundDrawMove:(BOOL)Moved;
@end

#ifndef IS_IPAD

#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#endif

@interface RoundCornerDialogView : UIView
@property (nonatomic, weak) id <RoundCornerDialogViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
- (void)prepareForPortrait:(NSNumber *)isp ;
- (IBAction)close:(id)sender ;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeButtonCenterX;
@property (nonatomic, assign) BOOL isp;

@end
