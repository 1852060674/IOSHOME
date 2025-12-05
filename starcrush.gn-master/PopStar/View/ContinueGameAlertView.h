//
//  ContinueGameAlertView.h
//  PopStar
//
//  Created by apple air on 15/12/23.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ContinueGameAlertViewDelegate <NSObject>
@optional
- (void)didClickContinueGameButtonAtIndex:(NSUInteger)index sender:(id)sender;
@end


@interface ContinueGameAlertView : UIView
@property (nonatomic,weak) id<ContinueGameAlertViewDelegate> delegate;
- (void)show;
@end
