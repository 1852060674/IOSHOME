//
//  BHImageDataModeld.m
//  PicFrame
//
//  Created by shen on 13-6-18.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHImageDataModeld.h"
#import "ZBAppDelegate.h"
#import "ZBCommonDefine.h"

@interface BHImageDataModeld()

@property (nonatomic, strong)ZBAppDelegate *appDelegate;
@property (strong,nonatomic) NSMutableArray *entries;

////query db
//- (void)queryFromDB;

//insert images data into db for the firt time running the app
- (void)insertImagesDataIntoDb;

@end

@implementation BHImageDataModeld

@synthesize appDelegate = _appDelegate;
@synthesize entries = _entries;

-(id)init
{
    self = [super init];
    if (self) {
        self.appDelegate = (ZBAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

#pragma mark -- Smiling Face

- (NSArray*)querySmilingFaceFromDB
{
    //创建取回数据请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SmilingFace" inManagedObjectContext:self.appDelegate.managedObjectContext];
    //设置请求实体
    [request setEntity:entity];
    //指定对结果的排序方式
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUseTime" ascending:NO];
    NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    
    NSError *error = nil;
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    self.entries = mutableFetchResult;
    
//    NSLog(@"The count of smiling face:%i",[self.entries count]);

    if (self.entries.count != 66 && self.entries.count>0) {
        for (NSManagedObject *object in self.entries) {
            [self.appDelegate.managedObjectContext deleteObject:object];
        }
        BOOL isSaveSuccess = [self.appDelegate.managedObjectContext save:&error];
        
        if (!isSaveSuccess) {
            NSLog(@"Error: %@,%@",error,[error userInfo]);
        }else {
            NSLog(@"Save successful!");
            [self.entries removeAllObjects];
        }
    }
    
    if ([self.entries count]<1) {
        //firt time run the app, so insert image data in the db
        [self insertImagesDataIntoDb];
    }

    return self.entries;
}

//insert images data into db for the firt time running the app
- (void)insertImagesDataIntoDb
{
    NSError *error;
    
//    NSString *_imageName;
    
    // new
    for (NSInteger i=65; i>=0; i--)
    {
        NSString *_imageName = [NSString stringWithFormat:@"sticker_%d@2x",(i)];
        //让CoreData在上下文中创建一个新对象(托管对象)
        SmilingFace *entry = (SmilingFace *)[NSEntityDescription insertNewObjectForEntityForName:@"SmilingFace" inManagedObjectContext:self.appDelegate.managedObjectContext];
        [entry setIndex:[NSNumber numberWithInteger:i+1]];
        [entry setImageName:_imageName];
        [entry setUserTimes:[NSNumber numberWithInteger:0]];
        [entry setLastUseTime:[NSDate date]];
    }
    
//    //yellow
//    for (NSInteger i=0; i<48; i++)
//    {
//        
//        if (i<9) {
//            _imageName = [NSString stringWithFormat:@"stk00%d",(i+1)];
//        }
//        else
//            _imageName = [NSString stringWithFormat:@"stk0%d",(i+1)];
//        //让CoreData在上下文中创建一个新对象(托管对象)
//        SmilingFace *entry = (SmilingFace *)[NSEntityDescription insertNewObjectForEntityForName:@"SmilingFace" inManagedObjectContext:self.appDelegate.managedObjectContext];
//        [entry setIndex:[NSNumber numberWithInteger:i+1]];
//        [entry setImageName:_imageName];
//        [entry setUserTimes:[NSNumber numberWithInteger:0]];
//        [entry setLastUseTime:[NSDate date]];
//    }
//    
//    //love
//    for (NSInteger i=0; i<24; i++)
//    {
//        NSString *_imageName = [NSString stringWithFormat:@"icons-6-%d",(i+1)];
//        //让CoreData在上下文中创建一个新对象(托管对象)
//        SmilingFace *entry = (SmilingFace *)[NSEntityDescription insertNewObjectForEntityForName:@"SmilingFace" inManagedObjectContext:self.appDelegate.managedObjectContext];
//        [entry setIndex:[NSNumber numberWithInteger:i+1+48]];
//        [entry setImageName:_imageName];
//        [entry setUserTimes:[NSNumber numberWithInteger:0]];
//        [entry setLastUseTime:[NSDate date]];
//    }
    //托管对象准备好后，调用托管对象上下文的save方法将数据写入数据库
    BOOL isSaveSuccess = [self.appDelegate.managedObjectContext save:&error];
    
    if (!isSaveSuccess) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }else {
        NSLog(@"Save successful!");
    }
}

- (void)updateSmilingFaceInfo:(SmilingFace*)entry
{
    if (nil == entry) {
        return;
    }
    
    [entry setImageName:entry.imageName];
    [entry setUserTimes:entry.userTimes];
    [entry setLastUseTime:[NSDate date]];
    
    NSError *error;
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:[entry imageName] inManagedObjectContext:self.appDelegate.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@""]];//这里相当于sqlite中的查询条件，具体格式参考苹果文档
    //https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Predicates/Articles/pCreating.html
    [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];//这里获取到的是一个数组，你需要取出你要更新的那个obj
    //假设你取到的是Person *a
    //a.xx=xx;//更新你的attribute
    NSUInteger _userTimes =[entry.userTimes integerValue];
    entry.userTimes = [NSNumber numberWithInteger:_userTimes++];
    entry.lastUseTime = [NSDate date];
    
    BOOL isUpdateSuccess = [self.appDelegate.managedObjectContext save:&error ];
    if (!isUpdateSuccess) {
        NSLog(@"Error:%@,%@",error,[error userInfo]);
    }
}

