//
//  ProtocolAlerView.h
//  HairColor
//
//  Created by 黄怡荣 on 2023/3/9.
//  Copyright © 2023 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProtocolAlerView : UIView
@property (nonatomic, strong) ViewController *ViewController;
//弹框内容
@property (nonatomic, copy) NSString *strContent;

- (void)showAlert:(UIViewController *)vc cancelAction:(void (^ _Nullable)(id _Nullable object))cancelAction  privateAction:(void (^ _Nullable)(id _Nullable object))privateAction delegateAction:(void (^ _Nullable)(id _Nullable object))delegateAction;
- (void)alterSpades:(ViewController*)hc;
@end

NS_ASSUME_NONNULL_END
