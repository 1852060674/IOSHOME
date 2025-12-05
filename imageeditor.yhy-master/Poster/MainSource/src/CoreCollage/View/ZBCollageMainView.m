//
//  ZBCollageMainView.m
//  Collage
//
//  Created by shen on 13-6-24.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBCollageMainView.h"
#import "ImageUtil.h"
#import "ZBShowSpecificTemplatesView.h"
#import "BHPhotoFrameView.h"
#import "BHAspectView.h"
#import "BHSmilingFaceView.h"
#import "ZBBackgroundImageView.h"
#import "BHSelectColorAndBackgroundImageView.h"
#import "ZBBottomBar.h"
#import "ZBJoinCollageBottomBar.h"
#import "ZBPosterCollageBottomBar.h"
#import "ZBPosterTableView.h"

#import "BHDragView.h"
#import "BHOneFingerRotationGestureRecognizer.h"
#import "BHCommenMethod.h"
#import "ZBBorderView.h"
#import <QuartzCore/QuartzCore.h>
#import "BHImageDataModeld.h"
#import "ZBFreeCollageBottomBar.h"
#import "ZBCommonMethod.h"
#import "ZBColorDefine.h"
#import "ZBAdjustFrameHeightForAd.h"
#import "ZBAppDelegate.h"
#import "AdUtility.h"
#import "GlobalSettingManger.h"
@import AppLovinSDK;

@interface ZBCollageMainView()<BHPresentTemplateViewDelegate,BHFreeCollageViewDelegate,ZBJoinCollageViewDelegte,ZBBottomBarDelegate,ZBJoinCollageBottomBarDelegate,ZBFreeCollageBottomBarDelegate,ZBPosterCollageBottomBarDelegate,ZBShowSpecificTemplatesViewDelegate,BHSmilingFaceViewDelegate,BHAspectViewDelegate,ZBBackgroundImageViewDelegate,UIGestureRecognizerDelegate,BHDragViewDelegate,ZBBorderViewDelegate,BHSelectColorAndBackgroundImageViewDelegate,UIScrollViewDelegate>
{
    NSInteger _lastSelectedIndex;
    
    
    NSUInteger _selectedImagesCount;
    
    ZBShowSpecificTemplatesView *_specificTemplateView;
    BHAspectView *_aspectView;
    BHSmilingFaceView *_smilingFaceView;
//    BHPhotoFrameView *_photoFrameView;
    ZBBackgroundImageView *_backgroundImageView;
    ZBPosterTableView *_posterTableView;
    float _aspectViewHeight;
    BHImageDataModeld *_dataModeld;
    UIButton *_hiddenOtherViewButton;
    float _joinViewHeight;
    
    UIButton *_lastButton;
    UIButton *_nextButton;
    
    UIButton *_showPosterButton;
    AdmobViewController *_adViewController;
}

@property (nonatomic, strong)ZBBottomBar *bottomBar;
@property (nonatomic, strong)ZBJoinCollageBottomBar *joincollageBottomBar;
@property (nonatomic, strong)ZBPosterCollageBottomBar *posterCollageBottomBar;
@property (nonatomic, strong)ZBFreeCollageBottomBar *freeBottomBar;
@property (nonatomic, strong)BHSelectColorAndBackgroundImageView *selectBGView;
@property (nonatomic, strong)ZBBorderView *colorAndBGImageView;
@property (nonatomic, strong)NSArray *selectedImagesArray;
@property (nonatomic, assign)NSUInteger currentTemplateIndex;
@property (nonatomic, assign)AspectType currentAspectType;

@property (nonatomic, strong) ZBShowSpecificTemplatesView *specificTemplateView;
@property (nonatomic, strong) BHAspectView *aspectView;
@property (nonatomic, strong) BHSmilingFaceView *smilingFaceView;
@property (nonatomic, strong) ZBBackgroundImageView *backgroundImageView;
@property (nonatomic, strong) ZBPosterTableView *posterTableView;

@property (nonatomic, weak) UIView *currentContentView;
- (void)initTemplateCollage;

- (void)initFreeCollage;

- (void)initJoinCollage;

- (void)initPosterCollage;

@end

@implementation ZBCollageMainView

@synthesize templateType = _templateType;
@synthesize delegate = _delegate;
@synthesize presentView = _presentView;
@synthesize freecollageView=_freecollageView;
@synthesize joinCollageView = _joinCollageView;
@synthesize posterCollageView=_posterCollageView;
@synthesize joinScrollView = _joinScrollView;
@synthesize bottomBar = _bottomBar;
@synthesize freeBottomBar;
@synthesize joincollageBottomBar;
@synthesize posterCollageBottomBar;
@synthesize colorAndBGImageView = _colorAndBGImageView;
@synthesize selectBGView = _selectBGView;
@synthesize selectedImagesArray = _selectedImagesArray;
@synthesize currentCollageType;
@synthesize currentTemplateIndex;
@synthesize currentAspectType;
@synthesize upgradeButton;

@synthesize specificTemplateView=_specificTemplateView;
-(ZBShowSpecificTemplatesView *)specificTemplateView
{
    return _specificTemplateView;
}

@synthesize aspectView=_aspectView;
-(BHAspectView *)aspectView
{
    return _aspectView;
}

@synthesize smilingFaceView=_smilingFaceView;
-(BHSmilingFaceView *)smilingFaceView
{
    return _smilingFaceView;
}

@synthesize backgroundImageView=_backgroundImageView;
-(ZBBackgroundImageView *)backgroundImageView
{
    return _backgroundImageView;
}

@synthesize posterTableView=_posterTableView;
-(ZBPosterTableView *)posterTableView
{
    return _posterTableView;
}

-(BHFreeCollageView *)freecollageView
{
    if (_freecollageView==nil) {
        _freecollageView = [[BHFreeCollageView alloc] initWithFrame:[AdUtility hasAd]?kFreecollageViewHeightWithAd:kFreecollageViewHeightNoAd withSelectedImages:self.selectedImagesArray];
        _freecollageView.hidden = YES;
        _freecollageView.delegate = self;
        [self addSubview:_freecollageView];
    }
    return _freecollageView;
}

-(UIScrollView *)joinScrollView
{
    if (_joinScrollView==nil) {
        _joinScrollView = [[UIScrollView alloc] initWithFrame:[AdUtility hasAd]?kFreecollageViewHeightWithAd:kJoinScrollViewHeightNoAd];
        _joinScrollView.delegate = self;
        _joinScrollView.backgroundColor = kTransparentColor;
        [self addSubview:_joinScrollView];
        [_joinScrollView addSubview:self.joinCollageView];
        _joinScrollView.hidden = YES;
    }
    return _joinScrollView;
}

-(ZBJoinCollageView *)joinCollageView
{
    if (_joinCollageView==nil) {
        _joinCollageView = [[ZBJoinCollageView alloc] initWithFrame:CGRectMake(0, 0, self.joinScrollView.frame.size.width, self.joinScrollView.frame.size.width) withSelectedImages:self.selectedImagesArray];
        _joinCollageView.delegate = self;
        [self.joinScrollView addSubview:_joinCollageView];
        
        _joinCollageView.frame = CGRectMake(0, 0, self.joinScrollView.frame.size.width, _joinViewHeight);
        _joinCollageView.photoFrameImageView.frame = CGRectMake(0, 0, self.joinScrollView.frame.size.width, _joinViewHeight);
        
    }
    return _joinCollageView;
}

-(ZBPosterCollageView *)posterCollageView
{
    if (_posterCollageView == nil) {
        _posterCollageView = [[ZBPosterCollageView alloc] initWithFrame:[AdUtility hasAd]?kPosterCollageViewHeightWithAd:kPosterCollageViewHeightNoAd andSelectedImages:self.selectedImagesArray];
        _posterCollageView.hidden = YES;
        [self addSubview:_posterCollageView];
    }
    return _posterCollageView;
}

- (void)dealloc
{
    self.bottomBar.delegate = nil;
    _aspectView.delegate = nil;
    _smilingFaceView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangeJoinHeight object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPosterChangeType object:nil];
}

#pragma mark - 单独选择一个拼图类型

