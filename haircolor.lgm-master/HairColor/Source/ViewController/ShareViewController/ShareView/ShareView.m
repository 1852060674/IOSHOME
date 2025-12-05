//
//  ShareView.m
//  eyeColorPlus
//
//  Created by shen on 14-7-22.
//  Copyright (c) 2014年 iosfunny. All rights reserved.
//

#import "ShareView.h"
#import "CGRectCGPointUtility.h"
#import "ShareViewImageCollectionCell.h"
#import "ShareService.h"
#import "ZBCommonMethod.h"
#import "Masonry.h"
@interface ShareView ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionViewFlowLayout *_layout;
}
@property (nonatomic, strong) UIImageView *backgroundView;
@end

@implementation ShareView

@synthesize platforms=_platforms;
-(NSArray *)platforms
{
    if (_platforms == nil) {
        if ([ZBCommonMethod getCurrentLanguageType] == LanguageTypeZH_hans)
        {
            _platforms = @[
                           @(ZBShareTypeSave),
                           @(ZBShareTypeWeixiTimeline),
                           @(ZBShareTypeWeixiSession),
                           @(ZBShareTypeQQ),
                           @(ZBShareTypeQQSpace),
                           @(ZBShareTypeSinaWeibo),
                           @(ZBShareTypeSMS),
                           @(ZBShareTypeMore),
                           
//                           @(ZBShareTypeQQSpace),
//                           @(ZBShareTypeSinaWeibo),
//                           @(ZBShareTypeTencentWeibo),
//                           @(ZBShareTypeSMS),
//                           @(ZBShareTypeMail),
//                           @(ZBShareTypeInstagram),
//                           @(ZBShareTypeFacebook),
//                           @(ZBShareTypeWhatsApp),
//                           @(ZBShareTypeTwitter),
                           ];
        }
        else
        {
            _platforms = @[
                           @(ZBShareTypeSave),
                           @(ZBShareTypeInstagram),
                           @(ZBShareTypeFacebook),
                           @(ZBShareTypeWhatsApp),
                           @(ZBShareTypeTwitter),
                           @(ZBShareTypeSMS),
                           @(ZBShareTypeMail),
                           @(ZBShareTypeMore),

//                           @(ZBShareTypeFlickr),
//                           @(ZBShareTypeTumblr),
//                           @(ZBShareTypeWeixiTimeline),
//                           @(ZBShareTypeWeixiSession),
//                           @(ZBShareTypeSinaWeibo),
//                           @(ZBShareTypeTencentWeibo),
                           ];
        }
    }
    return _platforms;
}

-(NSString *)shareTitleForPlatform:(ZBShareType)shareType
{
    NSString *title = nil;
    switch (shareType) {
        case ZBShareTypeInstagram:
            title = NSLocalizedStringFromTable(@"SHARE_INSTAGRAM", @"share", @"instagram for locale");
            break;
        case ZBShareTypeFacebook:
            title = NSLocalizedStringFromTable(@"SHARE_FACEBOOK", @"share", @"instagram for locale");
            break;
        case ZBShareTypeWhatsApp:
            title = NSLocalizedStringFromTable(@"SHARE_WHATSAPP", @"share", @"instagram for locale");
            break;
        case ZBShareTypeTumblr:
            title = NSLocalizedStringFromTable(@"SHARE_TUMBLR", @"share", @"instagram for locale");
            break;
        case ZBShareTypeSMS:
            title = NSLocalizedStringFromTable(@"SHARE_SMS", @"share", @"instagram for locale");
            break;
        case ZBShareTypeMail:
            title = NSLocalizedStringFromTable(@"SHARE_MAIL", @"share", @"instagram for locale");
            break;
        case ZBShareTypeVKontakte:
            title = NSLocalizedStringFromTable(@"SHARE_VKONTAKTE", @"share", @"instagram for locale");
            break;
        case ZBShareTypeFlickr:
            title = NSLocalizedStringFromTable(@"SHARE_FLICKR", @"share", @"instagram for locale");
            break;
        case ZBShareTypeWeixiTimeline:
            title = NSLocalizedStringFromTable(@"SHARE_WECHAT_TIMELINE", @"share", @"instagram for locale");
            break;
        case ZBShareTypeWeixiSession:
            title = NSLocalizedStringFromTable(@"SHARE_WECHAT", @"share", @"instagram for locale");
            break;
        case ZBShareTypeSinaWeibo:
            title = NSLocalizedStringFromTable(@"SHARE_SINA_WEIBO", @"share", @"instagram for locale");
            break;
        case ZBShareTypeTencentWeibo:
            title = NSLocalizedStringFromTable(@"SHARE_TC_WEIBO", @"share", @"instagram for locale");
            break;
        case ZBShareTypeQQ:
            title = NSLocalizedStringFromTable(@"SHARE_QQ", @"share", @"instagram for locale");
            break;
        case ZBShareTypeQQSpace:
            title = NSLocalizedStringFromTable(@"SHARE_QQ_SPACE", @"share", @"instagram for locale");
            break;
        case ZBShareTypeTwitter:
            title = NSLocalizedStringFromTable(@"SHARE_TWITTER", @"share", @"instagram for locale");
            break;
        case ZBShareTypeMore:
            title = NSLocalizedStringFromTable(@"SHARE_MORE", @"share", @"more");
            break;
        case ZBShareTypeSave:
            title = NSLocalizedStringFromTable(@"SHARE_SAVE", @"share", @"more");
            break;
        default:
            break;
    }
    return title;
}

