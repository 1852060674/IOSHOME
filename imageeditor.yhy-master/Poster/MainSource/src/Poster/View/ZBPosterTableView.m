//
//  ZBPosterTableView.m
//  Collage
//
//  Created by shen on 13-7-22.
//  Copyright (c) 2013年 ZB. All rights reserved.
//

#import "ZBPosterTableView.h"
#import "ZBPosterCell.h"
#import "ImageUtil.h"
#import "ZBCommonDefine.h"
#import "ZBPosterThumbnailView.h"
#import "ZBColorDefine.h"

@interface ZBPosterTableView()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger _lastSelectedIndex;
    NSInteger _currentSelectedIndex;
}

@property (nonatomic, strong)UITableView *posterTableView;
@property (nonatomic, strong)NSArray *posterArray;

- (void)clearSelectedStatus:(NSUInteger)thumbnailIndex;

@end

@implementation ZBPosterTableView

@synthesize posterTableView;
@synthesize posterArray;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPosterChangeType object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithPatternImage:[ImageUtil loadResourceImage:@"bg17"]];
        self.posterArray = [NSArray arrayWithObjects:@"poster_thumbnail_1",@"poster_thumbnail_2",@"poster_thumbnail_3",@"poster_thumbnail_4",@"poster_thumbnail_5",@"poster_thumbnail_6",@"poster_thumbnail_7",@"poster_thumbnail_8",@"poster_thumbnail_9",@"poster_thumbnail_10",@"poster_thumbnail_11",@"poster_thumbnail_12",@"poster_thumbnail_13",@"poster_thumbnail_14",@"poster_thumbnail_15", nil];
        
        UILabel *_selectLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _selectLabel.text = @"Please select a poster.";
        float _fontSize = IS_IPAD?20:16;
        UIFont *_font = [UIFont fontWithName:@"American Typewriter" size:_fontSize];
        _selectLabel.font = _font;
        _selectLabel.textColor = kPosterTableViewRemindTextColor;
        _selectLabel.backgroundColor = kTransparentColor;
        [self addSubview:_selectLabel];
        CGSize _labelSize = CGSizeZero;
        CGSize _maxSize = CGSizeMake(frame.size.width, 100);
         _labelSize = [_selectLabel.text sizeWithFont:_font constrainedToSize:_maxSize lineBreakMode:NSLineBreakByWordWrapping];
        _selectLabel.frame = CGRectMake((frame.size.width-_labelSize.width)*0.5, 5, _labelSize.width, _labelSize.height);
        
        self.posterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10+_labelSize.height, frame.size.width, frame.size.height-10-_labelSize.height)];
        self.posterTableView.backgroundColor = kTransparentColor;
        self.posterTableView.delegate = self;
        self.posterTableView.dataSource = self;
        [self addSubview:self.posterTableView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePosterType:) name:kPosterChangeType object:nil];
    }
    return self;
}

- (void)changePosterType:(NSNotification*)notification
{
    NSDictionary *_infoDic = [notification object];//获取到传递的对象
    NSUInteger _lastPostType = [[_infoDic objectForKey:@"LastPosterChangeType"] integerValue];
    NSUInteger _currentPostType = [[_infoDic objectForKey:@"PosterChangeType"] integerValue];
    
    _lastSelectedIndex = _lastPostType;
    _currentSelectedIndex = _currentPostType;
    
    [self.posterTableView reloadData];
//    for (UIView *_aView in [self.posterTableView subviews]) {
//        if ([_aView isKindOfClass:[ZBPosterCell class]]) {
//            for (UIView *_subView in [_aView subviews]) {
//                if ([_subView isKindOfClass:[ZBPosterThumbnailView class]]) {
//                    ZBPosterThumbnailView *_posterThumbnailView = (ZBPosterThumbnailView*)_subView;
//                    if (_posterThumbnailView.thumbnailIndex == _lastPostType) {
//                        [_posterThumbnailView clearSelectedStatus];
//                    }
//                    
//                    if (_posterThumbnailView.isSelected) {
//                        [_posterThumbnailView clearSelectedStatus];
//                    }
//                    
//                    if (_posterThumbnailView.thumbnailIndex == _currentPostType) {
//                        [_posterThumbnailView setSelectedStatus];
//                    }
//                }
//            }
//        }
//    }
}

#pragma mark -- tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil != self.posterArray) {
        
        NSInteger numberOfRowsInSection = 0;
        numberOfRowsInSection = self.posterArray.count / kImageViewCountsInPerLine;
        if((self.posterArray.count - numberOfRowsInSection * kImageViewCountsInPerLine) > 0) numberOfRowsInSection++;
        return numberOfRowsInSection;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdetify = @"PosterTableViewCell";
    ZBPosterCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdetify];
    if (!cell) {
        cell = [[ZBPosterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdetify];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.showsReorderControl = YES;
        cell.textLabel.backgroundColor = kTransparentColor;
        cell.imageView.image = [ImageUtil loadResourceImage:[self.posterArray objectAtIndex:indexPath.row]];
    }
    else
    {
        for (UIView *_subView in [cell subviews]) {
            if ([_subView isKindOfClass:[ZBPosterThumbnailView class]]) {
                ZBPosterThumbnailView *_posterThumbnailView = (ZBPosterThumbnailView*)_subView;
                if (_posterThumbnailView.thumbnailIndex == _lastSelectedIndex) {
                    [_posterThumbnailView clearSelectedStatus];
                }
                
                if (_posterThumbnailView.isSelected) {
                    [_posterThumbnailView clearSelectedStatus];
                }
                
                if (_posterThumbnailView.thumbnailIndex == _currentSelectedIndex) {
                    [_posterThumbnailView setSelectedStatus];
                }
            }
        }

    }
    NSInteger offset = kImageViewCountsInPerLine * indexPath.row;
    NSInteger numberOfAssetsToSet = (offset + kImageViewCountsInPerLine > self.posterArray.count) ? (self.posterArray.count - offset) : kImageViewCountsInPerLine;
    
    NSMutableDictionary *_thumbnailDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSMutableArray *thumbnailArray = [NSMutableArray array];
    for(NSUInteger i = 0; i < numberOfAssetsToSet; i++) {        
        [thumbnailArray addObject:[self.posterArray objectAtIndex:(offset + i)]];
        
    }
    [_thumbnailDic setObject:[NSNumber numberWithInteger:offset] forKey:@"offset"];
    [_thumbnailDic setObject:thumbnailArray forKey:@"imagesArray"];
    [cell refreshCell:_thumbnailDic];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{


}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) {
        return 200;
    }
    return 121;
}


//#pragma mark ZBPosterCellDelegate
//- (void)selectAPoster:(NSUInteger)lastPosterType
//{
//    //回调
//    [self clearSelectedStatus:lastPosterType];
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
