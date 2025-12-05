//
//  CreateCustomColorView.h
//  HairColor
//
//  Created by ZB_Mac on 15/5/13.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreateCustomColorView;

@protocol CreateCustomColorViewDelegate <NSObject>

-(void)createCustomColorView:(CreateCustomColorView *)view didFinishCreateColor:(UIColor *)color;
-(void)createCustomColorViewDidCancel:(CreateCustomColorView *)view;

@end

@interface CreateCustomColorView : UIView

@property (weak, nonatomic) id<CreateCustomColorViewDelegate>delegate;

@end
