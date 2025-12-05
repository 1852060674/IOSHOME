//
//  MGFile.m
//  MagicCamera
//
//  Created by tangtaoyu on 15-4-21.
//  Copyright (c) 2015年 tangtaoyu. All rights reserved.
//

#import "MGFile.h"

@implementation MGFile

+ (MGFile*)Instance
{
    static dispatch_once_t once;
    static id singleton;
    dispatch_once(&once, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
}

//获取应用沙盒根路径
+ (NSString*)dirHome
{
    return  NSHomeDirectory();
}

//获取Documents目录
+ (NSString*)dirDoc
{
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}

//获取Library目录
+ (NSString*)dirLib
{
    //[NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    
    return libraryDirectory;
}

//获取Cache目录
+ (NSString*)dirCache
{
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0];
    
    return cachePath;
}

//获取Tmp目录
+ (NSString*)dirTmp
{
    //[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    NSString *tmpDirectory = NSTemporaryDirectory();
    
    return tmpDirectory;
}

//获取path下所有文件路径
+ (NSArray*)getSubPathFromDic:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    fileList = [fileManager contentsOfDirectoryAtPath:path error:&error];
    
    return fileList;
}

//获取path下所有文件夹路径
+ (NSArray*)getSubDicPathFromDic:(NSString*)path
{
    NSMutableArray *dirArray = [[NSMutableArray alloc] init];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *fileList = [MGFile getSubPathFromDic:path];
    
    for (NSString *file in fileList) {
        NSString *path0 = [path stringByAppendingPathComponent:file];
        [fileManager fileExistsAtPath:path0 isDirectory:(&isDir)];
        if (isDir) {
            [dirArray addObject:file];
        }
        isDir = NO;
    }
    NSLog(@"Every Thing in the dir:%@",fileList);
    NSLog(@"All folders:%@",dirArray);
    
    return dirArray;
}

//创建文件
- (void)createFile
{
    NSString *documentsPath =[MGFile dirDoc];
    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:@"test"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testPath = [testDirectory stringByAppendingPathComponent:@"test.txt"];
    BOOL res=[fileManager createFileAtPath:testPath contents:nil attributes:nil];
    if (res) {
        NSLog(@"文件创建成功: %@" ,testPath);
    }else
        NSLog(@"文件创建失败");
}

//写文件
- (void)writeFile
{
    NSString *documentsPath =[MGFile dirDoc];
    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:@"test"];
    NSString *testPath = [testDirectory stringByAppendingPathComponent:@"test.txt"];
    NSString *content=@"测试写入内容！";
    BOOL res=[content writeToFile:testPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (res) {
        NSLog(@"文件写入成功");
    }else
        NSLog(@"文件写入失败");
}

//读文件
- (void)readFile
{
    NSString *documentsPath =[MGFile dirDoc];
    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:@"test"];
    NSString *testPath = [testDirectory stringByAppendingPathComponent:@"test.txt"];
    //    NSData *data = [NSData dataWithContentsOfFile:testPath];
    //    NSLog(@"文件读取成功: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSString *content=[NSString stringWithContentsOfFile:testPath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"文件读取成功: %@",content);
}

//文件属性
- (void)fileAttriutes
{
    NSString *documentsPath =[MGFile dirDoc];
    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:@"test"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testPath = [testDirectory stringByAppendingPathComponent:@"test.txt"];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:testPath error:nil];
    NSArray *keys;
    id key, value;
    keys = [fileAttributes allKeys];
    int count = [keys count];
    for (int i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        value = [fileAttributes objectForKey: key];
        NSLog (@"Key: %@ for value: %@", key, value);
    }
}