- (void)updateSmilingFaceInfoForImageName:(NSString*)imageName
{
    if (nil == imageName) {
        return;
    }
    
    NSError *error;
    NSString *_sql = [NSString stringWithFormat:@"imageName=\'%@\'",imageName];
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"SmilingFace" inManagedObjectContext:self.appDelegate.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:_sql]];//这里相当于sqlite中的查询条件，具体格式参考苹果文档
    //https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Predicates/Articles/pCreating.html
    [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];//这里获取到的是一个数组，你需要取出你要更新的那个obj
    //假设你取到的是Person *a
    //a.xx=xx;//更新你的attribute
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    
    if (mutableFetchResult.count>0) {
        SmilingFace *_entry = [mutableFetchResult objectAtIndex:0];
        NSUInteger _userTimes =[_entry.userTimes integerValue];
        _entry.userTimes = [NSNumber numberWithInteger:++_userTimes];
        _entry.lastUseTime = [NSDate date];
        BOOL isUpdateSuccess = [self.appDelegate.managedObjectContext save:&error ];
        if (!isUpdateSuccess)
            NSLog(@"Error:%@,%@",error,[error userInfo]);
    }    
}

//删除操作
-(void)deleteEntry:(SmilingFace *)entry
{
    [self.appDelegate.managedObjectContext deleteObject:entry];
//    [self.entries removeObject:entry];
    
    NSError *error;
    if (![self.appDelegate.managedObjectContext save:&error]) {
        NSLog(@"Error:%@,%@",error,[error userInfo]);
    }
}

#pragma mark -- photo frame
//frame
- (NSArray*)queryFrameFromDB
{
    //创建取回数据请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PhotoFrame" inManagedObjectContext:self.appDelegate.managedObjectContext];
    //设置请求实体
    [request setEntity:entity];
    //指定对结果的排序方式
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUseTime" ascending:NO];
    NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    
    NSError *error = nil;
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    self.entries = mutableFetchResult;
    
//    NSLog(@"The count of entry:%i",[self.entries count]);
    
    if ([self.entries count]<1) {
        //firt time run the app, so insert image data in the db
        [self insertFrameImagesDataIntoDb];
    }

    return self.entries;
}

- (void)updateFrameInfoForImageName:(NSString*)imageName
{
    if (nil == imageName) {
        return;
    }
    
    NSError *error;
    NSString *_sql = [NSString stringWithFormat:@"frameName=\'%@\'",imageName];
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"PhotoFrame" inManagedObjectContext:self.appDelegate.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:_sql]];//这里相当于sqlite中的查询条件，具体格式参考苹果文档
    //https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Predicates/Articles/pCreating.html
    [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];//这里获取到的是一个数组，你需要取出你要更新的那个obj
    //假设你取到的是Person *a
    //a.xx=xx;//更新你的attribute
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    
    if (mutableFetchResult.count>0) {
        PhotoFrame *_entry = [mutableFetchResult objectAtIndex:0];
        NSLog(@"index:%@---imagename:%@---Date:%@  times:%@",_entry.index,_entry.frameName,_entry.lastUseTime, _entry.userTimes);
        NSUInteger _userTimes =[_entry.userTimes integerValue];
        NSLog(@"%@,%@",_entry.frameName,imageName);
        NSLog(@"db: %d",_userTimes);
        _entry.userTimes = [NSNumber numberWithInteger:++_userTimes];
        _entry.lastUseTime = [NSDate date];
        NSLog(@"%@",_entry.userTimes);
        BOOL isUpdateSuccess = [self.appDelegate.managedObjectContext save:&error ];
        if (!isUpdateSuccess)
            NSLog(@"Error:%@,%@",error,[error userInfo]);
    }

}

