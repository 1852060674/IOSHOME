//
//  GameScene.m
//  PopStar
//
//  Created by apple air on 15/12/8.
//  Copyright (c) 2015年 zhongbo network. All rights reserved.
//

#import "GameScene.h"
#import "StarNode.h"
#import "Admob.h"
#import "AVFoundation/AVFoundation.h"// 音乐

@implementation GameScene {
    // 屏幕大小
    CGSize SCREEN_SIZE;
    
    // 当前关卡
    int level;
    // 当前分数
    int currentScoreGlobal;
    
    // 背景图片
    SKSpriteNode *bgNode;
    // 顶部node,用于存放顶部的控件
    SKSpriteNode *headerNode;
    // 顶部背景node
    SKSpriteNode *headerBgNode;
    // 红绸子,用来存放暂停和第几关
    SKSpriteNode *redSilkNode;
    // 小红花,用来存放第几关
    SKSpriteNode *redFlowerNode;
    // 暂停按钮
    SKSpriteNode *pauseBtn;
    // 关卡node
    SKSpriteNode *currentLevelNode;
    // 目标node
    SKSpriteNode *targetNode;
    // 关卡node
    SKSpriteNode *currentNode;
    // 目标分数标签
    SKLabelNode *targetScoreLabel;
    SKSpriteNode *targetScoreNode;
    // 当前分数标签
//    SKLabelNode *currentScoreLabel;
    SKSpriteNode *currentScoreNode;
    // 当前关卡标签
//    SKLabelNode *currentLevelLabel;
//    // 购买金币按钮
//    SKSpriteNode *buyCoinBtn;
    // 购买金币按钮
    SKSpriteNode *buyCoinNode;
    // 购买金币按钮
    SKSpriteNode *buyCoinNodePrefix;
    // 当前金币数
    //    SKLabelNode *coinLabelNode;
    SKSpriteNode *coinNode;
//    SKSpriteNode *coinBgNode;
    // 当前金币数
//    SKLabelNode *coinLabelNode;
    // 道具锤子按钮
    SKSpriteNode *hammerBtn;
    SKSpriteNode *hammerBadgeNode;
    SKSpriteNode *hammerCostCoinNode;
    // 道具调色板按钮,点击调色板弹出来的候选框
    SKSpriteNode *painterBtn;
    SKSpriteNode *painterBadgeNode;
    SKSpriteNode *painterCostCoinNode;
    SKSpriteNode *arrow;
    SKSpriteNode *paintingBar;
    SKSpriteNode *paintingMask;// 蒙板,盖住后面的东西,只能点击paintingBar

    // 道具重新排序按钮
    SKSpriteNode *randomBtn;
    SKSpriteNode *randomBadgeNode;
    SKSpriteNode *randomCostCoinNode;
    // 每次消除个数和得分显示Label
    SKLabelNode *numAndScoreLabel;
    
    // 锤子选中状态
    BOOL hammerIsSelected;
    // 调色板选中状态
    BOOL painterIsSelected;
    // 锤子和调色板使用次数(每局只能使用3次)
    int hammerUseTimes;
    int painterUseTimes;
    int randomUseTimes;
    // 当前分数是否已经通关
    BOOL isOverLevel;
    // 游戏失败
    BOOL isGameOver;
    
    // 星星正在下落,不能点击
    BOOL isFallingStar;
    
    // 存放游戏方块的容器node
    SKSpriteNode * containerNode;
    // 素材星星Texture
    SKTexture *redStarTexture;
    SKTexture *greenStarTexture;
    SKTexture *blueStarTexture;
    SKTexture *orangeStarTexture;
    SKTexture *purpleStarTexture;

    
    // 星星的宽高
    CGFloat starW;
    CGFloat starH;
    // 候选框中星星之间的间隔
    CGFloat spacing;
    
    // 连起来的星星
    NSMutableArray *connectedStarNodesArray;
    
    // 道具按钮选中时放大缩小的动画
    SKAction *btnSelectedAction;
    
    // 消除时的声音
    SKAction *popSound;
    // 连消6个以上烟花声音
    SKAction *hanabiSound;
    // 胜利时的声音
    SKAction *winSound;
    // 清除声音
    AVAudioPlayer* clearsound;
    
    // 图片数字的宽高
    CGFloat currentLevelHeight;
    CGFloat currentScoreHeight;
    CGFloat targetScoreHeight;
    CGFloat coinHeight;
    
    // 消除时飞出来的星星粒子
    SKEmitterNode *shotStarGlobal;
}


#pragma mark - 重写initWithSize方法,将要设置的东西写在这里
- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SCREEN_SIZE = size;
        // 素材星星Texture
        redStarTexture = [SKTexture textureWithImageNamed:@"red"];
        greenStarTexture = [SKTexture textureWithImageNamed:@"green"];
        blueStarTexture = [SKTexture textureWithImageNamed:@"blue"];
        orangeStarTexture = [SKTexture textureWithImageNamed:@"orange"];
        purpleStarTexture = [SKTexture textureWithImageNamed:@"purple"];
        // 初始化
        connectedStarNodesArray = [NSMutableArray array];
        
        // 道具按钮选中时放大缩小的动画
        btnSelectedAction = [SKAction repeatActionForever:[SKAction sequence:[NSArray arrayWithObjects:[SKAction scaleTo:1.2 duration:1.0],[SKAction scaleTo:0.8 duration:1.0], nil]]];
        // 消除时声音
        popSound = [SKAction playSoundFileNamed:@"pop.wav" waitForCompletion:NO];
        // 连消6个以上烟花声音
        hanabiSound = [SKAction playSoundFileNamed:@"tip.wav" waitForCompletion:NO];
        // 胜利时的声音
        winSound = [SKAction playSoundFileNamed:@"win.wav" waitForCompletion:NO];
        
        NSError *error;
        NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"clear" withExtension:@"wav"];
        clearsound = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        [clearsound setVolume:0.7];
        [clearsound prepareToPlay];
        
        // 消除时飞出来的星星粒子
        shotStarGlobal = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"shotStar" ofType:@"sks"]];
        // 设置背景层,即游戏界面显示的按钮label等
        [self initBackgroundLayer];
        
    }
    return self;
}


#pragma mark - 设置背景层
- (void)initBackgroundLayer
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    // 背景图片
//    bgNode = [SKSpriteNode spriteNodeWithImageNamed:@"up_bg"];
//    bgNode.size = SCREEN_SIZE;
    bgNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"up_bg"] size:SCREEN_SIZE];
    if (Iphone4) {
        [bgNode setTexture:[SKTexture textureWithImageNamed:@"up_bg_ip4"]];
    }
    bgNode.position = CGPointMake(SCREEN_SIZE.width / 2, SCREEN_SIZE.height / 2);
    [self addChild:bgNode];
    
    // 顶部node,用于存放顶部的控件
//    headerNode = [SKSpriteNode spriteNodeWithTexture:nil size:CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.height * 0.2)];
    headerNode = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.width * 0.48)];
    if (IS_IPAD) {
        headerNode.size = CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.width * 0.2);
    }
    if (Iphone4) {
        headerNode.size = CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.width * 0.2);
    }
    headerNode.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height - headerNode.size.height/2);
    [self addChild:headerNode];
    headerNode.zPosition = 1;