//删除文件
-(void)deleteFile
{
    NSString *documentsPath =[MGFile dirDoc];
    NSString *testDirectory = [documentsPath stringByAppendingPathComponent:@"test"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testPath = [testDirectory stringByAppendingPathComponent:@"test.txt"];
    BOOL res=[fileManager removeItemAtPath:testPath error:nil];
    if (res) {
        NSLog(@"文件删除成功");
    }else
        NSLog(@"文件删除失败");
    NSLog(@"文件是否存在: %@",[fileManager isExecutableFileAtPath:testPath]?@"YES":@"NO");
}

+ (NSString*)getFilePathOfFile:(NSString*)string
{
    NSString *docPath = [MGFile dirDoc];
    NSString *mgPath = [docPath stringByAppendingPathComponent:kPhotoDir];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:mgPath]){
        [fm createDirectoryAtPath:mgPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *filePath = [mgPath stringByAppendingPathComponent:string];
    
    return filePath;
}

+ (NSArray*)getVoiceFileNameArray
{
    NSString *docPath = [MGFile dirDoc];
    NSString *mgPath = [docPath stringByAppendingPathComponent:kPhotoDir];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:mgPath]){
        [fm createDirectoryAtPath:mgPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *plistPath = [mgPath stringByAppendingPathComponent:kPathSaveFile];
    if(![fm fileExistsAtPath:plistPath]){
        NSArray *plistArr1 = [[NSArray alloc] init];
        NSArray *plistArr2 = [[NSArray alloc] init];
        NSArray *plist = [[NSArray alloc] initWithObjects:plistArr1, plistArr2, nil];
        [plist writeToFile:plistPath atomically:YES];
    }
    
    NSArray *arr = [[ NSArray alloc] initWithContentsOfFile:plistPath];
    
    return arr;
}

+ (void)pushVoiceOriWith:(NSString*)fileName
{
    if(fileName == nil || [fileName isEqualToString:@""])
        return;
    
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[MGFile getVoiceFileNameArray]];
    NSMutableArray *imagePathArr = [[NSMutableArray alloc] initWithArray:pathArr[0]];
    
    [imagePathArr addObject:fileName];
    [pathArr replaceObjectAtIndex:0 withObject:imagePathArr];
    
    [pathArr writeToFile:[MGFile getFilePathOfFile:kPathSaveFile] atomically:YES];
}

+ (void)popVoiceOriWith:(NSString*)fileName
{
    if(fileName == nil || [fileName isEqualToString:@""])
        return;
    
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[MGFile getImageFileNameArray]];
    NSMutableArray *imagePathArr = [[NSMutableArray alloc] initWithArray:pathArr[0]];
    
    if(imagePathArr.count < 1)
        return;
    
    for(int i=0; i<imagePathArr.count; i++){
        NSString *str = imagePathArr[i];
        if([fileName isEqualToString:str]){
            [imagePathArr removeObjectAtIndex:i];
            break;
        }
    }
    
    [pathArr replaceObjectAtIndex:0 withObject:imagePathArr];
    [pathArr writeToFile:[MGFile getFilePathOfFile:kPathSaveFile] atomically:YES];
}

+ (void)pushVoicePathWith:(NSDictionary*)dict
{
    if(dict == nil)
        return;
    
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[MGFile getVoiceFileNameArray]];
    NSMutableArray *imagePathArr = [[NSMutableArray alloc] initWithArray:pathArr[1]];
    
    if(![MGFile dict:dict isInArray:imagePathArr])
        [imagePathArr addObject:dict];
    [pathArr replaceObjectAtIndex:1 withObject:imagePathArr];
    
    [pathArr writeToFile:[MGFile getFilePathOfFile:kPathSaveFile] atomically:YES];
}

+ (void)popVoicePathWith:(NSDictionary*)dict
{
    if(dict == nil)
        return;
    
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[MGFile getVoiceFileNameArray]];
    NSMutableArray *imagePathArr = [[NSMutableArray alloc] initWithArray:pathArr[1]];

    if(imagePathArr.count < 1)
        return;
    
    NSString *str = [dict objectForKey:kVoiceNum];
    for(int i=0; i<imagePathArr.count; i++){
        NSDictionary *t_dict = imagePathArr[i];
        NSString *str0 = [t_dict objectForKey:kVoiceNum];
        if([str0 isEqualToString:str]){
            [imagePathArr removeObjectAtIndex:i];
            break;
        }
    }
    
    [pathArr replaceObjectAtIndex:1 withObject:imagePathArr];
    [pathArr writeToFile:[MGFile getFilePathOfFile:kPathSaveFile] atomically:YES];
    
    [MGFile removeAddtion];
}

+ (BOOL)dict:(NSDictionary*)dict isInArray:(NSArray*)array
{
    BOOL isIn = NO;
    NSString *strName = [dict objectForKey:kVoiceName];
    NSString *strCate = [dict objectForKey:kVoiceCate];
    NSString *strCustom = [dict objectForKey:kVoiceCustom];
    NSString *strDate = [dict objectForKey:kVoiceDate];

    for(int i=0; i<array.count; i++){
        NSDictionary *t_dict = array[i];
        NSString *str0Name = [t_dict objectForKey:kVoiceName];
        NSString *str0Cate = [t_dict objectForKey:kVoiceCate];
        NSString *str0Custom = [t_dict objectForKey:kVoiceCustom];
        NSString *str0Date = [t_dict objectForKey:kVoiceDate];

        if([strName isEqualToString:str0Name] && [strCate isEqualToString:str0Cate] && [strCustom isEqualToString:str0Custom] && [strDate isEqualToString:str0Date]){
            isIn = YES;
            break;
        }
    }
    
    return isIn;
}

