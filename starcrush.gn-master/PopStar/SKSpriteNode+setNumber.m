//
//  SKSpriteNode+setNumber.m
//  PopStar
//
//  Created by apple air on 15/12/21.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import "SKSpriteNode+setNumber.h"

@implementation SKSpriteNode (setNumber)
- (void)setNumberWith:(int)number fontWidth:(int)fontWidth fontHeight:(int)fontHeight prefix:(NSString *)prefix
{
    NSMutableArray *array = [NSMutableArray array];
    int temp = 0;
    if (number == 0) {
        [array addObject:@0];
    }
    while (number > 0) {
        temp = number;
        number /= 10;
        int x = temp - number * 10;
        [array addObject:[NSNumber numberWithInt:x]];
    }
//    self.size = CGSizeMake(fontWidth*array.count, fontHeight);
//    self.anchorPoint = CGPointMake(0, 0.5);
    CGFloat marginX = (self.size.width - array.count*fontWidth)/2;
    [self removeAllChildren];
    for (int i = (int)array.count-1; i >= 0; i--) {
        NSNumber *num = [array objectAtIndex:i];
        //        NSLog(@"%@",num);
        NSString *imageName = [NSString stringWithFormat:@"%@_%@",prefix,num];
        SKSpriteNode *numNode = [SKSpriteNode spriteNodeWithImageNamed:imageName];
        //        numNode.anchorPoint = CGPointZero;
        numNode.size = CGSizeMake(fontWidth, fontHeight);
        numNode.zPosition = 2;
        numNode.position = CGPointMake(marginX + fontWidth*(array.count - i)-fontWidth*0.5 - self.size.width*0.5,0);
        //        NSLog(@"num:%@ ,node.width:%f,numNode.x:%f",num,node.size.width,numNode.position.x);
        [self addChild:numNode];
    }
}

- (void)setNumberWith:(int)number fontWidth:(int)fontWidth fontHeight:(int)fontHeight prefix:(NSString *)prefix toLeft:(BOOL)toLeft
{
    NSMutableArray *array = [NSMutableArray array];
    int temp = 0;
    if (number == 0) {
        [array addObject:@0];
    }
    while (number > 0) {
        temp = number;
        number /= 10;
        int x = temp - number * 10;
        [array addObject:[NSNumber numberWithInt:x]];
    }
    //    self.size = CGSizeMake(fontWidth*array.count, fontHeight);
    //    self.anchorPoint = CGPointMake(0, 0.5);
//    CGFloat marginX = (self.size.width - array.count*fontWidth)/2;
    [self removeAllChildren];
    for (int i = (int)array.count-1; i >= 0; i--) {
        NSNumber *num = [array objectAtIndex:i];
        //        NSLog(@"%@",num);
        NSString *imageName = [NSString stringWithFormat:@"%@_%@",prefix,num];
        SKSpriteNode *numNode = [SKSpriteNode spriteNodeWithImageNamed:imageName];
        //        numNode.anchorPoint = CGPointZero;
        numNode.size = CGSizeMake(fontWidth, fontHeight);
        numNode.zPosition = 2;
        numNode.position = CGPointMake(fontWidth*(array.count - i)-fontWidth*0.5 - self.size.width*0.5,0);
        //        NSLog(@"num:%@ ,node.width:%f,numNode.x:%f",num,node.size.width,numNode.position.x);
        [self addChild:numNode];
    }
}
@end
