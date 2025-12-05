//
//  MailLevelView.m
//  HairColorNew
//
//  Created by ZB_Mac on 16/8/26.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "MainLevelView_1.h"
#import "Masonry.h"

@interface MainLevelView_1 ()
{
    NSInteger _currentPopViewType;
}
@property (nonatomic, strong) UIView *mainView;
@end

@implementation MainLevelView_1

-(MainLevelView_1 *)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // init heights
        _adHeight = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad?90:50);
        _topHeight = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad?70:50);
        _bottomHeight = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad?70:50);
        _popHeight_1 = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad?90:80);
        _popHeight_2 = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad?90:70);
        _popHeight_3 = (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad?50:40);
        
        // init & add views
        _adContainerView = [[UIView alloc] init];
        _shellTopBarView = [[UIView alloc] init];
        _shellBottomBarView = [[UIView alloc] init];
        _popView_1 = [[UIView alloc] init];
        _popView_2 = [[UIView alloc] init];
        _popView_3 = [[UIView alloc] init];
        _contentView = [[UIView alloc] init];
        _mainView = [[UIView alloc] init];
        
        [self addSubview:_mainView];
        [_mainView addSubview:_popView_1];
        [_mainView addSubview:_popView_2];
        [_mainView addSubview:_popView_3];
        [_mainView addSubview:_contentView];
        [_mainView addSubview:_shellTopBarView];
        [_mainView addSubview:_shellBottomBarView];
        _mainView.clipsToBounds = YES;
        [self addSubview:_adContainerView];
        
        //
        _shellBottomBarView.backgroundColor = [UIColor whiteColor];
        _popView_1.backgroundColor = [UIColor whiteColor];
        _popView_2.backgroundColor = [UIColor whiteColor];
        _contentView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];

        // constraints
        [_adContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(_adHeight));
            make.left.right.equalTo(self);
            make.top.equalTo(self.mas_bottom);
        }];
        
        [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self);
            make.bottom.equalTo(_adContainerView.mas_top);
        }];
        
        [_shellTopBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_mainView);
            make.height.equalTo(@(_topHeight));
        }];
        
        [_shellBottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(_mainView);
            make.height.equalTo(@(_bottomHeight));
        }];
        
        [_popView_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_shellBottomBarView);
            make.height.equalTo(@(_popHeight_1));
        }];
        
        [_popView_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_shellBottomBarView);
            make.height.equalTo(@(_popHeight_2));
        }];

        [_popView_3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(_shellBottomBarView);
            make.height.equalTo(@(_popHeight_3));
        }];
        
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(_shellTopBarView.mas_bottom);
            make.bottom.equalTo(_shellBottomBarView.mas_top);
        }];
        
        [self sendSubviewToBack:self.contentView];
        self.contentView.clipsToBounds = YES;
    }
    
    return self;
}

-(NSInteger)currentPopViewType
{
    return _currentPopViewType;
}

-(void)showPopView:(NSInteger)type animated:(BOOL)animated completionAction:(void (^)(BOOL))completion
{
    if (type == _currentPopViewType) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    UIView *showView;
    UIView *hideView;
    
    switch (_currentPopViewType) {
        case 1:
        {
            hideView = _popView_1;
            break;
        }
        case 2:
        {
            hideView = _popView_2;
            break;
        }
        case 3:
        {
            hideView = _popView_3;
            break;
        }
        default:
            break;
    }
    
    switch (type) {
        case 1:
        {
            showView = _popView_1;
            break;
        }
        case 2:
        {
            showView = _popView_2;
            break;
        }
        case 3:
        {
            showView = _popView_3;
            break;
        }
        default:
            break;
    }
    
    [hideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(_shellBottomBarView.mas_top);
        make.height.mas_equalTo(CGRectGetHeight(hideView.frame));
    }];
    
    [showView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(_shellBottomBarView.mas_top);
        make.height.mas_equalTo(CGRectGetHeight(showView.frame));
    }];
    
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(_shellTopBarView.mas_bottom);
        make.bottom.equalTo(_shellBottomBarView.mas_top).offset(-CGRectGetHeight(showView.frame));
    }];
    
    if (animated)
    {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }
    else
    {
        [self layoutIfNeeded];
        
        if (completion) {
            completion(YES);
        }
    }
    _currentPopViewType = type;
}

-(void)showBanner:(BOOL)show animated:(BOOL)animated completionAction:(void (^)(BOOL))completion;
{
    if (show)
    {
        [_adContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(_adHeight));
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.mas_bottom);
        }];
    }
    else
    {
        [_adContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(_adHeight));
            make.left.right.equalTo(self);
            make.top.equalTo(self.mas_bottom);
        }];
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (completion) {
                completion(YES);
            }
        }];
    }
    else
    {
        [self layoutIfNeeded];
        
        if (completion) {
            completion(YES);
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
