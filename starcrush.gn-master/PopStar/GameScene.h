//
//  GameScene.h
//  PopStar
//

//  Copyright (c) 2015年 zhongbo network. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene

// 正在显示暂停/游戏结束 ,用处是判断是在显示,点击屏幕不应该有反应
@property (nonatomic,assign)BOOL isShowingPauseView;
@property (nonatomic,assign)BOOL isShowingGameOverView;
@property (nonatomic,weak)UIViewController* viewController;

// 重新开始游戏
- (void)restartGame;
// 给外部调用更新一些东西,目前是更新金币数
- (void)updateSomething;
// 根据存档时存得数据继续游戏
- (void)continueGameWithScore:(int)score level:(int)readLevel starsArray:(NSMutableArray *)starsArray;
// 存档
- (void)saveData;
// 主要是在购买了金币之后更新道具的可用状态
- (void)checkCoinsEnoughTobuy;
@end
