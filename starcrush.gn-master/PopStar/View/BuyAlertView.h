//
//  BuyAlertView.h
//  PopStar
//
//  Created by apple air on 15/12/23.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BuyAlertViewDelegate <NSObject>
@optional
- (void)didClickBuyButtonAtIndex:(NSUInteger)index sender:(id)sender;
@end

@interface BuyAlertView : UIView
@property (nonatomic,weak) id<BuyAlertViewDelegate> delegate;
- (void)show;
@end
