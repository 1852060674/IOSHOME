//
//  AssetHelper.m
//  DoImagePickerController
//
//  Created by Donobono on 2014. 1. 23..
//

#import "AssetHelper.h"
#import "ZBCommonDefine.h"
#import "ZBCommonMethod.h"
#import <ImageIO/ImageIO.h>
#import <Photos/Photos.h>

@interface AssetHelper ()

@property (nonatomic, strong)   ALAssetsLibrary			*assetsLibrary;
@property (nonatomic, strong)   NSMutableArray          *assetPhotos;
@property (nonatomic, strong)   NSMutableArray          *assetGroups;

@property (nonatomic, strong) PHCachingImageManager *cachingManger;
@property (nonatomic, strong) PHFetchResult *currentCollectionAssets;
@end


@implementation AssetHelper


+ (AssetHelper *)sharedAssetHelper
{
    static AssetHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AssetHelper alloc] init];
//        _sharedInstance.bReverse = YES;
        [_sharedInstance initAsset];
    });
    
    return _sharedInstance;
}

- (void)initAsset
{
    if (![PHAsset class] || !usePHAsset) {
        if (self.assetsLibrary == nil)
        {
            _assetsLibrary = [[ALAssetsLibrary alloc] init];
            
            NSString *strVersion = [[UIDevice alloc] systemVersion];
            if ([strVersion compare:@"5"] >= 0)
                [_assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                }];
        }
    }
    else
    {
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        NSString *strVersion = [[UIDevice alloc] systemVersion];
        if ([strVersion compare:@"5"] >= 0)
            [assetsLibrary writeImageToSavedPhotosAlbum:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            }];
        
        if (self.cachingManger == nil) {
            self.cachingManger = [[PHCachingImageManager alloc] init];
        }
    }
}

-(BOOL)canAccessLibrary
{
    __block BOOL canAccess = NO;
//    if (![PHAsset class] || !usePHAsset)
//    {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    canAccess = (status == PHAuthorizationStatusAuthorized);
    if(!canAccess){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                canAccess = YES;
            }else if(status == PHAuthorizationStatusDenied) {
            }
        }];
    }

//    }
//    else
//    {
//        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//        canAccess = (status==PHAuthorizationStatusAuthorized);
//    }
    return canAccess;
}

- (void)getGroupList:(void (^)(NSInteger))result
{
    [self initAsset];
    
    if (![PHAsset class] || !usePHAsset)
    {
        void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
        {
            if (group == nil)
            {
                //            if (_bReverse)
                _assetGroups = [[NSMutableArray alloc] initWithArray:[[_assetGroups reverseObjectEnumerator] allObjects]];
                
                // end of enumeration
                result(_assetGroups.count);
                return;
            }
            
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            ALAssetsGroupType type = (ALAssetsGroupType)[[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
            if (type != ALAssetsGroupPhotoStream) {
                [_assetGroups addObject:group];
            }
        };
        
        void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error)
        {
            NSLog(@"Error : %@", [error description]);
        };
        
        _assetGroups = [[NSMutableArray alloc] init];
        [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:assetGroupEnumerator
                                    failureBlock:assetGroupEnumberatorFailure];
    }
    else
    {
//        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];

        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
        PHFetchResult *smartAlbums_1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];

        PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        
        _assetGroups = [[NSMutableArray alloc] init];

        void (^assetGroupEnumerator)(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) = ^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
        {
//            NSLog(@"%@", [obj class]);
            if (![obj isKindOfClass:[PHCollection class]]) {
                return;
            }
//            PHCollection *collection = (PHCollection*)obj;
//            NSLog(@"collection: %@", collection.localizedTitle);

            if (![obj isKindOfClass:[PHAssetCollection class]]) {
                return;
            }
            
            PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
//            NSLog(@"asset collection: %@", assetCollection.localizedTitle);
            
            PHFetchOptions *fetchOptions = [PHFetchOptions new];
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType==%d", PHAssetMediaTypeImage];
            
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
            
            if (assetsFetchResult.count>0) {
                [_assetGroups addObject:assetCollection];
            }
        };

        [smartAlbums enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:assetGroupEnumerator];

        [smartAlbums_1 enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:assetGroupEnumerator];

        [topLevelUserCollections enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:assetGroupEnumerator];
        
        if (result) {
            result(_assetGroups.count);
        }
    }
}