//    headerNode.anchorPoint = CGPointZero;

    // 顶部背景按钮
    headerBgNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"header_bg"] size:CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.width * 0.24)];
    if (IS_IPAD) {
        headerBgNode.size = CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.width * 0.1);
    }
    if (Iphone4) {
        headerBgNode.size = CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.width * 0.1);
    }
    headerBgNode.position = CGPointMake(0, headerNode.size.height/2 - headerBgNode.size.height/2);
    headerBgNode.zPosition = 0;
    [headerNode addChild:headerBgNode];
    // 红绸子
    redSilkNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"red_silk"] size:CGSizeMake(headerBgNode.size.height * 1.3 * 0.55, headerBgNode.size.height * 1.3)];
    if (IS_IPAD) {
        redSilkNode.size = CGSizeMake(headerBgNode.size.height * 2 * 0.55, headerBgNode.size.height * 2);
    }
    if (Iphone4) {
        redSilkNode.size = CGSizeMake(headerBgNode.size.height * 2 * 0.55, headerBgNode.size.height * 2);
    }
    redSilkNode.position = CGPointMake(-headerBgNode.size.width/2 + redSilkNode.size.width/2 + headerBgNode.size.width * 0.02, headerBgNode.size.height/2 - redSilkNode.size.height/2);
    redSilkNode.zPosition = 2;
    [headerBgNode addChild:redSilkNode];
    // 暂停按钮
    pauseBtn = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"header_pause"] size:CGSizeMake(redSilkNode.size.width * 0.7, redSilkNode.size.width * 0.7)];
    //    pauseBtn.anchorPoint = CGPointZero;
    pauseBtn.position = CGPointMake(0,pauseBtn.size.height/2);
    pauseBtn.zPosition = 3;
    [redSilkNode addChild:pauseBtn];
    // 小红花
    redFlowerNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"red_flower"] size:CGSizeMake(redSilkNode.size.width * 0.6, redSilkNode.size.width * 0.6)];
    redFlowerNode.position = CGPointMake(0, -redFlowerNode.size.height/2);
    redFlowerNode.zPosition = 3;
    [redSilkNode addChild:redFlowerNode];
    // 当前关卡标签
    level = 1;
    currentLevelNode = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(redFlowerNode.size.width, redFlowerNode.size.height)];
    // 计算字体高度
    currentLevelHeight = currentLevelNode.size.height * 0.5;
    [currentLevelNode setNumberWith:level fontWidth:currentLevelHeight * FontWidthToHeight fontHeight:currentLevelHeight prefix:@"game_header"];
    currentLevelNode.position = CGPointMake(0, 0);
    currentLevelNode.zPosition = 4;
    [redFlowerNode addChild:currentLevelNode];
    // 目标node
    targetNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"target"] size:CGSizeMake(headerBgNode.size.width * 0.35, headerBgNode.size.width * 0.35 * 0.24)];
    targetNode.position = CGPointMake(-headerBgNode.size.width * 0.125, targetNode.size.height * 0.6);
    if (IS_IPAD) {
        targetNode.size = CGSizeMake(headerBgNode.size.width * 0.25, headerBgNode.size.width * 0.25 * 0.24);
        targetNode.position = CGPointMake(-headerBgNode.size.width * 0.24, 0);
    }
    if (Iphone4) {
        targetNode.size = CGSizeMake(headerBgNode.size.width * 0.25, headerBgNode.size.width * 0.25 * 0.24);
        targetNode.position = CGPointMake(-headerBgNode.size.width * 0.24, 0);
    }
    targetNode.zPosition = 3;
    [headerBgNode addChild:targetNode];
    // 当前node
    currentNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"current"] size:targetNode.size];
    currentNode.position = CGPointMake(targetNode.position.x, -currentNode.size.height * 0.6);
    if (IS_IPAD) {
        currentNode.position = CGPointMake(headerBgNode.size.width * 0.05, 0);
    }
    if (Iphone4) {
        currentNode.position = CGPointMake(headerBgNode.size.width * 0.05, 0);
    }
    currentNode.zPosition = 3;
    [headerBgNode addChild:currentNode];
    // 购买金币
    buyCoinNodePrefix = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"head_coin_prefix"] size:CGSizeMake(SCREEN_SIZE.width * 0.4, SCREEN_SIZE.width * 0.4 * 0.31)];
    buyCoinNodePrefix.position = CGPointMake(headerBgNode.size.width * 0.3,0) ;
    if (IS_IPAD) {
        buyCoinNodePrefix.size = CGSizeMake(SCREEN_SIZE.width * 0.28, SCREEN_SIZE.width * 0.28 * 0.31);
        buyCoinNodePrefix.position = CGPointMake(headerBgNode.size.width * 0.35,0) ;
        
    }
    if (Iphone4) {
        buyCoinNodePrefix.size = CGSizeMake(SCREEN_SIZE.width * 0.28, SCREEN_SIZE.width * 0.28 * 0.31);
        buyCoinNodePrefix.position = CGPointMake(headerBgNode.size.width * 0.35,0) ;
        
    }
    buyCoinNodePrefix.zPosition = 3;
    [headerBgNode addChild:buyCoinNodePrefix];
    
    // 购买金币按钮
    buyCoinNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"head_coin"] size:CGSizeMake(buyCoinNodePrefix.size.height * 0.57, buyCoinNodePrefix.size.height * 0.57)];
    buyCoinNode.position = CGPointMake(buyCoinNodePrefix.size.width/2 - buyCoinNode.size.width/2  , 0) ;
    buyCoinNode.zPosition = 3;
    [buyCoinNodePrefix addChild:buyCoinNode];
    
    // 金币数
    coinNode = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(buyCoinNodePrefix.size.width*0.5, buyCoinNodePrefix.size.height * 0.57)];
    coinNode.position = CGPointMake(buyCoinNodePrefix.size.width*0.15 - buyCoinNode.size.width/2, 0);
    int coin = (int)[settings integerForKey:@"coin"];
    coinNode.zPosition = 2;
    // 字体大小
    coinHeight = coinNode.size.height * 0.8;
    [coinNode setNumberWith:coin fontWidth:coinHeight * FontWidthToHeight fontHeight:coinHeight prefix:@"game_header"];
    [buyCoinNodePrefix addChild:coinNode];
    // 目标分数label
    level = 1;
    targetScoreNode = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(targetNode.size.width* 0.6, targetNode.size.height)];
    // 字体大小
    targetScoreHeight = targetScoreNode.size.height * 0.6;
    [targetScoreNode setNumberWith:[self caculateTargetScoreWithLevel:level] fontWidth:targetScoreHeight * FontWidthToHeight fontHeight:targetScoreHeight prefix:@"game_header" toLeft:YES];
    targetScoreNode.position = CGPointMake(targetScoreNode.size.width*0.45, 0);
    targetScoreNode.zPosition = 2;
    [targetNode addChild:targetScoreNode];
    // 当前分数Node
    currentScoreGlobal = 0;
    currentScoreNode = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(currentNode.size.width/2, currentNode.size.height)];
    currentScoreNode.position = CGPointMake(currentScoreNode.size.width*0.45, 0);
    currentScoreNode.zPosition = 2;
    // 字体大小
    currentScoreHeight = currentScoreNode.size.height * 0.6;
    [currentScoreNode setNumberWith:currentScoreGlobal fontWidth:currentScoreHeight * FontWidthToHeight fontHeight:currentScoreHeight prefix:@"game_header" toLeft:YES];
    [currentNode addChild:currentScoreNode];
    // 道具锤子
    CGFloat propsWidth = SCREEN_SIZE.width * 0.1;
    if (IS_IPAD) {
        propsWidth = SCREEN_SIZE.width * 0.08;
    }
    if (Iphone4) {
//        propsWidth = SCREEN_SIZE.width * 0.12;
    }
    CGFloat propsHeight = propsWidth * 1.3;
    CGFloat propsY = -headerNode.size.height*0.2;
    if (Iphone4) {
        propsY = -headerNode.size.height*0.3;
    }
    if (IS_IPAD) {
        propsY = -headerNode.size.height*0.3-20;
    }
    hammerBtn = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"hammer"] size:CGSizeMake(propsWidth, propsHeight)];
    hammerBtn.zPosition = 4;
    hammerBtn.position = CGPointMake(0, propsY);
    if (IS_IPAD) {
        hammerBtn.position = CGPointMake(headerNode.size.width*0.21, propsY);
    }
    if (Iphone4) {
        hammerBtn.position = CGPointMake(headerNode.size.width*0.10, propsY);
    }
    [headerNode addChild:hammerBtn];
    // 道具锤子个数
    hammerBadgeNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"badge_%d",3 - hammerUseTimes]] size:CGSizeMake(hammerBtn.size.width*0.5, hammerBtn.size.width*0.5)];
    hammerBadgeNode.position = CGPointMake(hammerBadgeNode.size.width/2, hammerBadgeNode.size.height*0.8);
    hammerBadgeNode.zPosition = 5;
    [hammerBtn addChild:hammerBadgeNode];
    // 道具锤子花费金币
    hammerCostCoinNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"cost_coin_%d",hammerUseTimes+1]] size:CGSizeMake(hammerBtn.size.width, hammerBtn.size.width * 0.36)];
    hammerCostCoinNode.position = CGPointMake(0, - hammerBtn.size.height * 0.4);
    hammerCostCoinNode.zPosition = 5;
    [hammerBtn addChild:hammerCostCoinNode];
    // 道具调色板
    painterBtn = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"paint"] size:CGSizeMake(propsWidth, propsHeight)];
    painterBtn.zPosition =4;
    painterBtn.position = CGPointMake(headerNode.size.width*0.18, propsY);
    if (IS_IPAD) {
        painterBtn.position = CGPointMake(headerNode.size.width*0.33, propsY);
    }
    if (Iphone4) {
        painterBtn.position = CGPointMake(headerNode.size.width*0.25, propsY);
    }
    [headerNode addChild:painterBtn];
    // 道具调色板个数
    painterBadgeNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"badge_%d",3 - painterUseTimes]] size:CGSizeMake(painterBtn.size.width*0.5, painterBtn.size.width*0.5)];
    painterBadgeNode.position = CGPointMake(painterBadgeNode.size.width/2, painterBadgeNode.size.height*0.8);
    painterBadgeNode.zPosition = 5;
    [painterBtn addChild:painterBadgeNode];
    // 道具调色板花费金币
    painterCostCoinNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"cost_coin_%d",painterUseTimes+1]] size:CGSizeMake(painterBtn.size.width, painterBtn.size.width * 0.36)];
    painterCostCoinNode.position = CGPointMake(0, - hammerBtn.size.height * 0.4);
    painterCostCoinNode.zPosition = 5;
    [painterBtn addChild:painterCostCoinNode];
    // 道具重新排序按钮
    randomBtn = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"refresh"] size:CGSizeMake(propsWidth, propsHeight)];
    randomBtn.zPosition = 4;
    randomBtn.position = CGPointMake(headerNode.size.width*0.36, propsY);
    if (IS_IPAD) {
        randomBtn.position = CGPointMake(headerNode.size.width*0.45, propsY);
    }
    if (Iphone4) {
        randomBtn.position = CGPointMake(headerNode.size.width*0.40, propsY);
    }
    [headerNode addChild:randomBtn];
    // 道具重新排序个数
    randomBadgeNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"badge_%d",3 - randomUseTimes]] size:CGSizeMake(randomBtn.size.width*0.5, randomBtn.size.width*0.5)];
    randomBadgeNode.position = CGPointMake(randomBadgeNode.size.width/2, randomBadgeNode.size.height*0.8);
    randomBadgeNode.zPosition = 5;
    [randomBtn addChild:randomBadgeNode];
    // 道具重新排序花费金币
    randomCostCoinNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed: [NSString stringWithFormat:@"cost_coin_%d",randomUseTimes+1]] size:CGSizeMake(randomBtn.size.width, randomBtn.size.width * 0.36)];
    randomCostCoinNode.position = CGPointMake(0, - randomBtn.size.height * 0.4);
    randomCostCoinNode.zPosition = 5;
    [randomBtn addChild:randomCostCoinNode];

// 更新道具的个数和金币显示
    [self updatePropsBadgeAndCostCoin];
    
    // 存放游戏方块的容器node
    containerNode = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor]size:CGSizeMake(SCREEN_SIZE.width, SCREEN_SIZE.width)];
    if (IS_IPAD) {
        containerNode.size = CGSizeMake(SCREEN_SIZE.width*0.9, SCREEN_SIZE.width*0.9);
    }
    containerNode.color = [UIColor clearColor];
    containerNode.anchorPoint = CGPointZero;
    CGFloat bannerH = ScreenWidth * 50.0/320.0;
    if (IS_IPAD) {
        bannerH = ScreenWidth * 90.0/728.0;
    }
    containerNode.position = CGPointMake((SCREEN_SIZE.width - containerNode.size.width)/2, bannerH);
    containerNode.zPosition = 2;
    [self addChild:containerNode];
    
    //每个方块的大小
    starW = containerNode.size.width/xSize;
    starH = containerNode.size.height/ySize;
    // 添加星星块
    [self setupStarBlocks];
    
    // 显示每次消除时消除个数和得分
    numAndScoreLabel = [SKLabelNode labelNodeWithFontNamed:FONTNAME];
    numAndScoreLabel.fontSize = FONTSIZE;
    if (IS_IPAD) {
        numAndScoreLabel.fontSize = FONTSIZEIPAD;
    }
    numAndScoreLabel.text = @"";
    numAndScoreLabel.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height * 0.69) ;
    if (IS_IPAD) {
        numAndScoreLabel.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height * 0.8) ;
    }
    if (Iphone4) {
        numAndScoreLabel.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height * 0.8) ;
    }
    numAndScoreLabel.zPosition = 3;
    [self addChild:numAndScoreLabel];
    
    // 2.添加指向选中方块的箭头
    arrow = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"arrow"] size:CGSizeMake(starW, starH)];
//    arrow.position = node.position;
    arrow.anchorPoint = CGPointMake(0.5, 0);
    [containerNode addChild:arrow];
    arrow.hidden = YES;
    // 3.添加存放候选方块的条
    paintingBar = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"paint_bg_extended"] size:CGSizeMake(SCREEN_SIZE.width, starH * 1.5)];
    paintingBar.anchorPoint = CGPointMake(0, 0);
//    paintingBar.position = CGPointMake(0, arrow.position.y+arrow.size.height/2);
    [containerNode addChild:paintingBar];
    paintingBar.zPosition = 10;
    arrow.zPosition = 11;
    // 4.在条上放方块和返回按钮
    for (int i = 0; i < 6; i++) {
        // 确定星星的颜色
        SKTexture *starTexture;
        NSString *colorString;
        switch (i) {
            case 0:
                starTexture = redStarTexture;
                colorString = @"red";
                break;
            case 1:
                starTexture = greenStarTexture;
                colorString = @"green";
                break;
            case 2:
                starTexture = blueStarTexture;
                colorString = @"blue";
                break;
            case 3:
                starTexture = orangeStarTexture;
                colorString = @"orange";
                break;
            case 4:
                starTexture = purpleStarTexture;
                colorString = @"purple";
                break;
            case 5:
                starTexture = [SKTexture textureWithImageNamed:@"painter_back"];
                colorString = @"back";
            default:
                break;
        }
        StarNode *starNode = [StarNode spriteNodeWithTexture:starTexture size:CGSizeMake(starW, starH)];
        // 设置xTag和yTag,用于定位,设置颜色字符串,用于比对两个星星
        starNode.colorString = colorString;
//        if ([node.colorString isEqualToString:starNode.colorString]) {
//            starNode.alpha = 0.4;
//        }
        // 设定间隔
        spacing = starW * 0.3;
        // 设定位置
        starNode.position = CGPointMake(i * (starW + spacing)  + starW * 0.5, paintingBar.size.height/2);
        starNode.zPosition = 12;
        [paintingBar addChild:starNode];
        paintingBar.hidden = YES;
    }
    //    NSLog(@"%d",bar.children.count);
    // 5.增加蒙版遮盖后面的东西
    paintingMask = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:SCREEN_SIZE];
    paintingMask.alpha = 0.4;
    paintingMask.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height/2);
    paintingMask.zPosition = 9;
    paintingMask.hidden = NO;
    [self addChild:paintingMask];
    paintingMask.hidden = YES;
    
    //[self checkCoinsEnoughTobuy];
}


