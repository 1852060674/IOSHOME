//
//  PopShareView.h
//  Transsexual
//
//  Created by ZB_Mac on 15/10/21.
//  Copyright © 2015年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopShareView : UIView
@property (weak, nonatomic) IBOutlet UIView *bgMaskView;
@property (weak, nonatomic) IBOutlet UIView *shareContainer;
@property (weak, nonatomic) IBOutlet UILabel *shareOnLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIView *shareContentView;


-(void)show;
-(void)hide;
@end