- (void)getPhotoListOfGroup:(ALAssetsGroup *)alGroup result:(void (^)(NSArray *))result
{
    [self initAsset];
    
    _assetPhotos = [[NSMutableArray alloc] init];
    [alGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    [alGroup enumerateAssetsUsingBlock:^(ALAsset *alPhoto, NSUInteger index, BOOL *stop) {
        
        if(alPhoto == nil)
        {
//            if (_bReverse)
                _assetPhotos = [[NSMutableArray alloc] initWithArray:[[_assetPhotos reverseObjectEnumerator] allObjects]];
            
            result(_assetPhotos);
            return;
        }
        
        [_assetPhotos addObject:alPhoto];
    }];
}

- (void)getPhotoListOfFetchResult:(PHAssetCollection *)assetCollection result:(void (^)(NSInteger))result
{
    if (![assetCollection isKindOfClass:[PHAssetCollection class]]) {
        result(0);
        return;
    }
    
    [self initAsset];
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType==%d", PHAssetMediaTypeImage];
    fetchOptions.sortDescriptors = @[
                                     [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
                                     ];
    
    _currentCollectionAssets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
    
    if (result)
        result(_currentCollectionAssets.count);
}

- (void)getPhotoListOfGroupByIndex:(NSInteger)nGroupIndex result:(void (^)(void))result
{
    if (![PHAsset class] || !usePHAsset) {
        [self getPhotoListOfGroup:_assetGroups[nGroupIndex] result:^(NSArray *aResult) {
            if (result)
                result();
        }];
    }
    else
    {
        [self getPhotoListOfFetchResult:_assetGroups[nGroupIndex] result:^(NSInteger count) {
            if (result)
                result();
        }];
    }
}

- (NSInteger)getGroupCount
{
    return _assetGroups.count;
}

- (NSInteger)getPhotoCountOfCurrentGroup
{
    if (![PHAsset class] || !usePHAsset) {
        return _assetPhotos.count;
    }
    else
    {
        return _currentCollectionAssets.count;
    }
}

- (NSDictionary *)getGroupInfo:(NSInteger)nIndex
{
    NSString *name;
    UIImage *thumbnail;
    NSInteger assetCount;
    
    if (![PHAsset class] || !usePHAsset) {
        name = [_assetGroups[nIndex] valueForProperty:ALAssetsGroupPropertyName];
        thumbnail = [UIImage imageWithCGImage:[(ALAssetsGroup*)_assetGroups[nIndex] posterImage]];
        
        assetCount = [_assetGroups[nIndex] numberOfAssets];
    }
    else
    {
        PHAssetCollection *collection = _assetGroups[nIndex];
        
        name = [collection localizedTitle];
        
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType==%d", PHAssetMediaTypeImage];
        fetchOptions.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
                                         ];
        
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
        
        assetCount = assetsFetchResult.count;
    }
    
    if (thumbnail == nil) {
        thumbnail = [UIImage imageNamed:@"thumbnail.jpg"];
    }
    
    return @{@"name" : name,
             @"count" : @(assetCount),
             @"thumbnail" : thumbnail};
}

-(void)getGroupInfo:(NSInteger)nIndex withCompletionHandler:(void (^)(NSDictionary *))endHandler
{
    NSString *name;
    UIImage *thumbnail;
    NSInteger assetCount;
    
    if (![PHAsset class] || !usePHAsset) {
        name = [_assetGroups[nIndex] valueForProperty:ALAssetsGroupPropertyName];
        thumbnail = [UIImage imageWithCGImage:[(ALAssetsGroup*)_assetGroups[nIndex] posterImage]];
        assetCount = [_assetGroups[nIndex] numberOfAssets];
        
        if (thumbnail == nil) {
            thumbnail = [UIImage imageNamed:@"thumbnail.jpg"];
        }
        
        NSDictionary *result = @{@"name" : name,
                         @"count" : @(assetCount),
                         @"thumbnail" : thumbnail};
        
        if (endHandler) {
            endHandler(result);
        }
    }
    else
    {
        PHAssetCollection *collection = _assetGroups[nIndex];
        
        name = [collection localizedTitle];
        
        PHFetchOptions *fetchOptions = [PHFetchOptions new];
        fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType==%d", PHAssetMediaTypeImage];
        fetchOptions.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO],
                                         ];
        
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:fetchOptions];
        assetCount = assetsFetchResult.count;
        
        PHAsset *asset = assetsFetchResult.firstObject;

        [self.cachingManger requestImageForAsset:asset
                                      targetSize:CGSizeMake(100, 100)
                                     contentMode:PHImageContentModeAspectFill
                                         options:nil
                                   resultHandler:^(UIImage *thumbnail, NSDictionary *info) {
                                       if (thumbnail == nil) {
                                           thumbnail = [UIImage imageNamed:@"thumbnail.jpg"];
                                       }
                                       
                                       NSDictionary *result = @{@"name" : name,
                                                                @"count" : @(assetCount),
                                                                @"thumbnail" : thumbnail};
                                       
                                       if (endHandler) {
                                           endHandler(result);
                                       }
                                   }];
    }
}

