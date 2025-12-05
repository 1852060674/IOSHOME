//
//  QRGenerator.h
//  QRReader
//
//  Created by awt on 15/7/21.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRGenerator : UIImage

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size ;
@end