- (id)initWithFrame:(CGRect)frame withSelectedImgesArray:(NSArray*)imagesArray andCollageType:(CollageType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        [UIApplication sharedApplication].statusBarHidden = YES;
        _selectedImagesCount = imagesArray.count;
        self.selectedImagesArray = imagesArray;
        self.currentCollageType = type; 
        [ZBCommonMethod setCurrentCollageType:type];   //设置当前拼图类型
        
        //设置背景图片
        UIImage *patternImage = [ImageUtil loadResourceImage:@"fram-bg"];
        UIImageView* iv = [[UIImageView alloc] initWithImage:patternImage];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.userInteractionEnabled = YES;
        iv.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:iv];
        [self sendSubviewToBack:iv];
        
        _hiddenOtherViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _hiddenOtherViewButton.backgroundColor = kTransparentColor;
        _hiddenOtherViewButton.frame = CGRectMake(0, 0, self.frame.size.width, kScreenHeight-kNavigationBarHeight);
        [_hiddenOtherViewButton addTarget:self action:@selector(hiddenActiveViwe) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_hiddenOtherViewButton];
        
        //监听拼接拼图高度变化信息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeJoinViewHeight:) name:kChangeJoinHeight object:nil];
        
        switch (type) {
            case CollageTypeGrid:
            {
                [self initTemplateCollage];
                self.currentContentView = _presentView;
            }
                break;
            case CollageTypeFree:
            {
                [self initFreeCollage];
                self.currentContentView = _freecollageView;
            }
                break;
            case CollageTypeJoin:
            {
                [self initJoinCollage];
                self.currentContentView = _joinScrollView;
            }
                break;
            case CollageTypePoster:
            {
                [self initPosterCollage];
                self.currentContentView = _posterCollageView;
            }
                break;
            default:
                break;
        }
        
        _lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _lastButton.frame = kLastButtonHgithNoAd;
        [_lastButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_last_down"] forState:UIControlStateNormal];
        [_lastButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_last_down"] forState:UIControlStateHighlighted];
        [_lastButton addTarget:self action:@selector(selectLastTemplate:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_lastButton];
        
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = kNextButtonHgithNoAd;
        [_nextButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_next_down"] forState:UIControlStateNormal];
        [_nextButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_next_down"] forState:UIControlStateHighlighted];
        [_nextButton addTarget:self action:@selector(selectNextTemplate:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_nextButton];
        
        if ((self.selectedImagesArray.count == 1 && self.currentCollageType != CollageTypePoster) || self.currentCollageType == CollageTypeJoin) {
            _lastButton.hidden = YES;
            _nextButton.hidden = YES;
        }
        else
        {
            _lastButton.hidden = NO;
            _nextButton.hidden = NO;
        }
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            _aspectViewHeight = 80;
        }
        else
        {
            _aspectViewHeight = 110;
        }
        
        // delete by jerry
        //[self performSelector:@selector(delayLoadViews) withObject:nil afterDelay:0.2];
    }
    
    // delete by jerry
    //[self adjustViewHeightForAd:YES];
    
    [self delayLoadViews];
    
    return self;
}

- (void)initTemplateCollage
{
    // Initialization code
    if ([ZBCommonMethod isShowRegularTemplateInFont]) {
        self.currentTemplateIndex = [ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)];
    }
    else
    {
        if (_selectedImagesCount ==6) {
            self.currentTemplateIndex = [ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)];
        }
        else
            self.currentTemplateIndex = [ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)]+[ZBCommonMethod getRegularTemplateCountWithImagesCount:MIN(_selectedImagesCount, 7)];
    }
    
    //显示模板图
    _presentView = [[BHPresentTemplateView alloc] initWithFrame:kPresentTemplateViewHeightNoAd withSelectedImages:self.selectedImagesArray];
    _presentView.delegate = self;
    [self addSubview:_presentView];
    [self selectedAspectType:aspect_3x4_icon];
    
    if (![ZBCommonMethod isShowRegularTemplateInFont] && (_selectedImagesCount!=1  && _selectedImagesCount != 6))
    {
        [_presentView showIrregularTemplate:self.currentTemplateIndex];
    }
    
    self.bottomBar = [[ZBBottomBar alloc] initWithFrame:kBottomBarHgithNoAd];
    self.bottomBar.delegate = self;
    [self addSubview:self.bottomBar];

}

- (void)initFreeCollage
{
    //自由拼图
    self.freecollageView = [[BHFreeCollageView alloc] initWithFrame:kFreecollageViewHeightNoAd withSelectedImages:self.selectedImagesArray];
    self.freecollageView.delegate = self;
    [self addSubview:self.freecollageView];
    
    self.freeBottomBar = [[ZBFreeCollageBottomBar alloc] initWithFrame:kFreeBottomBarHgithNoAd];
    self.freeBottomBar.delegate = self;
    [self addSubview:self.freeBottomBar];
}

- (void)initJoinCollage
{
    //拼接的scrollView
    self.joinScrollView = [[UIScrollView alloc] initWithFrame:kJoinScrollViewHeightNoAd];
    self.joinScrollView.delegate = self;
    self.joinScrollView.backgroundColor = kTransparentColor;
    [self addSubview:self.joinScrollView];
    
    //拼接
    self.joinCollageView = [[ZBJoinCollageView alloc] initWithFrame:CGRectMake(0, 0, self.joinScrollView.frame.size.width, self.joinScrollView.frame.size.width) withSelectedImages:self.selectedImagesArray];
    self.joinCollageView.delegate = self;
    [self.joinScrollView addSubview:self.joinCollageView];
    
    self.joinCollageView.frame = CGRectMake(0, 0, self.joinScrollView.frame.size.width, _joinViewHeight);
    self.joinCollageView.photoFrameImageView.frame = CGRectMake(0, 0, self.joinScrollView.frame.size.width, _joinViewHeight);
    
    self.joincollageBottomBar = [[ZBJoinCollageBottomBar alloc] initWithFrame:kJoincollageBottomBarHgithNoAd];
    self.joincollageBottomBar.delegate = self;
    [self addSubview:self.joincollageBottomBar];
}

- (void)initPosterCollage
{
    //海报拼图
    self.posterCollageView = [[ZBPosterCollageView alloc] initWithFrame:kPosterCollageViewHeightNoAd andSelectedImages:self.selectedImagesArray];
    [self addSubview:self.posterCollageView];
    
    float _posterTableHeight = 300;
    float _posterWidth = 194;
    float _posterX = (kScreenWidth-_posterWidth)/2;
    if (IS_IPAD) {
        _posterTableHeight = 500;
        _posterWidth = 469;
        _posterX = (kScreenWidth-_posterWidth)/2;
    }
    
    _posterTableView = [[ZBPosterTableView alloc] initWithFrame:kPosterTableViewHgithNoAd];
    [self addSubview:_posterTableView];
    _posterTableView.layer.cornerRadius = 5;
    
    _posterTableView.alpha = 1;
    _posterTableView.hidden = YES;
    
    self.posterCollageBottomBar = [[ZBPosterCollageBottomBar alloc] initWithFrame:kPosterCollageBottomBarHgithNoAd];
    self.posterCollageBottomBar.delegate = self;
    [self addSubview:self.posterCollageBottomBar];
}

- (void)initSpecificTemplateView
{
    _specificTemplateView = [[ZBShowSpecificTemplatesView alloc] initWithFrame:kSpecificTemplateViewHgithNoAd withSelectedImagesCount:_selectedImagesCount];
    _specificTemplateView.delegate = self;
    _specificTemplateView.hidden = YES;
    [self addSubview:_specificTemplateView];
}

- (void)initSmilingFaceView
{
    _smilingFaceView = [[BHSmilingFaceView alloc] initWithFrame:kSmilingFaceViewHgithNoAd];
    _smilingFaceView.hidden = YES;
    _smilingFaceView.delegate = self;
    [self addSubview:_smilingFaceView];
}

- (void)initAspectView
{
    _aspectView = [[BHAspectView alloc] initWithFrame:kAspectViewHgithNoAd];
    _aspectView.hidden = YES;
    _aspectView.delegate = self;
    [self addSubview:_aspectView];
}

- (void)initBackgroundImageView
{
    _backgroundImageView = [[ZBBackgroundImageView alloc] initWithFrame:kBackgroundImageViewHgithNoAd];
    _backgroundImageView.hidden = YES;
    _backgroundImageView.delegate = self;
    [self addSubview:_backgroundImageView];
}

- (void)initSelectBGView
{
    self.selectBGView = [[BHSelectColorAndBackgroundImageView alloc] initWithFrame:kSelectBGViewHgithNoAd];
    [self addSubview:self.selectBGView];
    self.selectBGView.delegate = self;
    self.selectBGView.layer.cornerRadius = 5;
    self.selectBGView.hidden = YES;
    
    
}

- (void)delayLoadViews
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeCollageType:)]) {
        [self.delegate changeCollageType:self.currentCollageType];
    }
    switch (self.currentCollageType) {
        case CollageTypeGrid:
        {
            [self initSpecificTemplateView];
            [self initSmilingFaceView];
            [self initAspectView];
        }
            break;
        case CollageTypeFree:
        {
            [self initSmilingFaceView];
            [self initBackgroundImageView];
            [self initSelectBGView];
        }
            break;
        case CollageTypeJoin:
        {
            [self initSelectBGView];
        }
            break;
        case CollageTypePoster:
        {
            
        }
            break;
        default:
            break;
    }
    _dataModeld = [[BHImageDataModeld alloc] init];
    [self adjustViewHeightForAd:YES];
    
    // added by jerry
    if ([ZBCommonMethod getCurrentCollageType]  == CollageTypeGrid) 
        [self selectedAspectType:aspect_3x4_icon];
}

#pragma mark - 选择所有类型

