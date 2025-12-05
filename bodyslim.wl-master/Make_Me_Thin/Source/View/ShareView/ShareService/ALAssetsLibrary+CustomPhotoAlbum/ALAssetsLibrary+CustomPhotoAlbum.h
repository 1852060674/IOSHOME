//
//  ALAssetsLibrary+CustomPhotoAlbum.h
//  cutout
//
//  Created by ZB_Mac on 16/4/5.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
typedef void(^SaveImageCompletion)(NSError* error);

@interface ALAssetsLibrary (CustomPhotoAlbum)
-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock;

@end
