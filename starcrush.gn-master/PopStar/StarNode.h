//
//  StarNode.h
//  PopStar
//
//  Created by apple air on 15/12/9.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface StarNode : SKSpriteNode
@property(nonatomic,assign) NSInteger xTag;
@property(nonatomic,assign) NSInteger yTag;
@property(nonatomic,assign) BOOL isConnected;
@property(nonatomic,strong) NSString *colorString;
@property(nonatomic,assign) BOOL isReadyForPainting;


/**颜色相同否*/
- (BOOL)isTheSameColorTo:(StarNode *)starNode;
/**初始化时设定xTag和yTag*/
- (instancetype)initWithXTag:(NSInteger)xTag YTag:(NSInteger)yTag;
+ (instancetype)spriteWithXTag:(NSInteger)xTag YTag:(NSInteger)yTag;

// 将自定义类转换为字典
- (NSDictionary *)encodeItem;
@end
