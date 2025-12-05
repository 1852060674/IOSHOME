//
//  PhotoStore.m
//  OldBooth
//
//  Created by ZB_Mac on 14-10-23.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import "CutoutPhotoStore.h"
#import "ZBCommonMethod.h"

static NSString *kIdentifier = @"Cutout";

static NSString *kItemBigImageKey = @"forgroundWrapping";
static NSString *kItemSmallImageKey = @"forgroundWrappingSmall";
static NSString *kItemForeImageKey = @"forground";
static NSString *kItemBackImageKey = @"background";
static NSString *kItemOriginalImageKey = @"original";
static NSString *kItemMaskImageKey = @"mask";
static NSString *kItemAPIVersionKey = @"apiVersion";

@interface CutoutPhotoStore ()
@property (strong, nonatomic) NSMutableArray* data;

@property (strong, nonatomic) NSString *descPath;
@property (strong, nonatomic) NSString *identifier;
@end

@implementation CutoutPhotoStore

+(CutoutPhotoStore *)defaultStore
{
    static dispatch_once_t once;
    static CutoutPhotoStore *store = nil;
    
    if (!store) {
        dispatch_once(&once, ^{
            
            NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *plistPath_V1 = [rootPath stringByAppendingPathComponent:@"CSCacheCollectPNGFile.plist"];
            
            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *ddPath =  [pathArray objectAtIndex:0];
            NSString *plistPath_V2 = [[ddPath stringByAppendingPathComponent:@"defaultStore"] stringByAppendingPathExtension:@"plist"];
            
            store = [[self alloc] initWithPath:plistPath_V2];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath_V1])
            {
                // append old data
                NSArray *data_V1 = [NSMutableArray arrayWithContentsOfFile:plistPath_V1];
                [store.data addObjectsFromArray:data_V1];
                
                BOOL succeed = [store.data writeToFile:plistPath_V2 atomically:YES];
                
                if (succeed) {
                    // successfully save, delete old data
                    [[NSFileManager defaultManager] removeItemAtPath:plistPath_V1 error:nil];
                }
                else
                {
                    // unsuccessfuly save, ignore old data this time
                    [store.data removeObjectsInArray:data_V1];
                    [store.data addObjectsFromArray:data_V1];
                }
            }
            
            
        });
    }
    return store;
}

