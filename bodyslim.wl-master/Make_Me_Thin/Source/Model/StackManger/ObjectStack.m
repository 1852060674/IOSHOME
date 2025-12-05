//
//  NumberStack.m
//  EyeColor4.0
//
//  Created by ZB_Mac on 15-1-21.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "ObjectStack.h"

@interface ObjectStack ()
{
    NSInteger maxSize;
    BOOL isSupportRedo;
    BOOL _canPopFirstObject;
}
@property (nonatomic, strong) NSMutableArray* objects;
@property (nonatomic, readwrite) NSInteger index;
@end

@implementation ObjectStack

-(instancetype)initWithMaxSize:(NSInteger)size andSupportRedo:(BOOL)supportRedo andCanPopFirstObject:(BOOL)canPop
{
    self = [super init];
    if (self) {
        self.objects = [NSMutableArray array];
        self.index = -1;
        maxSize = size;
        isSupportRedo = supportRedo;
        _canPopFirstObject = canPop;
    }
    return self;
}

-(instancetype)initWithMaxSize:(NSInteger)size andSupportRedo:(BOOL)supportRedo
{
    return [self initWithMaxSize:size andSupportRedo:supportRedo andCanPopFirstObject:NO];
}
-(void)reset
{
    if (_canPopFirstObject) {
        [self.objects removeAllObjects];
        self.index = -1;
    }
    else if (self.objects.count>=1)
    {
        [self.objects removeObjectsInRange:NSMakeRange(1, self.objects.count-1)];
        self.index = 0;
    }
}
-(void)pushObject:(NSObject *)object
{
    if (object == nil) {
        return;
    }
    NSInteger count = self.objects.count;
    for (NSInteger idx=self.index+1; idx<count; ++idx) {
        [self.objects removeLastObject];
    }
    if (self.objects.count >= maxSize && self.objects.count > 0) {
        [self.objects removeObjectAtIndex:maxSize/2.0];
    }
    [self.objects addObject:object];
    self.index = self.objects.count-1;
}
-(NSObject *)getRedoObject
{
    if ([self canRedo] == NO || isSupportRedo == NO) {
        return nil;
    }
    self.index += 1;
    NSObject *object = self.objects[self.index];
    return object;
}
-(NSObject *)getUndoObject
{
    if ([self canUndo] == NO) {
        return nil;
    }
    self.index -= 1;
    if (self.index < 0 || self.index >= self.objects.count) {
        return nil;
    }
    NSObject *object = self.objects[self.index];
    
    if (isSupportRedo == NO) {
        [self.objects removeObjectAtIndex:self.index];
    }
    return object;
}

-(NSObject *)getTopObject
{
    if (self.index < 0 || self.index >= self.objects.count) {
        return nil;
    }
    return self.objects[self.index];
}

-(BOOL)canRedo
{
    return self.objects.count>0 && self.index+1<self.objects.count && isSupportRedo;
}
-(BOOL)canUndo
{
    return self.objects.count>(_canPopFirstObject?0:1) && self.index>=(_canPopFirstObject?0:1);
}
@end