- (id)initWithFrame:(CGRect)frame withSelectedImgesArray:(NSArray*)imagesArray
{
    self = [super initWithFrame:frame];
    if (self) {
        [UIApplication sharedApplication].statusBarHidden = YES;
        _selectedImagesCount = imagesArray.count;
        self.selectedImagesArray = imagesArray;
        self.currentCollageType = CollageTypeGrid; //默认为网格拼图
        [ZBCommonMethod setCurrentCollageType:CollageTypeGrid];
        // Initialization code
        if ([ZBCommonMethod isShowRegularTemplateInFont]) {
            self.currentTemplateIndex = [ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)];
        }
        else
        {
            if (_selectedImagesCount ==6) {
                self.currentTemplateIndex = [ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)];
            }
            else
                self.currentTemplateIndex = [ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)]+[ZBCommonMethod getRegularTemplateCountWithImagesCount:MIN(_selectedImagesCount, 7)];
        }
        
        UIImage *patternImage = [ImageUtil loadResourceImage:@"fram-bg"];
        
        UIImageView* iv = [[UIImageView alloc] initWithImage:patternImage];
        iv.userInteractionEnabled = YES;
        iv.frame = CGRectMake(0, 0, kScreenWidth, self.frame.size.height);
        [self addSubview:iv];
        [self sendSubviewToBack:iv];
        
        
        _hiddenOtherViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _hiddenOtherViewButton.backgroundColor = kTransparentColor;
        _hiddenOtherViewButton.frame = CGRectMake(0, 0, self.frame.size.width, kScreenHeight-kNavigationBarHeight);
        [_hiddenOtherViewButton addTarget:self action:@selector(hiddenActiveViwe) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_hiddenOtherViewButton];
        
        //显示模板图
        _presentView = [[BHPresentTemplateView alloc] initWithFrame:kPresentTemplateViewHeightNoAd withSelectedImages:self.selectedImagesArray];
        _presentView.delegate = self;
        [self addSubview:_presentView];
        [self selectedAspectType:aspect_3x4_icon];
        
        if (![ZBCommonMethod isShowRegularTemplateInFont] && (imagesArray.count!=1  && imagesArray.count != 6))
        {
            [_presentView showIrregularTemplate:self.currentTemplateIndex];
        }
        self.currentContentView = _presentView;
        
        self.bottomBar = [[ZBBottomBar alloc] initWithFrame:CGRectMake(0, kScreenHeight-MAAdFormat.banner.adaptiveSize.height-kBottomBarHeight, kScreenWidth, kBottomBarHeight)];
        self.bottomBar.delegate = self;
        [self addSubview:self.bottomBar];
        
        self.freeBottomBar = [[ZBFreeCollageBottomBar alloc] initWithFrame:kFreeBottomBarHgithNoAd];
        self.freeBottomBar.delegate = self;
        self.freeBottomBar.hidden = YES;
        [self addSubview:self.freeBottomBar];
        
        self.joincollageBottomBar = [[ZBJoinCollageBottomBar alloc] initWithFrame:kJoincollageBottomBarHgithNoAd];
        self.joincollageBottomBar.delegate = self;
        self.joincollageBottomBar.hidden = YES;
        [self addSubview:self.joincollageBottomBar];
        
        self.posterCollageBottomBar = [[ZBPosterCollageBottomBar alloc] initWithFrame:kPosterCollageBottomBarHgithNoAd];
        self.posterCollageBottomBar.delegate = self;
        self.posterCollageBottomBar.hidden = YES;
        [self addSubview:self.posterCollageBottomBar];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            _aspectViewHeight = 80;
        }
        else
        {
            _aspectViewHeight = 110;
        }
        
        //监听拼接拼图高度变化信息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeJoinViewHeight:) name:kChangeJoinHeight object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePosterType:) name:kPosterChangeType object:nil];

        [self performSelector:@selector(delayLoadOtherView) withObject:nil afterDelay:0.2];
        

    }
    [self adjustViewHeightForAd:YES];
    return self;
}

//这个方法的作用在于提高页面之间的切换速度，把一些需要加载大量图片的工作放在页面打开了之后再做，提升用户的体验效果
//- (void)delayLoadOtherView
//{
//    //自由拼图
//    self.freecollageView = [[BHFreeCollageView alloc] initWithFrame:kFreecollageViewHeightNoAd withSelectedImages:self.selectedImagesArray];
//    self.freecollageView.hidden = YES;
//    self.freecollageView.delegate = self;
//    [self addSubview:self.freecollageView];
//    
//    _lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _lastButton.frame = kLastButtonHgithNoAd;
//    [_lastButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_last_nor"] forState:UIControlStateNormal];
//    [_lastButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_last_down"] forState:UIControlStateHighlighted];
//    [_lastButton addTarget:self action:@selector(selectLastTemplate:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_lastButton];
//    
//    _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _nextButton.frame = kNextButtonHgithNoAd;
//    [_nextButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_next_nor"] forState:UIControlStateNormal];
//    [_nextButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_next_down"] forState:UIControlStateHighlighted];
//    [_nextButton addTarget:self action:@selector(selectNextTemplate:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:_nextButton];
//    
//    if (self.selectedImagesArray.count == 1 && self.currentCollageType != CollageTypePoster) {
//        _lastButton.hidden = YES;
//        _nextButton.hidden = YES;
//    }
//    else
//    {
//        _lastButton.hidden = NO;
//        _nextButton.hidden = NO;
//    }
//    
//    //拼接的scrollView
//    self.joinScrollView = [[UIScrollView alloc] initWithFrame:kJoinScrollViewHeightNoAd];
//    self.joinScrollView.delegate = self;
//    self.joinScrollView.backgroundColor = kTransparentColor;
//    [self addSubview:self.joinScrollView];
//    self.joinScrollView.hidden = YES;
//    
//    //拼接
//    self.joinCollageView = [[ZBJoinCollageView alloc] initWithFrame:CGRectMake(0, 0, self.joinScrollView.frame.size.width, self.joinScrollView.frame.size.width) withSelectedImages:self.selectedImagesArray];
//    self.joinCollageView.delegate = self;
//    [self.joinScrollView addSubview:self.joinCollageView];
//    
//    self.joinCollageView.frame = CGRectMake(0, 0, self.joinScrollView.frame.size.width, _joinViewHeight);
//    self.joinCollageView.photoFrameImageView.frame = CGRectMake(0, 0, self.joinScrollView.frame.size.width, _joinViewHeight);
//    
//    //海报拼图
//    self.posterCollageView = [[ZBPosterCollageView alloc] initWithFrame:kPosterCollageViewHeightNoAd andSelectedImages:self.selectedImagesArray];
//    self.posterCollageView.hidden = YES;
//    [self addSubview:self.posterCollageView];
//    
//    float _posterTableHeight = 300;
//    float _posterWidth = 194;
//    float _posterX = (kScreenWidth-_posterWidth)/2;
//    if (IS_IPAD) {
//        _posterTableHeight = 500;
//        _posterWidth = 469;
//        _posterX = (kScreenWidth-_posterWidth)/2;
//    }
//    
//    // poster select
//    _posterTableView = [[ZBPosterTableView alloc] initWithFrame:kPosterTableViewHgithNoAd];
//    [self addSubview:_posterTableView];
//    _posterTableView.layer.cornerRadius = 5;
//    _posterTableView.alpha = 1;
//    _posterTableView.hidden = YES;
//    
//    // template select
//    _specificTemplateView = [[ZBShowSpecificTemplatesView alloc] initWithFrame:kSpecificTemplateViewHgithNoAd withSelectedImagesCount:_selectedImagesCount];
//    _specificTemplateView.delegate = self;
//    _specificTemplateView.hidden = YES;
//    [self addSubview:_specificTemplateView];
//    
//    //显示笑脸
//    _smilingFaceView = [[BHSmilingFaceView alloc] initWithFrame:kSmilingFaceViewHgithNoAd];
//    _smilingFaceView.hidden = YES;
//    _smilingFaceView.delegate = self;
//    [self addSubview:_smilingFaceView];
//    
//    // aspect select
//    _aspectView = [[BHAspectView alloc] initWithFrame:kAspectViewHgithNoAd];
//    _aspectView.hidden = YES;
//    _aspectView.delegate = self;
//    [self addSubview:_aspectView];
//    
//    // background image select
//    _backgroundImageView = [[ZBBackgroundImageView alloc] initWithFrame:kBackgroundImageViewHgithNoAd];
//    _backgroundImageView.hidden = YES;
//    _backgroundImageView.delegate = self;
//    [self addSubview:_backgroundImageView];
//    
//    // color select
//    self.selectBGView = [[BHSelectColorAndBackgroundImageView alloc] initWithFrame:kSelectBGViewHgithNoAd];
//    [self addSubview:self.selectBGView];
//    self.selectBGView.delegate = self;
//    self.selectBGView.layer.cornerRadius = 5;
//    self.selectBGView.hidden = YES;
//    
//    _dataModeld = [[BHImageDataModeld alloc] init];
//    [self adjustViewHeightForAd:YES];
//}


