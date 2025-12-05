//
//  resultTableView.h
//  QRReader
//
//  Created by awt on 15/8/5.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol reusltTabView <NSObject>


@end
@interface ResultTableView : NSObject <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSString *code;
@property  BOOL isWeb;
@property (nonatomic,strong) NSMutableArray *cell;
@end
