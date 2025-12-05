//
//  UIView+setNumber.m
//  PopStar
//
//  Created by apple air on 15/12/21.
//  Copyright © 2015年 zhongbo network. All rights reserved.
//

#import "UIView+setNumber.h"

@implementation UIView (setNumber)
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
     CGFloat marginX = (self.frame.size.width - array.count*fontWidth)/2;
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fontWidth*array.count, fontHeight);
//    self.backgroundColor = [UIColor blackColor];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    for (int i = (int)array.count-1; i >= 0; i--) {
        NSNumber *num = [array objectAtIndex:i];
        //        NSLog(@"%@",num);
        NSString *imageName = [NSString stringWithFormat:@"%@_%@",prefix,num];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        CGFloat imageViewX = marginX + fontWidth*(array.count-i-1);
        CGFloat imageViewY = (self.frame.size.height - fontHeight)/2;
        imageView.frame = CGRectMake(imageViewX, imageViewY, fontWidth, fontHeight);
        [self addSubview:imageView];
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
//    CGFloat marginX = (self.frame.size.width - array.count*fontWidth)/2;
    //    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fontWidth*array.count, fontHeight);
    //    self.backgroundColor = [UIColor blackColor];
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    for (int i = (int)array.count-1; i >= 0; i--) {
        NSNumber *num = [array objectAtIndex:i];
        //        NSLog(@"%@",num);
        NSString *imageName = [NSString stringWithFormat:@"%@_%@",prefix,num];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        CGFloat imageViewX = fontWidth*(array.count-i-1);
        CGFloat imageViewY = (self.frame.size.height - fontHeight)/2;
        imageView.frame = CGRectMake(imageViewX, imageViewY, fontWidth, fontHeight);
        [self addSubview:imageView];
    }
}
@end
