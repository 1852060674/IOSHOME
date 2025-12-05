//
//  T.m
//  PlutoLand
//
//  Created by xu xhan on 7/16/10.
//  Copyright 2010 xu han. All rights reserved.
//

#import "UIHelper.h"



@implementation UIHelper

+ (UIButton*)createBtnfromPoint:(CGPoint)point imageStr:(NSString*)imgstr target:(id)target selector:(SEL)selector;
{
	UIImage* img = [UIImage imageNamed:imgstr];
	return [self createBtnfromPoint:point image:img target:target selector:selector];
}


+ (UIButton*)createBtnfromPoint:(CGPoint)point imageStr:(NSString*)imgstr highlightImgStr:(NSString*)himgstr target:(id)target selector:(SEL)selector;
{
	UIImage* img = [UIImage imageNamed:imgstr];
	UIImage* imgHighlight = [UIImage imageNamed:himgstr];
	return [self createBtnfromPoint:point image:img highlightImg:imgHighlight target:target selector:selector];
}


+ (UIButton*)createBtnfromPoint:(CGPoint)point image:(UIImage*)img target:(id)target selector:(SEL)selector
{
	UIButton *abtn = [ [UIButton alloc] initWithFrame:CGRectMake(point.x,point.y ,img.size.width,img.size.height)];
	abtn.backgroundColor = [UIColor clearColor];
	[abtn setBackgroundImage:img forState:UIControlStateNormal];
	[abtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	return abtn;	
}


+ (UIButton*)createBtnfromPoint:(CGPoint)point image:(UIImage*)img highlightImg:(UIImage*)himg target:(id)target selector:(SEL)selector
{
	UIButton *abtn = [[UIButton alloc] initWithFrame:CGRectMake(point.x,point.y ,img.size.width,img.size.height)];
	abtn.backgroundColor = [UIColor clearColor];
	[abtn setBackgroundImage:img forState:UIControlStateNormal];
	[abtn setBackgroundImage:himg forState:UIControlStateHighlighted];
	[abtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
	return abtn;	
}


+ (UIBarButtonItem *)createBackBarItem:(id)target action:(SEL)selector
{
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 53, 32)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back_btn_nor.png"]
                   forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"back_btn_down.png"]
                   forState:UIControlStateHighlighted];
    [btn addTarget:target
            action:selector
  forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return back;
}

+ (UIBarButtonItem *)createWithTarget:(id)target 
            selector:(SEL)selector 
backgroundImageStateNormal:(NSString*)imageFile
backgroundImageStateHighlighted:(NSString*)imageFileHighlighted
               frame:(CGRect)frameBar
{
    UIButton * btn = [[UIButton alloc] initWithFrame:frameBar];
    [btn setBackgroundImage:[UIImage imageNamed:imageFile]
                   forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:imageFileHighlighted]
                   forState:UIControlStateHighlighted];
    [btn addTarget:target
            action:selector
  forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    return back;
}

// 文本颜色 353535
+ (UIColor *)getTextColor353535
{
    return [UIColor colorWithRed:0x35/255.0 
                           green:0x35/255.0 
                            blue:0x35/255.0 
                           alpha:1.0f];
}

+ (UIColor*)colorR:(float)r g:(float)g b:(float)b
{
	return [self colorR:r g:g b:b a:1];
}

//alpha from 0 to 1
+ (UIColor*)colorR:(float)r g:(float)g b:(float)b a:(float)a
{
	return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a];
}

+ (UIImage*)imageNamed:(NSString*)fileName
{
    BOOL isHighResolution = NO;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([UIScreen mainScreen].scale > 1) {
            isHighResolution = YES;  
        }
    }
    
    if (isHighResolution) {
        NSArray* array = [fileName componentsSeparatedByString:@"."];
        fileName = [array componentsJoinedByString:@"@2x."];
    }
	NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];   
