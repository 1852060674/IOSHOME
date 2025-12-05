//
//  CutoutViewController.m
//  HairColor
//
//  Created by ZB_Mac on 2016/11/22.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "CutoutViewController.h"
#import "MainLevelView_1.h"
#import "CutoutTopView.h"
#import "Masonry.h"
#import "HToolView.h"
#import "ComprehensiveCutoutView.h"
#import "MBProgressHUD.h"
#import "ZBCommonDefine.h"
#import "VideoPlayViewController.h"
#import "GlobalSettingManger.h"
#import "Admob.h"
#import "AdUtility.h"

@interface CutoutViewController ()<ComprehensiveCutoutViewDelegate, AdmobVCBannerAdDelegate>
{
    BOOL _everAppear;
    
    NSInteger _lastIndex;
    __weak IBOutlet UIView *contentView;
    
    BOOL bannerShowed;
    
}
@property (nonatomic, strong) MainLevelView_1 *mainLevelView;
@property (nonatomic, strong) ComprehensiveCutoutView *cutoutView;
@property (nonatomic, strong) HToolView *bottomToolView;

@end

@implementation CutoutViewController

-(void)loadView
{
    [super loadView];
    self.mainLevelView = [[MainLevelView_1 alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mainLevelView.clipsToBounds = YES;
    self.mainLevelView.backgroundColor = [UIColor whiteColor];
    //self.view = self.mainLevelView;
    [contentView addSubview:self.mainLevelView];
    [self.mainLevelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(contentView);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _lastIndex = -1;
    [self setupMainView];
    
    [[AdmobViewController shareAdmobVC] checkConfigUD];
    bannerShowed = NO;
}
#pragma mark -
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_everAppear) {
        
        if (_maskImage) {
            [self.cutoutView setMaskImage:_maskImage];
        }
        
        [self.bottomToolView selectAtIndex:0];
        [self cutoutBottomViewSelected:0];
        
        if ([GlobalSettingManger defaultManger].cropUseCnt < 3) {
            [self showDefaultHelp];
            ++[GlobalSettingManger defaultManger].cropUseCnt;
        }
    }
    
    _everAppear = YES;
}

- (void)adMobVCBannerAdLoaded:(ADWrapper *)bannerad {
    if([AdUtility hasAd] && !bannerShowed) {
        bannerShowed = YES;
        [self.mainLevelView showBanner:YES animated:YES completionAction:^(BOOL b) {
            [AdUtility tryShowBannerInView:self.mainLevelView.adContainerView];
        }];
    }
}

- (void)adMobVCBannerAdFailedLoaded:(ADWrapper *)bannerad error:(NSError *)error {
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if([AdUtility hasAd]) {
        if ([[AdmobViewController shareAdmobVC] admob_ever_recive_banner]) {
            bannerShowed = YES;
            [self.mainLevelView showBanner:YES animated:YES completionAction:^(BOOL b) {
                [AdUtility tryShowBannerInView:self.mainLevelView.adContainerView];
            }];
        }
        else
        {
            [AdUtility tryShowBannerInView:self.mainLevelView.adContainerView];
//            [AdmobViewController shareAdmobVC].delegate = self;
        }
        [[AdmobViewController shareAdmobVC] setBannerClient:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[AdmobViewController shareAdmobVC] setBannerClient:nil];
}

#pragma mark -

-(void)acceptChange
{
    UIImage *maskImage = [_cutoutView getMaskImage];
    
    [MBProgressHUD showSharedHUDInView:self.view];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSArray *images = [_cutoutView requireImages:@[@(kICImageTypeMaskFGFullSize)] withAccurateOn:YES];
        UIImage *refinedMaskImage = [images objectAtIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideSharedHUD];

            if (!refinedMaskImage) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TIP", @"") message:NSLocalizedString(@"NO_HAIR_MASK_MSG", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"") otherButtonTitles:NSLocalizedString(@"SEE_HELP", @""), nil];
                [alertView show];
                return;
            }
            else
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.actions) {
                        self.actions(YES, maskImage, refinedMaskImage);
                    }
                }];
            }
        });
    });
}

