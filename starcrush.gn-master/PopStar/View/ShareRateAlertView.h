//
//  ShareRateAlertView.h
//  PopStar
//
//  Created by apple air on 15/12/22.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ShareRateAlertViewDelegate <NSObject>
@optional
- (void)didClickShareRateButtonAtIndex:(NSUInteger)index sender:(id)sender;
@end

@interface ShareRateAlertView : UIView

@property (nonatomic,weak) id<ShareRateAlertViewDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)image buttonImage:(UIImage *)buttonImage;
- (void)show;
@end
