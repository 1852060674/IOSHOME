//
//  PhotoStore.m
//  OldBooth
//
//  Created by ZB_Mac on 14-10-23.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import "PhotoStore.h"
#import "ZBCommonMethod.h"

static NSString *kItemImageKey = @"image";
static NSString *kItemSmallImageKey = @"smallimage";
static NSString *kItemMaskImageKey = @"maskimage";

@interface PhotoStore ()
@property (strong, nonatomic) NSMutableArray* data;

@property (strong, nonatomic) NSString *descPath;
@property (strong, nonatomic) NSString *identifier;
@end

@implementation PhotoStore

+(PhotoStore *)defaultStore
{
    static dispatch_once_t once;
    static PhotoStore *store = nil;
    
    if (!store) {
        dispatch_once(&once, ^{
            store = [self photoStoreWithIdentifier:@"default"];;
        });
    }
    return store;
}
+(PhotoStore *)photoStoreWithIdentifier:(NSString *)identifier;
{
    PhotoStore *photoStore = [[PhotoStore alloc] initWithIdentifier:identifier];
    
    return photoStore;
}

-(PhotoStore *)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    
    if (self) {
        identifier = [@"photoStore" stringByAppendingString:identifier];
        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *ddPath =  [pathArray objectAtIndex:0];
        NSString *path = [[ddPath stringByAppendingPathComponent:identifier] stringByAppendingPathExtension:@"plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        self.descPath = path;
        self.identifier = identifier;
        if ([fileManager fileExistsAtPath:path]) {
            self.data = [NSMutableArray arrayWithContentsOfFile:path];
        }
        
        if (!self.data) {
            self.data = [NSMutableArray array];
            [self.data writeToFile:self.descPath atomically:YES];
        }
    }
    
    return self;
}

-(NSInteger)removeItemAtIndex:(NSInteger)index
{
    if (index >= [self itemNumber] || index < 0) {
        return -1;
    }
    
    NSString *path = [self imagePathAtIndex:index];
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    path = [self smallImagePathAtIndex:index];
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    path = [self maskImagePathAtIndex:index];
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
    {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    [self.data removeObjectAtIndex:index];
    [self.data writeToFile:self.descPath atomically:YES];
    
    return 0;
}

-(NSInteger)removeAllItems
{
    NSInteger itemNumber = [self itemNumber];
    
    for (NSInteger index=0; index<itemNumber; ++index) {
        NSString *path = [self imagePathAtIndex:index];
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        path = [self smallImagePathAtIndex:index];
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        path = [self maskImagePathAtIndex:index];
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
    
    [self.data removeAllObjects];
    [self.data writeToFile:self.descPath atomically:YES];

    return itemNumber;
}

-(NSInteger)itemNumber
{
    NSArray *itemArray = self.data;
    return itemArray.count;
}


-(BOOL) isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    return result;
}

-(CGFloat) photoStoreDiskUsage
{
    CGFloat totalSize = 0;
    NSInteger itemNumber = [self itemNumber];
    
    for (NSInteger index=0; index<itemNumber; ++index) {
        NSString *path = [self imagePathAtIndex:index];
        totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
        
        path = [self smallImagePathAtIndex:index];
        totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
        
        path = [self maskImagePathAtIndex:index];
        totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    }
    
    return totalSize;
}

-(NSInteger)addItemImage:(UIImage *)image andSmallImage:(UIImage *)smallImage andMaskImage:(UIImage *)maskImage
{
//    NSMutableArray *itemArray = self.data;

    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];

    NSUInteger randomNumber;
    NSString *relativePathBig;

    do {
        randomNumber = arc4random();
        relativePathBig = [self.identifier stringByAppendingFormat:@"_big_%lu", (unsigned long)randomNumber];
    } while ([self isFileExist:relativePathBig]);
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSString *originalPathBig, *originalPathMask, *originalPathSmall;
    // big image
    if (image) {
        originalPathBig = [ddPath stringByAppendingPathComponent:relativePathBig];
        NSData *data = UIImagePNGRepresentation(image);
        BOOL success = [data writeToFile:originalPathBig atomically:YES];
        if (!success) {
            return -1;
        }
        [dictionary setObject:relativePathBig forKey:kItemImageKey];
    }

    // small image
    if (smallImage) {
        NSString *relativePathSmall = [self.identifier stringByAppendingFormat:@"_small_%lu", (unsigned long)randomNumber];
        originalPathSmall = [ddPath stringByAppendingPathComponent:relativePathSmall];
        NSData *data = UIImagePNGRepresentation(smallImage);
        BOOL success = [data writeToFile:originalPathSmall atomically:YES];
        if (!success) {
            return -1;
        }
        [dictionary setObject:relativePathSmall forKey:kItemSmallImageKey];
    }
    
    // mask image
    if (maskImage) {
        NSString *relativePathMask = [self.identifier stringByAppendingFormat:@"_mask_%lu", (unsigned long)randomNumber];
        originalPathMask = [ddPath stringByAppendingPathComponent:relativePathMask];
        NSData *data = UIImagePNGRepresentation(maskImage);
        BOOL success = [data writeToFile:originalPathMask atomically:YES];
        if (!success) {
            return -1;
        }
        [dictionary setObject:relativePathMask forKey:kItemMaskImageKey];
    }
    
    //
    [self.data addObject:dictionary];
//    [self.data insertObject:dictionary atIndex:0];
    BOOL success = [self.data writeToFile:self.descPath atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:originalPathBig error:nil];
        [self.data removeLastObject];

        return -1;
    }
