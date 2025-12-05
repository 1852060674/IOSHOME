//
//  ZBAdjustFrameHeightForAd.h
//  Collage
//
//  Created by shen on 13-7-29.
//  Copyright (c) 2013年 ZB. All rights reserved.
//
#import "ZBCommonDefine.h"



#ifndef Collage_ZBAdjustFrameHeightForAd_h
#define Collage_ZBAdjustFrameHeightForAd_h

#define kPosterWidth    ((IS_IPAD?469:194))
#define kPosterTableHeight   ((IS_IPAD?500:300))
#define kAspectViewHeight   ((IS_IPAD?110:80))
#define kSelectBGViewX   ((IS_IPAD?100:50))
#define kSelectBGViewH   ((IS_IPAD?400:225))

//no ad
#define kPresentTemplateViewHeightNoAd CGRectMake(kTemplateGap, (kScreenHeight - kNavigationBarHeight - kBottomBarHeight - kTemplateEdge)/2, kTemplateEdge, kTemplateEdge)
#define kFreecollageViewHeightNoAd CGRectMake(30, 20, (kScreenWidth-2*30), (kScreenHeight  - kNavigationBarHeight -kBottomBarHeight- 20*2))
#define kJoinScrollViewHeightNoAd  CGRectMake(kTemplateGap, 20, (kScreenWidth-2*kTemplateGap), kScreenHeight-kNavigationBarHeight-kBottomBarHeight-40)
#define kPosterCollageViewHeightNoAd  CGRectMake(30, 20, (kScreenWidth-2*30),(kScreenHeight  - kNavigationBarHeight -20*2 - kBottomBarHeight))


#define kBottomBarHgithNoAd   CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight, kScreenWidth, kBottomBarHeight)
#define kFreeBottomBarHgithNoAd   CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight, kScreenWidth, kBottomBarHeight)
#define kJoincollageBottomBarHgithNoAd CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight, kScreenWidth, kBottomBarHeight)
#define kPosterCollageBottomBarHgithNoAd  CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight, kScreenWidth, kBottomBarHeight)

#define kSpecificTemplateViewHgithNoAd   CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAspectViewHeight+8, kScreenWidth, kAspectViewHeight)

#define kColorAndBGImageViewHgithNoAd CGRectMake(kSelectBGViewX, 20, kScreenWidth - 2*kSelectBGViewX, kSelectBGViewH)

#define kSelectBGViewHgithNoAd CGRectMake(kSelectBGViewX, 20, kScreenWidth - 2*kSelectBGViewX, kSelectBGViewH)

#define kSmilingFaceViewHgithNoAd CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAspectViewHeight+8, kScreenWidth, kAspectViewHeight)
#define kAspectViewHgithNoAd CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAspectViewHeight+8, kScreenWidth, kAspectViewHeight)
#define kBackgroundImageViewHgithNoAd CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAspectViewHeight+8, kScreenWidth, kAspectViewHeight)


#define kPosterTableViewHgithNoAd CGRectMake((kScreenWidth-kPosterWidth)/2, kScreenHeight-kNavigationBarHeight, kPosterWidth, kPosterTableHeight)

#define kLastButtonHgithNoAd CGRectMake(-5, (kScreenHeight-kNavigationBarHeight-kBottomBarHeight)/2-21.5, 43, 43)
#define kNextButtonHgithNoAd CGRectMake(kScreenWidth - 38, (kScreenHeight-kNavigationBarHeight-kBottomBarHeight)/2-21.5, 43, 43)


//with ad

#define kPresentTemplateViewHeightWithAd CGRectMake(kTemplateGap, (kScreenHeight - kNavigationBarHeight - kBottomBarHeight - kTemplateEdge-kAdHeiht)/2, kTemplateEdge, kTemplateEdge)
#define kFreecollageViewHeightWithAd CGRectMake(30, 5, (kScreenWidth-2*30), (kScreenHeight - kNavigationBarHeight -kBottomBarHeight-kAdHeiht- 5*2))
#define kJoinScrollViewHeightWithAd  CGRectMake(kTemplateGap, 5, (kScreenWidth-2*kTemplateGap), kScreenHeight-kNavigationBarHeight-kAdHeiht-kBottomBarHeight-10)
#define kPosterCollageViewHeightWithAd  CGRectMake(30, 5, (kScreenWidth-2*30),(kScreenHeight  - kNavigationBarHeight -kAdHeiht-5*2 - kBottomBarHeight))


#define kBottomBarHgithWithAd   CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAdHeiht, kScreenWidth, kBottomBarHeight)
#define kFreeBottomBarHgithWithAd   CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAdHeiht, kScreenWidth, kBottomBarHeight)
#define kJoincollageBottomBarHgithWithAd CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAdHeiht, kScreenWidth, kBottomBarHeight)
#define kPosterCollageBottomBarHgithWithAd  CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAdHeiht, kScreenWidth, kBottomBarHeight)

#define kSpecificTemplateViewHgithWithAd   CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAspectViewHeight+8-kAdHeiht, kScreenWidth, kAspectViewHeight)

//#define kColorAndBGImageViewHgithWithAd CGRectMake(kSelectBGViewX, 20, kScreenWidth - 2*kSelectBGViewX, kSelectBGViewH)
//
//#define kSelectBGViewHgithWithAd CGRectMake(kSelectBGViewX, 20, kScreenWidth - 2*kSelectBGViewX, kSelectBGViewH)

#define kSmilingFaceViewHgithWithAd CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAspectViewHeight+8-kAdHeiht, kScreenWidth, kAspectViewHeight)
#define kAspectViewHgithWithAd CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAspectViewHeight+8-kAdHeiht, kScreenWidth, kAspectViewHeight)
#define kBackgroundImageViewHgithWithAd CGRectMake(0, kScreenHeight-kNavigationBarHeight-kBottomBarHeight-kAspectViewHeight+8-kAdHeiht, kScreenWidth, kAspectViewHeight)


#define kPosterTableViewHgithWithAd CGRectMake((kScreenWidth-kPosterWidth)/2, kScreenHeight-kNavigationBarHeight, kPosterWidth, kPosterTableHeight)

#define kLastButtonHgithWithAd CGRectMake(-5, (kScreenHeight-kNavigationBarHeight-kBottomBarHeight)/2-21.5, 43, 43)
#define kNextButtonHgithWithAd CGRectMake(kScreenWidth - 38, (kScreenHeight-kNavigationBarHeight-kBottomBarHeight)/2-21.5, 43, 43)

#endif
