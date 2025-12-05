//
//  ShareUtility.h
//  EyeColor4.0
//
//  Created by ZB_Mac on 15-1-20.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define USE_SHARESDK

typedef enum
{
    ZBShareTypeSinaWeibo = 1,         /**< 新浪微博 */
    ZBShareTypeTencentWeibo = 2,      /**< 腾讯微博 */
    ZBShareTypeSohuWeibo = 3,         /**< 搜狐微博 */
    ZBShareType163Weibo = 4,          /**< 网易微博 */
    ZBShareTypeDouBan = 5,            /**< 豆瓣社区 */
    ZBShareTypeQQSpace = 6,           /**< QQ空间 */
    ZBShareTypeRenren = 7,            /**< 人人网 */
    ZBShareTypeKaixin = 8,            /**< 开心网 */
    ZBShareTypePengyou = 9,           /**< 朋友网 */
    ZBShareTypeFacebook = 10,         /**< Facebook */
    ZBShareTypeTwitter = 11,          /**< Twitter */
    ZBShareTypeEvernote = 12,         /**< 印象笔记 */
    ZBShareTypeFoursquare = 13,       /**< Foursquare */
    ZBShareTypeGooglePlus = 14,       /**< Google＋ */
    ZBShareTypeInstagram = 15,        /**< Instagram */
    ZBShareTypeLinkedIn = 16,         /**< LinkedIn */
    ZBShareTypeTumblr = 17,           /**< Tumbir */
    ZBShareTypeMail = 18,             /**< 邮件分享 */
    ZBShareTypeSMS = 19,              /**< 短信分享 */
    ZBShareTypeAirPrint = 20,         /**< 打印 */
    ZBShareTypeCopy = 21,             /**< 拷贝 */
    ZBShareTypeWeixiSession = 22,     /**< 微信好友 */
    ZBShareTypeWeixiTimeline = 23,    /**< 微信朋友圈 */
    ZBShareTypeQQ = 24,               /**< QQ */
    ZBShareTypeInstapaper = 25,       /**< Instapaper */
    ZBShareTypePocket = 26,           /**< Pocket */
    ZBShareTypeYouDaoNote = 27,       /**< 有道云笔记 */
    ZBShareTypeSohuKan = 28,          /**< 搜狐随身看 */
    ZBShareTypePinterest = 30,        /**< Pinterest */
    ZBShareTypeFlickr = 34,           /**< Flickr */
    ZBShareTypeDropbox = 35,          /**< Dropbox */
    ZBShareTypeVKontakte = 36,        /**< VKontakte */
    ZBShareTypeWeixiFav = 37,         /**< 微信收藏 */
    ZBShareTypeYiXinSession = 38,     /**< 易信好友 */
    ZBShareTypeYiXinTimeline = 39,    /**< 易信朋友圈 */
    ZBShareTypeYiXinFav = 40,         /**< 易信收藏 */
    ZBShareTypeMingDao = 41,          /**< 明道 */
    ZBShareTypeLine = 42,             /**< Line */
    ZBShareTypeWhatsApp = 43,         /**< Whats App */
    ZBShareTypeKaKaoTalk = 44,        /**< KaKao Talk */
    ZBShareTypeKaKaoStory = 45,       /**< KaKao Story */
    ZBShareTypeAny = 99               /**< 任意平台 */
}
ZBShareType;

typedef enum : NSUInteger {
    kShareServiceSuccess,
    kShareServiceFail,
    kShareServiceDeviceNotSupport,
    kShareServiceUserCancel,
    kShareServiceSaveCraft,
} ShareServiceResult;

@class ShareService;

@protocol ShareServiceDelegate <NSObject>

@optional
-(void) shareServiceDidEndShare:(ShareService *)shareService shareType:(ZBShareType)shareType result:(ShareServiceResult)resultCode;
-(void) shareServiceBeforeShare:(ShareService *)shareService;
-(void) shareServiceDidEndSave:(ShareService *)shareService result:(ShareServiceResult)resultCode;
@end

@interface ShareService : NSObject
@property (nonatomic, weak) id<ShareServiceDelegate> delegate;
@property (nonatomic, readwrite) BOOL reportResult;
+(ShareService *) defaultService;

-(void)initializeService;
-(void)showShareToPlatForm:(ZBShareType)shareType inVC:(UIViewController*)VC fromView:(UIView *)shareView title:(NSString *)title content:(NSString *)content image:(UIImage *)image;
-(void)saveToAlbumn:(UIImage *)image;
-(BOOL)sendSMSInVC:(UIViewController *)VC title:(NSString *)title content:(NSString *)content image:(UIImage *)image;
-(BOOL)sendMailInVC:(UIViewController *)VC title:(NSString *)title content:(NSString *)content image:(UIImage *)image recipients:(NSArray *)recipients;
-(BOOL)sendMailInVC:(UIViewController *)VC  title:(NSString *)title content:(NSString *)content gifImageData:(NSData *)imageData recipients:(NSArray *)recipients;

-(NSString *)getResultTipMessageWithShareType:(ZBShareType)shareType andResult:(ShareServiceResult)result;
-(NSString *)getShareContent;
-(NSString *)getShareTitle;
@end
