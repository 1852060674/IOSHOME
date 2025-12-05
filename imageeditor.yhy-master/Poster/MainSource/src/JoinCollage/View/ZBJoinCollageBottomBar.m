//
//  ZBJoinCollageBottomBar.m
//  Collage
//
//  Created by shen on 13-6-26.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBJoinCollageBottomBar.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBJoinCollageBottomBar()
{
    float _bottomBarWidth;
}

@end

@implementation ZBJoinCollageBottomBar

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
        
        NSArray *objects = [NSArray arrayWithObjects:@"Border",nil];
        
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
//            if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenPromptView)]) {
//                [self.delegate hiddenPromptView];
//            }
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showPhotoFrameView:)]) {
//                [self.delegate showPhotoFrameView:NO];
//            }
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showAddImageView:)]) {
//                [self.delegate showAddImageView:NO];
//            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
                [self.delegate showBorderAndColorView:YES];
            }
            
        }
            break;
//        case 1:
//        {
////            if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenPromptView)]) {
////                [self.delegate hiddenPromptView];
////            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
//                [self.delegate showBorderAndColorView:NO];
//            }
//            
////            if (self.delegate && [self.delegate respondsToSelector:@selector(showAddImageView:)]) {
////                [self.delegate showAddImageView:NO];
////            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showPhotoFrameView:)]) {
//                [self.delegate showPhotoFrameView:YES];
//            }
//        }
//            break;
//        case 2:
//        {
//            if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenPromptView)]) {
//                [self.delegate hiddenPromptView];
//            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
//                [self.delegate showBorderAndColorView:NO];
//            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showPhotoFrameView:)]) {
//                [self.delegate showPhotoFrameView:NO];
//            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showAddImageView:)]) {
//                [self.delegate showAddImageView:YES];
//            }
//        }
//            break;
        default:
            break;
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
