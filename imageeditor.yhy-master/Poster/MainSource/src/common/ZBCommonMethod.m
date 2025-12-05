//
//  ZBCommonMethod.m
//  Collage
//
//  Created by shen on 13-6-27.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBCommonMethod.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#include "Admob.h"

@implementation ZBCommonMethod

static CollageType _currentCollageType;
static NSMutableArray *selectedAssets;
static PosterCollageType _currentPosterType;
static bool _isShowAd = YES;

+(NSString*)currentLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages objectAtIndex:0];
    return currentLang;
}

+(LanguageType)getCurrentLanguageType
{
    LanguageType langType;
    if ([[self currentLanguage] compare:@"zh-Hant" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        langType = LanguageTypeZH_hant;
    }
    else if([[self currentLanguage] compare:@"zh-Hans" options:NSCaseInsensitiveSearch]==NSOrderedSame || [[self currentLanguage] rangeOfString:@"zh-Han"].location!=NSNotFound)
    {
        langType = LanguageTypeZH_hans;
    }
    else{
        langType = LanguageTypeEn;
    }
    return langType;
}

+ (void)setCurrentCollageType:(CollageType)type
{
    _currentCollageType = type;
}

+ (CollageType)getCurrentCollageType
{
    return _currentCollageType;
}

+ (NSUInteger)getTemplateIndex:(NSUInteger)imagesCount
{
    if (imagesCount<1) {
        return 0;
    }
    switch (imagesCount) {
        case 1:
            return 0;
            break;
        case 2:
            return kTemplateOneCount;
            break;
        case 3:
            return kTemplateOneCount+kTemplateTwoCount;
            break;
        case 4:
            return kTemplateOneCount+kTemplateTwoCount+kTemplateThreeCount;
            break;
        case 5:
            return kTemplateOneCount+kTemplateTwoCount+kTemplateThreeCount+kTemplateFourCount;
            break;
        case 6:
            return kTemplateOneCount+kTemplateTwoCount+kTemplateThreeCount+kTemplateFourCount+kTemplateFiveCount;
            break;
        case 7:
            return kTemplateOneCount+kTemplateTwoCount+kTemplateThreeCount+kTemplateFourCount+kTemplateFiveCount+kTemplateSixCount;
            break;
        default:
            break;
    }
    return 0;
}

+ (BOOL)isRegularCollage:(NSUInteger)templateIndex
{
    BOOL _isRegular = YES;
    if (templateIndex<([ZBCommonMethod getTemplateIndex:3]-kIrregularTemplateTwoCount)) {
        _isRegular = YES;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:3]-kIrregularTemplateTwoCount) && (templateIndex<[ZBCommonMethod getTemplateIndex:3]))
    {
        _isRegular = NO;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:3]) && (templateIndex<([ZBCommonMethod getTemplateIndex:4]-kIrregularTemplateThreeCount)))
    {
        _isRegular = YES;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:4]-kIrregularTemplateThreeCount) && (templateIndex<[ZBCommonMethod getTemplateIndex:4]))
    {
        _isRegular = NO;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:4]) && (templateIndex<([ZBCommonMethod getTemplateIndex:5]-kIrregularTemplateFourCount)))
    {
        _isRegular = YES;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:5]-kIrregularTemplateFourCount) && (templateIndex<[ZBCommonMethod getTemplateIndex:5]))
    {
        _isRegular = NO;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:5]) && (templateIndex<([ZBCommonMethod getTemplateIndex:6]-kIrregularTemplateFiveCount)))
    {
        _isRegular = YES;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:6]-kIrregularTemplateFiveCount) && (templateIndex<[ZBCommonMethod getTemplateIndex:6]))
    {
        _isRegular = NO;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:6]) && (templateIndex<([ZBCommonMethod getTemplateIndex:7]-kIrregularTemplateSixCount)))
    {
        _isRegular = YES;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:7]-kIrregularTemplateSixCount) && (templateIndex<[ZBCommonMethod getTemplateIndex:7]))
    {
        _isRegular = NO;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:7]) && (templateIndex<([ZBCommonMethod getTemplateIndex:7]+kTemplateSevenCount-kIrregularTemplateSevenCount)))
    {
        _isRegular = YES;
    }
    else if(templateIndex>=([ZBCommonMethod getTemplateIndex:7]+kTemplateSevenCount-kIrregularTemplateSevenCount) && (templateIndex<=[ZBCommonMethod getTemplateIndex:7]+kTemplateSevenCount))
    {
        _isRegular = NO;
    }
    return  _isRegular;
}