-(CutoutPhotoStore *)initWithPath:(NSString *)path
{
    self = [super init];
    
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        self.descPath = path;
        self.identifier = [NSString stringWithString:kIdentifier];
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
    
    if ([self itemAPIVersionAtIndex:index] < 2.0) {
        NSString *path = [self bigImagePathAtIndex:index];
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        path = [self smallImagePathAtIndex:index];
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        path = [self backImagePathAtIndex:index];
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        
        path = [self foreImagePathAtIndex:index];
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
    else
    {
        NSString *path = [self originalImagePathAtIndex:index];
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
    
    [self.data removeObjectAtIndex:index];
    [self.data writeToFile:self.descPath atomically:YES];
    
    return 0;
}

-(NSInteger)removeAllItems
{
    NSInteger itemNumber = [self itemNumber];
    
    for (NSInteger index=0; index<itemNumber; ++index) {
        if ([self itemAPIVersionAtIndex:index] < 2.0) {
            NSString *path = [self bigImagePathAtIndex:index];
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
            {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
            
            path = [self smallImagePathAtIndex:index];
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
            {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
            
            path = [self backImagePathAtIndex:index];
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
            {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
            
            path = [self foreImagePathAtIndex:index];
            if ([[NSFileManager defaultManager] isDeletableFileAtPath:path])
            {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
        }
        else
        {
            NSString *path = [self originalImagePathAtIndex:index];
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
        
        if ([self itemAPIVersionAtIndex:index] < 2.0) {
            NSString *path = [self bigImagePathAtIndex:index];
            totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
            
            path = [self smallImagePathAtIndex:index];
            totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
            
            path = [self backImagePathAtIndex:index];
            totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
            
            path = [self foreImagePathAtIndex:index];
            totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
        }
        else
        {
            NSString *path = [self originalImagePathAtIndex:index];
            totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
            
            path = [self smallImagePathAtIndex:index];
            totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
            
            path = [self maskImagePathAtIndex:index];
            totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
        }
    }
    
    return totalSize;
}

-(NSInteger)addItemBigImage:(UIImage *)bigImage andSmallImage:(UIImage *)smallImage andBackgroundImage:(UIImage *)backImage andForegroundImage:(UIImage *)foreImage
{
    NSMutableArray *itemArray = self.data;

    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];

    NSUInteger randomNumber;
    NSString *relativePathBig;

    do {
        randomNumber = arc4random();
        relativePathBig = [self.identifier stringByAppendingFormat:@"_big_%lu", (unsigned long)randomNumber];
    } while ([self isFileExist:relativePathBig]);
    
    // big image
    NSString *originalPathBig = [ddPath stringByAppendingPathComponent:relativePathBig];
    NSData *data = UIImagePNGRepresentation(bigImage);
    BOOL success = [data writeToFile:originalPathBig atomically:YES];
    if (!success) {
        return -1;
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:relativePathBig forKey:kItemBigImageKey];

    // small image
    NSString *relativePathSmall = [self.identifier stringByAppendingFormat:@"_small_%lu", (unsigned long)randomNumber];
    NSString *originalPathSmall = [ddPath stringByAppendingPathComponent:relativePathSmall];
    data = UIImagePNGRepresentation(smallImage);
    success = [data writeToFile:originalPathSmall atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:originalPathBig error:nil];
        return -1;
    }
    [dictionary setObject:relativePathSmall forKey:kItemSmallImageKey];

    // foreground image
    NSString *relativePathFore = [self.identifier stringByAppendingFormat:@"_fore_%lu", (unsigned long)randomNumber];
    NSString *originalPathFore = [ddPath stringByAppendingPathComponent:relativePathFore];
    data = UIImagePNGRepresentation(foreImage);
    success = [data writeToFile:originalPathFore atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:originalPathBig error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathSmall error:nil];
        return -1;
    }
    [dictionary setObject:relativePathFore forKey:kItemForeImageKey];

    // back image
    NSString *relativePathBack = [self.identifier stringByAppendingFormat:@"_back_%lu", (unsigned long)randomNumber];
    NSString *originalPathBack = [ddPath stringByAppendingPathComponent:relativePathBack];
    data = UIImagePNGRepresentation(backImage);
    success = [data writeToFile:originalPathBack atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:originalPathBig error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathSmall error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathFore error:nil];
        return -1;
    }
    [dictionary setObject:relativePathBack forKey:kItemBackImageKey];

    [self.data addObject:dictionary];
    success = [self.data writeToFile:self.descPath atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:originalPathBig error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathSmall error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathFore error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathBack error:nil];
        [self.data removeLastObject];

        return -1;
    }
    return itemArray.count-1;
}

-(NSInteger)updateItemAtIndex:(NSInteger)index withBigImage:(UIImage *)bigImage andSmallImage:(UIImage *)smallImage andBackgroundImage:(UIImage *)backImage andForegroundImage:(UIImage *)foreImage;
{
    NSString *path = [self bigImagePathAtIndex:index];
    NSData *data = UIImagePNGRepresentation(bigImage);
    BOOL success = [data writeToFile:path atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return -1;
    }
    
    path = [self smallImagePathAtIndex:index];
    data = UIImagePNGRepresentation(smallImage);
    success = [data writeToFile:path atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return -1;
    }
    
    path = [self backImagePathAtIndex:index];
    data = UIImagePNGRepresentation(backImage);
    success = [data writeToFile:path atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return -1;
    }
    
    path = [self foreImagePathAtIndex:index];
    data = UIImagePNGRepresentation(foreImage);
    success = [data writeToFile:path atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return -1;
    }
    return index;
}

-(UIImage *)bigImageAtIndex:(NSInteger)index
{
    NSString *imagePath = [self bigImagePathAtIndex:index];
//    [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

-(NSString *)bigImagePathAtIndex:(NSInteger)index
{
    NSArray *itemArray = self.data;
    if (index >= itemArray.count) {
        return nil;
    }
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    
    NSDictionary *item = [itemArray objectAtIndex:index];
    NSString *imagePath = [ddPath stringByAppendingPathComponent:[[item objectForKey:kItemBigImageKey] lastPathComponent]];
    
    return imagePath;
}

-(UIImage *)smallImageAtIndex:(NSInteger)index
{
    NSString *imagePath = [self smallImagePathAtIndex:index];
//    [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
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

-(UIImage *)backImageAtIndex:(NSInteger)index
{
    NSString *imagePath = [self backImagePathAtIndex:index];
    //    [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

-(NSString *)backImagePathAtIndex:(NSInteger)index
{
    NSArray *itemArray = self.data;
    if (index >= itemArray.count) {
        return nil;
    }
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    
    NSDictionary *item = [itemArray objectAtIndex:index];
    NSString *imagePath = [ddPath stringByAppendingPathComponent:[[item objectForKey:kItemBackImageKey] lastPathComponent]];
    
    return imagePath;
}

-(UIImage *)foreImageAtIndex:(NSInteger)index
{
    NSString *imagePath = [self foreImagePathAtIndex:index];
    //    [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}

-(NSString *)foreImagePathAtIndex:(NSInteger)index
{
    NSArray *itemArray = self.data;
    if (index >= itemArray.count) {
        return nil;
    }
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    
    NSDictionary *item = [itemArray objectAtIndex:index];
    NSString *imagePath = [ddPath stringByAppendingPathComponent:[[item objectForKey:kItemForeImageKey] lastPathComponent]];
    
    return imagePath;
}

-(NSInteger)addItemSmallImage:(UIImage *)smallImage andOriginalImage:(UIImage *)originalImage andMaskImage:(UIImage *)maskImage andBigImage:(UIImage *)bigImage;
{
    return [self addItemSmallImage:smallImage andOriginalImage:originalImage andMaskImage:maskImage andBigImage:bigImage atIndex:-1];
}
-(NSInteger)addItemSmallImage:(UIImage *)smallImage andOriginalImage:(UIImage *)originalImage andMaskImage:(UIImage *)maskImage andBigImage:(UIImage *)bigImage atIndex:(NSInteger)index
{
    NSMutableArray *itemArray = self.data;
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    
    NSUInteger randomNumber;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    // small image
    NSString *relativePathSmall;
    do {
        randomNumber = arc4random();
        relativePathSmall = [self.identifier stringByAppendingFormat:@"_small_%lu", (unsigned long)randomNumber];
    } while ([self isFileExist:relativePathSmall]);
    
    NSString *originalPathSmall = [ddPath stringByAppendingPathComponent:relativePathSmall];
    NSData *data = UIImagePNGRepresentation(smallImage);
    BOOL success = [data writeToFile:originalPathSmall atomically:YES];
    if (!success) {
        return -1;
    }
    [dictionary setObject:relativePathSmall forKey:kItemSmallImageKey];
    
    // original image
    NSString *relativePathOriginal = [self.identifier stringByAppendingFormat:@"_original_%lu", (unsigned long)randomNumber];
    NSString *originalPathOriginal = [ddPath stringByAppendingPathComponent:relativePathOriginal];
    data = UIImagePNGRepresentation(originalImage);
    success = [data writeToFile:originalPathOriginal atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:originalPathSmall error:nil];
        return -1;
    }
    [dictionary setObject:relativePathOriginal forKey:kItemOriginalImageKey];
    
    // mask image
    NSString *relativePathMask = [self.identifier stringByAppendingFormat:@"_mask_%lu", (unsigned long)randomNumber];
    NSString *originalPathMask = [ddPath stringByAppendingPathComponent:relativePathMask];
    data = UIImagePNGRepresentation(maskImage);
    success = [data writeToFile:originalPathMask atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:originalPathSmall error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathOriginal error:nil];
        return -1;
    }
    [dictionary setObject:relativePathMask forKey:kItemMaskImageKey];
    
    // big image
    NSString *relativePathBig = [self.identifier stringByAppendingFormat:@"_big_%lu", (unsigned long)randomNumber];
    NSString *originalPathBig = [ddPath stringByAppendingPathComponent:relativePathBig];
    data = UIImagePNGRepresentation(bigImage);
    success = [data writeToFile:originalPathBig atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:originalPathSmall error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathOriginal error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathMask error:nil];
        return -1;
    }
    [dictionary setObject:relativePathBig forKey:kItemBigImageKey];
    
    //
    [dictionary setObject:@(2.0) forKey:kItemAPIVersionKey];
    
    if (index < 0) {
        [self.data addObject:dictionary];
        index = itemArray.count-1;
    }
    else
    {
        [self.data insertObject:dictionary atIndex:index];
    }
    success = [self.data writeToFile:self.descPath atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:originalPathSmall error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathOriginal error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathMask error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:originalPathBig error:nil];

        [self.data removeLastObject];
        return -1;
    }
    return index;
}
-(NSInteger)updateItemAtIndex:(NSInteger)index withSmallImage:(UIImage *)smallImage andOriginalImage:(UIImage *)originalImage andMaskImage:(UIImage *)maskImage andBigImage:(UIImage *)bigImage;
{
    if ([self itemAPIVersionAtIndex:index] < 2.0) {
        [self removeItemAtIndex:index];
        NSInteger idx = [self addItemSmallImage:smallImage andOriginalImage:originalImage andMaskImage:maskImage andBigImage:bigImage atIndex:index];

        return idx;
    }
    
    NSString *path = [self originalImagePathAtIndex:index];
    NSData *data = UIImagePNGRepresentation(originalImage);
    BOOL success = [data writeToFile:path atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return -1;
    }
    
    path = [self smallImagePathAtIndex:index];
    data = UIImagePNGRepresentation(smallImage);
    success = [data writeToFile:path atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return -1;
    }
    
    path = [self maskImagePathAtIndex:index];
    data = UIImagePNGRepresentation(maskImage);
    success = [data writeToFile:path atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return -1;
    }
    
    path = [self bigImagePathAtIndex:index];
    data = UIImagePNGRepresentation(bigImage);
    success = [data writeToFile:path atomically:YES];
    if (!success) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        return -1;
    }
    
    return index;
}
-(float) itemAPIVersionAtIndex:(NSInteger)index;
{
    NSArray *itemArray = self.data;

    NSDictionary *item = [itemArray objectAtIndex:index];

    return [[item objectForKey:kItemAPIVersionKey] floatValue];
}
-(UIImage *)originalImageAtIndex:(NSInteger)index;
{
    NSString *imagePath = [self originalImagePathAtIndex:index];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}
-(UIImage *)maskImageAtIndex:(NSInteger)index;
{
    NSString *imagePath = [self maskImagePathAtIndex:index];
    
    return [UIImage imageWithContentsOfFile:imagePath];
}
-(NSString *)originalImagePathAtIndex:(NSInteger)index;
{
    NSArray *itemArray = self.data;
    if (index >= itemArray.count || [self itemAPIVersionAtIndex:index]<2.0) {
        return nil;
    }
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    
    NSDictionary *item = [itemArray objectAtIndex:index];
    NSString *imagePath = [ddPath stringByAppendingPathComponent:[[item objectForKey:kItemOriginalImageKey] lastPathComponent]];
    
    return imagePath;
}
-(NSString *)maskImagePathAtIndex:(NSInteger)index;
{
    NSArray *itemArray = self.data;
    if (index >= itemArray.count || [self itemAPIVersionAtIndex:index]<2.0) {
        return nil;
    }
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    
    NSDictionary *item = [itemArray objectAtIndex:index];
    NSString *imagePath = [ddPath stringByAppendingPathComponent:[[item objectForKey:kItemMaskImageKey] lastPathComponent]];
    
    return imagePath;
}
@end
