//
//  CutoutTopView.h
//  HairColorNew
//
//  Created by ZB_Mac on 16/8/26.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CutoutTopView : UIView
// UIBttons
// 0 - back; 1 - next;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *topToolBtns;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (nonatomic, copy) void(^actions)(NSInteger index);
@end
