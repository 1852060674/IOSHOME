//
//  NumberStack.h
//  EyeColor4.0
//
//  Created by ZB_Mac on 15-1-21.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectStack : NSObject
-(instancetype)initWithMaxSize:(NSInteger)size andSupportRedo:(BOOL)supportRedo;
-(void)reset;
-(void)jumpToLast;
-(void)jumpToFirst;
-(void)pushObject:(NSObject *)object;
-(NSObject *)getRedoObject;
-(NSObject *)getUndoObject;
-(NSObject *)getTopObject;
-(BOOL)canRedo;
-(BOOL)canUndo;
-(NSInteger)objectCount;
-(NSInteger)deleteRedoObjects;
@end
