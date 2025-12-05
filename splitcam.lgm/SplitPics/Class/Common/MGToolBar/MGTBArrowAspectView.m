//
//  MGTBArrowAspectView.m
//  SplitPics
//
//  Created by tangtaoyu on 15-3-18.
//  Copyright (c) 2015年 ZBNetWork. All rights reserved.
//

#import "MGTBArrowAspectView.h"
#import "MGScrollView.h"
#import "UIButton+ImageWithLabel.h"
#import "MGDefine.h"

@implementation MGTBArrowAspectView{
    CGRect originRect;
    float viewH;
    float gap;
    MGScrollView *mgSV;
}

@synthesize selectedBtnIdx;


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
    
}

- (void)scrollViewInit
{
    int btnCount = 4;
    float btnH = mgSV.bounds.size.height;
    float btnW = btnH;
    float btnGap = (self.bounds.size.width-btnW*btnCount)/(btnCount+1);
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-variable"
    float gapX = btnW/4;

#pragma clang diagnostic pop

    
    NSArray *btnArray = @[@"original",@"1x1",@"3x2",@"3x4"];
    
    for(int i=0; i<btnCount; i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(btnGap+(btnW+btnGap)*i, 0, btnW, btnH);
        [btn setImage:[UIImage imageNamed:btnArray[i]] withTitle:btnArray[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        btn.tag = i;
        [mgSV addSubview:btn];
    }
    
    mgSV.contentSize = CGSizeMake(mgSV.bounds.size.width, 0);
}

- (void)clickBtn:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    selectedBtnIdx = btn.tag;
    
    [self.delegate mgTBArrowAspectViewSelectItemAt:selectedBtnIdx];
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
