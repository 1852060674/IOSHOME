//
//  ZBBottomBar.m
//  Collage
//
//  Created by shen on 13-6-24.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBBottomBar.h"
#import "ZBCommonDefine.h"
#import "ImageUtil.h"
#import "ZBColorDefine.h"

@interface ZBBottomBar()
{
    float _bottomBarWidth;
    UISegmentedControl *segmentedControl;
}

@end

@implementation ZBBottomBar
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (IS_IPAD) {
            _bottomBarWidth = 400;
        }
        else
            _bottomBarWidth = kBottomBarWidth;
        
        self.backgroundColor = kTransparentColor;
        
        NSArray *objects = [NSArray arrayWithObjects:@"Template", @"Sticker", @"Aspect", @"Border",nil];
        
        segmentedControl=[[UISegmentedControl alloc] initWithItems:objects];
        segmentedControl.frame = CGRectMake((kScreenWidth-_bottomBarWidth)/2, 0, _bottomBarWidth, self.frame.size.height);
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        if (!IS_IPAD) {
            segmentedControl.tintColor= kBottomBarColor;
        }
        
        segmentedControl.momentary = YES;
//        [segmentedControl setSelectedSegmentIndex:0];
        segmentedControl.multipleTouchEnabled=NO;
        
        [segmentedControl addTarget:self action:@selector(clickSegmentAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:segmentedControl];
        segmentedControl.backgroundColor = [UIColor whiteColor];//kTransparentColor;
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
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSmilingFaceView:)]) {
                [self.delegate showSmilingFaceView:NO];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showAspectView:)]) {
                [self.delegate showAspectView:NO];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
                [self.delegate showBorderAndColorView:NO];
            }
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showPhotoFrameView:)]) {
//                [self.delegate showPhotoFrameView:NO];
//            }
            
            //显示笑脸view
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSpecificTemplateView:)]) {
                [self.delegate showSpecificTemplateView:YES];
            }
            
        }
            break;
        case 1:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSpecificTemplateView:)]) {
                [self.delegate showSpecificTemplateView:NO];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showAspectView:)]) {
                [self.delegate showAspectView:NO];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
                [self.delegate showBorderAndColorView:NO];
            }
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showPhotoFrameView:)]) {
//                [self.delegate showPhotoFrameView:NO];
//            }
            
            //显示笑脸view
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSmilingFaceView:)]) {
                [self.delegate showSmilingFaceView:YES];
            }

        }
            break;
        case 2:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSpecificTemplateView:)]) {
                [self.delegate showSpecificTemplateView:NO];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSmilingFaceView:)]) {
                [self.delegate showSmilingFaceView:NO];
            }
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showPhotoFrameView:)]) {
//                [self.delegate showPhotoFrameView:NO];
//            }
            
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
                [self.delegate showBorderAndColorView:NO];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenAllDeleteSmilingFaceIcon)]) {
                [self.delegate hiddenAllDeleteSmilingFaceIcon];
            }
            
            //显示aspect view
            if (self.delegate && [self.delegate respondsToSelector:@selector(showAspectView:)]) {
                [self.delegate showAspectView:YES];
            }
        }
            break;
//        case 3:
//        {
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showSpecificTemplateView:)]) {
//                [self.delegate showSpecificTemplateView:NO];
//            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showSmilingFaceView:)]) {
//                [self.delegate showSmilingFaceView:NO];
//            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showAspectView:)]) {
//                [self.delegate showAspectView:NO];
//            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showBorderAndColorView:)]) {
//                [self.delegate showBorderAndColorView:NO];
//            }
//            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(hiddenAllDeleteSmilingFaceIcon)]) {
//                [self.delegate hiddenAllDeleteSmilingFaceIcon];
//            }
//            
//            //显示PhotoFrame view
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showPhotoFrameView:)]) {
//                [self.delegate showPhotoFrameView:YES];
//            }
//        }
//            break;
        case 3:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSpecificTemplateView:)]) {
                [self.delegate showSpecificTemplateView:NO];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showSmilingFaceView:)]) {
                [self.delegate showSmilingFaceView:NO];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(showAspectView:)]) {
                [self.delegate showAspectView:NO];
            }
            
//            if (self.delegate && [self.delegate respondsToSelector:@selector(showPhotoFrameView:)]) {
//                [self.delegate showPhotoFrameView:NO];
//            }
            
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
