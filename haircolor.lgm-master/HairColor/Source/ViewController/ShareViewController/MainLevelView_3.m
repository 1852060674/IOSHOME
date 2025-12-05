//
//  MainLevelView_3.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/8.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "MainLevelView_3.h"
#import "Masonry.h"
#import "UIColor+Hex.h"

@interface MainLevelView_3 ()
{
    NSInteger _UIType;
}
@property (nonatomic, strong) UIView *maskView;
@end

@implementation MainLevelView_3

-(MainLevelView_3 *)initWithFrame:(CGRect)frame andHasAD:(BOOL)hasAD
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _topHeight = 50;
        
        _bottomHeight_1 = hasAD?300:200;
        _bottomHeight_2 = hasAD?450:200;
        
        BOOL isIPAD = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad);
        _bottomHeight_1 = hasAD?(isIPAD?600:300):(isIPAD?400:200);
        _bottomHeight_2 = hasAD?(isIPAD?800:450):(isIPAD?400:200);
        
        
        // top
        CGFloat topHeight = _topHeight;
        if (topHeight > 0) {
            _shellTopBarView = [[UIView alloc] init];
            _shellTopBarView.backgroundColor = [UIColor whiteColor];
            [self addSubview:_shellTopBarView];
            
            [_shellTopBarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.height.mas_equalTo(topHeight);
                
                make.bottom.equalTo(self.mas_top).offset(topHeight);
            }];
        }
        
        // main
        _mainAreaView = [[UIView alloc] init];
        _mainAreaView.clipsToBounds = YES;
        [self addSubview:_mainAreaView];
        [_mainAreaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(8);
            make.right.equalTo(self).offset(-8);
            make.top.equalTo(self).offset(topHeight+8);
            make.bottom.equalTo(self).offset(-_bottomHeight_1-8);
        }];
        _mainAreaView.backgroundColor = [UIColor whiteColor];
        // mask
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.hidden = YES;
        _maskView.alpha = 0.0;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTap:)];
        [_maskView addGestureRecognizer:tapGesture];
        
        // bottom
        CGFloat bottomHeight = _bottomHeight_2;
        if (bottomHeight > 0) {
            _shellBottomBarView = [[UIView alloc] init];
            _shellBottomBarView.backgroundColor = [UIColor whiteColor];
            [self addSubview:_shellBottomBarView];
            
            [_shellBottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self);
                make.height.mas_equalTo(bottomHeight);
                
                make.top.equalTo(self.mas_bottom).offset(-_bottomHeight_1);
            }];
        }
        
        if (hasAD) {
            UISwipeGestureRecognizer *upSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onBottomViewUpSwipe:)];
            upSwipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
            [_shellBottomBarView addGestureRecognizer:upSwipeGesture];
            
            UISwipeGestureRecognizer *downSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onBottomViewDownSwipe:)];
            downSwipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
            [_shellBottomBarView addGestureRecognizer:downSwipeGesture];
        }
    }
    
    return self;
}

-(void)showBottomType:(NSInteger)type animated:(BOOL)animated
{
    if (_UIType == type) {
        return;
    }
    _UIType = type;
    CGFloat height = type==0?_bottomHeight_1:_bottomHeight_2;
    self.maskView.hidden = NO;
    
    [_shellBottomBarView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_bottom).offset(-height);
    }];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
            self.maskView.alpha = (type==0?0.0:0.5);
        } completion:^(BOOL finished) {
            self.maskView.hidden = (type==0);
        }];
    }
    else
    {
        self.maskView.alpha = (type==0?0.0:0.5);
        self.maskView.hidden = (type==0);

        [self layoutIfNeeded];
    }
}

-(void)onBottomViewUpSwipe:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateRecognized:
            NSLog(@"%s", __FUNCTION__);
            [self showBottomType:1 animated:YES];
            break;
            
        default:
            break;
    }
}

-(void)onBottomViewDownSwipe:(UISwipeGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateRecognized:
            NSLog(@"%s", __FUNCTION__);
            [self showBottomType:0 animated:YES];
            break;
            
        default:
            break;
    }
}

-(void)bgTap:(UITapGestureRecognizer *)gesture
{
    [self showBottomType:0 animated:YES];
}
@end
