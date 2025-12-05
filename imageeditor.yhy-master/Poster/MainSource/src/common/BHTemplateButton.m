//
//  BHTemplateButton.m
//  PicFrame
//
//  Created by shen on 13-6-14.
//  Copyright (c) 2013年 BoHai. All rights reserved.
//

#import "BHTemplateButton.h"
#import "ImageUtil.h"

@interface BHTemplateButton()
{
   
}
@property (nonatomic, strong) UIImageView *checkmarkImageView;

@end

@implementation BHTemplateButton

@synthesize checkmarkImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // Position the checkmark image in the bottom right corner
        CGFloat x = 0;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            x = frame.size.width-28-20;
        }
        else
        {
            x = frame.size.width-20;
        }
        self.checkmarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, x, 28, 28)];
        self.checkmarkImageView.image = [ImageUtil loadResourceImage:@"BH-Checkmark-iPhone"];
        self.checkmarkImageView.hidden = YES;
		[self addSubview:self.checkmarkImageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected
{
//    self.selectionView.hidden = !selected;
    self.checkmarkImageView.hidden = !selected;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    CGPoint _startPoint = [[touches anyObject] locationInView:self];
//    NSLog(@"%f,%f",_startPoint.x,_startPoint.y);
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//    CGPoint _startPoint = [[touches anyObject] locationInView:self];
//    NSLog(@"moved %f,%f",_startPoint.x,_startPoint.y);
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