- (void)clearData
{
	_assetGroups = nil;
	_assetPhotos = nil;
    
    _currentCollectionAssets = nil;
}

- (UIImage *)getImageFromAsset:(ALAsset *)asset type:(NSInteger)nType
{
    CGImageRef iRef = nil;
    
    UIImageOrientation orientation = UIImageOrientationUp;
    
    CGFloat scale = 1.0;
    if (nType == ASSET_PHOTO_THUMBNAIL)
    {
        iRef = [asset thumbnail];
//        orientation = (UIImageOrientation)asset.defaultRepresentation.orientation;
        scale = [asset.defaultRepresentation scale];
    }
    else if (nType == ASSET_PHOTO_SCREEN_SIZE)
    {
        iRef = [asset.defaultRepresentation fullScreenImage];
        orientation = (UIImageOrientation)asset.defaultRepresentation.orientation;
        scale = [asset.defaultRepresentation scale];
    }
    else if (nType == ASSET_PHOTO_FULL_RESOLUTION)
    {
        iRef = [asset.defaultRepresentation fullResolutionImage];
        orientation = (UIImageOrientation)asset.defaultRepresentation.orientation;
        scale = [asset.defaultRepresentation scale];
    }
    
    UIImage *image = [UIImage imageWithCGImage:iRef scale:scale orientation:orientation];
    
//    NSLog(@"%d, %d", iRef, image.CGImage);
    
    return image;
}

- (void)getImageFromPHAsset:(PHAsset *)asset targetSize:(CGSize)targetSize andPHImageContentMode:(PHImageContentMode)contentMode withCompletionHandler:(void (^)(UIImage *))endBlock
{
    [self.cachingManger requestImageForAsset:asset
                                 targetSize:targetSize
                                contentMode:contentMode
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  // Set the cell's thumbnail image if it's still showing the same asset.
                                  endBlock(result);
                              }];
}

- (UIImage *)getImageAtIndex:(NSInteger)nIndex type:(NSInteger)nType
{
    return [self getImageFromAsset:(ALAsset *)_assetPhotos[nIndex] type:nType];
}

