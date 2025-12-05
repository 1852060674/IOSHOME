//
//  PDFGenerator.m
//  QRReader
//
//  Created by awt on 15/7/22.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "PDFGenerator.h"

@implementation PDFGenerator

+ (void)drawPDF:(NSString*)fileName with : (NSMutableArray *)array atSize : (CGSize) fileSize
{
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(fileName, CGRectZero, nil);
    //CGContextRef context = UIGraphicsGetCurrentContext();
//UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, fileSize.width ,fileSize.height), nil);
    for (UIImage *image in array) {
         UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, fileSize.width ,fileSize.height), nil);
    
         [image drawInRect:CGRectMake(0, 0, fileSize.width, fileSize.height)];
    }
   
    //[] Close the PDF context and write the contents out.
    //UIGraphicsEndPDFContext();
    UIGraphicsEndPDFContext();
}
@end
