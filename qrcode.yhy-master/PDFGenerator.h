//
//  PDFGenerator.h
//  QRReader
//
//  Created by awt on 15/7/22.
//  Copyright (c) 2015年 awt. All rights reserved.
//


#import <UIKit/UIKit.h>
@interface PDFGenerator : NSObject

+(void)drawPDF:(NSString *)fileName with : (NSMutableArray *)array atSize :(CGSize) fileSize;

@end
