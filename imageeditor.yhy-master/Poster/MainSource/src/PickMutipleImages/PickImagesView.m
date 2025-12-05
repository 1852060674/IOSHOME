//
//  PickImagesView.m
//  PuzzleImages
//
//  Created by 吕 广燊￼ on 13-5-17.
//  Copyright (c) 2013年 com.gs. All rights reserved.
//

#import "PickImagesView.h"

#import "ZBCommonDefine.h"
#import "PickImagesGroupCell.h"
#import "AssetHelper.h"
#import "AdUtility.h"

@interface PickImagesView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *assets;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, retain) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, retain) NSMutableArray *assetsGroups;
@property (nonatomic, assign) PickerImageFilterType filterType;

@end

@implementation PickImagesView
@synthesize albumTableView = _albumTableView;
@synthesize assets = _assets;
@synthesize imageSize = _imageSize;
@synthesize assetsLibrary = _assetsLibrary;
@synthesize assetsGroups = _assetsGroups;
@synthesize filterType = _filterType;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        safeAreaInsets = window.safeAreaInsets;
    }
    
    if (self) {
        //self.backgroundColor = [UIColor redColor];
        // Initialization code
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        self.assetsLibrary = assetsLibrary;
        
        self.assetsGroups = [[NSMutableArray alloc] initWithCapacity:1];
        
        self.filterType = PickerImageFilterTypeAllAssets;
        
        CGFloat adHeight = [AdUtility hasAd] ? kAdHeiht : 0;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavigationBarHeight + adHeight + safeAreaInsets.top, kScreenWidth, kScreenHeight) style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        
        //tableView.backgroundColor =  [UIColor redColor];
        //tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectNull];
        [self addSubview:tableView];
        self.albumTableView = tableView;
        
//        UIView *view = [UIView new];
//        view.backgroundColor = [UIColor clearColor];
//        [tableView setTableFooterView:view];
//        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (void)getAssetsFromAlbum:(BOOL)isReload
{
    [self.assetsGroups removeAllObjects];
    void (^assetsGroupsEnumerationBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *assetsGroup, BOOL *stop) {
        if(assetsGroup) {
            switch(self.filterType) {
                case PickerImageFilterTypeAllAssets:
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allAssets]];
                    break;
                case PickerImageFilterTypeAllPhotos:
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
                    break;
                case PickerImageFilterTypeAllVideos:
                    [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                    break;
            }
            
            if(assetsGroup.numberOfAssets > 0) {
                [self.assetsGroups addObject:assetsGroup];
//                [self.albumTableView reloadData];
            }
            
            if (isReload) {
                [self.albumTableView reloadData];
            }
        }
    };
    
    void (^assetsGroupsFailureBlock)(NSError *) = ^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    };
    
    // Enumerate Camera Roll
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Photo Stream
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Album
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Event
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupEvent usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
    
    // Faces
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupFaces usingBlock:assetsGroupsEnumerationBlock failureBlock:assetsGroupsFailureBlock];
}

- (void)dealloc
{
//    self.albumTableView.dataSource = nil;
//    self.albumTableView.delegate = nil;
//    [self.albumTableView release];
//    [self.assetsGroups release];
//    [super dealloc];
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [ASSETHELPER getGroupList:^(NSInteger count) {
        [self.albumTableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.assetsGroups.count;
    return [ASSETHELPER getGroupCount];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    PickImagesGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[PickImagesGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
//    ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
//    
//    cell.imageView.image = [UIImage imageWithCGImage:assetsGroup.posterImage];
//
//    cell.titleLabel.text = [NSString stringWithFormat:@"%@", [assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
//    cell.countLabel.text = [NSString stringWithFormat:@"(%d)", (int)assetsGroup.numberOfAssets];
    
    [ASSETHELPER getGroupInfo:indexPath.row withCompletionHandler:^(NSDictionary *info) {
//        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [info objectForKey:@"thumbnail"];
            cell.posterImageView.image = image;
            cell.titleLabel.text = [info objectForKey:@"name"];
            cell.countLabel.text = [NSString stringWithFormat:@"(%@)", [info objectForKey:@"count"]];
//        });
    }];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
         return 100;
    else
        return  65;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    view.backgroundColor = [UIColor greenColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    ALAssetsGroup *assetsGroup = [self.assetsGroups objectAtIndex:indexPath.row];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(goToImagesStitch: withType:)]) {
//        [self.delegate goToImagesStitch:assetsGroup withType:self.filterType];
//    }
    
    if ([self.delegate respondsToSelector:@selector(gotoAlbumGroupAtIndex:)]) {
        [self.delegate gotoAlbumGroupAtIndex:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
