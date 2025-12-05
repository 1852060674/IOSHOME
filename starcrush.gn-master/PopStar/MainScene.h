//
//  MainScene.h
//  PopStar
//
//  Created by apple air on 15/12/10.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MainScene : SKScene <UIAlertViewDelegate>
@property (nonatomic,assign) BOOL isShowingPrizeView;
- (void)updateSomething;
@end
