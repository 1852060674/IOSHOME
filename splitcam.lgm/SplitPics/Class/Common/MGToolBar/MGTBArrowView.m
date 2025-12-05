//
//  MGTBArrowView.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-12.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGTBArrowView.h"
#import "MGScrollView.h"
#import "MGDefine.h"

#define MGStr(x) [NSString stringWithFormat:@"%ld", (long)(x)]

@implementation MGTBArrowView{
    CGRect originRect;
    float viewH;
    float gap;
    MGScrollView *mgSV;
    
    NSArray *adjustNames;
    NSArray *adjustRanges;
    NSMutableDictionary *dicts;
}

@synthesize selectedPictureIdx;
@synthesize selectedBtnIdx;
@synthesize adjustView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.clipsToBounds = YES;
    originRect = frame;
    
    [self dataInit];
    [self widgetsInit];
    
    return self;
}

- (void)dataInit
{
    viewH = kToolBarH;
    gap = 5.0;
    adjustNames = @[kLocalizable(@"Brightness"),
                    kLocalizable(@"Contrast"),
                    kLocalizable(@"Saturation"),
                    kLocalizable(@"Exposure"),
                    kLocalizable(@"Blur")];
    
    adjustRanges = @[@"-0.5,0.5,0.0",
                     @"0.5,2.0,1.0",
                     @"0.0,2.0,1.0",
                     @"-1.0,1.0,0.0",
                     @"0.0,12.0,0.0"];
    self.backgroundColor = MGTBBgColor;
}

- (void)widgetsInit
{
    UIView *cvView = [[UIView alloc] init];
    cvView.frame = CGRectMake(0, 0, self.bounds.size.width, viewH);
    [self addSubview:cvView];
    
    mgSV = [[MGScrollView alloc] init];
    mgSV.frame = cvView.bounds;
    [cvView addSubview:mgSV];

    [self scrollViewInit];
    
    float ctlY = viewH-gap;
    UIView *ctlView = [[UIView alloc] init];
    ctlView.frame = CGRectMake(0, ctlY, self.bounds.size.width, self.bounds.size.height-ctlY);
    [self addSubview:ctlView];
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, gap, ctlView.bounds.size.width, self.bounds.size.height-viewH)];
    [ctlView addSubview:subView];
    subView.backgroundColor = MGTBCtlColor;
    
    float arrowH = subView.bounds.size.height*0.8;
    float arrowW = arrowH*1.5;
    
    UIImageView *arrow = [[UIImageView alloc] init];
    arrow.frame = CGRectMake((subView.bounds.size.width-arrowW)/2, (subView.bounds.size.height-arrowH)/2,
                             arrowW, arrowH);
    arrow.image = [UIImage imageNamed:@"arrow"];
    [subView addSubview:arrow];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HiddenView:)];
    [ctlView addGestureRecognizer:tap];
    ctlView.userInteractionEnabled = YES;
    
    self.frame = CGRectMake(0, kScreenHeight, self.bounds.size.width, self.bounds.size.height);
    
    [self adjustViewInit];
}

- (void)scrollViewInit
{
    int btnCount = 5;
    float btnW = mgSV.bounds.size.width/btnCount;
    float btnH = mgSV.bounds.size.height;
    float imgH = (btnW <btnH) ? btnW : btnH;
    imgH = imgH*0.7;
    
    float gapX = (btnW-imgH)/2;
    float gapY = (btnH-imgH)/2;
    
    NSArray *btnArray = @[@"btn_brightness",@"btn_contrast",@"btn_saturation",@"btn_exposure",@"btn_blur"];
    
    for(int i=0; i<btnCount; i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnW*i, 0, btnW, btnH);
        [btn setImage:[UIImage imageNamed:btnArray[i]] forState:UIControlStateNormal];
        btn.contentMode = UIViewContentModeCenter;
        [btn setContentEdgeInsets:UIEdgeInsetsMake(gapY, gapX, gapY, gapX)];
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [mgSV addSubview:btn];
    }
    
    mgSV.contentSize = CGSizeMake(mgSV.bounds.size.width, 0);
}

- (void)adjustViewInit
{
    adjustView = [[MGAdjustView alloc] initWithFrame:self.bounds];
    [self addSubview:adjustView];
}

- (void)clickBtn:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    selectedBtnIdx = btn.tag;
    
    adjustView.titleStr = adjustNames[selectedBtnIdx];
    NSArray *sliderRanges = [adjustRanges[selectedBtnIdx] componentsSeparatedByString:@","];
    adjustView.slider.minimumValue = [sliderRanges[0] floatValue];
    adjustView.slider.maximumValue = [sliderRanges[1] floatValue];
    adjustView.slider.value = [[[dicts objectForKey:MGStr(selectedPictureIdx)] objectForKey:adjustNames[selectedBtnIdx]] floatValue];
    
    [adjustView showSelf];
    
    __weak MGTBArrowView *weakSelf = self;
    [adjustView setSliderBlock:^(float value){
        [weakSelf.delegate mgTBAVAdjustAtIndex:weakSelf.selectedBtnIdx WithValue:value];
    }];
    
    [adjustView setConfirmBlock:^(float value){
        [weakSelf setAdjustDataAt:weakSelf.selectedBtnIdx WithValue:value];
    }];
    
    __block float sliderValue = adjustView.slider.value;

    [adjustView setCancelBlock:^(){
        [weakSelf.delegate mgTBAVAdjustAtIndex:weakSelf.selectedBtnIdx WithValue:sliderValue];
    }];
}

- (void)setSelectedPictureIdx:(NSInteger)newValue
{
    float currentValue = adjustView.slider.value;
    [self setAdjustDataAt:selectedBtnIdx WithValue:currentValue];
    
    selectedPictureIdx = newValue;
    adjustView.slider.value = [[[dicts objectForKey:MGStr(selectedPictureIdx)] objectForKey:adjustNames[selectedBtnIdx]] floatValue];
}

- (void)setAdjustDataAt:(NSInteger)index WithValue:(float)value {
    NSMutableDictionary *dict = [dicts objectForKey:[NSString stringWithFormat:@"%ld", (long)selectedPictureIdx]];
    [dict setValue:[NSString stringWithFormat:@"%f",value] forKey:adjustNames[index]];
}

- (void)setDefaultDataWith:(NSInteger)nums
{
    dicts = [[NSMutableDictionary alloc] init];
    for(int i = 0; i<nums; i++){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                     @"0.0",adjustNames[0],
                                     @"1.0",adjustNames[1],
                                     @"1.0",adjustNames[2],
                                     @"0.0",adjustNames[3],
                                     @"0.0",adjustNames[4],nil];
        [dicts setObject:dict forKey:MGStr(i)];
    }
}

- (void)HiddenView:(UITapGestureRecognizer*)recognizer
{
    [self hideSelf];
}

- (void)hideSelf
{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, kScreenHeight, self.bounds.size.width, self.bounds.size.height);
    } completion:^(BOOL finished) {
        [self.delegate mgTBAVHide];
    }];
}

- (void)showSelf
{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = originRect;
    } completion:^(BOOL finished) {
        
    }];
}

@end
