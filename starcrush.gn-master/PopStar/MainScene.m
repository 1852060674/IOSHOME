//
//  MainScene.m
//  PopStar
//
//  Created by apple air on 15/12/10.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene {
    // 屏幕大小
    CGSize SCREEN_SIZE;
    
    // 当前关卡
    int level;
    
    // 背景图片
    SKSpriteNode *bgNode;
    // 购买金币按钮
    SKSpriteNode *buyCoinNode;
    // 购买金币按钮
    SKSpriteNode *buyCoinNodePrefix;
    // 当前金币数
//    SKLabelNode *coinLabelNode;
    SKSpriteNode *coinNode;
    SKSpriteNode *coinBgNode;
    // 音效按钮
    SKSpriteNode *soundNode;
    // logo图片
    SKSpriteNode *logoNode;
    // 最高分数关卡开始按钮背景
    SKSpriteNode *startBgNode;
    // 开始按钮
    SKSpriteNode *playNode;
    // 继续游戏按钮
    SKSpriteNode *continueNode;
    // 分享按钮
//    SKSpriteNode *shareNode;
    // 领奖按钮
//    SKSpriteNode *prizeNode;
    // 评分按钮
    SKSpriteNode *jdugeNode;
    
    // 领奖界面
    SKSpriteNode *prizeViewNode;
    
    // 最高到达关卡
//    SKLabelNode *highestLevelNode;
    SKSpriteNode *highestLevelNode;
// 最高分数
//    SKLabelNode *highestScoreNode;
    SKSpriteNode *highestScoreNode;
}

#pragma mark - 重写initWithSize方法,将要设置的东西写在这里
-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SCREEN_SIZE = size;
        // 设置背景层,即游戏界面显示的按钮label等
        [self initBackgroundLayer];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{

}

// 设置背景层,即游戏界面显示的按钮label等
-(void)initBackgroundLayer
{
    
    // 2015年12月29日11:44:26 老板说声音 评价 分享的按钮太大
    CGFloat buttonWidth = SCREEN_SIZE.width * 0.13;
    if (IS_IPAD) {
        buttonWidth = SCREEN_SIZE.width * 0.11;
    }
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    // 背景图片
//    bgNode = [SKSpriteNode spriteNodeWithImageNamed:@"up_bg"];
    bgNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"up_bg"] size:SCREEN_SIZE];
    if (Iphone4) {
        [bgNode setTexture:[SKTexture textureWithImageNamed:@"up_bg_ip4"]];
    }
