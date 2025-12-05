//
//  ImageStack.m
//  EyeColor4.0
//
//  Created by ZB_Mac on 15-1-20.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "ImageStack.h"

@interface ImageStack ()
{
    NSInteger maxSize;
    BOOL isSupportRedo;
}
@property (nonatomic, strong) NSMutableArray* images;
@property (nonatomic, readwrite) NSInteger index;
@end

@implementation ImageStack

-(instancetype)initWithMaxSize:(NSInteger)size andSupportRedo:(BOOL)supportRedo
{
    self = [super init];
    if (self) {
        self.images = [NSMutableArray array];
        self.index = -1;
        maxSize = size;
        isSupportRedo = supportRedo;
    }
    return self;
}
-(void)reset
{
    [self.images removeAllObjects];
    self.index = -1;
}
-(void)pushImage:(UIImage *)image
{
    NSInteger count = self.images.count;
    for (NSInteger idx=self.index+1; idx<count; ++idx) {
        [self.images removeLastObject];
    }
    if (self.images.count >= maxSize && self.images.count > 0) {
        [self.images removeObjectAtIndex:0];
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    [self.images addObject:imageData];
    self.index = self.images.count-1;
}
-(UIImage *)getRedoImage
{
    if ([self canRedo] == NO || isSupportRedo == NO) {
        return nil;
    }
    self.index += 1;
    NSData *imageData = self.images[self.index];
    UIImage *image = [UIImage imageWithData:imageData];
    return image;
}
-(UIImage *)getUndoImage
{
    if ([self canUndo] == NO) {
        return nil;
    }
    self.index -= 1;
    if (self.index < 0 || self.index >= self.images.count) {
        return nil;
    }
    NSData *imageData = self.images[self.index];
    UIImage *image = [UIImage imageWithData:imageData];
    
    if (isSupportRedo == NO) {
        [self.images removeObjectAtIndex:self.index];
    }
    return image;
}
-(BOOL)canRedo
{
    return self.images.count>0 && self.index+1<self.images.count && isSupportRedo;
}
-(BOOL)canUndo
{
    return self.images.count>0 && self.index>=0;
}
@end