-(void)setupMainView
{
    __weak CutoutViewController *_wSelf = self;
    /// top
    NSArray  *apparray= [[NSBundle mainBundle] loadNibNamed:@"CutoutTopView" owner:nil options:nil];
    CutoutTopView *cutoutTopView = (CutoutTopView *)[apparray firstObject];
    
    [cutoutTopView setActions:^(NSInteger index) {

        switch (index) {
            case 0:
                [_wSelf.navigationController popViewControllerAnimated:YES];
                if (_wSelf.actions) {
                    _wSelf.actions(NO, nil, nil);
                }
                break;
            case 1:
                [_wSelf acceptChange];
                [_wSelf.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
            }
    }];
    [_mainLevelView.shellTopBarView addSubview:cutoutTopView];
    [cutoutTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(_mainLevelView.shellTopBarView);
    }];
    
    // bottom
    NSMutableArray *cellDatas = [NSMutableArray array];
    NSArray *titles = @[
                        NSLocalizedString(@"SMART_SCISSORS", @""),
                        NSLocalizedString(@"ERASER", @""),
                        NSLocalizedString(@"BRUSH", @""),
                        ];
    NSArray *icons = @[
                       @"btn_smart_scissor",
                       @"btn_erase",
                       @"btn_normal_brush",
                       ];

    for (NSInteger idx=0; idx<titles.count; ++idx) {
        HToolViewCellAttributes *attributes = [HToolViewCellAttributes new];
        attributes.title = titles[idx];
        attributes.icon = [[UIImage imageNamed:icons[idx]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        attributes.selectedTitleColor = CUT_HIGHLIGHT_COLOR;
        attributes.titleColor = CUT_NORMAL_COLOR;
        attributes.imageViewContentMode = UIViewContentModeScaleAspectFit;
        attributes.imageViewInsets = UIEdgeInsetsMake(2, 0, 2, 0);
        
        [cellDatas addObject:attributes];
    }
    
    HToolView *bottomToolView = [[HToolView alloc] initWithFrame:_mainLevelView.shellBottomBarView.bounds andCellDatas:cellDatas];
    bottomToolView.titleRatio = 0.25;
    bottomToolView.widthRatio = 1.20;
    bottomToolView.showSelectedMode = 5;
    
    [bottomToolView setActions:^(NSInteger index) {
        [_wSelf cutoutBottomViewSelected:index];
    }];
    
    [_mainLevelView.shellBottomBarView addSubview:bottomToolView];
    
    [bottomToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(_mainLevelView.shellBottomBarView);
    }];
    _bottomToolView = bottomToolView;
    // main
    [self setupCutoutView];
    
    [self fillCutoutPopViewForMode:0];
    [self fillCutoutPopViewForMode:1];
}

-(void)setupCutoutView
{
    ComprehensiveCutoutView *cutoutView = [[ComprehensiveCutoutView alloc] initWithFrame:self.mainLevelView.contentView.bounds andImage:self.originalImage];
    [self.mainLevelView.contentView addSubview:cutoutView];
    [cutoutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self.mainLevelView.contentView);
    }];
    [cutoutView setDefaultParaments];
    cutoutView.magnifierParentView = self.mainLevelView.contentView;
    cutoutView.delegate = self;
    cutoutView.brushRadius = 10;
    self.cutoutView = cutoutView;    
}

