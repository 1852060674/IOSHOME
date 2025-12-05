//
//  LoadPhotoView.h
//  HairColor
//
//  Created by ZB_Mac on 2016/11/22.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadPhotoView : UIView
-(void)showBtn:(BOOL)show animated:(BOOL)animated completionAction:(void (^)(BOOL))completion;

@property (nonatomic, copy) void(^actions)(NSInteger loadPhotoMethod);
@end
