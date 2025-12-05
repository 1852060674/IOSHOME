//
//  EditTopView.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/9/7.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareTopView : UIView

// 0 - back; 3 - share;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *topBtns;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, copy) void(^actions)(NSInteger index);
@end