-(void)didMoveToView:(SKView *)view {
//    NSLog(@"didMoveToView啦啦啦啦");
//    [self saveData];
}

#pragma mark - 点击屏幕,根据点击的位置进行了大量的判断
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // 测试游戏结束界面
//    NSMutableArray *passArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:level],currentScoreLabel.text,nil];
//    // 发送通知
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"gameover" object:passArray];
// 如果正在显示游戏结束或者暂停界面,是不能点击的 ,或者是星星正在下落
    if (self.isShowingGameOverView || self.isShowingPauseView || isFallingStar) {
        return;
    }
    // 获取触摸点
    UITouch *touch = [touches anyObject];
// 0. 获取触摸点相对于self的坐标点
    CGPoint locationForSelf = [touch locationInNode:self];
// 1. 获取触摸点相对于顶部headerNode的坐标点
    CGPoint locationForHead = [touch locationInNode:headerNode];
// 2. 获取触摸点相对于星星容器的坐标点
    CGPoint locationForStars = [touch locationInNode:containerNode];
// 3. 获取触摸点相对于顶部headBgNode的坐标点,用于判断暂停和购买金币
    CGPoint locationForheaderBg = [touch locationInNode:headerBgNode];
    // 根据坐标点可以得到xTag和yTag,xTag和yTag的取值范围为1-10(xSize ,ySize)
    int xTag = locationForStars.x / starW + 1;
    int yTag = locationForStars.y / starH + 1;
    //    NSLog(@"x:%d,y:%d",x,y);
    // 根据tag获得到点击的星星块,如果点击的地方没有星星块,返回nil
    StarNode *selectedStarNode = [self findStarNodeWithXTag:xTag yTag:yTag];
    //
    
    // 如果调色或者锤子是选中状态,那么如果没有点击下方星星使用道具,那么就取消选择状态
    if (hammerIsSelected || painterIsSelected) {
        if (!selectedStarNode) {// 如果点击的地方不是星星,就取消选中状态
            [self cancelSelectedModeWithBtnName:@"hammerBtn"];
            [self cancelSelectedModeWithBtnName:@"painterBtn"];
            return;
        }
    }
    
    // 点中了涂色条,并且涂色条没有隐藏
    if ([paintingBar containsPoint:locationForStars] && ![paintingBar isHidden]) {
//        NSLog(@"点中了paintingBar");
        CGPoint locationForpaintingBar = [touch locationInNode:paintingBar];
        // 获取索引,从0-5依次是红绿蓝黄紫返回
        int index = locationForpaintingBar.x/(starW + spacing);
        // 将点击了调色板上节点的操作放到一个方法里
        [self operationAfterClickNodeOnPaintingBar:index];
        return;
    } else if ([paintingMask containsPoint:locationForSelf] && ![paintingMask isHidden]) {
        // 如果是选调色板的蒙版, 则不做任何操作
//        NSLog(@"点中了蒙版");
        return;
    }
    
    if ([hammerBtn containsPoint:locationForHead]) {
//        NSLog(@"点中了锤子");
        //check enough coin
        if(![self canOfferedCurrentCost: hammerUseTimes]) {
            //show iap
            if([self showrtiap]) {
                return;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"buy" object:nil];
            return;
        }
        
        if (!hammerIsSelected) {
            [self toSelectedModeWithBtnName:@"hammerBtn"];
        } else {
            [self cancelSelectedModeWithBtnName:@"hammerBtn"];
        }
        return;
    } else if ([painterBtn containsPoint:locationForHead]) {
        //check enough coin
        if(![self canOfferedCurrentCost: painterUseTimes]) {
            //show iap
            if([self showrtiap]) {
                return;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"buy" object:nil];
            return;
        }
        
//        NSLog(@"点中了调色");
        if (!painterIsSelected) {// 如果不是选中状态
            [self toSelectedModeWithBtnName:@"painterBtn"];
        } else {// 已经是选中状态了再次点击取消选中
            [self cancelSelectedModeWithBtnName:@"painterBtn"];
        }
        return;
    } else if ([randomBtn containsPoint:locationForHead]) {
//        NSLog(@"点中了重排");
        if (randomUseTimes >= 3) {// 使用超过3次就不能再点了
            return;
        }
        // 在半透明状态下点击不反应
        if (randomBtn.alpha < 1) {
//            NSLog(@"%f",randomBtn.alpha);
            return;
        }
        
        //check enough coin
        if(![self canOfferedCurrentCost: randomUseTimes]) {
            if([self showrtiap]) {
                return;
            }
            
            //show iap
            [[NSNotificationCenter defaultCenter] postNotificationName:@"buy" object:nil];
            return;
        }
        
        if ([self spendCoinWithBtnName:@"randomBtn" useTimes:randomUseTimes]) {
            [self random:containerNode.children];
        }
    } else if ([headerBgNode containsPoint:locationForHead]) {
        if ([redSilkNode containsPoint:locationForheaderBg]) {
            // 将当前分数和当前关卡传递过去用于显示
            NSMutableArray *passArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:level],[NSNumber numberWithInt:currentScoreGlobal],nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pause" object:passArray];
        } else if ([buyCoinNodePrefix containsPoint:locationForheaderBg]) {
            // 点击了购买按钮
            [[NSNotificationCenter defaultCenter] postNotificationName:@"buy" object:nil];
        }
    }
//    else if ([pauseBtn containsPoint:locationForHead]) {
////        NSLog(@"点中了暂停按钮");
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"pause" object:nil];
//    } else if ([buyCoinNode containsPoint:locationForHead]) {
//        // 点击了购买按钮
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"buy" object:nil];
//    }
    
// 判断点击的地方是否是星星块
    if (selectedStarNode) {
        if (hammerIsSelected) {// 点击星星块时锤子是选中状态
            // 使用锤子消耗金币--2015-12-15 14:48:50
            if (![self spendCoinWithBtnName:@"hammerBtn" useTimes:hammerUseTimes]) {
                return;
            };
            // 取消锤子的选中状态
            [self cancelSelectedModeWithBtnName:@"hammerBtn"];
            // 清空星星连接数组
            [connectedStarNodesArray removeAllObjects];
            // 将选中的星星添加到数组中
            [connectedStarNodesArray addObject:selectedStarNode];
            // 进行消除
            [self operationsBeginCleanAfterSelectWithConnectedArray:connectedStarNodesArray];
            return;
        }
        if (painterIsSelected) {
            // 先取消选中状态
            [self cancelSelectedModeWithBtnName:@"painterBtn"];
            // 在进行一些处理:弹框等等
            [self painterClick:selectedStarNode];
            // 调色板消耗金币要放在operationAfterClickNodeOnPaintingBar:方法中
            // 使用调色板消耗金币--2015-12-15 14:48:50
//            [self spendCoinWithBtnName:@"painterBtn" useTimes:painterUseTimes];
            return;
        }
        // 根据点击的星星快获得与它相同颜色的块
        [connectedStarNodesArray removeAllObjects];
        connectedStarNodesArray = [self findSameColorStarsWithStarNode:selectedStarNode];
        if (connectedStarNodesArray.count > 1) {
            // 将成功点击之后的处理包装在一个方法里
            [self operationsBeginCleanAfterSelectWithConnectedArray:connectedStarNodesArray];
        }
    }

}


#pragma mark - 计算目标分数,根据当前关卡
- (int)caculateTargetScoreWithLevel:(int)currentLevel
{
    int targetScore = 0;
    switch (currentLevel) {
        case 1:
            targetScore = 1000;
            break;
        case 2:
            targetScore = 1000 + 1500;
            break;
        case 3:
            targetScore = 1000 + 1500*2;
            break;
        case 4:
            targetScore = 1000 + 1500*2 + 2000;
            break;
        case 5:
            targetScore = 1000 + 1500*2 + 2000*2;
            break;
        case 6:
            targetScore = 1000 + 1500*2 + 2000*3;
            break;
        case 7:
            targetScore = 1000 + 1500*2 + 2000*3 + 2500;
            break;
        case 8:
            targetScore = 1000 + 1500*2 + 2000*3 + 2500*2;
            break;
        case 9:
            targetScore = 1000 + 1500*2 + 2000*3 + 2500*3;
            break;
        case 10:
            targetScore = 1000 + 1500*2 + 2000*3 + 2500*3 + 3000;
            break;
        case 11:
            targetScore = 1000 + 1500*2 + 2000*3 + 2500*3 + 3000*2;
            break;
        case 12:
            targetScore = 1000 + 1500*2 + 2000*3 + 2500*3 + 3000*3;
            break;
        case 13:
            targetScore = 1000 + 1500*2 + 2000*3 + 2500*3 + 3000*3 + 3500;
            break;
        case 14:
            targetScore = 1000 + 1500*2 + 2000*3 + 2500*3 + 3000*3 + 3500*2;
            break;
        case 15:
            targetScore = 1000 + 1500*2 + 2000*3 + 2500*3 + 3000*3 + 3500*3;
            break;
        default:
//            targetScore = 37000 + 4000*(currentLevel-15);
            // 2015年12月30日16:32:56 调整难度,从第13关开始都是3500
            targetScore = 37000 + 3500*(currentLevel-15);
            break;
    }
    return targetScore;
}


#pragma mark - 根据xTag和yTag查找StarNode
- (StarNode *)findStarNodeWithXTag:(NSInteger)xTag yTag:(NSInteger)yTag
{
    for (StarNode *node in containerNode.children) {
        if ([node isKindOfClass:[StarNode class]]) {
            if (node.xTag == xTag && node.yTag == yTag) {
                return node;
            }
        } else {
//            NSLog(@"不是starNode");
        }
    }
    return nil;
}