- (void)delayLoadOtherView
{
    _lastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _lastButton.frame = kLastButtonHgithNoAd;
    [_lastButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_last_nor"] forState:UIControlStateNormal];
    [_lastButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_last_down"] forState:UIControlStateHighlighted];
    [_lastButton addTarget:self action:@selector(selectLastTemplate:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_lastButton];
    
    _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextButton.frame = kNextButtonHgithNoAd;
    [_nextButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_next_nor"] forState:UIControlStateNormal];
    [_nextButton setImage:[ImageUtil loadResourceImage:@"btn_arrow_next_down"] forState:UIControlStateHighlighted];
    [_nextButton addTarget:self action:@selector(selectNextTemplate:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_nextButton];
    
    if (self.selectedImagesArray.count == 1 && self.currentCollageType != CollageTypePoster) {
        _lastButton.hidden = YES;
        _nextButton.hidden = YES;
    }
    else
    {
        _lastButton.hidden = NO;
        _nextButton.hidden = NO;
    }
    
    float _posterTableHeight = 300;
    float _posterWidth = 194;
    float _posterX = (kScreenWidth-_posterWidth)/2;
    if (IS_IPAD) {
        _posterTableHeight = 500;
        _posterWidth = 469;
        _posterX = (kScreenWidth-_posterWidth)/2;
    }
    
    // poster select
    _posterTableView = [[ZBPosterTableView alloc] initWithFrame:kPosterTableViewHgithNoAd];
    [self addSubview:_posterTableView];
    _posterTableView.layer.cornerRadius = 5;
    _posterTableView.alpha = 1;
    _posterTableView.hidden = YES;
    
    // template select
    _specificTemplateView = [[ZBShowSpecificTemplatesView alloc] initWithFrame:kSpecificTemplateViewHgithNoAd withSelectedImagesCount:_selectedImagesCount];
    _specificTemplateView.delegate = self;
    _specificTemplateView.hidden = YES;
    [self addSubview:_specificTemplateView];

    //显示笑脸
    _smilingFaceView = [[BHSmilingFaceView alloc] initWithFrame:kSmilingFaceViewHgithNoAd];
    _smilingFaceView.hidden = YES;
    _smilingFaceView.delegate = self;
    [self addSubview:_smilingFaceView];

    // aspect select
    _aspectView = [[BHAspectView alloc] initWithFrame:kAspectViewHgithNoAd];
    _aspectView.hidden = YES;
    _aspectView.delegate = self;
    [self addSubview:_aspectView];

    // background image select
    _backgroundImageView = [[ZBBackgroundImageView alloc] initWithFrame:kBackgroundImageViewHgithNoAd];
    _backgroundImageView.hidden = YES;
    _backgroundImageView.delegate = self;
    [self addSubview:_backgroundImageView];

    // color select
    float _x = 0;
    float _w = 0;
    float _h = 0;
    float _y = 0;
    if (IS_IPAD) {
        _x = 100;
        _w = kScreenWidth - 2*_x - 160;
        _h = 440;
        _y = kScreenHeight - _h - kNavigationBarHeight - kAdHeiht - 65;
    }
    else
    {
        _x = 50;
        _w = kScreenWidth - 2*_x - 20;
        _h = 235;
        _y = kScreenHeight - _h - kNavigationBarHeight - kAdHeiht - 45;
    }
    self.selectBGView = [[BHSelectColorAndBackgroundImageView alloc] initWithFrame:CGRectMake(2*_x, _y, _w, _h)];
    [self addSubview:self.selectBGView];
    self.selectBGView.delegate = self;
    self.selectBGView.layer.cornerRadius = 5;
    self.selectBGView.hidden = YES;

    _dataModeld = [[BHImageDataModeld alloc] init];
    [self adjustViewHeightForAd:YES];
    
    [self updateNextLastButton];
}

#pragma mark -- custom method

- (void)setSelectedImage:(UIImage*)selectedImage
{
    if (self.currentCollageType == CollageTypeGrid)
    {
        _presentView.selectedImage = selectedImage;
    }
    else if(self.currentCollageType == CollageTypeFree)
    {
        [self.freecollageView setCurrentSelectedImage:selectedImage];
    }
    else if(self.currentCollageType == CollageTypeJoin)
    {
        [self.joinCollageView setCurrentSelectedImage:selectedImage];
    }
    else if(self.currentCollageType == CollageTypePoster)
    {
        [self.posterCollageView setSelectedImage:selectedImage];
    }
}

- (void)addRotationGestureToView:(UIView *)view
{
    BHOneFingerRotationGestureRecognizer *rotation = [[BHOneFingerRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotating:)];
    [view addGestureRecognizer:rotation];
}

- (void)rotating:(BHOneFingerRotationGestureRecognizer*)recognizer
{
    UIView *view = [recognizer view];
    [view setTransform:CGAffineTransformRotate([view transform], [recognizer rotation])];
}

- (void)hiddenActiveViwe
{
    _specificTemplateView.hidden = YES;
    _smilingFaceView.hidden = YES;
    _aspectView.hidden = YES;
//    _photoFrameView.hidden = YES;
    self.colorAndBGImageView.hidden = YES;
    self.selectBGView.hidden = YES;
    _backgroundImageView.hidden = YES;
    _posterTableView.hidden = YES;
}

- (void)turnGridAndFreeCollageViewAnimation:(NSUInteger)selectedIndex
{
    //    [UIView animateWithDuration:0.5 delay:.5 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
    //        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:image cache:YES];
    //    } completion:^(BOOL finish){
    //        animationDurationLabel.text = @"动画结束";
    //    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeCollageType:)]) {
        [self.delegate changeCollageType:selectedIndex];
    }
    
    [ZBCommonMethod setCurrentCollageType:selectedIndex];
    self.currentCollageType = selectedIndex;
    
    
    _specificTemplateView.hidden = YES;
    _colorAndBGImageView.hidden = YES;
    self.selectBGView.hidden = YES;
    _smilingFaceView.hidden = YES;
    _aspectView.hidden = YES;
    _backgroundImageView.hidden = YES;
    _posterTableView.hidden = YES;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	UIView *whiteBackdrop = self;
    
    [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:whiteBackdrop cache:YES];
    
    if (selectedIndex==CollageTypeGrid)
    {
        float _segmentItemWidth;
        float _segmentWidth;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            _segmentItemWidth = 75;
            _segmentWidth = kBottomBarWidth;
        }
        else
        {
            _segmentItemWidth = 100;
            _segmentWidth = 400;
        }
        
        if (self.selectedImagesArray.count == 1) {
            _lastButton.hidden = YES;
            _nextButton.hidden = YES;
        }
        else
        {
            _lastButton.hidden = NO;
            _nextButton.hidden = NO;
        }
//        
//        _presentView.hidden = NO;
//        self.freecollageView.hidden = YES;
//        self.joinScrollView.hidden = YES;
//        self.posterCollageView.hidden = YES;
//        
        self.currentContentView.hidden = YES;
        _presentView.hidden = NO;
        self.currentContentView = _presentView;

        self.bottomBar.hidden = NO;
        [self.bottomBar.superview bringSubviewToFront:self.bottomBar];
        self.freeBottomBar.hidden = YES;
        self.joincollageBottomBar.hidden = YES;
        
        [_specificTemplateView.superview bringSubviewToFront:_specificTemplateView];
        [_smilingFaceView.superview bringSubviewToFront:_smilingFaceView];
        [_aspectView.superview bringSubviewToFront:_aspectView];
        [_colorAndBGImageView.superview bringSubviewToFront:_colorAndBGImageView];
        
        _smilingFaceView.promptFrame.arrowPoint = CGPointMake((kScreenWidth-_segmentWidth)/2+1.5*_segmentItemWidth, _smilingFaceView.promptFrame.frame.size.height);
        self.posterCollageBottomBar.hidden = YES;
    }
    else if(selectedIndex == CollageTypeFree)
    {
        float _segmentItemWidth;
        float _segmentWidth;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            _segmentItemWidth = 75;
            _segmentWidth = 150;
        }
        else
        {
            _segmentItemWidth = 100;
            _segmentWidth = 200;
        }
        
        if (self.selectedImagesArray.count == 1 || self.selectedImagesArray.count>7) {
            _lastButton.hidden = YES;
            _nextButton.hidden = YES;
        }
        else
        {
            _lastButton.hidden = NO;
            _nextButton.hidden = NO;
        }

//        _presentView.hidden = YES;
//        self.posterCollageView.hidden = YES;
//        self.freecollageView.hidden = NO;
//        self.joinScrollView.hidden = YES;
//        
        self.currentContentView.hidden = YES;
        self.freecollageView.hidden = NO;
        self.currentContentView = self.freecollageView;

        self.bottomBar.hidden = YES;
        self.freeBottomBar.hidden = NO;
        [self.freeBottomBar.superview bringSubviewToFront:self.freeBottomBar];
        self.joincollageBottomBar.hidden = YES;
        self.posterCollageBottomBar.hidden = YES;

        [_smilingFaceView.superview bringSubviewToFront:_smilingFaceView];
        [_backgroundImageView.superview bringSubviewToFront:_backgroundImageView];
        [_selectBGView.superview bringSubviewToFront:_selectBGView];

        _smilingFaceView.promptFrame.arrowPoint = CGPointMake((kScreenWidth-_segmentWidth)/2+0.5*_segmentItemWidth, _smilingFaceView.promptFrame.frame.size.height);
    }
    else if(selectedIndex == CollageTypeJoin)
    {
//        _presentView.hidden = YES;
//        self.freecollageView.hidden = YES;
//        self.joinScrollView.hidden = NO;
//        self.posterCollageView.hidden = YES;
//        
        self.currentContentView.hidden = YES;
        self.joinScrollView.hidden = NO;
        self.currentContentView = self.joinScrollView;

        _lastButton.hidden = YES;
        _nextButton.hidden = YES;
        self.bottomBar.hidden = YES;
        self.freeBottomBar.hidden = YES;
        self.joincollageBottomBar.hidden = NO;
        [self.joincollageBottomBar.superview bringSubviewToFront:self.joincollageBottomBar];
        self.posterCollageBottomBar.hidden = YES;
        
        [_selectBGView.superview bringSubviewToFront:_selectBGView];
    }
    else if(selectedIndex == CollageTypePoster)
    {
//        _presentView.hidden = YES;
//        self.joinScrollView.hidden = YES;
//        self.freecollageView.hidden = YES;
//        self.posterCollageView.hidden = NO;

        self.currentContentView.hidden = YES;
        self.posterCollageView.hidden = NO;
        self.currentContentView = self.posterCollageView;
        
        _lastButton.hidden = NO;
        _nextButton.hidden = NO;
        self.bottomBar.hidden = YES;
        self.freeBottomBar.hidden = YES;
        self.joincollageBottomBar.hidden = YES;
        self.posterCollageBottomBar.hidden = NO;
        [self.posterCollageBottomBar.superview bringSubviewToFront:self.posterCollageBottomBar];
        
        [_posterTableView.superview bringSubviewToFront:_posterTableView];
    }
    
    [self updateNextLastButton];
    
    //	NSInteger purple = [[whiteBackdrop subviews] indexOfObject:_presentView];
    //	NSInteger maroon = [[whiteBackdrop subviews] indexOfObject:_freecollageView];
    //	[whiteBackdrop exchangeSubviewAtIndex:purple withSubviewAtIndex:maroon];
    
	[UIView setAnimationDelegate:self];
    //	[UIView setAnimationDidStopSelector:@selector(animationFinished:)];
	[UIView commitAnimations];
    
}

- (void)changeJoinViewHeight:(NSNotification*)notification
{
    NSDictionary *_infoDic = [notification object];//获取到传递的对象
    float joinViewHeight = [[_infoDic valueForKey:@"JoinHeight"] floatValue];
    

    _joinViewHeight = joinViewHeight;

    self.joinScrollView.contentSize = CGSizeMake(self.joinScrollView.frame.size.width, _joinViewHeight);
    
    if (_joinCollageView==nil) {
        return;
    }
    
    self.joinCollageView.frame = CGRectMake(0, 0, self.joinScrollView.frame.size.width, _joinViewHeight);
    self.joinCollageView.photoFrameImageView.frame = CGRectMake(0, 0, self.joinScrollView.frame.size.width, _joinViewHeight);
}

- (void)changePosterType:(NSNotification*)notification
{
    [self performSelector:@selector(updateNextLastButton) withObject:self afterDelay:0.5];
}

- (void)selectLastTemplate:(id)sender
{
//    NSLog(@"l %d",self.currentTemplateIndex);
    if (self.currentCollageType == CollageTypeGrid) //模板拼图
    {
        
        if ([ZBCommonMethod isShowRegularTemplateInFont])
        {
            if (self.currentTemplateIndex<=[ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)])
            {
                return;
            }
            self.currentTemplateIndex--;
            if ([ZBCommonMethod isRegularCollage:self.currentTemplateIndex]) {
                if (self.selectedImagesArray.count<=2) {
                    [_presentView adjustTemplate:self.currentTemplateIndex];
                }
                else
                {
                    NSUInteger _index = [ZBCommonMethod getRegularTemplateIndex:self.currentTemplateIndex];
                    [_presentView adjustTemplate:_index];
                }
            }
            else
            {
                [_presentView showIrregularTemplate:self.currentTemplateIndex];
            }
        }
        else
        {
            //不规则拼图在前
            if (self.currentTemplateIndex==[ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)]+[ZBCommonMethod getRegularTemplateCountWithImagesCount:MIN(_selectedImagesCount, 7)] || (self.currentTemplateIndex == [ZBCommonMethod getTemplateIndex:7]+kTemplateSevenCount))
            {
                return;
            }
            if (self.currentTemplateIndex==[ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)]) {
                if (MIN(_selectedImagesCount, 7)==7) {
                    self.currentTemplateIndex= [ZBCommonMethod getTemplateIndex:7]+kTemplateSevenCount;
                }
                else
                    self.currentTemplateIndex= [ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 6)+1];
            }
            self.currentTemplateIndex--;
            
            if ([ZBCommonMethod isRegularCollage:self.currentTemplateIndex]) {
                
                if (self.selectedImagesArray.count<=2) {
                    [_presentView adjustTemplate:self.currentTemplateIndex];
                }
                else
                {
                    NSUInteger _index = [ZBCommonMethod getRegularTemplateIndex:self.currentTemplateIndex];
                    [_presentView adjustTemplate:_index];
                }
            }
            else
            {
                [_presentView showIrregularTemplate:self.currentTemplateIndex];
            }
        }
        
    }
    else if(self.currentCollageType == CollageTypeFree)  //自由拼图
    {
        [self.freecollageView adjustTemplateType:self.selectedImagesArray.count  withFreeCollageChangeType:FreeCollageChangeTypeLast];
    }
    else if(self.currentCollageType == CollageTypePoster)
    {
        [self.posterCollageView changeBackgroundImageWithPosterCollageChangeType:PosterCollageChangeTypeLast];
    }
    [self updateNextLastButton];
}