//    return 0;
    return self.data.count-1;
}

-(NSInteger)updateItemAtIndex:(NSInteger)index withImage:(UIImage *)image andSmallImage:(UIImage *)smallImage andMaskImage:(UIImage *)maskImage
{
    if (image) {
        NSString *path = [self imagePathAtIndex:index];
        NSData *data = UIImagePNGRepresentation(image);
        BOOL success = [data writeToFile:path atomically:YES];
        if (!success) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            return -1;
        }
    }
    
    if (smallImage) {
        NSString *path = [self smallImagePathAtIndex:index];
        NSData *data = UIImagePNGRepresentation(smallImage);
        BOOL success = [data writeToFile:path atomically:YES];
        if (!success) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            return -1;
        }
    }
    
    if (maskImage) {
        NSString *path = [self maskImagePathAtIndex:index];
        NSData *data = UIImagePNGRepresentation(maskImage);
        BOOL success = [data writeToFile:path atomically:YES];
        if (!success) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            return -1;
        }
    }
    
    return index;
}

-(UIImage *)imageAtIndex:(NSInteger)index
{
    NSString *imagePath = [self imagePathAtIndex:index];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

-(UIImage *)smallImageAtIndex:(NSInteger)index
{
    NSString *imagePath = [self smallImagePathAtIndex:index];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

-(UIImage *)maskImageAtIndex:(NSInteger)index
{
    NSString *imagePath = [self maskImagePathAtIndex:index];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

-(NSString *)imagePathAtIndex:(NSInteger)index
{
    NSArray *itemArray = self.data;
    if (index >= itemArray.count) {
        return nil;
    }
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    
    NSDictionary *item = [itemArray objectAtIndex:index];
    NSString *imagePath = [ddPath stringByAppendingPathComponent:[[item objectForKey:kItemImageKey] lastPathComponent]];
    
    return imagePath;
}

-(NSString *)smallImagePathAtIndex:(NSInteger)index
{
    NSArray *itemArray = self.data;
    if (index >= itemArray.count) {
        return nil;
    }
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    
    NSDictionary *item = [itemArray objectAtIndex:index];
    NSString *imagePath = [ddPath stringByAppendingPathComponent:[[item objectForKey:kItemSmallImageKey] lastPathComponent]];
    
    return imagePath;
}

-(NSString *)maskImagePathAtIndex:(NSInteger)index
{
    NSArray *itemArray = self.data;
    if (index >= itemArray.count) {
        return nil;
    }
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    
    NSDictionary *item = [itemArray objectAtIndex:index];
    NSString *imagePath = [ddPath stringByAppendingPathComponent:[[item objectForKey:kItemMaskImageKey] lastPathComponent]];
    
    return imagePath;
}

@end
