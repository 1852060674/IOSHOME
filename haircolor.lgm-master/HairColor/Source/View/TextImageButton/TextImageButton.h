//
//  TextImageButton.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/8/26.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextImageButton : UIControl
-(void)setText:(NSString *)text;
-(NSString *)getText;
-(void)setTextColor:(UIColor *)textColor;

-(void)setImage:(UIImage *)image;
-(UIImage *)getImage;
-(void)rotateImageUp:(BOOL)up animated:(BOOL)animated;

@end