//    bgNode.size = SCREEN_SIZE;
    bgNode.position = CGPointMake(SCREEN_SIZE.width / 2, SCREEN_SIZE.height / 2);
    [self addChild:bgNode];
    // 购买金币
    buyCoinNodePrefix = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"coin_prefix"] size:CGSizeMake(SCREEN_SIZE.width * 0.45, SCREEN_SIZE.width * 0.45 * 0.31)];
    if (IS_IPAD) {
        buyCoinNodePrefix.size = CGSizeMake(SCREEN_SIZE.width * 0.35, SCREEN_SIZE.width * 0.35 * 0.31);
    }
    if (Iphone4) {
        buyCoinNodePrefix.size = CGSizeMake(SCREEN_SIZE.width * 0.35, SCREEN_SIZE.width * 0.35 * 0.31);
    }
    buyCoinNodePrefix.position = CGPointMake(SCREEN_SIZE.width*0.06+buyCoinNodePrefix.size.width*0.5, SCREEN_SIZE.height * 0.97 - buyCoinNodePrefix.size.height *0.5) ;
    
    buyCoinNodePrefix.zPosition = 1;
    [self addChild:buyCoinNodePrefix];
    
    // 购买金币按钮
    buyCoinNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"coin"] size:CGSizeMake(buyCoinNodePrefix.size.height * 0.57, buyCoinNodePrefix.size.height * 0.57)];
    buyCoinNode.position = CGPointMake(buyCoinNodePrefix.size.width/2 - buyCoinNode.size.width/2  , 0) ;
    buyCoinNode.zPosition = 3;
    [buyCoinNodePrefix addChild:buyCoinNode];

    // 当前金币数背景
    coinBgNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"coin_bg"] size:CGSizeMake(buyCoinNodePrefix.size.width*0.5, buyCoinNodePrefix.size.height * 0.57)];
    coinBgNode.position = CGPointMake(buyCoinNodePrefix.size.width*0.15 - buyCoinNode.size.width/2, 0);
    coinBgNode.zPosition = 1;
    [buyCoinNodePrefix addChild:coinBgNode];
    // 金币数
    coinNode = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:coinBgNode.size];
    coinNode.position = CGPointMake(0, 0);
    int coin = (int)[settings integerForKey:@"coin"];
    coinNode.zPosition = 2;
    [coinNode setNumberWith:coin fontWidth:coinNode.size.height * 0.8 * 0.537 fontHeight:coinNode.size.height * 0.8 prefix:@"home"];
    [coinBgNode addChild:coinNode];
    // 声音按钮
    soundNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"sound"] size:CGSizeMake(buttonWidth, buttonWidth)];
    soundNode.position = CGPointMake(SCREEN_SIZE.width * 0.85, SCREEN_SIZE.height * 0.97 - soundNode.size.height/2);
    soundNode.zPosition = 1;
    [self addChild:soundNode];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        soundNode.texture = [SKTexture textureWithImageNamed:@"sound"];
    } else {
        soundNode.texture = [SKTexture textureWithImageNamed:@"no_sound"];
    }
    
    // logo图片
    SKTexture *logoTexture = [SKTexture textureWithImageNamed:@"logo"];
    logoNode = [SKSpriteNode spriteNodeWithTexture:logoTexture size:CGSizeMake(SCREEN_SIZE.width * 0.8, SCREEN_SIZE.width * 0.8 * 0.684)];
    logoNode.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height * 0.7);
    if (IS_IPAD) {
        logoNode.size = CGSizeMake(SCREEN_SIZE.width * 0.6, SCREEN_SIZE.width * 0.6 * 0.684);
    }
    if (Iphone4) {
        logoNode.size = CGSizeMake(SCREEN_SIZE.width * 0.7, SCREEN_SIZE.width * 0.7 * 0.684);
        logoNode.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height * 0.72);
    }
    logoNode.zPosition = 1;
    [self addChild:logoNode];
    
    // 最高分数关卡开始按钮背景
    startBgNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"start_bg"] size:CGSizeMake(SCREEN_SIZE.width * 0.72, SCREEN_SIZE.width * 0.72 * 0.64)];
    if (IS_IPAD) {
        startBgNode.size = CGSizeMake(SCREEN_SIZE.width * 0.55, SCREEN_SIZE.width * 0.55 * 0.64);
    }
    if (Iphone4) {
        startBgNode.size = CGSizeMake(SCREEN_SIZE.width * 0.7, SCREEN_SIZE.width * 0.7 * 0.64);
    }
    startBgNode.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height * 0.38);
    startBgNode.zPosition = 1;
    [self addChild:startBgNode];
    // 最高到达关卡
    highestLevelNode = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(100, 100)];
    int highestLevel = (int)[settings integerForKey:@"highestLevel"];
    [highestLevelNode setNumberWith:highestLevel fontWidth:startBgNode.size.height* 0.1*0.537 fontHeight:startBgNode.size.height* 0.1 prefix:@"home"];
    highestLevelNode.position = CGPointMake(startBgNode.size.width * 0.17, startBgNode.size.height* 0.333);
    [startBgNode addChild:highestLevelNode];
    // 最高分数
//    highestScoreNode = [SKLabelNode labelNodeWithFontNamed:FONTNAME];
    highestScoreNode = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(100, 100)];
    int highestScore = (int)[settings integerForKey:@"highestScore"];
    [highestScoreNode setNumberWith:highestScore fontWidth:startBgNode.size.height* 0.1*0.537 fontHeight:startBgNode.size.height* 0.1 prefix:@"home"];
    highestScoreNode.position = CGPointMake(startBgNode.size.width * 0.17, startBgNode.size.height* 0.1);
    [startBgNode addChild:highestScoreNode];
    // 开始按钮
    playNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"play"] size:CGSizeMake(startBgNode.size.width * 0.5, startBgNode.size.width * 0.5 * 0.412)];
    playNode.position = CGPointMake(0, - startBgNode.size.height* 0.235);
    playNode.zPosition = 1;
    [startBgNode addChild:playNode];
    // 继续游戏按钮
    continueNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"play"] size:CGSizeMake(SCREEN_SIZE.width/2, SCREEN_SIZE.width/5)];
//    continueNode.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height/2-100);
//    [self addChild:continueNode];
    BOOL isGameOver = [settings boolForKey:@"isGameOver"];
    NSArray *starNodes = [settings objectForKey:@"starNodes"];
    if (isGameOver || !starNodes) {
        continueNode.hidden = YES;
    } else {
        continueNode.hidden = NO;
    }
    // 分享按钮
//    shareNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"share"] size:CGSizeMake(buttonWidth, buttonWidth)];
//    shareNode.position = CGPointMake(SCREEN_SIZE.width * 0.2, SCREEN_SIZE.height * 0.15);
//    shareNode.zPosition = 1;
//    [self addChild:shareNode];
//    // 领奖按钮
//    prizeNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"share"] size:CGSizeMake(64, 64)];
//    prizeNode.position = CGPointMake(SCREEN_SIZE.width * 0.5, SCREEN_SIZE.height * 0.2);
//    [self addChild:prizeNode];
    // 评分按钮
    jdugeNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"rate"] size:CGSizeMake(buttonWidth, buttonWidth)];
