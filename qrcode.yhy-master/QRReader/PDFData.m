//
//  PDFData.m
//  QRReader
//
//  Created by awt on 15/8/3.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "PDFData.h"

@implementation PDFData
@synthesize count;
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bookArray forKey:@"bookArray"];
    [aCoder encodeObject:self.count forKey:@"count"];
    
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [self init]) {
        self.bookArray = [aDecoder decodeObjectForKey:@"bookArray"];
        self.count = [aDecoder decodeObjectForKey:@"count"];
       
    }
    return self;
}

@end