#pragma mark - 寻找相同颜色星星
- (NSMutableArray *)findSameColorStarsWithStarNode:(StarNode *)starNode
{
    NSInteger xTag = starNode.xTag;
    NSInteger yTag = starNode.yTag;
    starNode.isConnected = YES;
//    NSLog(@"%ld,%ld",(long)starNode.xTag,(long)starNode.yTag);
    [connectedStarNodesArray addObject:starNode];
    // 对上下左右的节点进行判断,如果该节点颜色一致,而且该
    // 上
    if (yTag < ySize) {
        StarNode *upStarNode = [self findStarNodeWithXTag:xTag yTag:yTag+1];
        if ([starNode isTheSameColorTo:upStarNode] && !(upStarNode.isConnected)) {
//            [upStarNode runAction:[SKAction scaleBy:1.2 duration:0.4]];
//            NSLog(@"上面颜色相同");
            [self findSameColorStarsWithStarNode:upStarNode];
            
        }
    }
    // 下
    if (yTag > 1) {
        StarNode *downStarNode = [self findStarNodeWithXTag:xTag yTag:yTag-1];
        if ([starNode isTheSameColorTo:downStarNode] && !(downStarNode.isConnected)) {
//            [downStarNode runAction:[SKAction scaleBy:1.2 duration:0.4]];
//            NSLog(@"下面颜色相同");
            [self findSameColorStarsWithStarNode:downStarNode];
            
        }
    }
    // 左
    if (xTag > 1) {
        StarNode *leftStarNode = [self findStarNodeWithXTag:xTag-1 yTag:yTag];
        if ([starNode isTheSameColorTo:leftStarNode] && !(leftStarNode.isConnected)) {
//            [leftStarNode runAction:[SKAction scaleBy:1.2 duration:0.4]];
//            NSLog(@"左边颜色相同");
            [self findSameColorStarsWithStarNode:leftStarNode];
            
        }
    }
    // 右
    if (xTag < xSize) {
        StarNode *rightStarNode = [self findStarNodeWithXTag:xTag+1 yTag:yTag];
        if ([starNode isTheSameColorTo:rightStarNode] && !(rightStarNode.isConnected)) {
//            [rightStarNode runAction:[SKAction scaleBy:1.2 duration:0.4]];
//            NSLog(@"右边颜色相同");
            [self findSameColorStarsWithStarNode:rightStarNode];
            
        }
    }
    return connectedStarNodesArray;

}


#pragma mark - 把消除的节点以上的方块往下移动
- (void)moveDownStarHigherThen:(StarNode *)node
{
    
    // 先往上移动1/4格,再下落,效果会好一点
    SKAction *moveDown = [SKAction sequence:[NSArray arrayWithObjects:[SKAction moveByX:0 y:starH/6 duration:0.15],[SKAction moveByX:0 y:-starH-starH/6 duration:0.2],nil]];
    
    //    moveDown.timingMode= SKActionTimingEaseOut;
    for (StarNode *higherNode in containerNode.children) {
        if (![higherNode isKindOfClass:[StarNode class]]) {
//            NSLog(@"不是starnode");
//            return;
        } else if (higherNode.xTag == node.xTag && higherNode.yTag > node.yTag) {
            higherNode.yTag -= 1;
            
            //            [higherNode runAction:[SKAction moveByX:0 y:-starH duration:0.1]];
//            isFallingStar = YES;
            [higherNode runAction:moveDown completion:^{
//                isFallingStar = NO;
            }];
        }
    }
}


#pragma mark - 检查左边为空时,右边星星需要左移
- (void)checkLeftLineIsNull:(StarNode *)node
{
    // 遍历被消除的节点所在的列,看是否还剩余节点
    for (int i = 1; i <= ySize; i++) {
        StarNode *leftNode = [self findStarNodeWithXTag:node.xTag yTag:i];
        if (leftNode) {
            return;
        }
    }
    for (StarNode *rightNode in containerNode.children) {
        if ([rightNode isKindOfClass:[StarNode class]]) {
            if (rightNode.xTag >= node.xTag) {
                [rightNode runAction:[SKAction moveByX:-starW y:0 duration:0.1]];
                rightNode.xTag -= 1;
            }
        }
    }
//    NSLog(@"左边空了");
}


#pragma mark - 根据消除的星星个数计算显示得分
- (void)caculateScoreWithCleanNumber:(int)num
{
    // 每个星星块的分数为消除的星星个数乘以5,然后再乘以星星个数得到本次消除所得总分
    int score = num * 5 * num;
    numAndScoreLabel.text = [NSString stringWithFormat:@"%@%d %@%d",kLocalString(@"Clear"),num,kLocalString(@"Ponits"),score];
//    // 当前分数
//    int currentScore = [currentScoreLabel.text intValue];
//    // 当前分数加上本次得分
//    currentScore += score;
//    // 更新分数标签显示
//    currentScoreLabel.text = [NSString stringWithFormat:@"%d",currentScore];
    
}


#pragma mark - 检查是否通关.如若通关,会有"恭喜通关"Node显示
- (void)checkOverLevel
{
    if (isOverLevel) {
        return;
    }
    int currentScore = currentScoreGlobal;
    int targetScore = [self caculateTargetScoreWithLevel:level];
    if (currentScore >= targetScore) {
//        NSLog(@"恭喜通关");
        isOverLevel = YES;
        // 播放音效
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
            [self runAction:winSound];
        }
        SKSpriteNode *overLevelNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"congratulation"] size:CGSizeMake(SCREEN_SIZE.width/2, SCREEN_SIZE.width/8)];
        overLevelNode.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height/2);
        [self addChild:overLevelNode];
        overLevelNode.zPosition = containerNode.zPosition + 1;
        // 闪烁
        SKAction *fadeOut = [SKAction fadeAlphaTo:0.5 duration:0.15];
        SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.15];
        SKAction *blink = [SKAction repeatAction:[SKAction sequence:@[fadeOut,fadeIn]] count:2];
        // 等待
        SKAction *wait = [SKAction waitForDuration:0.5];
        // 移动缩放
        SKAction *move = [SKAction moveTo:CGPointMake(SCREEN_SIZE.width*0.2, SCREEN_SIZE.height * 0.8) duration:0.5];
        if (IS_IPAD) {
            move = [SKAction moveTo:CGPointMake(SCREEN_SIZE.width*0.3, SCREEN_SIZE.height * 0.88) duration:0.5];
        }
        if (Iphone4) {
            move = [SKAction moveTo:CGPointMake(SCREEN_SIZE.width*0.3, SCREEN_SIZE.height * 0.88) duration:0.5];
        }
        SKAction *scale = [SKAction scaleTo:0.6 duration:0.5];
        SKAction *moveAndScale = [SKAction group:@[move,scale]];
        
        SKAction *blinkWaitMoveAndScale = [SKAction sequence:@[blink,wait,moveAndScale]];
        [overLevelNode runAction:blinkWaitMoveAndScale];
        overLevelNode.name = @"overLevelNode";
        
        [[AdmobViewController shareAdmobVC] recordValidUseCount];
    }
}


#pragma mark - 检查游戏是否已经结束
- (void)checkGameOver
{
// 0. 检查剩余的方块还能不能消除,不能了则游戏结束,往下执行,计算剩余方块分数,判断胜利还是失败. 如果剩余方块还能消除,则直接return,游戏继续
    [connectedStarNodesArray removeAllObjects];
    for (StarNode *node in containerNode.children) {
        if ([node isKindOfClass:[StarNode class]]) {
            [connectedStarNodesArray removeAllObjects];
            connectedStarNodesArray = [self findSameColorStarsWithStarNode:node];
        }
        if (connectedStarNodesArray.count > 1) {
            for (StarNode *node in containerNode.children) {
                if (![node isKindOfClass:[StarNode class]]) {
//                    NSLog(@"不是starnode");
                } else {
                    node.isConnected = NO;
                }
            }
            return;
        }
    }
//    NSLog(@"游戏结束");
    [self operationsWhenCannotClearMore];

}

#pragma mark - 已经消除到了不可以再消除的时候的处理
- (void)operationsWhenCannotClearMore
{
    // 每个节点消失所有时间
    CGFloat secondPerNode = 0.4;
    // 剩余的星星个数
    int count = 0;
    // 遍历剩下的node,获得剩下星星的个数
    for (StarNode *node in containerNode.children) {
        if ([node isKindOfClass:[StarNode class]]) {// 如果是星星
            count ++;
        }
    }
// 1. 处理剩余的方块
    // 剩余的方块数量,用于在遍历的时候加1来计算移除等待时间
    int restNumOfStars = count;
    // 等待移除动作:等待一会儿再移除,不要一次全炸了
    SKAction *waitFor1 = [SKAction waitForDuration:1.5];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *waitFor1ThenRemove = [SKAction sequence:@[waitFor1, remove]];
    // 遍历剩下的node
    for (StarNode *node in containerNode.children) {
        if ([node isKindOfClass:[StarNode class]]) {// 如果是星星
            // 移除节点
            if (count >= 10) {// 如果剩余大于10个了,直接等一会儿全部移除掉
                [node runAction:waitFor1 completion:^{
                    // 添加移除节点时的动画效果
                    [self addParticleEffectWithNode:node];
                    // 声音
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
                        [self runAction:[SKAction runBlock:^{
                            [clearsound play];
                        }]];
                    }
                    [node removeFromParent];
                    // 2015年12月24日18:18:20
                    [self saveData];
                }];
            } else {// 如果剩余的小于10个,则一个一个移除,间隔时间为secondPerNode
                SKAction *wait = [SKAction waitForDuration:(restNumOfStars+1) * secondPerNode];
                SKAction *waitThenRemove = [SKAction sequence:@[wait, remove]];
                [node runAction:wait completion:^{
                    // 添加移除节点时的动画效果
                    [self addParticleEffectWithNode:node];
                    // 声音
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
                        [self runAction:popSound];
                    }
                    [node removeFromParent];
                    // 2015年12月24日18:18:26
                    [self saveData];
                }];
            }
            restNumOfStars --;
        }
    }
    // 计算剩下方块的分数
    int restScore = 2000 - count * count * 20;
    if (restScore < 0) {
        restScore = 0;
    }
// 2. 显示剩余的方块的奖励分数
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.5 duration:0.11];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.11];
    SKAction *blink = [SKAction repeatAction:[SKAction sequence:@[fadeOut,fadeIn]] count:6];
    numAndScoreLabel.text = [NSString stringWithFormat:@"%@%d %@%d",kLocalString(@"LeftStarNum"),count,kLocalString(@"PrizeScore"),restScore];
    [numAndScoreLabel runAction:blink completion:^{
        
    }];
// 3. 计算当前总分
    // 当前分数
//    int currentScore = [currentScoreLabel.text intValue];
    // 当前分数加上本次得分
//    currentScore += restScore;
    currentScoreGlobal += restScore;
    // 更新分数标签显示
//    currentScoreLabel.text = [NSString stringWithFormat:@"%d",currentScore];
    [currentScoreNode setNumberWith:currentScoreGlobal fontWidth:currentScoreHeight * FontWidthToHeight fontHeight:currentScoreHeight prefix:@"game_header" toLeft:YES];
// 4. 与最高分比对,决定是否刷新最高分
    int highestScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highestScore"];
    int highestLevel = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highestLevel"];
    if (currentScoreGlobal > highestScore) {
        [[NSUserDefaults standardUserDefaults] setInteger:currentScoreGlobal forKey:@"highestScore"];
    }
    if (level > highestLevel) {
        [[NSUserDefaults standardUserDefaults] setInteger:level forKey:@"highestLevel"];
    }
    
// 5. 判断与目标分数的关系,决定是弹游戏结束,还是进入下一关
    CGFloat waitTimeToCheck = 2 + count * secondPerNode;
    if (count >= 10) {
        waitTimeToCheck = 4.0;
    }
    [self runAction:[SKAction waitForDuration:waitTimeToCheck] completion:^{
        int targetScore = [self caculateTargetScoreWithLevel:level];
        if (currentScoreGlobal < targetScore) {
            // 存档最高分
            if (currentScoreGlobal > highestScore) {
                [[NSUserDefaults standardUserDefaults] setInteger:currentScoreGlobal forKey:@"highestScore"];
            }
            isGameOver = YES;
            // 存档游戏失败否
            [[NSUserDefaults standardUserDefaults] setBool:isGameOver forKey:@"isGameOver"];
            NSLog(@"游戏失败,未达到目标分数");
            // 游戏失败的时候送金币
            NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
            int coin = (int)[settings integerForKey:@"coin"];
            // 按照分数除以1000来送金币
            coin += currentScoreGlobal/1000;
            [settings setInteger:coin forKey:@"coin"];
            [coinNode setNumberWith:coin fontWidth:coinHeight * FontWidthToHeight fontHeight:coinHeight prefix:@"game_header"];
            // 5.1 游戏结束,发送通知给控制器,传递参数弹游戏结束窗口

            // 将当前分数和当前关卡传递过去用于显示
            NSMutableArray *passArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:level],[NSNumber numberWithInt:currentScoreGlobal],nil];
            // 发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gameover" object:passArray];
        } else {
            // 5.2 达到目标跟,关卡加1,进入关卡
            level += 1;
            [self goToNextLevel:level];
        }
    }];
}


