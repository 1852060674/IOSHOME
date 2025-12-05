//
//  PhotoStore.m
//  OldBooth
//
//  Created by ZB_Mac on 14-10-23.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import "PhotoCache.h"
#import <UIKit/UIKit.h>

const NSString *defaultIdentifier = @"defaultCache";

const NSString *kItemImageKey = @"bigImage";

@interface PhotoCache ()
@property (strong, nonatomic) NSMutableDictionary* imageNames;

@property (strong, nonatomic) NSString *identifier;
@end

@implementation PhotoCache

+(PhotoCache *)defaultCache
{
    static dispatch_once_t once;
    static PhotoCache *store = nil;
    
    if (store == nil) {
        dispatch_once(&once, ^{
            store = [[self alloc] initWithIdentifier:(NSString *)defaultIdentifier];
        });
    }
    return store;
}

-(PhotoCache *)initWithIdentifier:(NSString *)identity
{
    self = [super init];
    if (self) {
        self.identifier = identity;
        self.imageNames = [NSMutableDictionary dictionary];
    }

    return self;
}

-(NSInteger)addCacheImage:(UIImage *)bigImage withKey:(NSString *)key
{
    if (!key) {
        return -1;
    }
    
    if ([self.imageNames.allKeys containsObject:key]) {
        NSInteger cnt = [[self.imageNames valueForKey:key] integerValue];
        [self.imageNames setValue:@(cnt+1) forKey:key];
        return 0;
    }
    
    if (!bigImage) {
        return -1;
    }
    
    [self.imageNames setValue:@(1) forKey:key];
    
    NSString *path = [self pathForKey:key];

    NSData *pngData = UIImagePNGRepresentation(bigImage);
    BOOL success = [pngData writeToFile:path atomically:YES];
    
    return success;
}

-(void)removeCacheImageKey:(NSString *)key
{
    if (!key) {
        return;
    }
    if (![self.imageNames.allKeys containsObject:key]) {
        return;
    }
    NSInteger cnt = [[self.imageNames valueForKey:key] integerValue];
    cnt = cnt - 1;
    
    if (cnt <= 0) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [self pathForKey:key];
        
        [fileManager removeItemAtPath:path error:nil];
        [self.imageNames removeObjectForKey:key];
        return;
    }
    [self.imageNames setValue:@(cnt) forKey:key];
}

-(UIImage *)cachedImageWithKey:(NSString *)key
{
    UIImage *image = nil;
    if ([self.imageNames.allKeys containsObject:key]) {
        NSString *path = [self pathForKey:key];
        image = [UIImage imageWithContentsOfFile:path];
    }

    return image;
}

-(NSInteger)referencCntWithKey:(NSString *)key
{
    if (![self.imageNames.allKeys containsObject:key]) {
        return 0;
    }
    NSInteger cnt = [[self.imageNames valueForKey:key] integerValue];
    return cnt;
}

-(void)removeAllCachedImage
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    for (NSString* imageName in self.imageNames) {
        NSString *path = [self pathForKey:imageName];
        
        [fileManager removeItemAtPath:path error:nil];
    }
    [self.imageNames removeAllObjects];
}

-(NSString *)pathForKey:(NSString *)key
{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *ddPath =  [pathArray objectAtIndex:0];
    NSString *path = [ddPath stringByAppendingPathComponent:[self.identifier stringByAppendingString:key]];
    
    return path;
}

-(void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
    [self removeAllCachedImage];
}

@end
