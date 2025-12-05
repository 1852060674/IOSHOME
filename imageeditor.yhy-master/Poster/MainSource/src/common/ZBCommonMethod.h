//
//  ZBCommonMethod.h
//  Collage
//
//  Created by shen on 13-6-27.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBCommonDefine.h"

typedef enum {
    LanguageTypeZH_hans,
    LanguageTypeZH_hant,
    LanguageTypeEn,
}LanguageType;


@interface ZBCommonMethod : NSObject

+ (LanguageType)getCurrentLanguageType;

+ (void)setCurrentCollageType:(CollageType)type;

+ (CollageType)getCurrentCollageType;

+ (NSUInteger)getTemplateIndex:(NSUInteger)imagesCount;

+ (BOOL)isRegularCollage:(NSUInteger)templateIndex;

+ (NSUInteger)getRegularTemplateIndex:(NSUInteger)templateIndex;

+ (void)setUserSelectedAssets:(NSArray*)array;

+ (NSMutableArray*)getUserSelectedAssets;

+ (BOOL)isShowRegularTemplateInFont;

+ (NSUInteger)getRegularTemplateCountWithImagesCount:(NSUInteger)imagescount;

+ (NSUInteger)getIrregularTemplateCountWithImagesCount:(NSUInteger)imagescount;

+ (void)setCurrentPosterType:(PosterCollageType)type;

+ (PosterCollageType)getCurrentPosterType;

+ (void)setIsShowAdValue:(BOOL)isShow;

+ (BOOL)getIsShowAdValue;

+ (ShowCollageType)showAllCollageType;

+(CGFloat) systemVersion;

+(BOOL)isIpad;

+ (NSString*)getDeviceModel;
@end
