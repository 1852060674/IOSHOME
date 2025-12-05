//
//  ProtocolAlerView.h
//  HairColor
//
//  Created by 黄怡荣 on 2023/3/9.
//  Copyright © 2023 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProtocolAlerView : UIView
//弹框内容
@property (nonatomic, copy) NSString *strContent;
//@property (nonatomic, strong) MGPaintViewController *mGPaintViewController;

- (void)showAlert:(UIViewController *)vc cancelAction:(void (^ _Nullable)(id _Nullable object))cancelAction  privateAction:(void (^ _Nullable)(id _Nullable object))privateAction delegateAction:(void (^ _Nullable)(id _Nullable object))delegateAction;
@end

NS_ASSUME_NONNULL_END
