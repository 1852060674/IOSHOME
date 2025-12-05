//
//  ZBCommonDefine.h
//  Collage
//
//  Created by shen on 13-6-24.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#ifndef Collage_ZBCommonDefine_h
#define Collage_ZBCommonDefine_h

#import "CfgCenter.h"

#define APP_URL [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/id%d",kAppID]

// Added by jerry
#define kNeedAds YES
#define kPhotoCollageTitle @"PhotoCollage"


#define IS_IPAD ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define kSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]
#define kScreenWidth   ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight  ([[UIScreen mainScreen] bounds].size.height)
#define kStatusBarHeight          20.0f
#define kNavigationBarHeight      44.0f
#define kBottomBarHeight          (IS_IPAD?44:36)
#define kMargin                   5
#define kCountOfImagesPerLine     (IS_IPAD?6:4)
#define kAssetEdgeLength   ((kScreenWidth - (kCountOfImagesPerLine+1)*kMargin)/kCountOfImagesPerLine)
#define kAssetScrollViewHeight    (kAssetEdgeLength+15)
#define kAssetRemindTextHeight    20
#define kAssetRemindFontSize      16
#define kTemplateGap              4
#define kTemplateEdge             (kScreenWidth-2*kTemplateGap)
#define kBottomBarWidth  300
#define kAdHeiht                  ((IS_IPAD?90:50))

#define kEditImageViewTopGap      ((IS_IPAD?10:10))
#define kEditImageViewLefGap      ((IS_IPAD?10:10))

#define kStartButtonTag              500
#define kStartScrollViewTag          600
#define kStartImageViewTag           700
#define kDragViewStartTag            800
#define kSmilingButtonStartTag       1000
#define kAspectButtonStartTag        1200
#define kPhotoFrameButtonStartTag    1300
#define kTemplateButtonStartTag      1400
#define kFreeCollageImageViewStartTag   1500
#define kJoinCollageImageViewStartTag   1600
#define kBackgroundImageViewStartTag   1700
#define kAddImageViewStartTag        1800
#define kIrregularScrollViewStartTag 1900
#define kPosterImageViewStartTag     2000
#define kPosterThumbnailStartTag     2100


#define kTemplateOneCount            1
#define kTemplateTwoCount            8
#define kTemplateThreeCount          21
#define kTemplateFourCount           28
#define kTemplateFiveCount           38
#define kTemplateSixCount            6
#define kTemplateSevenCount          3

#define kRegularTemplateOneCount            1
#define kRegularTemplateTwoCount            6
#define kRegularTemplateThreeCount          16
#define kRegularTemplateFourCount           25
#define kRegularTemplateFiveCount           31
#define kRegularTemplateSixCount            6
#define kRegularTemplateSevenCount          2

#define kIrregularTemplateTwoCount            2
#define kIrregularTemplateThreeCount          5
#define kIrregularTemplateFourCount           3
#define kIrregularTemplateFiveCount           7
#define kIrregularTemplateSixCount            0
#define kIrregularTemplateSevenCount          1

#define kIrregularTemplateGap     (IS_IPAD?10:4)  

#define kCountOfBackgroundImage   33

#define kImageViewCountsInPerLine (IS_IPAD?3:2) 

#define kChangeBackGroundImage @"ChangeBackgroundImage"
#define kSelectedAnImage       @"SelectedAnImage"
#define kChangeJoinHeight      @"ChangeJoinHeight"
#define kIrregularChangeImage  @"IrregularChangeImage"
#define kIrregularEditImage    @"IrregularEditImage"
#define kPosterChangeType      @"PosterChangeType"

#define PI 3.14159265358979323846

typedef enum {
    PickerImageFilterTypeAllAssets,
    PickerImageFilterTypeAllPhotos,
    PickerImageFilterTypeAllVideos
} PickerImageFilterType;

typedef enum {
    PicImageTypeAllAssets,
    PicImageTypeAllPhotos,
    PicImageTypeAllVideos
} PicImageType;

typedef enum {
    CollageTypeGrid,
    CollageTypeFree,
    CollageTypeJoin,
    CollageTypePoster,
    CollageTypeAll
} CollageType;

typedef enum {
    ShowCollageTypeGrid,
    ShowCollageTypeFree,
    ShowCollageTypeJoin,
    ShowCollageTypePoster,
    ShowCollageTypeAll
} ShowCollageType;

typedef enum {
    SliderChangeTypeBorder,
    SliderChangeTypeCorner,
} SliderChangeType;

