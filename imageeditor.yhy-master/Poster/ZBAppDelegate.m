//
//  ZBAppDelegate.m
//  Poster
//
//  Created by shen on 13-8-2.
//  Copyright (c) 2013年 ZBNetwork. All rights reserved.
//

#import "ZBAppDelegate.h"
#import "ZBColorDefine.h"
#import "ZBHomePageViewController.h"

//@import Flurry_iOS_SDK;
#import "ShareService.h"

#import "GlobalSettingManger.h"
#import "PickImagesViewController.h"
#import "iOS12AFAnalyticsBug.h"

@implementation ZBAppDelegate

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [iOS12AFAnalyticsBug fix];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];

    // Override point for customization after application launch.
    self.viewController = [[ZBHomePageViewController alloc] init];
    
//    self.viewController = [[MIPMainViewController alloc] initWithNibName:@"MIPMainViewController" bundle:[NSBundle mainBundle]];

//    self.viewController = [[PickImagesViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    navigationController.navigationBar.tintColor = kNavigationBarColor;
    
//    [Flurry startSession:@"C76SKRNF7945R6V8XBBN"];
//    [Flurry logAllPageViewsForTarget:navigationController];
    
    [AdmobViewController shareAdmobVC];
    [[ShareService defaultService] initializeService];
    
    [[GlobalSettingManger defaultManger] setLanchCnt:[[GlobalSettingManger defaultManger] lanchCnt] + 1];

    self.window.rootViewController = navigationController;
    [self initCoreData];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //这个方法定义的是当应用程序退到后台时将执行的方法，按下home键执行（通知中心来调度）
    //实现此方法的目的是将托管对象上下文存储到数据存储区，防止程序退出时有未保存的数据
    NSError *error;
    if (self.managedObjectContext != nil) {
        //hasChanges方法是检查是否有未保存的上下文更改，如果有，则执行save方法保存上下文
        if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
            NSLog(@"Error: %@,%@",error,[error userInfo]);
            abort();
        }
    }
}

#pragma mark - core data

- (void) initCoreData
{
	NSError *error;
	
	// Path to sqlite file.
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/SortImages.sqlite"];
	NSURL *url = [NSURL fileURLWithPath:path];
	
	// Init the model, coordinator, context
	NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error])
		NSLog(@"Error: %@", [error localizedDescription]);
	else
	{
		self.managedObjectContext = [[NSManagedObjectContext alloc] init];
		[self.managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
	}
    //	[persistentStoreCoordinator release];
}

-(NSManagedObjectModel *)managedObjectModel
{
    if (self.managedObjectModel != nil) {
        return self.managedObjectModel;
    }
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return self.managedObjectModel;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (self.persistentStoreCoordinator != nil) {
        return self.persistentStoreCoordinator;
    }
    
    //得到数据库的路径
    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //CoreData是建立在SQLite之上的，数据库名称需与Xcdatamodel文件同名
    NSURL *storeUrl = [NSURL fileURLWithPath:[docs stringByAppendingPathComponent:@"SortImages.sqlite"]];
    NSError *error = nil;
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    
    return self.persistentStoreCoordinator;
}


@end
