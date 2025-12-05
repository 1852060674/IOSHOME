//
//  DyeTopView.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/1.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoDyeTopView : UIView
// 0 - back; 1 - undo; 2 - redo; 3 - next;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *topToolBtns;

@property (nonatomic, copy) void(^actions)(NSInteger index);
@end