+ (NSUInteger)getRegularTemplateIndex:(NSUInteger)templateIndex
{
    NSUInteger _regularTempalteIndex = templateIndex;
    if (templateIndex<[ZBCommonMethod getTemplateIndex:3]) {
        _regularTempalteIndex = templateIndex - kIrregularTemplateTwoCount;
    }
    else if (templateIndex<[ZBCommonMethod getTemplateIndex:4]) {
        _regularTempalteIndex = templateIndex - kIrregularTemplateTwoCount;
    }
    else if (templateIndex<([ZBCommonMethod getTemplateIndex:5])) {   //4张图片，
        _regularTempalteIndex = templateIndex - kIrregularTemplateTwoCount - kIrregularTemplateThreeCount;
    }
    else if(templateIndex<[ZBCommonMethod getTemplateIndex:6])
    {
        _regularTempalteIndex = templateIndex - kIrregularTemplateTwoCount - kIrregularTemplateThreeCount-kIrregularTemplateFourCount;
    }
    else if(templateIndex<([ZBCommonMethod getTemplateIndex:7]))
    {
        _regularTempalteIndex = templateIndex - kIrregularTemplateTwoCount - kIrregularTemplateThreeCount-kIrregularTemplateFourCount-kIrregularTemplateFiveCount;
    }
    else if(templateIndex<[ZBCommonMethod getTemplateIndex:7]+kTemplateSevenCount)
    {
        _regularTempalteIndex = templateIndex - kIrregularTemplateTwoCount - kIrregularTemplateThreeCount-kIrregularTemplateFourCount-kIrregularTemplateFiveCount-kIrregularTemplateSixCount;
    }
    return _regularTempalteIndex;
}

+ (void)setUserSelectedAssets:(NSArray*)array
{
    if (selectedAssets == nil) {
        selectedAssets = [[NSMutableArray alloc] initWithArray:array];
    }
    else
    {
        [selectedAssets removeAllObjects];
        [selectedAssets addObjectsFromArray:array];
    }
}

+ (NSMutableArray*)getUserSelectedAssets
{
    return selectedAssets;
}

+ (BOOL)isShowRegularTemplateInFont
{
    return YES;
}

+ (NSUInteger)getRegularTemplateCountWithImagesCount:(NSUInteger)imagescount
{
    switch (imagescount) {
        case 2:
            return kRegularTemplateTwoCount;
            break;
        case 3:
            return kRegularTemplateThreeCount;
            break;
        case 4:
            return kRegularTemplateFourCount;
            break;
        case 5:
            return kRegularTemplateFiveCount;
            break;
        case 6:
            return kRegularTemplateSixCount;
            break;
        case 7:
            return kRegularTemplateSevenCount;
            break;
        default:
            break;
    }
    return 0;
}

+ (NSUInteger)getIrregularTemplateCountWithImagesCount:(NSUInteger)imagescount
{
    switch (imagescount) {
        case 2:
            return kIrregularTemplateTwoCount;
            break;
        case 3:
            return kIrregularTemplateThreeCount;
            break;
        case 4:
            return kIrregularTemplateFourCount;
            break;
        case 5:
            return kIrregularTemplateFiveCount;
            break;
        case 6:
            return kIrregularTemplateSixCount;
            break;
        case 7:
            return kIrregularTemplateSevenCount;
            break;
        default:
            break;
    }
    return 0;
}

+ (void)setCurrentPosterType:(PosterCollageType)type
{
    _currentPosterType = type;
}

+ (PosterCollageType)getCurrentPosterType
{
    return _currentPosterType;
}

+ (void)setIsShowAdValue:(BOOL)isShow
{
    _isShowAd = isShow;
}

+ (BOOL)getIsShowAdValue
{
    return _isShowAd;
}

+ (ShowCollageType)showAllCollageType
{
    // funny1 pro/free
    //return ShowCollageTypePoster;
    
    // dev7 pro
    //return ShowCollageTypeAll;
    
    // dev1->lele free
    return ShowCollageTypeGrid;
    
    // funny2
//    return ShowCollageTypeAll;
}

+ (NSString*)getDeviceModel
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char*)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    //NSString *platform = [NSStringstringWithUTF8String:machine];二者等效
    free(machine);
    return platform;
}

+(BOOL)isIpad
{
    return ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

+(CGFloat) systemVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}
@end