//insert images data into db for the firt time running the app
- (void)insertFrameImagesDataIntoDb
{
    NSError *error;
    
    NSString *_imageName;
    for (NSInteger i=0; i<43; i++)
    {
        
        _imageName = [NSString stringWithFormat:@"fme%d",(i+1)];
        //让CoreData在上下文中创建一个新对象(托管对象)
        PhotoFrame *entry = (PhotoFrame *)[NSEntityDescription insertNewObjectForEntityForName:@"PhotoFrame" inManagedObjectContext:self.appDelegate.managedObjectContext];
        [entry setIndex:[NSNumber numberWithInteger:i+1]];
        [entry setFrameName:_imageName];
        [entry setUserTimes:[NSNumber numberWithInteger:0]];
        [entry setLastUseTime:[NSDate date]];
    }
    
    //托管对象准备好后，调用托管对象上下文的save方法将数据写入数据库
    BOOL isSaveSuccess = [self.appDelegate.managedObjectContext save:&error];
    
    if (!isSaveSuccess) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }else {
        NSLog(@"Save successful!");
    }
}

#pragma mark -- Background image

//background image
- (NSArray*)queryBackgroundFromDB
{
    //创建取回数据请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //设置要检索哪种类型的实体对象
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BackgroundImage" inManagedObjectContext:self.appDelegate.managedObjectContext];
    //设置请求实体
    [request setEntity:entity];
    //指定对结果的排序方式
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastUseTime" ascending:NO];
    NSArray *sortDescriptions = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptions];
    
    NSError *error = nil;
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    self.entries = mutableFetchResult;
    
    NSLog(@"The count of entry:%i",[self.entries count]);
    
    if ([self.entries count] < kCountOfBackgroundImage) {
        for (NSManagedObject *object in self.entries) {
            [self.appDelegate.managedObjectContext deleteObject:object];
        }
        BOOL isSaveSuccess = [self.appDelegate.managedObjectContext save:&error];
        
        if (!isSaveSuccess) {
            NSLog(@"Error: %@,%@",error,[error userInfo]);
        }else {
            NSLog(@"Save successful!");
            [self.entries removeAllObjects];
        }
    }
    
    if ([self.entries count]<1) {
        //firt time run the app, so insert image data in the db
        [self insertBackgroundImagesDataIntoDb];
    }
    
    return self.entries;
}

- (void)updateBackgroundInfoForImageName:(NSString*)imageName
{
    if (nil == imageName) {
        return;
    }
    
    NSError *error;
    NSString *_sql = [NSString stringWithFormat:@"imageName=\'%@\'",imageName];
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"BackgroundImage" inManagedObjectContext:self.appDelegate.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:_sql]];//这里相当于sqlite中的查询条件，具体格式参考苹果文档
    //https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Predicates/Articles/pCreating.html
    [self.appDelegate.managedObjectContext executeFetchRequest:request error:&error];//这里获取到的是一个数组，你需要取出你要更新的那个obj
    //假设你取到的是Person *a
    //a.xx=xx;//更新你的attribute
    //执行获取数据请求，返回数组
    NSMutableArray *mutableFetchResult = [[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult == nil) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }
    
    if (mutableFetchResult.count>0) {
        BackgroundImage *_entry = [mutableFetchResult objectAtIndex:0];
        NSLog(@"index:%@---imagename:%@---Date:%@  times:%@",_entry.index,_entry.imageName,_entry.lastUseTime, _entry.userTimes);
        NSUInteger _userTimes =[_entry.userTimes integerValue];
        NSLog(@"%@,%@",_entry.imageName,imageName);
        NSLog(@"db: %d",_userTimes);
        _entry.userTimes = [NSNumber numberWithInteger:++_userTimes];
        _entry.lastUseTime = [NSDate date];
        NSLog(@"%@",_entry.userTimes);
        BOOL isUpdateSuccess = [self.appDelegate.managedObjectContext save:&error ];
        if (!isUpdateSuccess)
            NSLog(@"Error:%@,%@",error,[error userInfo]);
    }

}

//insert images data into db for the firt time running the app
- (void)insertBackgroundImagesDataIntoDb
{
    NSError *error;
    
    NSString *_imageName;
    for (NSInteger i=kCountOfBackgroundImage-1; i>=0; i--)
    {
        _imageName = [NSString stringWithFormat:@"free_back_%d",(i+1)];
        //让CoreData在上下文中创建一个新对象(托管对象)
        BackgroundImage *entry = (BackgroundImage *)[NSEntityDescription insertNewObjectForEntityForName:@"BackgroundImage" inManagedObjectContext:self.appDelegate.managedObjectContext];
        [entry setIndex:[NSNumber numberWithInteger:i+1]];
        [entry setImageName:_imageName];
        [entry setUserTimes:[NSNumber numberWithInteger:0]];
        [entry setLastUseTime:[NSDate date]];
    }
    
    //托管对象准备好后，调用托管对象上下文的save方法将数据写入数据库
    BOOL isSaveSuccess = [self.appDelegate.managedObjectContext save:&error];
    
    if (!isSaveSuccess) {
        NSLog(@"Error: %@,%@",error,[error userInfo]);
    }else {
        NSLog(@"Save successful!");
    }
}


@end