typedef enum {
    FreeCollageChangeTypeLast,
    FreeCollageChangeTypeNext,
}FreeCollageChangeType;

typedef enum {
    PosterCollageChangeTypeLast,
    PosterCollageChangeTypeNext,
}PosterCollageChangeType;

typedef enum
{
    aspect_1x1_icon,
    aspect_2x3_icon,
    aspect_3x2_icon,
    aspect_3x4_icon,
    aspect_4x3_icon,
    aspect_4x5_icon,
    aspect_5x4_icon,
    aspect_5x7_icon,
    aspect_7x5_icon,
    aspect_9x16_icon,
    aspect_16x9_icon,
    aspect_fb_icon
}AspectType;

typedef enum
{
    PicImageTemplateType1,
    PicImageTemplateType2_1,
    PicImageTemplateType2_2,
    PicImageTemplateType2_3,
    PicImageTemplateType2_4,
    PicImageTemplateType2_5,
    PicImageTemplateType2_6,
    PicImageTemplateType3_1,
    PicImageTemplateType3_2,
    PicImageTemplateType3_3,
    PicImageTemplateType3_4,
    PicImageTemplateType3_5,
    PicImageTemplateType3_6,
    PicImageTemplateType3_7,
    PicImageTemplateType3_8,
    PicImageTemplateType3_9,
    PicImageTemplateType3_10,
    PicImageTemplateType3_11,
    PicImageTemplateType3_12,
    PicImageTemplateType3_13,
    PicImageTemplateType3_14,
    PicImageTemplateType3_15,
    PicImageTemplateType3_16,
    PicImageTemplateType4_1,
    PicImageTemplateType4_2,
    PicImageTemplateType4_3,
    PicImageTemplateType4_4,
    PicImageTemplateType4_5,
    PicImageTemplateType4_6,
    PicImageTemplateType4_7,
    PicImageTemplateType4_8,
    PicImageTemplateType4_9,
    PicImageTemplateType4_10,
    PicImageTemplateType4_11,
    PicImageTemplateType4_12,
    PicImageTemplateType4_13,
    PicImageTemplateType4_14,
    PicImageTemplateType4_15,
    PicImageTemplateType4_16,
    PicImageTemplateType4_17,
    PicImageTemplateType4_18,
    PicImageTemplateType4_19,
    PicImageTemplateType4_20,
    PicImageTemplateType4_21,
    PicImageTemplateType4_22,
    PicImageTemplateType4_23,
    PicImageTemplateType4_24,
    PicImageTemplateType4_25,
    PicImageTemplateType5_1,
    PicImageTemplateType5_2,
    PicImageTemplateType5_3,
    PicImageTemplateType5_4,
    PicImageTemplateType5_5,
    PicImageTemplateType5_6,
    PicImageTemplateType5_7,
    PicImageTemplateType5_8,
    PicImageTemplateType5_9,
    PicImageTemplateType5_10,
    PicImageTemplateType5_11,
    PicImageTemplateType5_12,
    PicImageTemplateType5_13,
    PicImageTemplateType5_14,
    PicImageTemplateType5_15,
    PicImageTemplateType5_16,
    PicImageTemplateType5_17,
    PicImageTemplateType5_18,
    PicImageTemplateType5_19,
    PicImageTemplateType5_20,
    PicImageTemplateType5_21,
    PicImageTemplateType5_22,
    PicImageTemplateType5_23,
    PicImageTemplateType5_24,
    PicImageTemplateType5_25,
    PicImageTemplateType5_26,
    PicImageTemplateType5_27,
    PicImageTemplateType5_28,
    PicImageTemplateType5_29,
    PicImageTemplateType5_30,
    PicImageTemplateType5_31,
    PicImageTemplateType6_1,
    PicImageTemplateType6_2,
    PicImageTemplateType6_3,
    PicImageTemplateType6_4,
    PicImageTemplateType6_5,
    PicImageTemplateType6_6,
    PicImageTemplateType7_1,
    PicImageTemplateType7_2,    
}PicImageTemplateType;

typedef enum
{
    PosterCollageType1,
    PosterCollageType2,
    PosterCollageType3,
    PosterCollageType4,
    PosterCollageType5,
    PosterCollageType6,
    PosterCollageType7,
    PosterCollageType8,
    PosterCollageType9,
    PosterCollageType10,
    PosterCollageType11,
    PosterCollageType12,
    PosterCollageType13,
    PosterCollageType14,
    PosterCollageType15
}PosterCollageType;

#endif
