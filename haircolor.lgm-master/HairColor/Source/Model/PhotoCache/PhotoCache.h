//
//  PhotoStore.h
//  OldBooth
//
//  Created by ZB_Mac on 14-10-23.
//  Copyright (c) 2014年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class NSString;
@interface PhotoCache: NSObject
+(PhotoCache *)defaultCache;

-(PhotoCache *)initWithIdentifier:(NSString *)identity;
-(NSInteger)addCacheImage:(UIImage *)bigImage withKey:(NSString *)key;
-(UIImage *)cachedImageWithKey:(NSString *)key;
-(NSInteger)referencCntWithKey:(NSString *)key;

-(void)removeCacheImageKey:(NSString *)key;
-(void)removeAllCachedImage;
@end