#pragma mark - 选择之后消除所做的一些动作:1 消除 2 上面方块下落 3 检测是否需要左移 4 计算得分 5 检查结束否
- (void)operationsBeginCleanAfterSelectWithConnectedArray:(NSMutableArray *)array
{
//    for (StarNode *node in array) {
//        // 移除节点
//        [node removeFromParent];
//        // 添加移除节点时的动画效果
//        [self addParticleEffectWithNode:node];
//        // 把消除的节点以上的方块往下移动
//        [self moveDownStarHigherThen:node];
//        // 检测左侧的是否空了,否则右侧的星星需要左移
//        [self checkLeftLineIsNull:node];
//    }
//    // 2015年12月29日10:05:51
//    int test = 0;
//    for (SKEmitterNode *node in containerNode.children) {
//        if ([node isKindOfClass:[SKEmitterNode class]]) {
//            test ++;
//        }
//    }
        int i = 0;
        isFallingStar = YES;// 在消除下落的过程中不能点
        CGFloat longestDurantion = 0;
        for (StarNode *node in array) {
            i++;
            CGFloat duration = 0.05*i;
            longestDurantion = MAX(longestDurantion, duration);
            SKAction *wait = [SKAction waitForDuration:duration];
            [node runAction:wait completion:^{
                // 添加移除节点时的动画效果
                [self addParticleEffectWithNode:node];
                [node removeFromParent];
//                // 把消除的节点以上的方块往下移动
                [self moveDownStarHigherThen:node];
                // 检测左侧的是否空了,否则右侧的星星需要左移
                [self checkLeftLineIsNull:node];
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
                    [self runAction:popSound];
                }
            }];
        }
    [self runAction:[SKAction waitForDuration:longestDurantion] completion:^{
        isFallingStar = NO;
    }];

// 达到连消个数的特效
    [self addClearEffectWithCount:(int)array.count];
    // 播放音效
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
//        [self runAction:popSound];
    }
//    SKAction *popSoundNum = [SKAction repeatAction:[SKAction playSoundFileNamed:@"pop.wav" waitForCompletion:NO] count:array.count];
//    [self runAction:popSoundNum];

    // 分数飞上去特效
    
    int num = (int)array.count;
//    SKLabelNode *scoreNode = [SKLabelNode labelNodeWithFontNamed:FONTNAME];
//    scoreNode.text = [NSString stringWithFormat:@"%d",num*5*num];
//    scoreNode.color = [UIColor redColor];
//    scoreNode.position = [[array objectAtIndex:0] position];
//    [containerNode addChild:scoreNode];
//    [scoreNode runAction:[SKAction group:[NSArray arrayWithObjects:[SKAction moveTo:CGPointMake(SCREEN_SIZE.width*0.4,SCREEN_SIZE.width*1.5) duration:2], [SKAction scaleTo:0 duration:2],nil]]];
    SKAction *move = [SKAction moveTo:CGPointMake(SCREEN_SIZE.width*0.4,SCREEN_SIZE.width*1.5) duration:1];
//    SKAction *scale = [SKAction scaleTo:0 duration:1];
//    SKAction *moveAndScale = [SKAction group:@[move,scale]];
    CGFloat bannerH = ScreenWidth * 50.0/320.0;
    if (IS_IPAD) {
        bannerH = ScreenWidth * 90.0/728.0;
    }
    CGFloat desX = SCREEN_SIZE.width * 0.45;
    if (Iphone4) {
        desX = SCREEN_SIZE.width * 0.5;
    }
    CGFloat desY = SCREEN_SIZE.height - headerNode.size.height/2 - bannerH + currentScoreNode.position.y;
    CGPoint destination = CGPointMake(desX, desY);
    for (int i = 0; i < num; i++) {
        SKLabelNode *scoreNode = [SKLabelNode labelNodeWithFontNamed:FONTNAME];
        scoreNode.text = [NSString stringWithFormat:@"%d",5 + 10 * i];
        scoreNode.position = [(StarNode*)[array objectAtIndex:i] position];
        scoreNode.fontSize = 15;
        if (IS_IPAD) {
            scoreNode.fontSize = 30;
        }
        [containerNode addChild:scoreNode];
        SKAction *move = [SKAction moveTo:destination  duration:1+i/10.0];
        [scoreNode runAction:move completion:^{
            [scoreNode removeFromParent];
            currentScoreGlobal += 5 + 10 * i;
            // 更新分数标签显示
            [currentScoreNode setNumberWith:currentScoreGlobal fontWidth:currentScoreHeight * FontWidthToHeight fontHeight:currentScoreHeight prefix:@"game_header" toLeft:YES];
            // 检查是否通关
            [self checkOverLevel];
            // 2015年12月24日10:43:36 因为加分数是在block中延迟进行的,而存档时先存的,所以先存档后加分,会丢失分数,在加分之后再存档一次
            [self saveData];
        }];
//        SKAction *wait = [SKAction waitForDuration:i*0.1];
//        [scoreNode runAction:[SKAction sequence:@[wait,move]] completion:^{
//            [scoreNode removeFromParent];
//        }];
        
    }
    // 弹出总分数
    SKLabelNode *totalScore = [SKLabelNode labelNodeWithFontNamed:FONTNAME];
    totalScore.fontSize = 40;
    if (IS_IPAD) {
        totalScore.fontSize = 60;
    }
    totalScore.text = [NSString stringWithFormat:@"%d",num*num*5];
    // 2015年12月29日14:55:43
    // 如果点击的星星在最左边或者最右边,探出来的分数会有一部分被遮住
    StarNode *star = [array objectAtIndex:0];
    totalScore.position = star.position;
    if (star.xTag == 1) {// 最左
        totalScore.position = CGPointMake(star.position.x + starW, star.position.y);
    } else if (star.xTag == 10){ // 最右
        totalScore.position = CGPointMake(star.position.x - starW, star.position.y);
    }
    [containerNode addChild:totalScore];
    totalScore.zPosition = 23;
    SKAction *moveup = [SKAction moveByX:0 y:80 duration:0.2];
    SKAction *scale = [SKAction scaleTo:0.8 duration:1];
    [totalScore runAction:[SKAction sequence:@[moveup,scale]] completion:^{
        [totalScore removeFromParent];
    }];
    
    // 计算分数
    [self caculateScoreWithCleanNumber:(int)array.count];
    // 上次消除星星块是在block中,有延迟,而这个必须要等上面消除完了再判断
    [self runAction:[SKAction waitForDuration:0.1*array.count] completion:^{
//        // 检查是否通关
//        [self checkOverLevel];
        // 检查游戏是否已经结束
        [self checkGameOver];
    }];

    // 完事之后把ConnectedArray存放连接点的数组清空
//    [array removeAllObjects];
    // 存档,以便下次继续游戏
    [self saveData];
}


#pragma mark - 达到连消个数的特效
- (void)addClearEffectWithCount:(int)count
{
    if (count < 6) {// 小于6个无特效
        return;
    }
    // 后面要换成图片
//    SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:FONTNAME];
    SKSpriteNode *label = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"good"] size:CGSizeMake(100, 100)];
    label.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height * 0.6);
    [self addChild:label];
    label.zPosition = 100;
    if (count >=6 && count <10) {
        label.texture = [SKTexture textureWithImageNamed:@"good"];
        label.size = CGSizeMake(SCREEN_SIZE.width * 0.4, SCREEN_SIZE.width * 0.4 * 0.527);
    } else if (count >= 10 && count < 15) {
        label.texture = [SKTexture textureWithImageNamed:@"cool"];
        label.size = CGSizeMake(SCREEN_SIZE.width * 0.4, SCREEN_SIZE.width * 0.4 * 0.57);
    } else if (count >= 15) {
        label.texture = [SKTexture textureWithImageNamed:@"perfect"];
        label.size = CGSizeMake(SCREEN_SIZE.width * 0.7, SCREEN_SIZE.width * 0.7 * 0.4);
    }
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.5 duration:0.11];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.11];
    SKAction *blink = [SKAction repeatAction:[SKAction sequence:@[fadeOut,fadeIn]] count:4];
    SKAction *wait = [SKAction waitForDuration:1.5];
//    SKAction *move = [SKAction moveByX:0 y:50 duration:1.5];
    [label runAction:[SKAction sequence:@[blink,wait]] completion:^{
        [label removeFromParent];
    }];
    // 播放音效
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sound"]) {
        [self runAction:hanabiSound];
    }
    // 2015年12月29日11:17:25 iPhone4放烟花太卡了,就不放了
    if (!Iphone4) {
        // 放烟花
        [self addHanabiWithPosition:CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height*0.9) color:[UIColor redColor]];
        [self addHanabiWithPosition:CGPointMake(SCREEN_SIZE.width/4, SCREEN_SIZE.height*0.85) color:[UIColor yellowColor]];
        [self addHanabiWithPosition:CGPointMake(SCREEN_SIZE.width/3, SCREEN_SIZE.height*0.8) color:[UIColor blueColor]];
        [self addHanabiWithPosition:CGPointMake(SCREEN_SIZE.width/1.5, SCREEN_SIZE.height*0.7) color:[UIColor orangeColor]];
    }
    
//    SKEmitterNode *hanabi = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"Hanabi" ofType:@"sks"]];
//    hanabi.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height*0.9);
//    [self addChild:hanabi];
//    hanabi.particleColor = [UIColor redColor];
//    // 放烟花
//    SKEmitterNode *hanabi2 = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"Hanabi" ofType:@"sks"]];
//    hanabi2.position = CGPointMake(SCREEN_SIZE.width/4, SCREEN_SIZE.height*0.85);
//    [self addChild:hanabi2];
//    hanabi2.particleColor = [UIColor yellowColor];
//    // 放烟花
//    SKEmitterNode *hanabi3 = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"Hanabi" ofType:@"sks"]];
//    hanabi3.position = CGPointMake(SCREEN_SIZE.width/3, SCREEN_SIZE.height*0.8);
//    [self addChild:hanabi3];
//    hanabi3.particleColor = [UIColor blueColor];
}

#pragma mark - 添加烟花
- (void)addHanabiWithPosition:(CGPoint)position color:(UIColor *)color
{
    SKEmitterNode *hanabi = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle]pathForResource:@"MyParticle" ofType:@"sks"]];
    hanabi.position = position;
    hanabi.particleColor = color;
    [self addChild:hanabi];
    // 2015年12月29日10:45:34 烟花移除
//    [hanabi runAction:[SKAction sequence:@[[SKAction waitForDuration:hanabi.particleLifetime],[SKAction removeFromParent]]]];
    // 2015年12月31日18:46:35
    [hanabi runAction:[SKAction waitForDuration:hanabi.particleLifetime * 0.9] completion:^{
        if (hanabi != nil) {
            [hanabi removeFromParent];
        }
    }];
}

