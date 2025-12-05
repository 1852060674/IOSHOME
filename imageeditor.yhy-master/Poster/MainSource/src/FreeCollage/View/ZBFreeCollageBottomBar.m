//
//  ZBFreeCollageBottomBar.m
//  Collage
//
//  Created by shen on 13-6-25.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBFreeCollageBottomBar.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBFreeCollageBottomBar()
{
    float _bottomBarWidth;
}

@end

@implementation ZBFreeCollageBottomBar

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (IS_IPAD) {
            _bottomBarWidth = 300;
        }
        else
            _bottomBarWidth = 225;
        
        self.backgroundColor = kTransparentColor;
        
        NSArray *objects = [NSArray arrayWithObjects:@"Sticker", @"Background", @"Border",nil];
        
        UISegmentedControl *segmentedControl=[[UISegmentedControl alloc] initWithItems:objects];
        segmentedControl.frame = CGRectMake((kScreenWidth-_bottomBarWidth)/2, 0, _bottomBarWidth, self.frame.size.height);
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        segmentedControl.momentary = YES;
        segmentedControl.multipleTouchEnabled=NO;
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
    //    [_collageMainView turnGridAndFreeCollageViewAnimation:_segControl.selectedSegmentIndex];
    switch (_segControl.selectedSegmentIndex) {
        case 0:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSpecificTemplateView:)]) {
                [self.delegate showBackGroundImageView:NO];
            }
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showAspectView:)]) {
//                [self.delegate showAspectView:NO];
//            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
                [self.delegate showBorderAndColorView:NO];
            }

            
            //显示笑脸view
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSmilingFaceView:)]) {
                [self.delegate showSmilingFaceView:YES];
            }
            
        }
            break;
//        case 1:
//        {
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showSmilingFaceView:)]) {
//                [self.delegate showSmilingFaceView:NO];
//            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showPhotoFrameView:)]) {
//                [self.delegate showBackGroundImageView:NO];
//            }
//            
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
//                [self.delegate showBorderAndColorView:NO];
//            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenAllDeleteSmilingFaceIcon)]) {
//                [self.delegate hiddenAllDeleteSmilingFaceIcon];
//            }
//            
//            //显示aspect view
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showAspectView:)]) {
//                [self.delegate showAspectView:YES];
//            }
//        }
//            break;
        case 1:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSmilingFaceView:)]) {
                [self.delegate showSmilingFaceView:NO];
            }
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showAspectView:)]) {
//                [self.delegate showAspectView:NO];
//            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
                [self.delegate showBorderAndColorView:NO];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenAllDeleteSmilingFaceIcon)]) {
                [self.delegate hiddenAllDeleteSmilingFaceIcon];
            }
            
            //显示PhotoFrame view
            if (self.delegate && [self.delegate respondsToSelector:@selector(showBackGroundImageView:)]) {
                [self.delegate showBackGroundImageView:YES];
            }
        }
            break;
        case 2:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSmilingFaceView:)]) {
                [self.delegate showSmilingFaceView:NO];
            }
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showAspectView:)]) {
//                [self.delegate showAspectView:NO];
//            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showBackGroundImageView:)]) {
                [self.delegate showBackGroundImageView:NO];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenAllDeleteSmilingFaceIcon)]) {
                [self.delegate hiddenAllDeleteSmilingFaceIcon];
            }
            
            //显示BorderAndColor view
            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
                [self.delegate showBorderAndColorView:YES];
            }
        }
            break;
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
