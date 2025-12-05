//
//  SKSpriteNode+setNumber.h
//  PopStar
//
//  Created by apple air on 15/12/21.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (setNumber)
// 将数字中的每一位全部转换成图片,然后将图片拼接成节点
- (void)setNumberWith:(int)number fontWidth:(int)fontWidth fontHeight:(int)fontHeight prefix:(NSString *)prefix;
- (void)setNumberWith:(int)number fontWidth:(int)fontWidth fontHeight:(int)fontHeight prefix:(NSString *)prefix toLeft:(BOOL)toLeft;
@end
