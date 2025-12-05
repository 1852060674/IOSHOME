//
// PauseAlertView.h
//  连连看
//
//  Created by apple air on 15/11/16.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//  自定义的alertview

#import <UIKit/UIKit.h>


// 代理方法 ,点击按钮
@protocol PauseAlertViewDelegate <NSObject>
@optional
-(void)didClickPauseButtonAtIndex:(NSUInteger)index sender:(id)sender;
@end

@interface PauseAlertView : UIView
// 代理
@property (nonatomic,weak) id<PauseAlertViewDelegate> delegate;

- (instancetype)initWithLevel:(int)level score:(int)score;
// 显示view方法
- (void)show;
@end