+ (void)removeVoiceWith:(NSString*)fileName
{
    if(fileName == nil || [fileName isEqualToString:@""])
        return;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *filePath = [MGFile getFilePathOfFile:fileName];
    
    if(![fm fileExistsAtPath:filePath])
        return;
    [fm removeItemAtPath:filePath error:nil];
}

+ (void)removeAddtion
{
    NSArray *array = [MGFile getVoiceFileNameArray];
    NSArray *voiceArr = array[0];
    NSArray *voiceChangerArr = array[1];
    
    for(int i=0; i<voiceArr.count; i++){
        NSString *str = voiceArr[i];
        
        BOOL isInDict = NO;
        for(int j=0; j<voiceChangerArr.count; j++){
            NSDictionary *dict = [voiceChangerArr objectAtIndex:j];
            NSString *voiceName = [dict objectForKey:kVoiceName];
            
            if([str isEqualToString:voiceName]){
                isInDict = YES;
                break;
            }
        }
        
        if(!isInDict){
            [MGFile popVoiceOriWith:str];
            [MGFile removeVoiceWith:[NSString stringWithFormat:@"%@.wav", str]];
        }
    }
}

- (NSInteger)voiceIndex
{
    NSInteger index = [[NSUserDefaults standardUserDefaults] integerForKey:kVoiceIndex];
    index++;
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:kVoiceIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return [[NSUserDefaults standardUserDefaults] integerForKey:kVoiceIndex];
}


/////////////////////////////////////////////////////////////////////////////////////
+ (NSArray*)getImageFileNameArray
{
    NSString *docPath = [MGFile dirDoc];
    NSString *mgPath = [docPath stringByAppendingPathComponent:kPhotoDir];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:mgPath]){
        [fm createDirectoryAtPath:mgPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *plistPath = [mgPath stringByAppendingPathComponent:kPathSaveFile];
    if(![fm fileExistsAtPath:plistPath]){
        NSArray *plistArr1 = [[NSArray alloc] init];
        NSArray *plistArr2 = [[NSArray alloc] init];
        NSArray *plist = [[NSArray alloc] initWithObjects:plistArr1, plistArr2, nil];
        [plist writeToFile:plistPath atomically:YES];
    }
    
    NSArray *arr = [[ NSArray alloc] initWithContentsOfFile:plistPath];
    
    return arr;
}

+ (void)popImagePathWith:(NSString*)fileName WithType:(NSInteger)type
{
    if(fileName == nil || [fileName isEqualToString:@""])
        return;
    
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[MGFile getImageFileNameArray]];
    NSMutableArray *imagePathArr = [[NSMutableArray alloc] initWithArray:pathArr[type]];
    
    if(imagePathArr.count < 1)
        return;
    
    for(int i=0; i<imagePathArr.count; i++){
        NSString *str = imagePathArr[i];
        if([fileName isEqualToString:str]){
            [imagePathArr removeObjectAtIndex:i];
            break;
        }
    }
    
    [pathArr replaceObjectAtIndex:type withObject:imagePathArr];
    
    [pathArr writeToFile:[MGFile getFilePathOfFile:kPathSaveFile] atomically:YES];
}

+ (void)pushImagePathWith:(NSString*)fileName WithType:(NSInteger)type
{
    if(fileName == nil || [fileName isEqualToString:@""])
        return;
    
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[MGFile getImageFileNameArray]];
    NSMutableArray *imagePathArr = [[NSMutableArray alloc] initWithArray:pathArr[type]];
    
    [imagePathArr addObject:fileName];
    [pathArr replaceObjectAtIndex:type withObject:imagePathArr];
    
    [pathArr writeToFile:[MGFile getFilePathOfFile:kPathSaveFile] atomically:YES];
}

+ (void)saveImageWithData:(NSData*)imageData WithFileName:(NSString*)fileName
{
    if(fileName == nil || [fileName isEqualToString:@""])
        return;
    
    NSString *filePath = [MGFile getFilePathOfFile:fileName];
    [imageData writeToFile:filePath atomically:YES];
}

+ (void)removeImageWith:(NSString*)fileName
{
    if(fileName == nil || [fileName isEqualToString:@""])
        return;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *filePath = [MGFile getFilePathOfFile:fileName];
    
    if(![fm fileExistsAtPath:filePath])
        return;
    [fm removeItemAtPath:filePath error:nil];
}

+ (NSInteger)getImageCount
{
    NSMutableArray *pathArr = [[NSMutableArray alloc] initWithArray:[MGFile getImageFileNameArray]];
    NSMutableArray *imagePathArr = [[NSMutableArray alloc] initWithArray:pathArr[0]];
    
    NSInteger imageCount = imagePathArr.count;
    return imageCount;
}

@end