#pragma mark - 选择了调色板之后点中星星块
- (void)painterClick:(StarNode *)node
{
    // 上方的提示语"选择需要变色方块"拿掉
    numAndScoreLabel.text = @"";
    // 星星的准备涂色属性标志位YES
    node.isReadyForPainting = YES;
    // 设定位置,设置不隐藏
    arrow.position = node.position;
    arrow.hidden = NO;
    paintingBar.position = CGPointMake(0, arrow.position.y+arrow.size.height/2);
    paintingBar.hidden = NO;
    paintingMask.hidden = NO;
    for (StarNode *starNode in paintingBar.children) {
        if ([starNode isKindOfClass:[StarNode class]]) {
            if ([starNode.colorString isEqualToString:node.colorString]) {
                starNode.alpha = 0.4;
                return;
            }
        }
    }

}


#pragma mark - 选择了调色板之后点中星星块
- (void)operationAfterClickNodeOnPaintingBar:(int)index
{
    // 红绿蓝黄紫,这个顺序是写死的,要注意!
    //        NSLog(@"%d",index);
    SKTexture *starTexture;
    NSString *colorString;
    switch (index) {
        case 0:
            starTexture = redStarTexture;
            colorString = @"red";
            break;
        case 1:
            starTexture = greenStarTexture;
            colorString = @"green";
            break;
        case 2:
            starTexture = blueStarTexture;
            colorString = @"blue";
            break;
        case 3:
            starTexture = orangeStarTexture;
            colorString = @"orange";
            break;
        case 4:
            starTexture = purpleStarTexture;
            colorString = @"purple";
            break;
        case 5:
            starTexture = [SKTexture textureWithImageNamed:@"back"];
            colorString = @"back";
        default:
            break;
    }
    // 点到了别的地方,直接return
    if (index > 5) {
        return;
    }
    // 找到被选中要替换掉的星星
    for (StarNode *node in containerNode.children) {
        if ([node isKindOfClass:[StarNode class]]) {
            if (node.isReadyForPainting) {// 根据isReadyForPainting找到要背替换的星星
                if (index == 5) { // 点到返回
                    paintingBar.hidden = YES;
                    paintingMask.hidden = YES;
                    arrow.hidden = YES;
                    node.isReadyForPainting = NO;
                    // 在点击时判断了和星星颜色一样的会改alpha,现在要改回去了
                    for (SKSpriteNode *node in paintingBar.children) {
                        node.alpha = 1;
                    }
                    return;
                } else if (![node.colorString isEqualToString:colorString]) {
                    // 使用调色板要花费金币 - 2015年12月15日16:06:18
                    if (![self spendCoinWithBtnName:@"painterBtn" useTimes:painterUseTimes]) {
                        return;
                    }
                    // 进行变色,改变colorString和texture
                    node.colorString = colorString;
                    node.texture = starTexture;
                    // 将准备涂色标志位置为No
                    node.isReadyForPainting = NO;
                    // 隐藏涂色条
                    paintingBar.hidden = YES;
                    paintingMask.hidden = YES;
                    arrow.hidden = YES;
                    // 在点击时判断了和星星颜色一样的会改alpha,现在要改回去了
                    for (SKSpriteNode *node in paintingBar.children) {
                        node.alpha = 1;
                    }
                    return;
                }
            }
        }
    }
}


#pragma mark - 重新排序
- (void)random:(NSArray *)array
{
//    [containerNode runAction:[SKAction sequence:[NSArray arrayWithObjects:[SKAction fadeOutWithDuration:0.2],[SKAction fadeInWithDuration:0.2], nil]]];

    // 数组总个数
    __block NSInteger i = [array count];
    StarNode *tmpNode = [[StarNode alloc] init];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.2];
//    SKAction *scale = [SKAction scaleTo:0 duration:0.2];
//    SKAction *outGroup = [SKAction group:@[fadeOut,scale]];
    [containerNode runAction:fadeOut completion:^{
        // 用while循环,--i先对i执行减一后判断
        while (--i > 0) {
            NSInteger j = arc4random() % (i+1);
            StarNode *node1 = [array objectAtIndex:i];
            StarNode *node2 = [array objectAtIndex:j];
            if ([node1 isKindOfClass:[StarNode class]] && [node2 isKindOfClass:[StarNode class]]) {
                // 交换的本质就是把他们的位置交换,就是position
                // 但是xTag和yTag是通过position计算出来的,也是和位置相关,需要通过xTag和yTag来确定所点区域的星星,所以也要交换
                tmpNode.position = node1.position;
                tmpNode.xTag = node1.xTag;
                tmpNode.yTag = node1.yTag;
                
                node1.position = node2.position;
                node1.xTag = node2.xTag;
                node1.yTag = node2.yTag;
                
                
                node2.position = tmpNode.position;
                node2.xTag = tmpNode.xTag;
                node2.yTag = tmpNode.yTag;
            }
        }
        [containerNode runAction:[SKAction fadeInWithDuration:0.2]];
    }];
}


#pragma mark - 重新开始游戏
- (void)restartGame
{
    // 1. 清除星星块,重新生成
    for (StarNode *node in containerNode.children) {
        if ([node isKindOfClass:[StarNode class]]) {
            [node removeFromParent];
        }
    }
    // 2. 添加星星块
    [self setupStarBlocks];
    // 3. 分数清零
//    currentScoreLabel.text = @"0";
    currentScoreGlobal = 0;
    [currentScoreNode setNumberWith:0 fontWidth:currentScoreHeight * FontWidthToHeight fontHeight:currentScoreHeight prefix:@"game_header" toLeft:YES];
    // 4. 关卡重置
    level = 1;
//    targetScoreLabel.text = [self caculateTargetScoreWithLevel:level];
    [targetScoreNode setNumberWith:[self caculateTargetScoreWithLevel:level] fontWidth:targetScoreHeight * FontWidthToHeight fontHeight:targetScoreHeight prefix:@"game_header" toLeft:YES];
    // 5. 消除得分的label清空
    numAndScoreLabel.text = @"";
    // 6. 当前关卡
//    currentLevelLabel.text = [NSString stringWithFormat:@"%@%d",kLocalString(@"Level"),level];
//    [currentLevelNode setNumberWith:level fontWidth:10 fontHeight:20 prefix:@"game_header"];
    
    [currentLevelNode setNumberWith:level fontWidth:currentLevelHeight * FontWidthToHeight fontHeight:currentLevelHeight prefix:@"game_header"];
    // 7. 删除恭喜通关node
    [[self childNodeWithName:@"overLevelNode"] removeFromParent];
    // 8. 通关标志位置为No
    isOverLevel = NO;
    // 9. 消除*个得*分清空
    numAndScoreLabel.text = @"";
    // 10. 游戏失败标志位
    // 存档游戏失败否
    [[NSUserDefaults standardUserDefaults] setBool:isGameOver forKey:@"isGameOver"];
    isGameOver = NO;
    // 11. 道具的使用次数归零,个数和金币显示更新
    hammerUseTimes = 0;
    painterUseTimes = 0;
    randomUseTimes = 0;
    hammerBtn.alpha = 1.0;
    painterBtn.alpha = 1.0;
    randomBtn.alpha = 1.0;
    // 11.2 道具个数和金币显示更新
    [self updatePropsBadgeAndCostCoin];
    // 12.存档
    [self saveData];

}

#pragma mark - 更新所有3个道具的个数和金币显示
- (void)updatePropsBadgeAndCostCoin
{
    [self updateBadgeNode:hammerBadgeNode andCostCoinNode:hammerCostCoinNode withUseTimes:hammerUseTimes];
    [self updateBadgeNode:painterBadgeNode andCostCoinNode:painterCostCoinNode withUseTimes:painterUseTimes];
    [self updateBadgeNode:randomBadgeNode andCostCoinNode:randomCostCoinNode withUseTimes:randomUseTimes];
    if (hammerUseTimes >= 3) {
        hammerBtn.alpha = 0.4;
    }
    if (painterUseTimes >= 3) {
        painterBtn.alpha = 0.4;
    }
    if (randomUseTimes >= 3) {
        randomBtn.alpha = 0.4;
    }
    
    //[self checkCoinsEnoughTobuy];
}

#pragma mark - 根据使用次数更新一个道具的金币和个数
- (void)updateBadgeNode:(SKSpriteNode *)badgeNode andCostCoinNode:(SKSpriteNode *)costCoinNode withUseTimes:(int)useTimes
{
    badgeNode.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"badge_%d",3 - useTimes]];
    costCoinNode.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"cost_coin_%d",useTimes+1]];
    if (useTimes >=0 && useTimes < 3) {
        badgeNode.alpha = 1;
        costCoinNode.alpha = 1;
    } else {
        badgeNode.alpha = 0;
        costCoinNode.alpha = 0;
    }
    
}


#pragma mark - 进入下一关
- (void)goToNextLevel:(int)nextLevel
{
    int highestLevel = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highestLevel"];
    if (level > highestLevel) {
        [[NSUserDefaults standardUserDefaults] setInteger:level forKey:@"highestLevel"];
    }
//    // 1. 清除特效产生的node
//    for (SKEmitterNode *node in containerNode.children) {
//        if ([node isKindOfClass:[SKEmitterNode class]]) {
//            [node removeFromParent];
//        }
//    }
    // 4. 关卡重置
//    targetScoreLabel.text = [self caculateTargetScoreWithLevel:nextLevel];
    [targetScoreNode setNumberWith:[self caculateTargetScoreWithLevel:nextLevel] fontWidth:targetScoreHeight * FontWidthToHeight fontHeight:targetScoreHeight prefix:@"game_header" toLeft:YES];
    // 1.5 进入下一关的过场动画,显示第几关,目标分数
    SKLabelNode *toNextLevelNode = [SKLabelNode labelNodeWithFontNamed:FONTNAME];
    toNextLevelNode.text = [NSString stringWithFormat:@"%@%d\n%@%d",kLocalString(@"Level"),nextLevel,kLocalString(@"TargetScore"),[self caculateTargetScoreWithLevel:nextLevel]] ;
    toNextLevelNode.fontSize = FONTSIZE;
    if (IS_IPAD) {
        toNextLevelNode.fontSize = FONTSIZEIPAD;
    }
    toNextLevelNode.position = CGPointMake(SCREEN_SIZE.width/2, SCREEN_SIZE.height/2);
    [self addChild:toNextLevelNode];
    toNextLevelNode.zPosition = 20;
//    NSLog(@"%@",toNextLevelNode);
    // 2015年12月29日10:07:25 打印看看有多少个子节点
//    NSLog(@"containerNode的子节点个数:%d",containerNode.children.count);
//    NSLog(@"self的子节点个数:%d",self.children.count);
//    NSLog(@"header的子节点个数:%d",headerNode.children.count);
    
    SKAction *fadeOut = [SKAction fadeAlphaTo:0.5 duration:0.11];
    SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.11];
    SKAction *blink = [SKAction repeatAction:[SKAction sequence:@[fadeOut,fadeIn]] count:4];
    SKAction *wait = [SKAction waitForDuration:1.0];
    SKAction *move = [SKAction moveByX:-SCREEN_SIZE.width y:0 duration:1.5];
    SKAction *blinkAndWaitAndMove = [SKAction sequence:@[blink,wait]];

    [toNextLevelNode runAction:blinkAndWaitAndMove completion:^{
        // 2. 添加星星块
        [self setupStarBlocks];
        // 12.存档
        [self saveData];
        [toNextLevelNode removeFromParent];
    }];
//    // 2. 添加星星块
//    [self setupStarBlocks];
    // 3. 分数清零
