//
//  MyScrollView.m
//  PhotoBooth
//
//  Created by  on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyScrollView.h"

@implementation MyScrollView

//@synthesize MyDelegate = MyDelegate_;
@synthesize image_view;
@synthesize mask_view;


-(BOOL) isInThisArea:(CGPoint )point
           ThisArea : (CGRect )area
{
    BOOL return_value = FALSE;
    
    if (point.x >= area.origin.x
        && point.y >= area.origin.y
        && point.x <= area.origin.x + area.size.width
        && point.y <= area.origin.y + area.size.height) 
    {
        return_value = TRUE;
    }
    
    return return_value;
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"my scroll view touched begin");
    [super touchesBegan:touches withEvent:event];
    [self.superview touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    //NSLog(@"touch begin = %d, touch count=%d", touch.tapCount, touches.count);
    if ([touches count]==1
        && [self isInThisArea:[touch locationInView:self] ThisArea:image_view.frame])
    {
        startLoc = [touch locationInView:self];
    }
    
    
  /*  
    if ([MyDelegate_ respondsToSelector:@selector(MyScrollView:touchBegin:withEvent:)])
        //(MyScrollView:touchBegin:withEvent:)]) 
    {
        [MyDelegate_ MyScrollView:self touchBegin:touches withEvent:event];
    }
    else
    {
        NSLog(@"cant find");
    }
   */
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"my scroll view touched moved");
    
    [super touchesMoved:touches withEvent:event];
    [self.superview touchesMoved:touches withEvent:event];
    
    if ([touches count]>1) 
    {
        return ;
    }
    
    UITouch *touch = [[event allTouches] anyObject];
    //int clickCount = [touch tapCount];
    
    //NSLog(@"touch moved");
    
    // uilabel的点击
    //if (touch.view == imageWords)
    if ([self isInThisArea:[touch locationInView:self] ThisArea:image_view.frame])
    {
        //NSLog(@"Movied in *****");
        endLoc = [touch locationInView:self];
        
        //需要滑动一定距离才算，避免误操作
        float dist = sqrtf((endLoc.x - startLoc.x) * (endLoc.x - startLoc.x) + (endLoc.y - startLoc.y) * (endLoc.y - startLoc.y));
        
        //UITouch *touch = [touches anyObject];
        //int clickCount = [touch tapCount];
        
        if (dist > 5.0 && dist<50)
        {
            //NSLog(@"**** x=%f", endLoc.x);
            
            float x_new = image_view.frame.origin.x + endLoc.x - startLoc.x;
            
            float y_new = image_view.frame.origin.y + endLoc.y - startLoc.y;
            
            image_view.frame = CGRectMake(x_new, y_new, image_view.frame.size.width, image_view.frame.size.height);
            mask_view.frame = image_view.frame;
            startLoc = endLoc;
        }
        
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"my scroll view touched end");
    [super touchesEnded:touches withEvent:event];
    [self.superview touchesEnded:touches withEvent:event];
    
    if ([touches count]>1) 
    {
        return ;
    }
    
    
    //需要滑动一定距离才算，避免误操作
    float dist = sqrtf((endLoc.x - startLoc.x) * (endLoc.x - startLoc.x) + (endLoc.y - startLoc.y) * (endLoc.y - startLoc.y));
    
    UITouch *touch = [touches anyObject];
    //int clickCount = [touch tapCount];
    
    if (dist > 5.0 
        && [self isInThisArea:[touch locationInView:self] ThisArea:image_view.frame])
    {
        float x_new = image_view.frame.origin.x + endLoc.x - startLoc.x;
        float y_new = image_view.frame.origin.y + endLoc.y - startLoc.y;
        
        x_new = x_new<=0?0:x_new;
        y_new = y_new<=0?0:y_new;
        
        image_view.frame = CGRectMake(x_new, y_new, image_view.frame.size.width, image_view.frame.size.height);
        mask_view.frame = image_view.frame;
    }
    
}

/*
- (void) drawRect:(CGRect)rect
{
    CGContextRef context =UIGraphicsGetCurrentContext();  
    CGContextBeginPath(context);  
    CGContextSetLineWidth(context, 2.0);  
    CGRect rectangle = CGRectMake(60,170,200,80);
    
    CGContextAddRect(context, rectangle);
    
    CGContextStrokePath(context);  
    CGContextClosePath(context); 
}
*/

@end
