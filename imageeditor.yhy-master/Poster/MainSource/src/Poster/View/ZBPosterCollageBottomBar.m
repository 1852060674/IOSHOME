//
//  ZBPosterCollageBottomBar.m
//  Collage
//
//  Created by shen on 13-7-22.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBPosterCollageBottomBar.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBPosterCollageBottomBar()
{
    float _bottomBarWidth;
}

@end

@implementation ZBPosterCollageBottomBar

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (IS_IPAD) {
            _bottomBarWidth = 100;
        }
        else
            _bottomBarWidth = 80;
        
        self.backgroundColor = kTransparentColor;
        
        NSArray *objects = [NSArray arrayWithObjects:@"Poster",nil];
        
        UISegmentedControl *segmentedControl=[[UISegmentedControl alloc] initWithItems:objects];
        segmentedControl.frame = CGRectMake((kScreenWidth-_bottomBarWidth)/2, 0, _bottomBarWidth, self.frame.size.height);
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        segmentedControl.multipleTouchEnabled=NO;
        segmentedControl.momentary = YES;
        if (!IS_IPAD) {
            segmentedControl.tintColor= kBottomBarColor;
        }
        [segmentedControl addTarget:self action:@selector(clickSegmentAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:segmentedControl];
    }
    return self;
}

- (void)clickSegmentAction:(id)sender
{
    UISegmentedControl *_segControl = (UISegmentedControl*)sender;
    switch (_segControl.selectedSegmentIndex) {
        case 0:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSelectPosterView:)]) {
                [self.delegate showSelectPosterView:YES];
            }
        }
            break;
        default:
            break;
    }
}

@end
