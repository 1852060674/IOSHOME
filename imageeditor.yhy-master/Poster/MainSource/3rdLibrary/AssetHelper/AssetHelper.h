//
//  AssetHelper.m
//  DoImagePickerController
//
//  Created by Donobono on 2014. 1. 23..
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#define ASSETHELPER    [AssetHelper sharedAssetHelper]

#define ASSET_PHOTO_THUMBNAIL           0
#define ASSET_PHOTO_SCREEN_SIZE         1
#define ASSET_PHOTO_FULL_RESOLUTION     2

const static BOOL usePHAsset = YES;

@interface AssetHelper : NSObject

- (void)initAsset;

@property (readwrite)           BOOL                    bReverse;

+ (AssetHelper *)sharedAssetHelper;

-(BOOL)canAccessLibrary;
// get album list from asset
//- (void)getGroupList:(void (^)(NSArray *))result;
- (void)getGroupList:(void (^)(NSInteger))result;
// get photos from specific album with index of album array
- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(void))result;

- (NSInteger)getGroupCount;
- (NSInteger)getPhotoCountOfCurrentGroup;
- (NSDictionary *)getGroupInfo:(NSInteger)nIndex;

- (void)getGroupInfo:(NSInteger)nIndex withCompletionHandler:(void (^)(NSDictionary *))endHandler;
- (void)clearData;

// utils
//- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(NSInteger)nType;

// new utils for compatible of PHAsset
- (void)getImageAtIndex:(NSInteger)nIndex targetSize:(CGSize)targetSize type:(NSInteger)nType withStartHandler:(void (^)(NSString *))startHandler withCompletionHandler:(void (^)(NSString *, UIImage *))endHandler;

-(NSString *)getAssetIdentifierAtIndex:(NSInteger)nIndex;
- (void)getImageForAssetIdentifier:(NSString*)identifier targetSize:(CGSize)targetSize type:(NSInteger)nType withStartHandler:(void (^)(NSString *))startHandler withCompletionHandler:(void (^)(NSString *, UIImage *))endHandler;
@end