- (void)selectNextTemplate:(id)sender
{
//    NSLog(@"N %d",self.currentTemplateIndex);
    if (self.currentCollageType == CollageTypeGrid)
    {
        if ([ZBCommonMethod isShowRegularTemplateInFont])
        {
            if (self.currentTemplateIndex>=[ZBCommonMethod getTemplateIndex:_selectedImagesCount+1]-1 || self.currentTemplateIndex>=104) {
                return;
            }
            self.currentTemplateIndex++;
            
            if ([ZBCommonMethod isRegularCollage:self.currentTemplateIndex]) {
                if (self.selectedImagesArray.count<=2) {
                    [_presentView adjustTemplate:self.currentTemplateIndex];
                }
                else
                {
                    NSUInteger _index = [ZBCommonMethod getRegularTemplateIndex:self.currentTemplateIndex];
                    [_presentView adjustTemplate:_index];
                }
            }
            else
            {
                [_presentView showIrregularTemplate:self.currentTemplateIndex];
            }
        }
        else
        {
            if (self.currentTemplateIndex==[ZBCommonMethod getTemplateIndex:_selectedImagesCount+1]-1 || self.currentTemplateIndex>=104) {
                self.currentTemplateIndex= [ZBCommonMethod getTemplateIndex:_selectedImagesCount]-1;
            }
            if (self.currentTemplateIndex == [ZBCommonMethod getTemplateIndex:_selectedImagesCount]+[ZBCommonMethod getRegularTemplateCountWithImagesCount:_selectedImagesCount]-1) {
                return;
            }
            self.currentTemplateIndex++;
            
            if ([ZBCommonMethod isRegularCollage:self.currentTemplateIndex]) {
                if (self.selectedImagesArray.count<=2) {
                    [_presentView adjustTemplate:self.currentTemplateIndex];
                }
                else
                {
                    NSUInteger _index = [ZBCommonMethod getRegularTemplateIndex:self.currentTemplateIndex];
                    [_presentView adjustTemplate:_index];
                }
            }
            else
            {
                [_presentView showIrregularTemplate:self.currentTemplateIndex];
            }
        }
        
        
    }
    else if(self.currentCollageType == CollageTypeFree)
    {
        [self.freecollageView adjustTemplateType:self.selectedImagesArray.count withFreeCollageChangeType:FreeCollageChangeTypeNext];
    }
    else if(self.currentCollageType == CollageTypePoster)
    {
        [self.posterCollageView changeBackgroundImageWithPosterCollageChangeType:PosterCollageChangeTypeNext];
    }
    
    [self updateNextLastButton];
}

