//
//  ZBHomePageView.m
//  Poster
//
//  Created by shen on 13-8-2.
//  Copyright (c) 2013年 ZBNetwork. All rights reserved.
//

#import "ZBHomePageView.h"
#import "ZBCommonDefine.h"
#import "ZBAppDelegate.h"
#import "AdUtility.h"

@interface ZBHomePageView()
{
    UIButton *_posterButton;
}

@end

@implementation ZBHomePageView

@synthesize editButton = _editButton;
@synthesize upgradeButton;
@synthesize moreButton;
@synthesize feedbackButton = _feedbackButton;

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        BOOL isPaid = ![AdUtility hasAd];
        
        self.backgroundColor = [UIColor clearColor];
        
        NSString* strBgName = @"main-bg-h568";
        float btnHeightStart = 200;
        float btnHeightMargin = 80;
        float btnSize = 120;
        float xshift = 30;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            strBgName = @"main-bg-ipad";
            
            btnSize = 240;
            btnHeightStart = 400;
            btnHeightMargin = 80;
            xshift = 100;
        } else {
            btnHeightStart = 230;
            btnHeightMargin = 60;
            btnSize = 120;
            if ([UIScreen mainScreen].bounds.size.height < 481){
                strBgName = @"main-bg-iphone4";
                btnHeightStart -= 35;
                btnHeightMargin = 35;
            }
        }
 
#if 0
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            strBgName = @"main-bg-ipad";
            btnHeightStart = 400;
            if (kNeedAds == NO)
                btnHeightMargin = 110;
        }
        else
        {
            if (kNeedAds == YES)
            {
                btnHeightStart = 160;
                btnHeightMargin = 60;
            }
            
            if ([UIScreen mainScreen].bounds.size.height < 481)
            {
                strBgName = @"main-bg-iphone4";
                if (kNeedAds == YES)
                    btnHeightStart = 140;
                else
                    btnHeightStart = 160;
                //btnHeightMargin = 70;
            }
        }
