//
//  StarNode.m
//  PopStar
//
//  Created by apple air on 15/12/9.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import "StarNode.h"

@implementation StarNode

#pragma mark - 判断两个星星颜色是否相同
- (BOOL)isTheSameColorTo:(StarNode *)starNode
{
    if ([self.colorString isEqualToString:starNode.colorString]) {
        return YES;
    }
    return NO;
}


- (instancetype)initWithXTag:(NSInteger)xTag YTag:(NSInteger)yTag
{
    if (self = [super init]) {
        self.xTag = xTag;
        self.yTag = yTag;
    }
    return self;
}
+ (instancetype)spriteWithXTag:(NSInteger)xTag YTag:(NSInteger)yTag
{
    return [[self alloc] initWithXTag:xTag YTag:yTag];
}

#pragma mark - 将自定义类转换为字典
- (NSDictionary *)encodeItem
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInteger:self.xTag] , @"xTag",
            [NSNumber numberWithInteger:self.yTag], @"yTag",
            self.colorString , @"colorString", nil];
}

@end