//    BOOL bRated = [settings boolForKey:@"already-rated"];
//    if (bRated) {
//        jdugeNode.alpha = 0.5;
//    }
    jdugeNode.position = CGPointMake(SCREEN_SIZE.width * 0.8, SCREEN_SIZE.height * 0.15);
    jdugeNode.zPosition = 1;
    [self addChild:jdugeNode];

//    // 测试图片数字
//    SKSpriteNode *node = [self getNodeWithNumber:12345 fontWidth:20 fontHeight:40];
//    node.position = CGPointMake(100, 100);
//    [self addChild:node];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    // 检查领奖标志位,如果现在是有领奖窗口的,则点击屏幕后侧是没反应的
    if (self.isShowingPrizeView) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
//    if ([playNode containsPoint:location]) {// 开始按钮
//        // 如果上一局gameover了,那么就直接开始新游戏了
//        BOOL isGameOver = [settings boolForKey:@"isGameOver"];
//        NSArray *starNodes = [settings objectForKey:@"starNodes"];
//        NSLog(@"%d",starNodes.count);
//        if (isGameOver || !starNodes) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"restartGame" object:nil];
//        } else {// 否则弹窗提示有存档,点确定就重新开始游戏
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLocalString(@"Message") delegate:self cancelButtonTitle:kLocalString(@"Cancel") otherButtonTitles:kLocalString(@"Sure"), nil];
//            alert.delegate = self;
//            [alert show];
//        }
//    } else
    CGPoint locationForStart = [touch locationInNode:startBgNode];
    if ([playNode containsPoint:locationForStart]) {
        // 如果上一局gameover了,那么就直接开始新游戏了
        BOOL isGameOver = [settings boolForKey:@"isGameOver"];
        NSArray *starNodes = [settings objectForKey:@"starNodes"];
//        NSLog(@"%d",starNodes.count);
        if (isGameOver || !starNodes) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"restartGame" object:nil];
        } else {// 否则弹窗提示有存档,点确定就重新开始游戏
            [[NSNotificationCenter defaultCenter] postNotificationName:@"continueOrRestartGame" object:nil];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLocalString(@"Message") delegate:self cancelButtonTitle:kLocalString(@"Cancel") otherButtonTitles:kLocalString(@"Sure"), nil];
//            alert.delegate = self;
//            [alert show];
        }
        return;
    }
    if ([soundNode containsPoint:location]) { // 声音按钮
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
        BOOL soundFlag = [settings boolForKey:@"sound"];
        soundFlag = !soundFlag;
        [settings setBool:soundFlag forKey:@"sound"];
        [settings synchronize];
        if (soundFlag) {
            soundNode.texture = [SKTexture textureWithImageNamed:@"sound"];
        } else {
            soundNode.texture = [SKTexture textureWithImageNamed:@"no_sound"];
        }
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:@"soundchange" object:[NSNumber numberWithBool:soundFlag]];
    } else if ([jdugeNode containsPoint:location]) { // 评价按钮
        [[NSNotificationCenter defaultCenter] postNotificationName:@"jduge" object:nil];
//    } else if ([shareNode containsPoint:location]) { // 分享按钮
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"share" object:nil];
    } else if ([buyCoinNodePrefix containsPoint:location]) { // 购买金币
        [[NSNotificationCenter defaultCenter] postNotificationName:@"buy" object:nil];
    } else if ([continueNode containsPoint:location] && !continueNode.hidden) { // 继续游戏
        [[NSNotificationCenter defaultCenter] postNotificationName:@"continue" object:nil];
    }
}

- (void)updateSomething
{
    // 更新金币数量
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    int coin = (int)[settings integerForKey:@"coin"];
    [coinNode setNumberWith:coin fontWidth:coinNode.size.height * 0.8 * 0.537 fontHeight:coinNode.size.height * 0.8 prefix:@"home"];
    // 更新继续游戏按钮,控制其是否显示
    BOOL isGameOver = [settings boolForKey:@"isGameOver"];
    NSArray *starNodes = [settings objectForKey:@"starNodes"];
    if (isGameOver || !starNodes) {
        continueNode.hidden = YES;
    } else {
        continueNode.hidden = NO;
    }
//    // 更新分享按钮,分享过了变灰
//    BOOL bRated = [settings boolForKey:@"already-rated"];
//    if (bRated) {
//        jdugeNode.alpha = 0.5;
//    }
    // 更新最高关卡和最高分数
    int highestLevel = (int)[settings integerForKey:@"highestLevel"];
    [highestLevelNode setNumberWith:highestLevel fontWidth:startBgNode.size.height* 0.1*0.537 fontHeight:startBgNode.size.height* 0.1 prefix:@"home"];    int highestScore = (int)[settings integerForKey:@"highestScore"];
    [highestScoreNode setNumberWith:highestScore fontWidth:startBgNode.size.height* 0.1*0.537 fontHeight:startBgNode.size.height* 0.1 prefix:@"home"];}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"continue" object:nil];
            break;
        case 1:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"restartGame" object:nil];
            break;
        default:
            break;
    }
}

@end