//	UIImage* i = [UIImage imageWithContentsOfFile:path];
	return [UIImage imageWithContentsOfFile:path];
}

+ (UIImageView*)imageViewNamed:(NSString*)fileName
{
	UIImageView* imageview = [[UIImageView alloc] initWithImage:[self imageNamed:fileName]];
	return imageview;
}


+ (NSString*)randomName
{
	return	[NSString stringWithFormat:@"%.2lf",[[NSDate date] timeIntervalSince1970]];
}


+(UILabel*)customeLabel
{
    CGRect frame = CGRectMake((320 - 130)/2, 0, 130, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame]; 
    label.backgroundColor = [UIColor clearColor]; 
//    label.font = [UIFont boldSystemFontOfSize:20.0]; 
//    label.shadowColor = [UIColor colorWithRed:(float)0x00ff/255.0
//                                        green: (float)0x00ff/255.0
//                                         blue:(float)0x00ff/255.0 alpha:0.53];
//    label.shadowOffset = CGSizeMake(1, 1);
    label.textAlignment = UITextAlignmentCenter; 
//    label.textColor = [UIColor colorWithRed:(float)0x0030/255.0
//                                      green: (float)0x0084/255.0
//                                       blue:(float)0x00ce/255.0 alpha:1]; 
    label.textColor = [UIColor whiteColor];
    
    return label ;

}

+(NSArray*)loadUIFromNibFile:(NSString*)strFileName
{
    if(strFileName == nil)
    {
        return nil;
    }
    
    NSArray* arrs = [[NSBundle mainBundle] loadNibNamed:strFileName
                                                  owner:self
                                                options:nil];
    
    return arrs;
}

+(id)createNavBarButtonItem:(NSString*)imageFile 
                 andHilight:(NSString*)hlightedImage
                andSelector:(SEL)sel
                  andTarget:(id)target
{
    if(imageFile == nil)
    {
        return nil;
    }
    
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *refreshImg = [UIHelper imageNamed:imageFile];
    [refreshButton setFrame:CGRectMake(10, 0, refreshImg.size.width, refreshImg.size.height)];
    [refreshButton setBackgroundImage:refreshImg
                   forState:UIControlStateNormal];
    [refreshButton addTarget:target
                      action:sel
            forControlEvents:UIControlEventTouchUpInside];
    
    //refreshButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 5,0);
//    refreshButton.titleLabel.text = @"提问";
//    [refreshButton setTitle:@"提问" forState:UIControlStateNormal];
////    refreshButton.bounds 

    if(hlightedImage)
    {
        [refreshButton setImage:[UIHelper imageNamed:hlightedImage]
                       forState:UIControlStateHighlighted];
    }
    
    return [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
}


+(id)createNavBarButtonItem:(NSString*)imageFile 
             andHilight:(NSString*)hlightedImage 
                  title:(NSString *)title 
                   font:(UIFont *)font
                  color:(NSDictionary *)colorDic
          buttonOffset:(CGSize)buttonOffset
    OffsetROrientation:(BOOL)rightOrientation
                  navH:(float)navH
           shadowOffset:(CGSize)shadowOffset 
            andSelector:(SEL)sel 
              andTarget:(id)target
{
    float w = buttonOffset.width;
    float h = buttonOffset.height;
    if(buttonOffset.width < 0)
    {
        w = -buttonOffset.width;
    }
    if(buttonOffset.height < 0)
    {
        h = -buttonOffset.height; 
    }
  UIButton *button = [UIHelper createCommonButton:imageFile 
                      andHilight:hlightedImage 
                           title:title 
                            font:font 
                           color:colorDic 
                    shadowOffset:shadowOffset 
                      startPoint:CGPointMake(rightOrientation ? w : 0, h) 
                     andSelector:sel 
                       andTarget:target];
    
    
   UIView *bgV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, button.frame.size.width + w, navH)];
    [bgV setBackgroundColor:[UIColor clearColor]];
    [bgV addSubview:button];
   UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:bgV];
    return buttonItem;
}