-(NSString *)shareIconForPlatform:(ZBShareType)shareType
{
    NSString *icon = nil;
    switch (shareType) {
        case ZBShareTypeInstagram:
            icon = @"share_icon_instragram";
            break;
        case ZBShareTypeFacebook:
            icon = @"share_icon_facebook";
            break;
        case ZBShareTypeWhatsApp:
            icon = @"share_icon_whatsapp";
            break;
        case ZBShareTypeTumblr:
            icon = @"share_icon_tumblr";
            break;
        case ZBShareTypeSMS:
            icon = @"share_icon_sms";
            break;
        case ZBShareTypeMail:
            icon = @"share_icon_email";
            break;
        case ZBShareTypeVKontakte:
            icon = @"share_icon_vkontakte";
            break;
        case ZBShareTypeFlickr:
            icon = @"share_icon_flickr";
            break;
        case ZBShareTypeWeixiTimeline:
            icon = @"share_icon_timeline";
            break;
        case ZBShareTypeWeixiSession:
            icon = @"share_icon_wechat";
            break;
        case ZBShareTypeSinaWeibo:
            icon = @"share_icon_sinaweibo";
            break;
        case ZBShareTypeTencentWeibo:
            icon = @"share_icon_tencentweibo";
            break;
        case ZBShareTypeQQ:
            icon = @"share_icon_qq";
            break;
        case ZBShareTypeQQSpace:
            icon = @"share_icon_qq_space";
            break;
        case ZBShareTypeTwitter:
            icon = @"share_icon_twitter";
            break;
        case ZBShareTypeMore:
            icon = @"share_icon_more";
            break;
        case ZBShareTypeSave:
            icon = @"share_icon_save";
            break;
        default:
            break;
    }
    return icon;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupSubView
{
    CGRect frame = CGRectZero; frame.size = self.frame.size;
    
    const static NSInteger colNum = 4;
    const static NSInteger rowNum = 2;

    CGFloat minimumInteritemSpacing = CGRectGetWidth(frame)*0.02;
    CGFloat minimumLineSpacing = CGRectGetHeight(frame)*0.02;
    
    BOOL isIPAD = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    UIEdgeInsets insets = isIPAD?UIEdgeInsetsMake(25, 16, 10, 16):UIEdgeInsetsMake(10, 10, 10, 10);
    const CGFloat size = MIN(((frame.size.width-insets.left-insets.right-minimumInteritemSpacing*(colNum-1))/(colNum)), ((frame.size.height-insets.bottom-insets.top-minimumLineSpacing*(rowNum-1))/(rowNum)));

    NSInteger interitemSpacing = (frame.size.width-insets.left-insets.right-size*colNum)/(colNum-1);
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(size, size);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = interitemSpacing;
//    layout.minimumLineSpacing = lineSpacing;
    layout.sectionInset = insets;
    _layout = layout;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView registerClass:[ShareViewImageCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;

    [self addSubview:collectionView];

    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
}

#pragma mark - UICollectionView Datasource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.platforms.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShareViewImageCollectionCell *cell = (ShareViewImageCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.titleRatio = 0.3;
    [cell setImage:[UIImage imageNamed:[self shareIconForPlatform:(ZBShareType)[self.platforms[indexPath.row] integerValue]]]];
    [cell setTitle:[self shareTitleForPlatform:(ZBShareType)[self.platforms[indexPath.row] integerValue]]];

//    cell.titleColor = [UIColor whiteColor];

//    cell.titleColor = [UIColor colorWithRed:47.0/255.0 green:88.0/255.0 blue:133.0/255.0 alpha:1.0];
    [cell setFontRatio:0.53];
    return cell;
}
#pragma mark - UICollectionView Delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self doShare:(ZBShareType)[self.platforms[indexPath.row] integerValue]];
}
#pragma mark -

-(void)close
{
    [self.delegate closeShareView:self];
}

-(void)save
{
    [self.delegate saveImageShareView:self];
}

-(void)share:(UIButton *)sender
{
    [self doShare:(ZBShareType)[self.platforms[sender.tag-1] integerValue]];
}

-(void)doShare:(ZBShareType)shareType
{
    [self.delegate shareView:self shareImageToPlatform:shareType];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = CGRectZero; frame.size = self.frame.size;
    
    const static NSInteger colNum = 4;
    const static NSInteger rowNum = 1;
    
    CGFloat minimumInteritemSpacing = CGRectGetWidth(frame)*0.02;
    CGFloat minimumLineSpacing = CGRectGetHeight(frame)*0.02;
    
//    UIEdgeInsets insets = UIEdgeInsetsMake(10, 10, 10, 10);
    BOOL isIPAD = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    UIEdgeInsets insets = isIPAD?UIEdgeInsetsMake(25, 16, 10, 16):UIEdgeInsetsMake(10, 10, 10, 10);
    
    const CGFloat size = MIN(((frame.size.width-insets.left-insets.right-minimumInteritemSpacing*(colNum-1))/(colNum)), ((frame.size.height-insets.bottom-insets.top-minimumLineSpacing*(rowNum-1))/(rowNum)));
    
    NSInteger interitemSpacing = (frame.size.width-insets.left-insets.right-size*colNum)/(colNum-1);
    
    _layout.itemSize = CGSizeMake(size, size);
    _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _layout.minimumInteritemSpacing = interitemSpacing;
    _layout.sectionInset = insets;
    
    [_layout invalidateLayout];
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