//    currentScoreLabel.text = @"0";
    // 进入下一关分数不清零
//    currentScoreGlobal = 0;
//    // 4. 关卡重置
//   targetScoreLabel.text = [self caculateTargetScoreWithLevel:nextLevel];
    // 5. 消除得分的label清空
//    numAndScoreLabel.text = @"";
    
    // 6. 当前关卡
//    currentLevelLabel.text = [NSString stringWithFormat:@"%@%d",kLocalString(@"Level"),nextLevel];
    [currentLevelNode setNumberWith:nextLevel fontWidth:currentLevelHeight * FontWidthToHeight fontHeight:currentLevelHeight prefix:@"game_header"];
    
    // 7. 删除恭喜通关node
    [[self childNodeWithName:@"overLevelNode"] removeFromParent];
    // 8. 通关标志位置为No
    isOverLevel = NO;
    // 9. 消除*个得*分清空
    numAndScoreLabel.text = @"";
    // 10. 游戏失败标志位
    // 存档游戏失败否
    [[NSUserDefaults standardUserDefaults] setBool:isGameOver forKey:@"isGameOver"];
    isGameOver = NO;
    // 11. 道具的使用次数归零
    hammerUseTimes = 0;
    painterUseTimes = 0;
    randomUseTimes = 0;
    hammerBtn.alpha = 1.0;
    painterBtn.alpha = 1.0;
    randomBtn.alpha = 1.0;
    [self updatePropsBadgeAndCostCoin];
//    // 12.存档
//    [self saveData];
    
    if(level % 5 == 0) {
        if([[AdmobViewController shareAdmobVC] show_admob_interstitial:self.viewController placeid:2]) {
            self.view.paused = YES;
        }
    }
}


#pragma mark - 添加设置星星块
- (void)setupStarBlocks
{
    // 2015年12月29日09:58:34 清除星星块,重新生成
    for (StarNode *node in containerNode.children) {
        if ([node isKindOfClass:[StarNode class]]) {
            [node removeFromParent];
        }
    }
    CGSize starSize = CGSizeMake(starW,starH);
    CGFloat longestDuration = 0;
    // 2015年12月29日18:11:50 看看各个颜色的数量
    int rednum = 0,bluenum = 0,greennum = 0,orangenum = 0,purplenum = 0;
    // 按照设定好的横排数量和竖排数量,添加星星
    for (int i = 0; i < xSize; i++) {
        for (int j = 0; j < ySize; j++) {
            // 随机确定星星的颜色
            SKTexture *starTexture;
            NSString *colorString;
            int num = arc4random() % 5;
            switch (num) {
                case 0:
                    starTexture = redStarTexture;
                    colorString = @"red";
                    rednum++;
                    break;
                case 1:
                    starTexture = greenStarTexture;
                    colorString = @"green";
                    greennum++;
                    break;
                case 2:
                    starTexture = blueStarTexture;
                    colorString = @"blue";
                    bluenum++;
                    break;
                case 3:
                    starTexture = orangeStarTexture;
                    colorString = @"orange";
                    orangenum++;
                    break;
                case 4:
                    starTexture = purpleStarTexture;
                    colorString = @"purple";
                    purplenum++;
                    break;
                    
                default:
                    break;
            }
            StarNode *starNode = [StarNode spriteNodeWithTexture:starTexture size:starSize];
            // 设置xTag和yTag,用于定位,设置颜色字符串,用于比对两个星星
            starNode.xTag = i+1;
            starNode.yTag = j+1;
            starNode.colorString = colorString;
            // 将锚点改为0
            //            starNode.anchorPoint = CGPointZero;
            // 设定位置
            CGFloat starX = i * starW + starW * 0.5;
            CGFloat starY = j * starH + starH * 0.5;
//            starNode.position = CGPointMake(i * starW + starW * 0.5, j * starH + starH * 0.5);
//            starNode.position = CGPointMake(starX, starY);
            // 增加移动下来的动画效果
            starNode.position = CGPointMake(starX, SCREEN_SIZE.width/2+starY);
            CGFloat duration = 0.4+i/30.0+j/30.0;
            longestDuration = MAX(longestDuration, duration);
            SKAction *move = [SKAction moveTo:CGPointMake(starX, starY) duration:duration];
            move.timingMode = SKActionTimingEaseInEaseOut;
            [starNode runAction:move];
            [containerNode addChild:starNode];
        }
    }
//    NSLog(@"\n红色个数: %d\n蓝色个数: %d\n黄色个数: %d\n紫色个数: %d\n绿色个数: %d\n",rednum,bluenum,orangenum,purplenum,greennum);
    // 在设置星星块的时候,星星下落的时候不能点击消除
    isFallingStar = YES;
    [self runAction:[SKAction waitForDuration:longestDuration] completion:^{
        isFallingStar = NO;
    }];
    
    // 2015年12月29日18:04:54 一种颜色不能超过30个,不能少于10个
    
    // 针对前几关,设置的简单一些
    // 2015年12月29日11:24:10 老板提出前几关太简单了,先不执行下面的,完全随机好了
//    if (level >= 5) {
    if (level >= 0) {
        return;
    }
    
    int xTagOne = arc4random() % 10 + 1;// 产生1-10的随机数,随机选定一列进行变色
    int yTagOne = arc4random() % 5 + 1;// 产生从1-5的随机数,在选定的列上随机确定从哪一行开始变色
    int xTagTwo = arc4random() % 10 + 1;// 第二列,产生1-10的随机数,随机选定一列进行变色
    // 为了两次产生的不在同一列
    while (xTagTwo == xTagOne) {
        xTagTwo = arc4random() % 10 + 1;// 第二列,产生1-10的随机数,随机选定一列进行变色
    }
    int yTagTwo = arc4random() % 5 + 1;// 第二列,产生从1-5的随机数,在选定的列上随机确定从哪一行开始变色
    int num = 6 - level;
    // 随机确定星星的颜色
    SKTexture *starTexture;
    NSString *colorString;
    int index = arc4random() % 5;
    switch (index) {
        case 0:
            starTexture = redStarTexture;
            colorString = @"red";
            break;
        case 1:
            starTexture = greenStarTexture;
            colorString = @"green";
            break;
        case 2:
            starTexture = blueStarTexture;
            colorString = @"blue";
            break;
        case 3:
            starTexture = orangeStarTexture;
            colorString = @"orange";
            break;
        case 4:
            starTexture = purpleStarTexture;
            colorString = @"purple";
            break;
            
        default:
            break;
    }
    // 随机确定星星的颜色
    SKTexture *starTexture2;
    NSString *colorString2;
    int index2 = arc4random() % 5;
    switch (index2) {
        case 0:
            starTexture2 = redStarTexture;
            colorString2 = @"red";
            break;
        case 1:
            starTexture2 = greenStarTexture;
            colorString2 = @"green";
            break;
        case 2:
            starTexture2 = blueStarTexture;
            colorString2 = @"blue";
            break;
        case 3:
            starTexture2 = orangeStarTexture;
            colorString2 = @"orange";
            break;
        case 4:
            starTexture2 = purpleStarTexture;
            colorString2 = @"purple";
            break;
            
        default:
            break;
    }
    for (StarNode *node in containerNode.children) {
        if ([node isKindOfClass:[StarNode class]]) {
            if (node.xTag == xTagOne && node.yTag >= yTagOne && node.yTag <= yTagOne + num ) {
                node.colorString = colorString;
                node.texture = starTexture;
            }
            if (node.xTag == xTagTwo && node.yTag >= yTagTwo && node.yTag <= yTagTwo + num ) {
                node.colorString =  colorString2;
                node.texture = starTexture2;
            }
        }
    }
}


#pragma mark - 消除时显示特效
- (void)addParticleEffectWithNode:(StarNode *)node
{
    // 粒子特效
    SKEmitterNode *shotStar = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"shotStar" ofType:@"sks"]];
//    SKEmitterNode *shotStar = [shotStarGlobal copy];
    shotStar.position = node.position;
    shotStar.zPosition = node.zPosition + 1;
    shotStar.particleTexture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@_star",node.colorString]];
    // 如果是ipad,星星变大一点
    if (IS_IPAD) {
//        shotStar.particleScale = 0.25;
        // 2016年01月05日12:03:46
        shotStar.particleScale = 0.2;
        shotStar.particleSpeed = 400;
        shotStar.yAcceleration = -500;
    }
    if (Iphone4) {
        shotStar.particleScale = 0.08;
        shotStar.numParticlesToEmit = 4;
        shotStar.particleLifetime = 2.0;
    }
    
    [containerNode addChild:shotStar];
//    NSLog(@"%f",shotStar.particleLifetime);
    
    // 2015年12月29日10:17:34
    // 特效完之后移除
    // 2015年12月31日18:38:21
    // 有可能在执行removeFromParent动作的时候,shotStar已经被释放为nil了,这时就会出现野指针错误.所以将原来的SKAction sequence改为completion,在Block中去判断shotStar != nil才执行removeFromParent
//        [shotStar runAction:[SKAction sequence:@[[SKAction waitForDuration:shotStar.particleLifetime],[SKAction removeFromParent]]]];
    [shotStar runAction:[SKAction waitForDuration:shotStar.particleLifetime * 0.9] completion:^{
        if (shotStar != nil) {
            [shotStar removeFromParent];
        }
    }];
}


#pragma mark - 按钮进入选中模式(锤子,调色板)
- (void)toSelectedModeWithBtnName:(NSString *)btnName
{
    if ([btnName isEqualToString:@"hammerBtn"]) {// 如果选了锤子
        if (hammerUseTimes >= 3) {
            return;
        }
        if (hammerBtn.alpha < 1) {
            return;
        }
        // 锤子选择标志位
        hammerIsSelected = YES;
        // 进行放大缩小动画
        [hammerBtn runAction:btnSelectedAction];
        // 显示得分的label要改成锤子使用提示
        numAndScoreLabel.text = kLocalString(@"HammerUseTips");
    } else if ([btnName isEqualToString:@"painterBtn"]) {
        if (painterUseTimes >= 3) {
            return;
        }
        if (painterBtn.alpha < 1) {
            return;
        }
        // 进入选中状态
        painterIsSelected = YES;
        // 按钮一直进行放大缩小表示调色板进入选中状态
        [painterBtn runAction:btnSelectedAction];
//        NSLog(@"按钮一直进行放大缩小表示调色板进入选中状态");
        // 显示得分的label要改成显示调色板提示
        numAndScoreLabel.text = kLocalString(@"PainterUseTips");
    }
}


#pragma mark - 按钮选择选中模式(锤子,调色板)
- (void)cancelSelectedModeWithBtnName:(NSString *)btnName
{
    if ([btnName isEqualToString:@"hammerBtn"]) {// 如果是锤子
        // 之前已经是选中状态了,则取消选中状态
        hammerIsSelected = NO;
        [hammerBtn removeAllActions];
        [hammerBtn runAction:[SKAction scaleTo:1 duration:0.2]];
    } else if ([btnName isEqualToString:@"painterBtn"]) {
        painterIsSelected = NO;
        [painterBtn removeAllActions];
        [painterBtn runAction:[SKAction scaleTo:1 duration:0.2]];
        numAndScoreLabel.text = @"";
    }
}


#pragma mark - 使用道具花费金币
- (int) getCurrentCost:(int)useTimes {
    // 使用道具需要花费的金币
    int cost = 20;
    // 根据使用次数的不同,花费的金币数量不同
    switch (useTimes) {
        case 0:
            cost = 20;
            break;
        case 1:
            cost = 40;
            break;
        case 2:
            cost = 80;
            break;
        default:
            break;
    }
    return cost;
}