- (void)getImageAtIndex:(NSInteger)nIndex targetSize:(CGSize)targetSize type:(NSInteger)nType withStartHandler:(void (^)(NSString *))startHandler withCompletionHandler:(void (^)(NSString *, UIImage *))endHandler;
{
    if (![PHAsset class] || !usePHAsset) {
        if (startHandler) {
            startHandler(@"alasset");
        }
        UIImage *image = [self getImageFromAsset:(ALAsset *)_assetPhotos[nIndex] type:nType];
        if (endHandler) {
            endHandler(@"alasset", image);
        }
    }
    else
    {
        PHAsset *asset = self.currentCollectionAssets[nIndex];
        if (startHandler) {
            startHandler(asset.localIdentifier);
        }
        
        if (nType==ASSET_PHOTO_FULL_RESOLUTION) {
            targetSize.width = asset.pixelWidth;
            targetSize.height = asset.pixelHeight;
        }
        else
        {
            CGFloat scale = [UIScreen mainScreen].scale;
            targetSize = CGSizeMake(targetSize.width * scale, targetSize.height * scale);
        }
        
        if (nType == ASSET_PHOTO_THUMBNAIL) {
            [self.cachingManger requestImageForAsset:asset
                                          targetSize:targetSize
                                         contentMode:PHImageContentModeAspectFit
                                             options:nil
                                       resultHandler:^(UIImage *result, NSDictionary *info) {

                                           if (endHandler) {
                                               endHandler(asset.localIdentifier, result);
                                           }
                                       }];
        }
        else if (nType == ASSET_PHOTO_FULL_RESOLUTION || nType == ASSET_PHOTO_SCREEN_SIZE)
        {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.networkAccessAllowed = NO;
            
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                // Hide the progress view now the request has completed.
                
                // Check if the request was successful.
                if (!result) {
                    return;
                }
                if (endHandler) {
                    endHandler(asset.localIdentifier, result);
                }
            }];
        }
    }
}

-(NSString *)getAssetIdentifierAtIndex:(NSInteger)nIndex
{
    if (![PHAsset class] || !usePHAsset) {
        ALAsset *asset = (ALAsset *)_assetPhotos[nIndex];
        NSURL *url = [[asset defaultRepresentation]url];
        return url.absoluteString;
    }
    else
    {
        PHAsset *asset = self.currentCollectionAssets[nIndex];
        return asset.localIdentifier;
    }
}

- (void)getImageForAssetIdentifier:(NSString*)identifier targetSize:(CGSize)targetSize type:(NSInteger)nType withStartHandler:(void (^)(NSString *))startHandler withCompletionHandler:(void (^)(NSString *, UIImage *))endHandler
{
    if (![PHAsset class] || !usePHAsset) {
        if (startHandler) {
            startHandler(identifier);
        }
        [self.assetsLibrary assetForURL:[NSURL URLWithString:identifier] resultBlock:^(ALAsset *asset) {
            UIImage *image = [self getImageFromAsset:asset type:nType];

            if (endHandler) {
                endHandler(identifier, image);
            }
        } failureBlock:^(NSError *error) {
            if (endHandler) {
                endHandler(identifier, nil);
            }
        }];
    }
    else
    {
        
        PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil];
        
        PHAsset *asset = result.firstObject;
        if (startHandler) {
            startHandler(asset.localIdentifier);
        }
        
        if (nType==ASSET_PHOTO_FULL_RESOLUTION) {
            targetSize.width = asset.pixelWidth;
            targetSize.height = asset.pixelHeight;
        }
        else
        {
            CGFloat scale = [UIScreen mainScreen].scale;
            targetSize = CGSizeMake(targetSize.width * scale, targetSize.height * scale);
        }
        
        if (nType == ASSET_PHOTO_THUMBNAIL) {
            [self.cachingManger requestImageForAsset:asset
                                          targetSize:targetSize
                                         contentMode:PHImageContentModeAspectFit
                                             options:nil
                                       resultHandler:^(UIImage *result, NSDictionary *info) {
                                           
                                           if (endHandler) {
                                               endHandler(asset.localIdentifier, result);
                                           }
                                       }];
        }
        else if (nType == ASSET_PHOTO_FULL_RESOLUTION || nType == ASSET_PHOTO_SCREEN_SIZE)
        {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.networkAccessAllowed = NO;
            
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
                // Hide the progress view now the request has completed.
                
                // Check if the request was successful.
                if (!result) {
                    return;
                }
                if (endHandler) {
                    endHandler(asset.localIdentifier, result);
                }
            }];
        }
    }
}
@end
