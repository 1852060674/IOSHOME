//
//  ScoreInfoView.h
//  Hearts
//
//  Created by yysdsyl on 13-9-16.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreInfoView : UIView

@property (strong, nonatomic) UIView* baseView;
@property (strong, nonatomic) UILabel* nameLabel;
@property (strong, nonatomic) UILabel* scoreLabel;

- (id)initWithFrame:(CGRect)frame withIntValue:(int)value ;

- (void)setInfo:(NSString*)name curscore:(int)curscore totalscore:(int)totalscore;
-(void) adjustUI;
@end
