//
//  HistoryData.m
//  QRReader
//
//  Created by awt on 15/7/23.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "HistoryData.h"

@implementation HistoryData

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.codeType forKey:@"type"];
    [aCoder encodeObject:self.codeNumber forKey:@"number"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.next forKey:@"next"];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [self init]) {
        self.codeType = [aDecoder decodeObjectForKey:@"type"];
        self.codeNumber = [aDecoder decodeObjectForKey:@"number"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.next = [aDecoder decodeObjectForKey:@"next"];
    }
    return self;
}

@end