-(void)fillCutoutPopViewForMode:(NSInteger)mode
{
    switch (mode) {
        case 0:
        {
            UIButton *button = [[UIButton alloc] init];
            [button setContentEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            [button setImage:[UIImage imageNamed:@"btn_help"] forState:UIControlStateNormal];
            [_mainLevelView.popView_3 addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.top.bottom.equalTo(_mainLevelView.popView_3);
                make.width.equalTo(button.mas_height);
            }];
            [button addTarget:self action:@selector(showDefaultHelp) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *label = [[UILabel alloc] init];
            [_mainLevelView.popView_3 addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(_mainLevelView.popView_3);
                make.width.equalTo(@(50));
                make.left.equalTo(_mainLevelView.popView_3).offset(8);
            }];
            label.text = NSLocalizedString(@"RADIUS", @"");
            label.font = [UIFont systemFontOfSize:13];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = CUT_HIGHLIGHT_COLOR;
            
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectZero];
//                        [slider setMaximumValueImage:[UIImage imageNamed:@"slider_max"]];
//                        [slider setMinimumValueImage:[UIImage imageNamed:@"slider_min"]];
//            [slider setThumbImage:[UIImage imageNamed:@"cut_slider_thumb"] forState:UIControlStateNormal];
            [slider setMinimumTrackTintColor:CUT_HIGHLIGHT_COLOR];
            [slider setMaximumTrackTintColor:CUT_NORMAL_COLOR];
            [slider setMaximumValue:20.0];
            [slider setMinimumValue:8.0];
            [slider addTarget:self action:@selector(cutoutDrawLineWidthChanged:) forControlEvents:UIControlEventValueChanged];
            slider.value = [_cutoutView drawLineWidth];
            
            [_mainLevelView.popView_3 addSubview:slider];
            [slider mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(_mainLevelView.popView_3);
                make.left.equalTo(label.mas_right).offset(4);
                make.right.equalTo(button.mas_left).offset(-8);
                //                make.right.equalTo(_mainLevelView.cutoutBottomPopBarView2).offset(-16);
            }];
            
            break;
        }
        case 1:
        case 2:
        {
            UILabel *label_1 = [[UILabel alloc] init];
            [_mainLevelView.popView_1 addSubview:label_1];
            label_1.text = NSLocalizedString(@"RADIUS", @"");
            label_1.font = [UIFont systemFontOfSize:13];
            label_1.textAlignment = NSTextAlignmentCenter;
            label_1.textColor = CUT_HIGHLIGHT_COLOR;
            
            UISlider *slider_1 = [[UISlider alloc] initWithFrame:CGRectZero];
            //            [slider_1 setMaximumValueImage:[UIImage imageNamed:@"slider_max"]];
            //            [slider_1 setMinimumValueImage:[UIImage imageNamed:@"slider_min"]];
//            [slider_1 setThumbImage:[UIImage imageNamed:@"cut_slider_thumb"] forState:UIControlStateNormal];
            [slider_1 setMinimumTrackTintColor:CUT_HIGHLIGHT_COLOR];
            [slider_1 setMaximumTrackTintColor:CUT_NORMAL_COLOR];
            [slider_1 setMaximumValue:30.0];
            [slider_1 setMinimumValue:5.0];
            slider_1.value = _cutoutView.brushRadius;
            [slider_1 addTarget:self action:@selector(cutoutBrushRadiusChanged:) forControlEvents:UIControlEventValueChanged];
            
            [_mainLevelView.popView_1 addSubview:slider_1];
            
            UILabel *label_2 = [[UILabel alloc] init];
            [_mainLevelView.popView_1 addSubview:label_2];
            label_2.text = NSLocalizedString(@"SMOOTH_BRUSH", @"");
            label_2.font = [UIFont systemFontOfSize:13];
            label_2.textAlignment = NSTextAlignmentCenter;
            label_2.textColor = CUT_HIGHLIGHT_COLOR;
            
            UISlider *slider_2 = [[UISlider alloc] initWithFrame:CGRectZero];
            //            [slider_2 setMaximumValueImage:[UIImage imageNamed:@"slider_max"]];
            //            [slider_2 setMinimumValueImage:[UIImage imageNamed:@"slider_min"]];
//            [slider_2 setThumbImage:[UIImage imageNamed:@"cut_slider_thumb"] forState:UIControlStateNormal];
            [slider_2 setMinimumTrackTintColor:CUT_HIGHLIGHT_COLOR];
            [slider_2 setMaximumTrackTintColor:CUT_NORMAL_COLOR];
            [slider_2 setMaximumValue:1.0];
            [slider_2 setMinimumValue:0.0];
            slider_2.value = _cutoutView.brushSmooth;
            [slider_2 addTarget:self action:@selector(cutoutBrushSmoothChanged:) forControlEvents:UIControlEventValueChanged];
            
            [_mainLevelView.popView_1 addSubview:slider_2];
            
            [@[label_1, label_2] mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:8.0 leadSpacing:8.0 tailSpacing:8.0];
            [@[slider_1, slider_2] mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:8.0 leadSpacing:8.0 tailSpacing:8.0];
            
            [@[label_1, label_2] mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(50));
                make.left.equalTo(_mainLevelView.popView_1).offset(8);
            }];
            
            [@[slider_1, slider_2] mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(_mainLevelView.popView_1).offset(-16);
            }];
            
            [slider_1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(label_1.mas_right).offset(8);
            }];
            
            [slider_2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(label_2.mas_right).offset(8);
            }];
            
            break;
        }
        default:
            break;
    }
}