-(void)updateNextLastButton
{
    BOOL showNextButton = YES;
    BOOL showLastButton = YES;
    if (self.currentCollageType == CollageTypeGrid)
    {
        if ([ZBCommonMethod isShowRegularTemplateInFont])
        {
            if (self.currentTemplateIndex>=[ZBCommonMethod getTemplateIndex:_selectedImagesCount+1]-1 || self.currentTemplateIndex>=104)
            {
                showNextButton = NO;
            }
        }
        else
        {
            if (self.currentTemplateIndex == [ZBCommonMethod getTemplateIndex:_selectedImagesCount]+[ZBCommonMethod getRegularTemplateCountWithImagesCount:_selectedImagesCount]-1) {
                showNextButton = NO;
            }
        }
        
        if ([ZBCommonMethod isShowRegularTemplateInFont])
        {
            if (self.currentTemplateIndex<=[ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)])
            {
                showLastButton = NO;
            }
        }
        else
        {
            //不规则拼图在前
            if (self.currentTemplateIndex==[ZBCommonMethod getTemplateIndex:MIN(_selectedImagesCount, 7)]+[ZBCommonMethod getRegularTemplateCountWithImagesCount:MIN(_selectedImagesCount, 7)] || (self.currentTemplateIndex == [ZBCommonMethod getTemplateIndex:7]+kTemplateSevenCount))
            {
                showLastButton = NO;
            }
        }
        
    }
    else if (self.currentCollageType == CollageTypeFree)
    {
        showLastButton = [self.freecollageView canAdjustTemplateType:self.selectedImagesArray.count withFreeCollageChangeType:FreeCollageChangeTypeLast];
        showNextButton = [self.freecollageView canAdjustTemplateType:self.selectedImagesArray.count withFreeCollageChangeType:FreeCollageChangeTypeNext];
    }
    else if(self.currentCollageType == CollageTypePoster)
    {
        showLastButton = [self.posterCollageView canChangeBackgroundImageWithPosterCollageChangeType:PosterCollageChangeTypeLast];
        showNextButton = [self.posterCollageView canChangeBackgroundImageWithPosterCollageChangeType:PosterCollageChangeTypeNext];
    }
    else
    {
        showNextButton = NO;
        showLastButton = NO;
    }
    _nextButton.hidden = !showNextButton;
    _lastButton.hidden = !showLastButton;
}

- (void)adjustViewHeightForAd:(BOOL)flag
{
    [self selectedAspectType:self.currentAspectType];
    if (flag)
    {
        [UIApplication sharedApplication].statusBarHidden = YES;
        switch ([ZBCommonMethod showAllCollageType]) {
            case CollageTypeGrid:
            {
                self.bottomBar.frame = kBottomBarHgithWithAd;
                _specificTemplateView.frame = kSpecificTemplateViewHgithWithAd;
                self.presentView.frame = kPresentTemplateViewHeightWithAd;
                _smilingFaceView.frame = kSmilingFaceViewHgithWithAd;
                _aspectView.frame = kAspectViewHgithWithAd;
                _lastButton.frame = kLastButtonHgithWithAd;
                _nextButton.frame = kNextButtonHgithWithAd;
            }
                break;
            case CollageTypeFree:
            {
                self.freeBottomBar.frame = kFreeBottomBarHgithWithAd;
                self.freecollageView.frame = kFreecollageViewHeightWithAd;
                [self.freecollageView setNeedsDisplay];
                _smilingFaceView.frame = kSmilingFaceViewHgithWithAd;
                _backgroundImageView.frame = kBackgroundImageViewHgithWithAd;
                _lastButton.frame = kLastButtonHgithWithAd;
                _nextButton.frame = kNextButtonHgithWithAd;
            }
                break;
            case CollageTypeJoin:
            {
                self.joincollageBottomBar.frame = kJoincollageBottomBarHgithWithAd;
                self.joinScrollView.frame = kJoinScrollViewHeightWithAd;
            }
                break;
            case CollageTypePoster:
            {
                self.posterCollageBottomBar.frame = kPosterCollageBottomBarHgithWithAd;
                self.posterCollageView.frame = kPosterCollageViewHeightWithAd;
                [self.posterCollageView setNeedsDisplay];
                _posterTableView.frame = kPosterCollageBottomBarHgithWithAd;
                _lastButton.frame = kLastButtonHgithWithAd;
                _nextButton.frame = kNextButtonHgithWithAd;
            }
            case ShowCollageTypeAll:
            {
                self.bottomBar.frame = kBottomBarHgithWithAd;
                self.freeBottomBar.frame = kFreeBottomBarHgithWithAd;
                self.joincollageBottomBar.frame = kJoincollageBottomBarHgithWithAd;
                self.posterCollageBottomBar.frame = kPosterCollageBottomBarHgithWithAd;
                
                //        self.presentView.frame = kPresentTemplateViewHeightWithAd;
//                self.freecollageView.frame = kFreecollageViewHeightWithAd;
//                [self.freecollageView setNeedsDisplay];
//                self.posterCollageView.frame = kPosterCollageViewHeightWithAd;
//                [self.posterCollageView setNeedsDisplay];
//                self.joinScrollView.frame = kJoinScrollViewHeightWithAd;
//                
                _specificTemplateView.frame = kSpecificTemplateViewHgithWithAd;
                //        _colorAndBGImageView.frame = CGRectMake(_colorAndBGImageView.frame.origin.x, _colorAndBGImageView.frame.origin.y-50, _colorAndBGImageView.frame.size.width, _colorAndBGImageView.frame.size.height);
                //        self.selectBGView.frame = kSpecificTemplateViewHgithWithAd;
                _smilingFaceView.frame = kSmilingFaceViewHgithWithAd;
                _aspectView.frame = kAspectViewHgithWithAd;
                _backgroundImageView.frame = kBackgroundImageViewHgithWithAd;
                _posterTableView.frame = kPosterCollageBottomBarHgithWithAd;
                _lastButton.frame = kLastButtonHgithWithAd;
                _nextButton.frame = kNextButtonHgithWithAd;
            }
                break;
            default:
                break;
        }
    }
    else
    {
        switch ([ZBCommonMethod showAllCollageType]) {
            case CollageTypeGrid:
            {
                self.bottomBar.frame = kBottomBarHgithNoAd;
                _specificTemplateView.frame = kSpecificTemplateViewHgithNoAd;
                self.presentView.frame = kPresentTemplateViewHeightNoAd;
                _smilingFaceView.frame = kSmilingFaceViewHgithNoAd;
                _aspectView.frame = kAspectViewHgithNoAd;
                _lastButton.frame = kLastButtonHgithNoAd;
                _nextButton.frame = kNextButtonHgithNoAd;
            }
                break;
            case CollageTypeFree:
            {
                self.freeBottomBar.frame = kFreeBottomBarHgithNoAd;
                self.freecollageView.frame = kFreecollageViewHeightNoAd;
                [self.freecollageView setNeedsDisplay];
                _smilingFaceView.frame = kSmilingFaceViewHgithNoAd;
                _backgroundImageView.frame = kBackgroundImageViewHgithNoAd;
                _lastButton.frame = kLastButtonHgithNoAd;
                _nextButton.frame = kNextButtonHgithNoAd;
            }
                break;
            case CollageTypeJoin:
            {
                self.joincollageBottomBar.frame = kJoincollageBottomBarHgithNoAd;
                self.joinScrollView.frame = kJoinScrollViewHeightNoAd;
            }
                break;
            case CollageTypePoster:
            {
                self.posterCollageBottomBar.frame = kPosterCollageBottomBarHgithNoAd;
                self.posterCollageView.frame = kPosterCollageViewHeightNoAd;
                [self.posterCollageView setNeedsDisplay];
                _posterTableView.frame = kPosterCollageBottomBarHgithNoAd;
                _lastButton.frame = kLastButtonHgithNoAd;
                _nextButton.frame = kNextButtonHgithNoAd;
            }
            case ShowCollageTypeAll:
            {
                self.bottomBar.frame = kBottomBarHgithNoAd;
                self.freeBottomBar.frame = kFreeBottomBarHgithNoAd;
                self.joincollageBottomBar.frame = kJoincollageBottomBarHgithNoAd;
                self.posterCollageBottomBar.frame = kPosterCollageBottomBarHgithNoAd;
                
                //        self.presentView.frame = kPresentTemplateViewHeightWithAd;
                self.freecollageView.frame = kFreecollageViewHeightNoAd;
                self.posterCollageView.frame = kPosterCollageViewHeightNoAd;
                self.joinScrollView.frame = kJoinScrollViewHeightNoAd;
                
                _specificTemplateView.frame = kSpecificTemplateViewHgithNoAd;
                //        _colorAndBGImageView.frame = kColorAndBGImageViewHgithNoAd;
                //        self.selectBGView.frame = kSelectBGViewHgithNoAd;
                _smilingFaceView.frame = kSmilingFaceViewHgithNoAd;
                _aspectView.frame = kAspectViewHgithNoAd;
                _backgroundImageView.frame = kBackgroundImageViewHgithNoAd;
                _posterTableView.frame = kPosterTableViewHgithNoAd;
                _lastButton.frame = kLastButtonHgithNoAd;
                _nextButton.frame = kNextButtonHgithNoAd;
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark -- BHPhotoFrameViewDelegate

- (void)selectedAPhotoFrame:(NSString*)photoFrameImage
{
    if (nil == photoFrameImage) {
        return;
    }
    
    if (self.currentCollageType == CollageTypeGrid)
    {
        if ([photoFrameImage isEqualToString:@"fme1"] || [photoFrameImage isEqualToString:@"fme001.png"]) {
            self.presentView.photoFrame.image = nil;
            return;
        }
        
        self.presentView.photoFrame.image = [ImageUtil loadResourceImage:photoFrameImage];
    }
    else if(self.currentCollageType == CollageTypeJoin)
    {
        if ([photoFrameImage isEqualToString:@"fme1"] || [photoFrameImage isEqualToString:@"fme001.png"]) {
            self.joinCollageView.photoFrameImageView.image = nil;
            return;
        }
        
        self.joinCollageView.photoFrameImageView.image = [ImageUtil loadResourceImage:photoFrameImage];
    }
    
    [self updateNextLastButton];
}

#pragma mark -- ZBBottomBarDelegate

- (void)showSpecificTemplateView:(BOOL)isShow
{
    if (!isShow) {
        _specificTemplateView.hidden = !isShow;
    }
    else
        _specificTemplateView.hidden = !_specificTemplateView.hidden;
}

- (void)showSmilingFaceView:(BOOL)isShow
{
    if (!isShow) {
        _smilingFaceView.hidden = !isShow;
    }
    else
        _smilingFaceView.hidden = !_smilingFaceView.hidden;
}

- (void)showAspectView:(BOOL)isShow
{
    if (!isShow) {
        _aspectView.hidden = !isShow;
    }
    else
        _aspectView.hidden = !_aspectView.hidden;
}

//- (void)showPhotoFrameView:(BOOL)isShow
//{    
//    if (!isShow) {
//        _photoFrameView.hidden = !isShow;
//    }
//    else
//        _photoFrameView.hidden = !_photoFrameView.hidden;
//}

- (void)hiddenAllDeleteSmilingFaceIcon
{
    for (UIView *_aView in [self.presentView subviews])
    {
        if ([_aView isKindOfClass:[BHDragView class]]) {
            [((BHDragView*)_aView) hiddenDeleteButtonIcon:YES];
        }
    }
}

- (void)showBorderAndColorView:(BOOL)isShow
{
    if (self.currentCollageType == CollageTypeGrid) {
        float _x = 0;
        float _w = 0;
        float _h = 0;
        float _y = 0;
        if (IS_IPAD) {
            _x = 100;
            _w = kScreenWidth - 2*_x - 160;
            _h = 440;
           _y = kScreenHeight - _h - kNavigationBarHeight - kAdHeiht - 65;
        }
        else
        {
            _x = 50;
            _w = kScreenWidth - 2*_x - 20;
            _h = 235;
            _y = kScreenHeight - _h - kNavigationBarHeight - kAdHeiht - 45;
        }

        if (self.colorAndBGImageView == nil) {
            self.colorAndBGImageView = [[ZBBorderView alloc] initWithFrame:CGRectMake(2*_x, _y, _w, _h)];
            [self addSubview:self.colorAndBGImageView];
            self.colorAndBGImageView.delegate = self;
            self.colorAndBGImageView.layer.cornerRadius = 5;
            self.colorAndBGImageView.hidden = YES;
        }
        if (!isShow) {
            self.colorAndBGImageView.hidden = !isShow;
        }
        else
            self.colorAndBGImageView.hidden = !self.colorAndBGImageView.hidden;
    }
    else
    {
        if (!isShow) {
            self.selectBGView.hidden = !isShow;
        }
        else
            self.selectBGView.hidden = !self.selectBGView.hidden;
    }
    
}

- (void)showBackGroundImageView:(BOOL)isShow
{
    if (!isShow) {
        _backgroundImageView.hidden = !isShow;
    }
    else
        _backgroundImageView.hidden = !_backgroundImageView.hidden;
}

#pragma mark -- ZBPosterCollageBottomBarDelegate
- (void)showSelectPosterView:(BOOL)isShow
{    
    float _adHeight = 0;
    if ([ZBCommonMethod getIsShowAdValue]) {
        _adHeight = kAdHeiht;
    }
    float _posterTableHeight = 300;
    float _posterWidth = 194;
    float _x = (kScreenWidth-_posterWidth)/2;
    if (IS_IPAD) {
        _posterTableHeight = 500;
        _posterWidth = 469;
        _x = (kScreenWidth-_posterWidth)/2;
    }
    
    if (_posterTableView.hidden)
    {
        _posterTableView.frame = CGRectMake(_x, kScreenHeight-kNavigationBarHeight, _posterWidth, _posterTableHeight);
        _posterTableView.hidden = !_posterTableView.hidden;
        //开始动画
        [UIView beginAnimations:nil context:nil];
        //设定动画持续时间
        [UIView setAnimationDuration:1];
        //动画的内容
        _posterTableView.frame = CGRectMake(_x, kScreenHeight-kNavigationBarHeight-_posterTableHeight-50-_adHeight, _posterWidth, _posterTableHeight);
        //动画结束
        [UIView commitAnimations];
    }
    else
    {
        //开始动画
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationFinish:)];
        //设定动画持续时间
        [UIView setAnimationDuration:1];
        //动画的内容
        _posterTableView.frame = CGRectMake(_x, kScreenHeight-kNavigationBarHeight, _posterWidth, _posterTableHeight);
        //动画结束
        [UIView commitAnimations];
    }    
}

- (void)animationFinish:(id)sender
{
    _posterTableView.hidden = !_posterTableView.hidden;
}

#pragma mark -- BHPresentTemplateViewDelegate
- (void)openAlbum:(NSUInteger)sourceType withRect:(CGRect)rect
{
    [self hiddenActiveViwe];
    if (self.delegate && [self.delegate respondsToSelector:@selector(openAlbumAnLibrary:withRect:)]) {
        [self.delegate openAlbumAnLibrary:sourceType withRect:rect];
    }
}

- (void)editCurrentSelectedImage:(UIImage *)image
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editImage:)]) {
        [self.delegate editImage:image];
    }
}