#endif
        
        UIImageView* mainBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:strBgName]];
        [mainBgView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [self addSubview:mainBgView];

        // lele
//        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _editButton.frame = CGRectMake(xshift, btnHeightStart, btnSize, btnSize);
//        [_editButton setImage:[UIImage imageNamed:@"photo-edit-btn"] forState:UIControlStateNormal];
//        [_editButton addTarget:self action:@selector(editImage) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_editButton];
//        
//        _posterButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _posterButton.frame = CGRectMake(kScreenWidth- btnSize - xshift, btnHeightStart, btnSize, btnSize);
//        [_posterButton setImage:[UIImage imageNamed:@"photo-frame-btn"] forState:UIControlStateNormal];
//        [_posterButton addTarget:self action:@selector(createPoster) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_posterButton];
//        
//        _feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _feedbackButton.frame = CGRectMake(kScreenWidth- btnSize/3 - 10, btnHeightStart - btnHeightMargin, btnSize/3, btnSize/3);
//        [_feedbackButton setImage:[UIImage imageNamed:@"rating"] forState:UIControlStateNormal];
//        [_feedbackButton addTarget:self action:@selector(rating) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_feedbackButton];
//        
//        if (!isPaid)
//        {
//             upgradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//            upgradeButton.frame = CGRectMake(10, btnHeightStart - btnHeightMargin, btnSize/3, btnSize/3);
//            [upgradeButton setImage:[UIImage imageNamed:@"update-btn"] forState:UIControlStateNormal];
//            [upgradeButton addTarget:self action:@selector(updateApps) forControlEvents:UIControlEventTouchUpInside];
//            [self addSubview:upgradeButton];
//        }
//        
//        if (!isReview)
//        {
//                 moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                moreButton.frame = CGRectMake(10, btnHeightStart + btnSize + btnHeightMargin - 40, btnSize/3, btnSize/3);
//                [moreButton setImage:[UIImage imageNamed:@"more-apps-btn"] forState:UIControlStateNormal];
//                [moreButton addTarget:self action:@selector(moreApps) forControlEvents:UIControlEventTouchUpInside];
//                [self addSubview:moreButton];
//        }
        
        // funny2
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//        {
//            strBgName = @"main-bg-ipad";
//            
//            btnSize = 200;
//            btnHeightStart = 400;
//            btnHeightMargin = 80;
//            xshift = 100;
//        } else {
//            btnHeightStart = 200;
//            btnHeightMargin = 60;
//            btnSize = 100;
//            xshift = 50.0;
//            if ([UIScreen mainScreen].bounds.size.height < 481){
//                strBgName = @"main-bg-iphone4";
//                btnHeightStart -= 40;
//                btnHeightMargin = 40;
//            }
//        }
//        
//        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _editButton.frame = CGRectMake(xshift, btnHeightStart, btnSize, btnSize);
//        [_editButton setImage:[UIImage imageNamed:@"photo-edit-btn"] forState:UIControlStateNormal];
//        [_editButton addTarget:self action:@selector(editImage) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_editButton];
//        
//        _posterButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _posterButton.frame = CGRectMake(kScreenWidth- btnSize - xshift, btnHeightStart, btnSize, btnSize);
//        [_posterButton setImage:[UIImage imageNamed:@"photo-frame-btn"] forState:UIControlStateNormal];
//        [_posterButton addTarget:self action:@selector(createPoster) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_posterButton];
//        
//        upgradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        upgradeButton.frame = CGRectMake(xshift, btnHeightStart+btnSize*1.3, btnSize, btnSize);
//        [upgradeButton setImage:[UIImage imageNamed:@"update-btn"] forState:UIControlStateNormal];
//        [upgradeButton addTarget:self action:@selector(updateApps) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:upgradeButton];
//        
//        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        moreButton.frame = CGRectMake(kScreenWidth- btnSize - xshift, btnHeightStart+btnSize*1.3, btnSize, btnSize);
//        [moreButton setImage:[UIImage imageNamed:@"more-apps-btn"] forState:UIControlStateNormal];
//        [moreButton addTarget:self action:@selector(moreApps) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:moreButton];
        
        // funny2 new
        btnHeightStart = 300;
        btnHeightMargin = 80;
        btnSize = 100;
        xshift = 40;
        CGFloat titleHeight = IS_IPAD?80:40;
        CGFloat titleWidth = IS_IPAD?500:250;
        CGFloat titleHeightStart = IS_IPAD?380:200;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            strBgName = @"main-bg-ipad";
            
            btnSize = 220;
            btnHeightStart = 550;
            btnHeightMargin = 80;
            xshift = 100;
        } else {
            btnHeightStart = 300;
            btnHeightMargin = 60;
            btnSize = 110;
            if ([UIScreen mainScreen].bounds.size.height < 481){
                strBgName = @"main-bg-iphone4";
                btnHeightStart -= 40;
                btnHeightMargin = 40;
            }
        }
        UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-titleWidth)/2.0, titleHeightStart, titleWidth, titleHeight)];
        titleView.image = [UIImage imageNamed:@"main_title"];
        titleView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:titleView];
        
        UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.keyWindow;
            safeAreaInsets = window.safeAreaInsets;
        }
        
        _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _editButton.frame = CGRectMake(xshift, btnHeightStart + safeAreaInsets.top, btnSize, btnSize);
        [_editButton setImage:[UIImage imageNamed:@"photo-edit-btn"] forState:UIControlStateNormal];
        [_editButton addTarget:self action:@selector(editImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_editButton];
        
        _posterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _posterButton.frame = CGRectMake(kScreenWidth- btnSize - xshift, btnHeightStart + safeAreaInsets.top, btnSize, btnSize);
        [_posterButton setImage:[UIImage imageNamed:@"photo-frame-btn"] forState:UIControlStateNormal];
        [_posterButton addTarget:self action:@selector(createPoster) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_posterButton];
        
//        _feedbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        _feedbackButton.frame = CGRectMake(kScreenWidth- btnSize/3 - 10, btnHeightStart - btnHeightMargin, btnSize/3, btnSize/3);
//        [_feedbackButton setImage:[UIImage imageNamed:@"rating"] forState:UIControlStateNormal];
//        [_feedbackButton addTarget:self action:@selector(rating) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:_feedbackButton];
//        
        if (!isPaid)
        {
            upgradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            upgradeButton.frame = CGRectMake(10, kScreenHeight-btnSize/2.0-10, btnSize/2, btnSize/2);
            [upgradeButton setImage:[UIImage imageNamed:@"update-btn"] forState:UIControlStateNormal];
            [upgradeButton addTarget:self action:@selector(updateApps) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:upgradeButton];
        }
    }
    return self;
}

#pragma mark -
#pragma mark custom method

- (void)editImage
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editImage)]) {
        [self.delegate editImage];
    }
}

- (void)createPoster
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(collage)]) {
        [self.delegate collage];
    }
}

- (void)moreApps
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(more_app)]) {
        [self.delegate more_app];
    }
}

- (void)updateApps
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(update_pro)]) {
        [self.delegate update_pro];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
