//
//  IAPViewController.h
//
//  Modify by cloud on  2014-06-04
//  Copyright (c) 2014年 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBPurchase.h"


@interface IAPViewController : UIViewController<EBPurchaseDelegate>

@property (nonatomic, strong) NSString *product_id;

- (void)restore;
- (void)purchase;
- (void)purchase:(NSString*)product_id;
- (id) initWithProductID:(NSString*)product_id login:(int) loginTimes;

@end
