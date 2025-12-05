//
//  GameOverAlertView.h
//  连连看
//
//  Created by apple air on 15/11/16.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//  自定义的alertview

#import <UIKit/UIKit.h>


// 代理方法 ,点击按钮
@protocol GameOverAlertViewDelegate <NSObject>
@optional
-(void)didClickGameOverButtonAtIndex:(NSUInteger)index sender:(id)sender;
@end

@interface GameOverAlertView : UIView
// 代理
@property (nonatomic,weak) id<GameOverAlertViewDelegate> delegate;

//- (instancetype)initWithImage:(UIImage *)image rightButtonImage:(UIImage *)rightButtonImage;
- (instancetype)initWithScore:(int)score level:(int)level;
// 显示view方法
- (void)show;
@end
