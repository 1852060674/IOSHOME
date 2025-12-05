//
//  T.h
//  PlutoLand
//
//  Created by J.Horn on 7/16/10.
//  Copyright 2010 Baidu.com. All rights reserved.
//

/*
 an global helper class, all the methods inside should be class method.
 */


#import <Foundation/Foundation.h>

#define NAV_Lelf_OR_RIGHT_BUTTON_OFFSET 3.5

#define BUTTON_TITLE_COLOR_FOR_NORMAL  @"titleColorForNormal"
#define BUTTON_TITLE_COLOR_FOR_HIGHTLIGHT  @"titleColorForHighlight"
#define BUTTON_TITLE_SHADOW_COLOR_FOR_NORMAL  @"titleShadowColorForNormal"
#define BUTTON_TITLE_SHADOW_COLOR_FOR_HIGHTLIGHT  @"titleShadowColorForHighlight"

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@interface UIHelper : NSObject 

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIButton


+ (UIButton*)createBtnfromPoint:(CGPoint)point image:(UIImage*)img target:(id)target selector:(SEL)selector; 

+ (UIButton*)createBtnfromPoint:(CGPoint)point image:(UIImage*)img highlightImg:(UIImage*)himg target:(id)target selector:(SEL)selector; 

+ (UIButton*)createBtnfromPoint:(CGPoint)point imageStr:(NSString*)imgstr target:(id)target selector:(SEL)selector; 

+ (UIButton*)createBtnfromPoint:(CGPoint)point imageStr:(NSString*)imgstr highlightImgStr:(NSString*)himgstr target:(id)target selector:(SEL)selector; 

// 创建返回按钮，仅用于TM项目
+ (UIBarButtonItem *)createBackBarItem:(id)target action:(SEL)selector;

+ (UIBarButtonItem *)createWithTarget:(id)target 
            selector:(SEL)selector 
backgroundImageStateNormal:(NSString*)imageFile
backgroundImageStateHighlighted:(NSString*)imageFileHighlighted
               frame:(CGRect)frameBar;

// 文本颜色 353535
+ (UIColor *)getTextColor353535;

// each value comes from 0 to 255
+ (UIColor*)colorR:(float)r g:(float)g b:(float)b;

//alpha from 0 to 1
+ (UIColor*)colorR:(float)r g:(float)g b:(float)b a:(float)a;

//load image by contents of file
+ (UIImage*)imageNamed:(NSString*)fileName;

+ (UIImageView*)imageViewNamed:(NSString*)fileName;

/* return an random string powered by UTSC seconds */
+ (NSString*)randomName;

+(UILabel*)customeLabel;


+(NSArray*)loadUIFromNibFile:(NSString*)strFileName;

+(id)createNavBarButtonItem:(NSString*)imageFile 
                 andHilight:(NSString*)hlightedImage
                andSelector:(SEL)sel
                  andTarget:(id)target;

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
                  andTarget:(id)target;
+(id)createCommonButton:(NSString*)imageFile 
             andHilight:(NSString*)hlightedImage 
                  title:(NSString *)title 
                   font:(UIFont *)font
                  color:(NSDictionary *)colorDic
           shadowOffset:(CGSize)shadowOffset 
             startPoint:(CGPoint)startPoint
            andSelector:(SEL)sel 
              andTarget:(id)target;

+(UILabel*)customeNavTitleLableWithFrame:(CGRect)frame
                                   title:(NSString *)title 
                             shadowColor:(UIColor *)shadowColor 
                               textcolor:(UIColor *)textcolor 
                                    font:(UIFont *)font 
                            shadowOffset:(CGSize)shadowOffset;
+(id)colorButtonData;

@end