- (BOOL)canChangeBackground:(NSInteger) index {
    if(self.delegate && [self.delegate respondsToSelector:@selector(canChangeBackground:)]) {
        return [self.delegate canChangeBackground:index];
    }
    return TRUE;
}

#pragma mark -- ZBShowSpecificTemplatesViewDelegate
- (void)selectedATemplate:(NSUInteger)templateIndex
{
    if(self.delegate
       && [self.delegate respondsToSelector:@selector(canChangeTemplate:)]
       && ![self.delegate canChangeTemplate:templateIndex]) {
        return;
    }

    if (_lastSelectedIndex==28 && templateIndex==10) {
        NSException *e = [NSException
                          exceptionWithName: @"Invalid layout parament!"
                          reason: @"Template"
                          userInfo: nil];
        @throw e;
    }
    
    _lastSelectedIndex = templateIndex;
    
    self.currentTemplateIndex = templateIndex;
    if ([ZBCommonMethod isRegularCollage:templateIndex]) {
        if (self.selectedImagesArray.count<=2) {
            [_presentView adjustTemplate:templateIndex];
        }
        else
        {
            NSUInteger _index = [ZBCommonMethod getRegularTemplateIndex:templateIndex];
            NSLog(@"%d,%d",templateIndex,_index);
            [_presentView adjustTemplate:_index];
        }
    }
    else
    {
        [_presentView showIrregularTemplate:templateIndex];
    }
    
    for (UIView *aView in _presentView.subviews)
    {
        if ([aView isKindOfClass:[BHDragView class]]) {
            [_presentView bringSubviewToFront:aView];
        }
    }
    
    [self updateNextLastButton];
}

#pragma mark -- BHSmilingFaceViewDelegate
-(BOOL) canAddSmilingFace:(NSInteger)index {
    if(self.delegate && [self.delegate respondsToSelector:@selector(canAddSticker:)]) {
        return [self.delegate canAddSticker:index];
    }
    return TRUE;
}

- (void)selectedSmilingFaceType:(UIImage*)smilingFaceImage atIndex:(NSInteger)index
{
    //    [self.delegate test];
    //在 _presentView 中心位置添加所选择的笑脸
    BHDragView *_dragView;
    NSUInteger _dragViewTag = [BHCommenMethod getAUniqueTag]+kDragViewStartTag;
    _dragView = [[BHDragView alloc]initWithFrame:CGRectMake(abs(_presentView.center.x-smilingFaceImage.size.width/2),abs(_presentView.center.y-smilingFaceImage.size.height/2), smilingFaceImage.size.width, smilingFaceImage.size.height) withImage:smilingFaceImage andTag:_dragViewTag];
    _dragView.delegate = self;
    _dragView.tag = _dragViewTag;
    //    NSLog(@"%@",_dragView);
    if (self.currentCollageType == CollageTypeGrid) {
        _dragView.center = CGPointMake(CGRectGetMidX(_presentView.bounds), CGRectGetMidY(_presentView.bounds));
        [_presentView addSubview:_dragView];
    }
    else if(self.currentCollageType == CollageTypeFree)
    {
        [self.freecollageView addSubview:_dragView];
    }
    
    
    //    [self.presentView.dragViewArray addObject:_dragView];
    
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)] ;
    [rotationRecognizer setDelegate:self];
    [_dragView addGestureRecognizer:rotationRecognizer];
    
    //    //拖动
    //    UIPanGestureRecognizer *_panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handelPan:)];
    //    [_panGes setDelegate:self];
    //    [_dragView addGestureRecognizer:_panGes];
}

