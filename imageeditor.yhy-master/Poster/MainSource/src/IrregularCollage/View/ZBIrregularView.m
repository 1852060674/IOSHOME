//
//  ZBIrregularView.m
//  Collage
//
//  Created by shen on 13-7-8.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBIrregularView.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"

@implementation ZBIrregularView

@synthesize selectedIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //监听背景变化信息
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBackgroundImage:) name:kChangeBackGroundImage object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kChangeBackGroundImage object:nil];
}

- (void)changeBackgroundImage:(NSNotification*)notification
{
    NSDictionary *_infoDic = [notification object];//获取到传递的对象
    
    CollageType _type = [[_infoDic valueForKey:@"CollageType"] integerValue];
    if (_type != CollageTypeGrid) {
        return;
    }
    
    NSString *_imageName = [_infoDic valueForKey:@"imageIndex"];
    _imageName = [NSString stringWithFormat:@"bg%@.png",_imageName];
    
    UIImage *_backgroundImage = [ImageUtil loadResourceImage:_imageName];
    self.backgroundColor = [UIColor colorWithPatternImage:_backgroundImage];
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
