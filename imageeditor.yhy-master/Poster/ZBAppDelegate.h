//
//  ZBAppDelegate.h
//  Poster
//
//  Created by shen on 13-8-2.
//  Copyright (c) 2013年 ZBNetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Admob.h"

@class ZBHomePageViewController;

@interface ZBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

//数据模型对象
@property(strong,nonatomic) NSManagedObjectModel *managedObjectModel;
//上下文对象
@property(strong,nonatomic) NSManagedObjectContext *managedObjectContext;
//持久性存储区
@property(strong,nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//初始化Core Data使用的数据库
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

//managedObjectModel的初始化赋值函数
-(NSManagedObjectModel *)managedObjectModel;

//managedObjectContext的初始化赋值函数
-(NSManagedObjectContext *)managedObjectContext;

@end