#pragma mark -- BHAspectViewDelegate
- (void)selectedAspectType:(AspectType)type
{
    float y = 0;
    float _adHeight=0;
    if ([ZBCommonMethod getIsShowAdValue])
    {
        _adHeight = kAdHeiht;
    }
    self.currentAspectType = type;
    switch (type) {
        case aspect_1x1_icon:
        {
            y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - kTemplateEdge-_adHeight)/2;
            [_presentView adjustFrameSize:kTemplateEdge withHeight:kTemplateEdge];
            _presentView.frame = CGRectMake(kTemplateGap, y, kTemplateEdge, kTemplateEdge);
        }
            break;
        case aspect_2x3_icon:
        {
            
            float w = kTemplateEdge;
            float h = 0;
            if ([ZBCommonMethod getIsShowAdValue]) {
                w -= 25;
            }
            if (w*1.5<=(kScreenHeight - kNavigationBarHeight -kBottomBarHeight-_adHeight))
            {
                h = 1.5*w;
            }
            else
            {
                y = 10;
                h = kScreenHeight - kNavigationBarHeight -kBottomBarHeight-_adHeight;
                w = h/1.5;
            }
            y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
            [_presentView adjustFrameSize:w withHeight:h];
            _presentView.frame = CGRectMake((kScreenWidth-w)/2, y, w, h);
        }
            break;
        case aspect_3x2_icon:
        {
            float w = kTemplateEdge;
            float h = kTemplateEdge*2/3;
            y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
            [_presentView adjustFrameSize:w withHeight:h];
            _presentView.frame = CGRectMake(kTemplateGap, y, w, h);
        }
            break;
        case aspect_3x4_icon:
        {
            float x = kTemplateGap;
            float w = kTemplateEdge;
            float h = w*4/3;
            float _maxHeight = kScreenHeight - kNavigationBarHeight -kBottomBarHeight-2*kTemplateGap-_adHeight;
            y = (kScreenHeight - kNavigationBarHeight - kBottomBarHeight - h-_adHeight)/2;
            
            if (h>_maxHeight) {
                float scale = h/_maxHeight;
                w = w/scale;
                h = _maxHeight;
                y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
                x = (kScreenWidth-w)/2;
            }
            
            if (!IS_IPAD) {
                w = kTemplateEdge-52;
                h = w*4/3;
                x = (kScreenWidth-w)/2;
                y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
            }
            
            [_presentView adjustFrameSize:w withHeight:h];
            _presentView.frame = CGRectMake(x, y, w, h);
        }
            break;
        case aspect_4x3_icon:
        {
            float w = kTemplateEdge;
            float h = kTemplateEdge*3/4;
            y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
            [_presentView adjustFrameSize:w withHeight:h];
            _presentView.frame = CGRectMake(kTemplateGap, y, w, h);
        }
            break;
        case aspect_4x5_icon:
        {
            float x = kTemplateGap;
            float w = kTemplateEdge;
            float h = kTemplateEdge*5/4;
            float _maxHeight = kScreenHeight - kNavigationBarHeight -kBottomBarHeight - 2*kTemplateGap-_adHeight;
            y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
            
            if (h>_maxHeight) {
                float scale = h/_maxHeight;
                w = w/scale;
                h = _maxHeight;
                y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
                x = (kScreenWidth-w)/2;
            }
            [_presentView adjustFrameSize:w withHeight:h];
            _presentView.frame = CGRectMake(x, y, w, h);
        }
            break;
        case aspect_5x4_icon:
        {
            float w = kTemplateEdge;
            float h = kTemplateEdge*4/5;
            y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
            [_presentView adjustFrameSize:w withHeight:h];
            _presentView.frame = CGRectMake(kTemplateGap, y, w, h);
        }
            break;
        case aspect_5x7_icon:
        {
            float x = kTemplateGap;
            float w = kTemplateEdge;
            float h = kTemplateEdge*7/5;
            float _maxHeight = kScreenHeight - kNavigationBarHeight -kBottomBarHeight - 2*kTemplateGap-_adHeight;
            y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
            
            if (h>_maxHeight) {
                float scale = h/_maxHeight;
                w = w/scale;
                h = _maxHeight;
                y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
                x = (kScreenWidth-w)/2;
            }
            [_presentView adjustFrameSize:w withHeight:h];
            _presentView.frame = CGRectMake(x, y, w, h);
        }
            break;
        case aspect_7x5_icon:
        {
            float w = kTemplateEdge;
            float h = kTemplateEdge*5/7;
            y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
            [_presentView adjustFrameSize:w withHeight:h];
            _presentView.frame = CGRectMake(kTemplateGap, y, w, h);
        }
            break;
        case aspect_9x16_icon:
        {
            float x = kTemplateGap;
            float w = kTemplateEdge;
            float h = w*16/9;

            float _maxHeight = kScreenHeight - kNavigationBarHeight - kBottomBarHeight - 2*kTemplateGap-_adHeight;
            y = (kScreenHeight - kNavigationBarHeight - kBottomBarHeight - h-_adHeight)/2;
            h = _maxHeight;
            if (h>=_maxHeight)
            {
                w = _maxHeight*9/16;
                h = _maxHeight;
                y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
                x = (kScreenWidth-w)/2;
            }
            
            [_presentView adjustFrameSize:w withHeight:h];
            _presentView.frame = CGRectMake(x, y, w, h);
        }
            break;
        case aspect_16x9_icon:
        {
            float x = kTemplateGap;
            float w = kTemplateEdge;
            float h = kTemplateEdge*9/16;
            y = (kScreenHeight - kNavigationBarHeight -kBottomBarHeight - h-_adHeight)/2;
            
            [_presentView adjustFrameSize:w withHeight:h];
            _presentView.frame = CGRectMake(x, y, w, h);
        }
            break;
        default:
            break;
    }
}


#pragma mark -- ZBBackgroundImageViewDelegate
- (void)selectedABackgroundImage:(NSString*)imageName atIndex:(NSInteger)index
{
//    if (self.currentCollageType == CollageTypeFree) {
//        
//    }
    
    [self.freecollageView setBackgroundImage:imageName];
}

#pragma mark -- ZBBorderViewDelegate
- (void)selectedColor:(UIColor *)color
{
    if (self.currentCollageType == CollageTypeGrid)
    {
        [_presentView setTemplateBackgroundColor:color];
    }
    else if(self.currentCollageType == CollageTypeFree)
    {
        [self.freecollageView setBackgroundColorOrImage:color];
    }
    else if(self.currentCollageType == CollageTypeJoin)
    {
        [self.joinCollageView setBackgroundColorOrImage:color];
    }
}

- (void)selectedAnImage:(UIImage *)image
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)hiddenFromSuperView
{
    _colorAndBGImageView.hidden = YES;
    self.selectBGView.hidden = YES;
}

- (void)changeBorderOrCorner:(CGFloat)value withChangedType:(SliderChangeType)type
{
    if (self.currentCollageType == CollageTypeGrid)
    {
        [_presentView changedBorderOrCornerValue:value withChangedType:type];
    }
    else if(self.currentCollageType == CollageTypeFree && type == SliderChangeTypeCorner)
    {
        [self.freecollageView changedCornerValue:value];
    }
}

#pragma mark -- BHDragViewDelegate

- (void)deleteSeletedSmilingIcon:(NSUInteger)tag
{
    NSUInteger _selectedTag= kDragViewStartTag + tag;
    BHDragView *_deleteDragView = (BHDragView*)[self viewWithTag:_selectedTag];
    [_deleteDragView removeFromSuperview];
}

- (void)adjustDragViewFrame:(CGRect)rect withDragViewTag:(NSUInteger)tag andRadians:(CGFloat)radians
{
    BHDragView *_dragView = (BHDragView*)[self viewWithTag:tag];
    CGFloat x = _dragView.frame.origin.x+rect.origin.x;
    _dragView.frame = CGRectMake(x, _dragView.frame.origin.y+rect.origin.y, _dragView.frame.size.width + rect.size.width, _dragView.frame.size.height + rect.size.height);
    //    NSLog(@"_dragView -----------> %@",_dragView);
    //    CGAffineTransform transform =CGAffineTransformMakeRotation(M_PI*0.001);//定义一个transform 旋转（3.14/6）;
    //    [_dragView setTransform:transform];
    //    _dragView.transform = CGAffineTransformRotate([_dragView transform], radians);
}

#pragma mark -- 手势
// 旋转
-(void)rotate:(id)sender {
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        //        _lastRotation = 0.0;
        return;
    }
    
    //    CGFloat rotation = 0.0 - (_lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    //
    //    CGAffineTransform currentTransform = photoImage.transform;
    //    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    //
    //    [photoImage setTransform:newTransform];
    //
    //    _lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
    //    [self showOverlayWithFrame:photoImage.frame];
    UIRotationGestureRecognizer *gestureRecognizer = (UIRotationGestureRecognizer*)sender;
    if([gestureRecognizer state]== UIGestureRecognizerStateBegan||[gestureRecognizer state]==UIGestureRecognizerStateChanged)
    {
        //        NSLog(@"%f",[gestureRecognizer rotation]);
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        // rotate = [gestureRecognizer rotation];
        [gestureRecognizer setRotation:0];
        
    }
}

//-(void)handelPan:(UIPanGestureRecognizer*)gestureRecognizer{
//    //获取平移手势对象在self.view的位置点，并将这个点作为self.aView的center,这样就实现了拖动的效果
//    CGPoint curPoint = [gestureRecognizer locationInView:self.presentView];
//    [[gestureRecognizer view] setCenter:curPoint];
//}


@end