- (BOOL) canOfferedCurrentCost:(int) usesTimes {
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    int coin = (int)[settings integerForKey:@"coin"];
    
    return [self getCurrentCost:usesTimes] <= coin;
}

- (BOOL)spendCoinWithBtnName:(NSString *)btnName useTimes:(int)useTimes
{
    int cost = [self getCurrentCost:useTimes];
    // 读取金币数
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    int coin = (int)[settings integerForKey:@"coin"];
    coin -= cost;
    // 如果当前金币不够购买ƒ
    if (coin < 0) {
//        NSLog(@"金币不够支付,请充值");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:kLocalString(@"NotEnoughCoin") delegate:self cancelButtonTitle:kLocalString(@"OK") otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    // 更新道具个数金币和透明度显示
//    [self updatePropsBadgeAndCostCoin];
    // 花费之后存档
    [settings setInteger:coin forKey:@"coin"];
    // 更新金币数量显示
//    coinLabelNode.text = [NSString stringWithFormat:@"%d",coin];
    [coinNode setNumberWith:coin fontWidth:coinHeight * FontWidthToHeight fontHeight:coinHeight prefix:@"game_header"];
    // 如果使用次数超过3次,则变灰,不能再使用
    if ([btnName isEqualToString:@"hammerBtn"]) {
        hammerUseTimes++;
        if (hammerUseTimes >= 3) {
            hammerBtn.alpha = 0.4;
            hammerBadgeNode.alpha = 0;
            hammerCostCoinNode.alpha = 0;
        } else {
            [self updateBadgeNode:hammerBadgeNode andCostCoinNode:hammerCostCoinNode withUseTimes:hammerUseTimes];
        }
    } else if ([btnName isEqualToString:@"painterBtn"]) {
        painterUseTimes++;
        if (painterUseTimes >= 3) {
            painterBtn.alpha = 0.4;
            painterBadgeNode.alpha = 0;
            painterCostCoinNode.alpha = 0;
        } else {
            [self updateBadgeNode:painterBadgeNode andCostCoinNode:painterCostCoinNode withUseTimes:painterUseTimes];
        }
    } else if ([btnName isEqualToString:@"randomBtn"]) {
        randomUseTimes++;
        if (randomUseTimes >= 3) {
            randomBtn.alpha = 0.4;
            randomBadgeNode.alpha = 0;
            randomCostCoinNode.alpha = 0;
        } else {
            [self updateBadgeNode:randomBadgeNode andCostCoinNode:randomCostCoinNode withUseTimes:randomUseTimes];
        }
    }
    
    //[self checkCoinsEnoughTobuy];
    return YES;
}


#pragma mark - 供外部调用更新
- (void)updateSomething
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    int coin = (int)[settings integerForKey:@"coin"];
//    coinLabelNode.text = [NSString stringWithFormat:@"%d",coin];
    [coinNode setNumberWith:coin fontWidth:coinHeight * FontWidthToHeight fontHeight:coinHeight prefix:@"game_header"];
}


#pragma mark - 存档以便继续游戏进行读取
- (void)saveData
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    // 1.存档星星块
//    NSArray *starsNodes = containerNode.children;
//    [settings setObject:starsNodes forKey:@"starNodes"];
    NSMutableArray *newArray = [NSMutableArray array];
    for (StarNode *node in containerNode.children) {
        if ([node isKindOfClass:[StarNode class]]) {
           [newArray addObject:[node encodeItem]];
        }
    }
    [settings setObject:newArray forKey:@"starNodes"];
    // 2.存档当前关卡和分数
    [settings setObject:[NSNumber numberWithInt:level] forKey:@"level"];
    [settings setObject:[NSNumber numberWithInt:currentScoreGlobal] forKey:@"currentScoreGlobal"];
    // 3. 存档游戏失败否
    [settings setBool:isGameOver forKey:@"isGameOver"];
    // 4. 存档道具的使用次数
    [settings setObject:[NSNumber numberWithInt:hammerUseTimes] forKey:@"hammerUseTimes"];
    [settings setObject:[NSNumber numberWithInt:painterUseTimes] forKey:@"painterUseTimes"];
    [settings setObject:[NSNumber numberWithInt:randomUseTimes] forKey:@"randomUseTimes"];
    [settings synchronize];
}


#pragma mark - 继续游戏
- (void)continueGameWithScore:(int)score level:(int)readLevel starsArray:(NSMutableArray *)starsArray
{
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
// 1. 将生成的所有星星和存档中的星星比对,如果这个位置之前是有星星的 ,那么改texture和colorstring一致,如果之前没有,则remove掉
    // 用来判断是否存在的标志位
    BOOL isExist;
    // 遍历原容器中的所有子节点
    for (StarNode *node in containerNode.children) {
        if ([node isKindOfClass:[StarNode class]]) {// 如果节点是星星块
            isExist = NO;
            for (NSDictionary *continueNode in starsArray) {
                int xTag = [[continueNode objectForKey:@"xTag"] intValue];
                int yTag = [[continueNode objectForKey:@"yTag"] intValue];
                NSString *colorString = [continueNode objectForKey:@"colorString"];
                if (node.xTag == xTag && node.yTag == yTag) {
                    isExist = YES;
                    node.colorString = colorString;
                    if ([colorString isEqualToString:@"red"]) {
                        node.texture = redStarTexture;
                    } else if ([colorString isEqualToString:@"green"]) {
                        node.texture = greenStarTexture;
                    } else if ([colorString isEqualToString:@"blue"]) {
                        node.texture = blueStarTexture;
                    } else if ([colorString isEqualToString:@"orange"]) {
                        node.texture = orangeStarTexture;
                    } else if ([colorString isEqualToString:@"purple"]) {
                        node.texture = purpleStarTexture;
                    }
                }
            }
            if (!isExist) {
                [node removeFromParent];
            }
        }
    }

// 3. 分数读档
//    currentScoreLabel.text = score;
    currentScoreGlobal = score;
    [currentScoreNode setNumberWith:score fontWidth:currentScoreHeight * FontWidthToHeight fontHeight:currentScoreHeight prefix:@"game_header" toLeft:YES];
// 4. 关卡读档
    level = readLevel;
//    currentLevelLabel.text = [NSString stringWithFormat:@"%@%d",kLocalString(@"Level"),level];
    [currentLevelNode setNumberWith:level fontWidth:currentLevelHeight * FontWidthToHeight fontHeight:currentLevelHeight prefix:@"game_header"];

    
//    targetScoreLabel.text = [self caculateTargetScoreWithLevel:level];
    [targetScoreNode setNumberWith:[self caculateTargetScoreWithLevel:level] fontWidth:targetScoreHeight * FontWidthToHeight fontHeight:targetScoreHeight prefix:@"game_header" toLeft:YES];
// 5. 读档道具使用次数
    hammerUseTimes = [[settings objectForKey:@"hammerUseTimes"] intValue];
    painterUseTimes = [[settings objectForKey:@"painterUseTimes"] intValue];
    randomUseTimes = [[settings objectForKey:@"randomUseTimes"] intValue];
// 6. 更新道具次数和金币显示
    [self updatePropsBadgeAndCostCoin];
//    // 5. 消除得分的label清空
//    numAndScoreLabel.text = @"";
//    // 6. 当前关卡
//    currentLevelLabel.text = [NSString stringWithFormat:@"第 %d 关",level];
//    // 7. 删除恭喜通关node
//    [[self childNodeWithName:@"overLevelNode"] removeFromParent];
    // 8. 通关标志位置为No
    isOverLevel = NO;
//    // 9. 消除*个得*分清空
//    numAndScoreLabel.text = @"";
    [self checkGameOver];
}


- (SKSpriteNode *)getNodeWithNumber:(int)number fontWidth:(int)fontWidth fontHeight:(int)fontHeight
{
    NSMutableArray *array = [NSMutableArray array];
    int temp = 0;
    while (number > 0) {
        temp = number;
        number /= 10;
        int x = temp - number * 10;
        [array addObject:[NSNumber numberWithInt:x]];
    }
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(fontWidth*array.count, fontHeight)];
    int i = 1;
    for (NSNumber *num in array) {
        NSString *imageName = [NSString stringWithFormat:@"%@",num];
        SKSpriteNode *numNode = [SKSpriteNode spriteNodeWithImageNamed:imageName];
        numNode.anchorPoint = CGPointZero;
        numNode.position = CGPointMake(node.size.width - fontWidth*i,0);
        numNode.size = CGSizeMake(fontWidth, fontHeight);
        [node addChild:numNode];
        NSLog(@"%@",imageName);
        i++;
    }
    return node;
}

- (void)checkCoinsEnoughTobuy
{
    // 2016年01月08日10:14:23
    // 增加在购买了金币之后更新道具的显示
    // 如果当前金币不够使用道具,那么将道具变灰
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    int coin = (int)[settings integerForKey:@"coin"];
    if (coin < 20) {
        hammerBtn.alpha = 0.4;
        painterBtn.alpha = 0.4;
        randomBtn.alpha = 0.4;
    } else if (coin >= 20 && coin < 40) {
        if (hammerUseTimes >= 1) {
            hammerBtn.alpha = 0.4;
        } else {
            hammerBtn.alpha = 1;
        }
        if (painterUseTimes >= 1) {
            painterBtn.alpha = 0.4;
        } else {
            painterBtn.alpha = 1;
        }
        if (randomUseTimes >= 1) {
            randomBtn.alpha = 0.4;
        } else {
            randomBtn.alpha = 1;
        }
    } else if (coin >= 40 && coin < 80) {
        if (hammerUseTimes >= 2) {
            hammerBtn.alpha = 0.4;
        } else {
            hammerBtn.alpha = 1;
        }
        if (painterUseTimes >= 2) {
            painterBtn.alpha = 0.4;
        } else {
            painterBtn.alpha = 1;
        }
        if (randomUseTimes >= 2) {
            randomBtn.alpha = 0.4;
        } else {
            randomBtn.alpha = 1;
        }
    } else if (coin >= 80) {
        if (hammerUseTimes >= 3) {
            hammerBtn.alpha = 0.4;
        } else {
            hammerBtn.alpha = 1;
        }
        if (painterUseTimes >= 3) {
            painterBtn.alpha = 0.4;
        } else {
            painterBtn.alpha = 1;
        }
        if (randomUseTimes >= 3) {
            randomBtn.alpha = 0.4;
        } else {
            randomBtn.alpha = 1;
        }
    }
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}


- (BOOL) showrtiap {
    if(self.viewController == nil) {
        return FALSE;
    }
    
    if([[AdmobViewController shareAdmobVC] hasInAppPurchased])
        return FALSE;
    GRTService* service = (GRTService*)[[AdmobViewController shareAdmobVC] rtService];
    if([service isRT] || [service isGRT]) {
        return FALSE;
    }
    
    long language = [service getCurrentLanguageType];
    
    NSString* msg = @"get 200 coins";
    if(language == 1)
        msg = @"获得200金币";
    
    return [[AdmobViewController shareAdmobVC] getRT:self.viewController isLock:true rd:msg cb:^{
        NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
        int coin = (int)[settings integerForKey:@"coin"];
        coin += 200;
        [settings setInteger:coin forKey:@"coin"];
        [settings synchronize];
        [coinNode setNumberWith:coin fontWidth:coinHeight * FontWidthToHeight fontHeight:coinHeight prefix:@"game_header"];
    }];
}

@end