+(id)createCommonButton:(NSString*)imageFile 
             andHilight:(NSString*)hlightedImage 
                  title:(NSString *)title 
                   font:(UIFont *)font
                  color:(NSDictionary *)colorDic
           shadowOffset:(CGSize)shadowOffset 
             startPoint:(CGPoint)startPoint
            andSelector:(SEL)sel 
              andTarget:(id)target
{
    if(imageFile == nil)
    {
        return nil;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *bgImg = [UIHelper imageNamed:imageFile];
    [button setFrame:CGRectMake(startPoint.x, startPoint.y, bgImg.size.width, bgImg.size.height)];
    [button setBackgroundImage:bgImg forState:UIControlStateNormal];
    
    if(hlightedImage)
    {
        [button setBackgroundImage:[UIHelper imageNamed:hlightedImage]
                       forState:UIControlStateHighlighted];
    }
    
    [button setTitle:title forState:UIControlStateNormal];
   if(colorDic) 
   {
       UIColor *color = [colorDic objectForKey:BUTTON_TITLE_COLOR_FOR_NORMAL];
        if(color)
        {
          [button setTitleColor:color forState:UIControlStateNormal];
        }
       color = [colorDic objectForKey:BUTTON_TITLE_COLOR_FOR_HIGHTLIGHT];
       if(color)
       {
           [button setTitleColor:color forState:UIControlStateHighlighted];  
       }
       color = [colorDic objectForKey:BUTTON_TITLE_SHADOW_COLOR_FOR_NORMAL];
       if(color)
       {
           [button setTitleShadowColor:color forState:UIControlStateNormal];
   
       }
       color = [colorDic objectForKey:BUTTON_TITLE_SHADOW_COLOR_FOR_HIGHTLIGHT];
       if(color)
       {
           [button setTitleShadowColor:color forState:UIControlStateHighlighted];  
       }
        
   }
    
    button.titleLabel.shadowOffset = shadowOffset;
    if(font)
    {
     [button.titleLabel setFont:font];
    }
    if(target && sel)
    {
        [button addTarget:target
                   action:sel
         forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

+(UILabel*)customeNavTitleLableWithFrame:(CGRect)frame
                                   title:(NSString *)title 
                             shadowColor:(UIColor *)shadowColor 
                               textcolor:(UIColor *)textcolor 
                                    font:(UIFont *)font 
                            shadowOffset:(CGSize)shadowOffset
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame]; 
    label.backgroundColor = [UIColor clearColor]; 
    label.textAlignment = UITextAlignmentCenter; 
    if(textcolor)
    {
      label.textColor = textcolor;
    }
    if(font)
    {
     [label setFont:font];
    }
    if(title)
    {
      [label setText:title];
    }
    if(shadowColor)
    {
     label.shadowColor = shadowColor;
     label.shadowOffset = shadowOffset;
    }
    
    return label;
    
}
+(id)colorButtonData {

    NSDictionary *colorDic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:60.0f/255.0f green:127.0f/255.0f blue:27.0f/255.0f alpha:1],
                              BUTTON_TITLE_COLOR_FOR_NORMAL,
                              [UIColor colorWithRed:27.0f/255.0f green:58.0f/255.0f blue:12.0f/255.0f alpha:1],
                              BUTTON_TITLE_COLOR_FOR_HIGHTLIGHT,
                              [UIColor colorWithRed:138.0f/255.0f green:208.0f/255.0f blue:91.0f/255.0f alpha:1],BUTTON_TITLE_SHADOW_COLOR_FOR_NORMAL,
                              [UIColor colorWithRed:67.0f/255.0f green:103.0f/255.0f blue:44.0f/255.0f alpha:1],
                              BUTTON_TITLE_SHADOW_COLOR_FOR_HIGHTLIGHT,
                              nil];
    
    return colorDic;

}

@end
