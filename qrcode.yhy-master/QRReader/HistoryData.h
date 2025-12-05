//
//  HistoryData.h
//  QRReader
//
//  Created by awt on 15/7/23.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryData : NSObject<NSCoding>
@property (nonatomic, strong) NSString *codeType;
@property (nonatomic,strong) NSString *codeNumber;
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) HistoryData *next;
@end
