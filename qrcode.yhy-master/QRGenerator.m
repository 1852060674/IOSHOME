//
//  QRGenerator.m
//  QRReader
//
//  Created by awt on 15/7/21.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import "QRGenerator.h"
#import "qrencode.h"
enum {
    qr_margin = 3
};

@implementation QRGenerator

+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size {
    unsigned char *data = 0;
    int width;
    data = code->data;
    width = code->width;
    float zoom = (double)size / (code->width + 2.0 * qr_margin);
    CGRect rectDraw = CGRectMake(0, 0, zoom, zoom);
    
    // draw
    CGContextSetFillColor(ctx, CGColorGetComponents([UIColor blackColor].CGColor));
    for(int i = 0; i < width; ++i) {
        for(int j = 0; j < width; ++j) {
            if(*data & 1) {
                rectDraw.origin = CGPointMake((j + qr_margin) * zoom,(i + qr_margin) * zoom);
                CGContextAddRect(ctx, rectDraw);
            }
            ++data;
        }
    }
    CGContextFillPath(ctx);
}

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size {
    if (![string length]) {
        return nil;
    }
    
    QRcode *code = QRcode_encodeString([string UTF8String], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
    if (!code) {
        return nil;
    }
    unsigned char *data = 0;
    int width;
    data = code->data;
    width = code->width;
    // create context;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    float zoom = size/(width +4);
     CGRect rectDraw = CGRectMake(0, 0, size, size);
    CGContextSetFillColor(context, CGColorGetComponents([UIColor whiteColor].CGColor));
    CGContextFillRect(context, rectDraw);
    CGContextSetFillColor(context, CGColorGetComponents([UIColor blackColor].CGColor));
    rectDraw = CGRectMake(0, 0, zoom, zoom);
    for(int i = 0; i < width; ++i) {
        for(int j = 0; j < width; ++j) {
            if(*data & 1) {
                rectDraw.origin = CGPointMake((j + 2 ) * zoom,(i  +2) * zoom);
                CGContextAddRect(context, rectDraw);
            }
            ++data;
        }
    }
    CGContextFillPath(context);
    UIImage *qrImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    QRcode_free(code);
    UIImageWriteToSavedPhotosAlbum(qrImage, self, nil, nil);
    return qrImage;
}
@end