#pragma mark -

-(void)cutoutDrawLineWidthChanged:(UISlider *)slider
{
    [_cutoutView setDrawLineWidth:slider.value];
}

-(void)cutoutBrushRadiusChanged:(UISlider *)slider
{
    [_cutoutView setBrushRadius:slider.value];
}

-(void)cutoutBrushSmoothChanged:(UISlider *)slider
{
    [_cutoutView setBrushSmooth:slider.value];
}

-(void)cutoutBottomViewSelected:(NSInteger)index
{
    CutoutMode cutoutMode = kCutoutModeNone;
    NSInteger popViewType = 0;

    switch (index) {
        case 0:
        {
            cutoutMode = kCutoutModeSmartScissors;
            popViewType = 3;
            break;
        }
        case 1:
        {
            cutoutMode = kCutoutModeNormalEraser;
            popViewType = 1;
            break;
        }
        case 2:
        {
            cutoutMode = kCutoutModeNormalBrush;
            popViewType = 1;
            break;
        }
        default:
            break;
    }
    
    if (_lastIndex == index && [_mainLevelView currentPopViewType] == popViewType)
    {
        popViewType = 0;
    }
    
    [_mainLevelView showPopView:popViewType animated:YES completionAction:nil];
    
    _lastIndex = index;
    _cutoutView.cutoutMode = cutoutMode;
}

-(void)showDefaultHelp
{
    [self showHelpForIndex:0];
}

-(void)showHelpForIndex:(NSInteger)helpIndex
{
    NSInteger defaultPage = helpIndex;
    VideoPlayViewController *purchaseVC = [[VideoPlayViewController alloc] initWithNibName:@"VideoPlayViewController" bundle:[NSBundle mainBundle]];
    purchaseVC.defaultPageIndex = defaultPage;
    [self presentViewController:purchaseVC animated:YES completion:nil];
}
#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            break;
        case 1:
            [self showHelpForIndex:0];
            break;
        default:
            break;
    }
}

#pragma mark - ComprehensiveCutoutViewDelegate
-(void)comprehensiveCutoutViewDidChange:(ComprehensiveCutoutView *)cutoutView
{
}

-(void)comprehensiveCutoutViewWillBeginDraw:(ComprehensiveCutoutView *)cutoutView
{
//    [_mainLevelView showPopView:0 animated:YES completionAction:nil];
}

-(void)comprehensiveCutoutViewWillBeginTimeConsumingOperation:(ComprehensiveCutoutView *)cutoutView
{
    [MBProgressHUD showSharedHUDInView:self.view];
}

-(void)comprehensiveCutoutViewDidFinishTimeConsumingOperation:(ComprehensiveCutoutView *)cutoutView
{
    [MBProgressHUD hideSharedHUD];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"%s", __FUNCTION__);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
