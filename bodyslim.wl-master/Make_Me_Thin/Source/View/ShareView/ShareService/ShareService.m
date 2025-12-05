//
//  ShareUtility.m
//  EyeColor4.0
//
//  Created by ZB_Mac on 15-1-20.
//  Copyright (c) 2015年 ZB_Mac. All rights reserved.
//

#import "ShareService.h"
#import <MessageUI/MessageUI.h>
#import "ShareCommon.h"
#ifdef USE_SHARESDK
#import "WXApi.h"
#import "WeiboSDK.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#endif
#ifdef APP_ALBUM_FOLDER
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#endif
//#import <sketchLib2.0_iOS/UIImage+Rotation.h>
#import "UIImage+Rotation.h"
#ifdef USE_SHARESDK
@interface ShareService ()<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, WXApiDelegate>
#else
@interface ShareService ()<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>
#endif
@property (nonatomic, weak) UIViewController *rootVC;
@property (strong, nonatomic) UIDocumentInteractionController *documentController;
@property (strong, nonatomic) UIPopoverController *popController;
@end

@implementation ShareService

+(ShareService *) defaultService
{
    static dispatch_once_t once;
    static ShareService *service = nil;
    dispatch_once(&once, ^{
        service = [[self alloc] init];
        service.reportResult = YES;
    });
    return service;
}

-(void)initializeService
{
#ifdef USE_SHARESDK
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
            [platformsRegister setupSinaWeiboWithAppkey:SINA_WEIBO_KEY appSecret:SINA_WEIBO_SECRET redirectUrl:SINA_WEIBO_URI];
            [platformsRegister setupFacebookWithAppkey:FB_KEY appSecret:FB_SECRET displayName:@"Make_Me_Thin"];
            [platformsRegister setupTwitterWithKey:TWITTER_KEY secret:TWITTER_SECRET redirectUrl:TWITTER_URI];
            [platformsRegister setupWeChatWithAppId:WECHAT_APPID appSecret:WECHAT_SECRET universalLink:@""];
            [platformsRegister setupQQWithAppId:QQ_APP_ID appkey:QQ_APP_KEY];
            [platformsRegister setupInstagramWithClientId:IG_APP_ID clientSecret:IG_APP_SECRET redirectUrl:IG_APP_URI];
            [platformsRegister setupLinkedInByApiKey:LINKEDIN_KEY secretKey:LINKEDIN_SECRET redirectUrl:LINKEDIN_URI];
            [platformsRegister setupTumblrByConsumerKey:TUMBLR_KEY consumerSecret:TUMBLR_SECRET redirectUrl:TUMBLR_URL];
            [platformsRegister setupFlickrWithApiKey:FLICKR_KEY apiSecret:FLICKR_SECRET];
    }];
#endif
}

-(void)showShareToPlatForm:(ZBShareType)shareType inVC:(UIViewController *)VC fromView:(UIView *)shareView title:(NSString *)title content:(NSString *)content image:(UIImage *)image
{
//    [self simplyShare];
//    return;
    self.rootVC = VC;
    switch (shareType) {
        case ZBShareTypeInstagram:
            [self sendInstagramInVC:VC title:title content:content image:image];
            break;
        case ZBShareTypeMail:
            [self sendMailInVC:VC title:title content:content image:image recipients:nil];
            break;
        case ZBShareTypeSMS:
            [self sendSMSInVC:VC title:title content:content image:image];
            break;
        case ZBShareTypeSave:
            [self saveToAlbumn:image];
            break;
        case ZBShareTypeMore:
            [self shareMore:image inVC:VC fromView:shareView];
            break;
        default:
            [self ShareSDKShowShareToPlatForm:shareType inVC:VC fromView:shareView title:title content:content image:image];
            break;
    }
}

-(void)shareMore:(UIImage *)image inVC:(UIViewController *)VC fromView:(UIView *)shareView
{
    NSString *textToShare = NSLocalizedString(@"SHARE_TEXT", @"Share");
    
    UIImage *imageToShare = image;
    
    NSURL *urlToShare = [NSURL URLWithString:APP_URL];
    
    NSArray *activityItems = nil;
    
    if (imageToShare != nil) {
//        activityItems = @[textToShare, urlToShare, imageToShare];
        activityItems = @[textToShare, imageToShare];
    }
    else
    {
        activityItems = @[textToShare, urlToShare];
    }
    
    NSArray *applicationActivities = nil;
    NSArray *excludedActivityTypes = nil;

    excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:applicationActivities];
    
    //不出现在活动项目
    activityVC.excludedActivityTypes = excludedActivityTypes;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
        self.popController = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        CGRect frame = shareView.frame;
        frame.origin = [VC.view convertPoint:frame.origin fromView:shareView.superview];
        [self.popController presentPopoverFromRect:frame inView:VC.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [VC presentViewController:activityVC animated:TRUE completion:nil];
    }
}

-(void)saveToAlbumn:(UIImage *)image
{
#ifdef APP_ALBUM_FOLDER
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library saveImage:image toAlbum:[[ShareService defaultService] getAppName] withCompletionBlock:^(NSError *error) {
        ShareServiceResult result = kShareServiceSuccess;
        if (error) {
            result = kShareServiceFail;
        }
        [self tryReportShare:ZBShareTypeSave result:result];
    }];
#else
    UIImage *shareImage = image;
    
    UIImageWriteToSavedPhotosAlbum(shareImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
#endif
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    ShareServiceResult result = kShareServiceSuccess;
    if (error != nil) {
        result = kShareServiceFail;
    }
    [self tryReportShare:ZBShareTypeSave result:result];
//    [self tryReportSaveResult:result];
}
#ifdef USE_SHARESDK

-(SSDKPlatformType)shareTypeFromZBShareType:(ZBShareType)shareType
{
    return (SSDKPlatformType)shareType;
}
#endif


-(void)ShareSDKShowShareToPlatForm:(ZBShareType)shareType inVC:(UIViewController *)VC fromView:(UIView *)shareView title:(NSString *)title content:(NSString *)content image:(UIImage *)image
{
#ifdef USE_SHARESDK

    if (image == nil) {
        return;
    }
//    if (shareType==ZBShareTypeQQ || shareType==ZBShareTypeQQSpace)
    {
        image = [image rotateAndScaleWithMaxSize:640];
    }
    
    NSArray* imageArray = @[image];
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    SSDKContentType contentType = SSDKContentTypeAuto;
    
    if (shareType==ZBShareTypeQQ || shareType==ZBShareTypeQQSpace) {
        contentType = SSDKContentTypeImage;
    }
    else if (shareType==ZBShareTypeWeixiTimeline)
    {
        title = content;
    }
    

    {
        [shareParams SSDKSetupShareParamsByText:content
                                         images:imageArray
                                            url:[NSURL URLWithString:APP_URL]
                                          title:title
                                           type:contentType];

        [ShareSDK showShareEditor:[self shareTypeFromZBShareType:shareType]
               otherPlatformTypes:nil
                      shareParams:shareParams
              onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
         {
             if ((state==SSDKResponseStateFail || state==SSDKResponseStateSuccess || state==SSDKResponseStateCancel) && end) {
                 ShareServiceResult result = kShareServiceSuccess;
                 if (state == SSDKResponseStateFail && [error description] != nil)
                 {
                     result = kShareServiceFail;
                     
                     if (shareType == SSDKPlatformSubTypeWechatSession || shareType == SSDKPlatformTypeWhatsApp)
                     {
                         result = kShareServiceDeviceNotSupport;
                     }
                 }
                 else if (state == SSDKResponseStateCancel)
                 {
                     result = kShareServiceUserCancel;
                 }
                 else if (state == SSDKResponseStateSuccess)
                 {
                     result = kShareServiceSuccess;
                 }
                 
                 [self tryReportShare:shareType result:result];
             }
         }];
    }
#else
    NSAssert(NO, @"Set USE_SHARE to YES to enable sdk share! You should also make sure ShareSDK is added to the project!");
#endif
}
-(void)sendInstagramInVC:(UIViewController *)VC  title:(NSString *)title content:(NSString *)content image:(UIImage *)image
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://media?id=MEDIA_ID"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        UIImage *shareImage = image;
        
        const CGFloat sizeLimit = 640;
        
        CGSize imageSize = shareImage.size;
        CGFloat widthFactor = sizeLimit/imageSize.width;
        CGFloat heightFactor = sizeLimit/imageSize.height;
        
        CGFloat factor = MIN(widthFactor, heightFactor);
        
        UIGraphicsBeginImageContext(CGSizeMake(sizeLimit, sizeLimit));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation((sizeLimit-factor*imageSize.width)/2.0, (sizeLimit-factor*imageSize.height)/2.0));
        CGContextConcatCTM(context, CGAffineTransformMakeScale(factor, -factor));
        CGContextConcatCTM(context, CGAffineTransformMakeTranslation(0, -imageSize.height));
        CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), shareImage.CGImage);
        shareImage = UIGraphicsGetImageFromCurrentImageContext();
        //UIImageWriteToSavedPhotosAlbum(shareImage, nil, nil, nil);
        UIGraphicsEndImageContext();
        
        NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/instagram.igo"];
        NSURL *igImageHookFile = [[NSURL alloc] initWithString:[[NSString alloc] initWithFormat:@"file://%@", jpgPath]];
        NSData *data = UIImageJPEGRepresentation(shareImage, 1.0);
        [data writeToURL:igImageHookFile atomically:YES];
        UIDocumentInteractionController *documentController = [UIDocumentInteractionController interactionControllerWithURL:igImageHookFile];
        documentController.UTI = @"com.instagram.exclusivegram";
        [documentController presentOpenInMenuFromRect:CGRectZero inView:VC.view animated:YES];
        self.documentController = documentController;
    }
    else {
        [self tryReportShare:ZBShareTypeInstagram  result:kShareServiceDeviceNotSupport];
    }
}

-(BOOL)sendMailInVC:(UIViewController *)VC  title:(NSString *)title content:(NSString *)content image:(UIImage *)image recipients:(NSArray *)recipients
{
    BOOL send = NO;

    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        if ([mailClass canSendMail])
        {
            self.rootVC = VC;

            MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
            
            mailPicker.mailComposeDelegate = self;
            mailPicker.delegate = self;
            UIImage *shareImage = image;
            
            if (shareImage) {
                // 添加图片
                NSData *imageData = UIImageJPEGRepresentation(shareImage, 1);
                [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"final.jpg"];

            }
            [mailPicker setSubject:title];
            [mailPicker setToRecipients:recipients];
            [mailPicker setMessageBody:content isHTML:YES];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                mailPicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [VC presentViewController:mailPicker animated:YES completion:nil];
            send = YES;
        }
        else
        {
            [self tryReportShare:ZBShareTypeMail result:kShareServiceDeviceNotSupport];
        }
    }
    else
    {
        [self tryReportShare:ZBShareTypeMail result:kShareServiceDeviceNotSupport];
    }
    return send;
}

-(BOOL)sendMailInVC:(UIViewController *)VC  title:(NSString *)title content:(NSString *)content gifImageData:(NSData *)imageData recipients:(NSArray *)recipients
{
    BOOL send = NO;
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        if ([mailClass canSendMail])
        {
            self.rootVC = VC;
            
            MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
            
            mailPicker.mailComposeDelegate = self;
            mailPicker.delegate = self;
            
            if (imageData) {
                // 添加图片
                [mailPicker addAttachmentData: imageData mimeType: @"image/gif" fileName: @"final.gif"];
            }
            [mailPicker setSubject:title];
            [mailPicker setToRecipients:recipients];
            [mailPicker setMessageBody:content isHTML:YES];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                mailPicker.modalPresentationStyle = UIModalPresentationFormSheet;
            [VC presentViewController:mailPicker animated:YES completion:nil];
            send = YES;
        }
        else
        {
            [self tryReportShare:ZBShareTypeMail result:kShareServiceDeviceNotSupport];
        }
    }
    else
    {
        [self tryReportShare:ZBShareTypeMail result:kShareServiceDeviceNotSupport];
    }
    return send;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.rootVC dismissViewControllerAnimated:YES completion:^{
        ShareServiceResult shareResult = kShareServiceSuccess;
        switch (result) {
            case MFMailComposeResultSent:
                shareResult = kShareServiceSuccess;
                break;
            case MFMailComposeResultSaved:
                shareResult = kShareServiceSaveCraft;
                break;
            case MFMailComposeResultCancelled:
                shareResult = kShareServiceUserCancel;
                break;
            case MFMailComposeResultFailed:
                shareResult = kShareServiceFail;
                break;
            default:
                break;
        }
        [self tryReportShare:ZBShareTypeMail result:shareResult];
    }];
}

-(BOOL)sendSMSInVC:(UIViewController *)VC title:(NSString *)title content:(NSString *)content image:(UIImage *)image
{
    BOOL send = NO;

    Class mailClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (mailClass != nil)
    {
        if ([mailClass canSendText])
        {
            self.rootVC = VC;

            MFMessageComposeViewController *smsPicker = [[MFMessageComposeViewController alloc] init];
            
            smsPicker.messageComposeDelegate = self;
            [smsPicker setBody:content];
            [smsPicker setTitle:title];
            
            UIImage *shareImage = image;
            // 添加图片
            NSData *imageData = UIImageJPEGRepresentation(shareImage, 1);
            
            if ([smsPicker respondsToSelector:@selector(addAttachmentData:typeIdentifier:filename:)]) {
                [smsPicker addAttachmentData:imageData typeIdentifier:@"image/jpeg" filename:@"image.jpeg"];
                [VC presentViewController:smsPicker animated:YES completion:nil];
            }
            else
            {
                [UIPasteboard generalPasteboard].image = shareImage;
                [VC presentViewController:smsPicker animated:YES completion:^{
                }];
            }
            send = YES;

        }
        else
        {
            [self tryReportShare:ZBShareTypeSMS result:kShareServiceDeviceNotSupport];
        }
    }
    else
    {
        [self tryReportShare:ZBShareTypeSMS result:kShareServiceDeviceNotSupport];
    }
    return send;
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self.rootVC dismissViewControllerAnimated:YES completion:^{

        ShareServiceResult shareResult = kShareServiceSuccess;
        switch (result) {
            case MessageComposeResultSent:
                shareResult = kShareServiceSuccess;
                break;
            case MessageComposeResultCancelled:
                shareResult = kShareServiceUserCancel;
                break;
            case MessageComposeResultFailed:
                shareResult = kShareServiceFail;
                break;
            default:
                break;
        }

        [self tryReportShare:ZBShareTypeSMS result:shareResult];

    }];
}

-(void)tryReportShare:(ZBShareType)shareType result:(ShareServiceResult) result
{
    if (self.reportResult) {
        if ([self.delegate respondsToSelector:@selector(shareServiceDidEndShare:shareType:result:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate shareServiceDidEndShare:self shareType:shareType result:result];
            });
        }
    }
}

-(void)tryReportSaveResult:(ShareServiceResult) result
{
    if (self.reportResult) {
        if ([self.delegate respondsToSelector:@selector(shareServiceDidEndSave:result:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate shareServiceDidEndSave:self result:result];
            });
        }
    }
}


-(NSString *)getShareTitle
{
    return [self getAppName];
}

-(NSString *)getShareContent
{
    return [NSString stringWithFormat:@"#%@#%@", [self getAppName], APP_URL];
}

-(NSString *)getAppName
{
    NSString *prodName = NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @"");
    
    if (!prodName || [prodName isEqualToString:@"CFBundleDisplayName"]) {
        NSBundle*bundle =[NSBundle mainBundle];
        NSDictionary*info =[bundle infoDictionary];
        prodName =[info objectForKey:@"CFBundleDisplayName"];
    }
    else if (!prodName)
    {
        prodName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    }
    
    return prodName;
}

-(NSString *)getResultTipMessageWithShareType:(ZBShareType)shareType andResult:(ShareServiceResult)result
{
    NSString *message = nil;
    
    NSString *shareName = nil;
    switch (shareType) {
        case ZBShareTypeInstagram:
            shareName = NSLocalizedStringFromTable(@"SHARE_INSTAGRAM", @"share", @"instagram for locale");
            break;
        case ZBShareTypeSMS:
            shareName = NSLocalizedStringFromTable(@"SHARE_SMS", @"share", @"sms for locale");
            break;
        case ZBShareTypeFlickr:
            shareName = NSLocalizedStringFromTable(@"SHARE_FLICKR", @"share", @"flickr for locale");
            break;
        case ZBShareTypeWhatsApp:
            shareName = NSLocalizedStringFromTable(@"SHARE_WHATSAPP", @"share", @"whatsapp for locale");
            break;
        case ZBShareTypeMail:
            shareName = NSLocalizedStringFromTable(@"SHARE_MAIL", @"share", @"mail for locale");
            break;
        case ZBShareTypeDropbox:
            shareName = NSLocalizedStringFromTable(@"SHARE_DROPBOX", @"share", @"dropbox for locale");
            break;
        case ZBShareTypeFacebook:
            shareName = NSLocalizedStringFromTable(@"SHARE_FACEBOOK", @"share", @"facebook for locale");
            break;
        case ZBShareTypeTencentWeibo:
            shareName = NSLocalizedStringFromTable(@"SHARE_TC_WEIBO", @"share", @"tc weibo for locale");
            break;
        case ZBShareTypeWeixiSession:
            shareName = NSLocalizedStringFromTable(@"SHARE_WECHAT", @"share", @"wechat for locale");
            break;
        case ZBShareTypeSinaWeibo:
            shareName = NSLocalizedStringFromTable(@"SHARE_SINA_WEIBO", @"share", @"sina weibo for locale");
            break;
        case ZBShareTypeLinkedIn:
            shareName = NSLocalizedStringFromTable(@"SHARE_LINKEDIN", @"share", @"linkedin for locale");
            break;
        case ZBShareTypeTumblr:
            shareName = NSLocalizedStringFromTable(@"SHARE_TUMBLR", @"share", @"tumblr for locale");
            break;
        case ZBShareTypeVKontakte:
            shareName = NSLocalizedStringFromTable(@"SHARE_VKONTAKTE", @"share", @"vkontakte for locale");
            break;
        case ZBShareTypeTwitter:
            shareName = NSLocalizedStringFromTable(@"SHARE_TWITTER", @"share", @"twitter for locale");
            break;
        case ZBShareTypeAirPrint:
            shareName = NSLocalizedStringFromTable(@"SHARE_AIRPRINT", @"share", @"airprint for locale");
            break;
        case ZBShareTypeCopy:
            shareName = NSLocalizedStringFromTable(@"SHARE_COPY", @"share", @"copy for locale");
            break;
        case ZBShareTypeQQ:
            shareName = NSLocalizedStringFromTable(@"SHARE_QQ", @"share", @"copy for locale");
            break;
        case ZBShareTypeQQSpace:
            shareName = NSLocalizedStringFromTable(@"SHARE_QQ_SPACE", @"share", @"copy for locale");
            break;
        case ZBShareTypeWeixiTimeline:
            shareName = NSLocalizedStringFromTable(@"SHARE_WECHAT_TIMELINE", @"share", @"copy for locale");
            break;
        default:
            break;
    }
    
    switch (result) {
        case kShareServiceDeviceNotSupport:
        {
            if (shareType == ZBShareTypeInstagram) {
                message = [NSString stringWithFormat:@"%@%@%@%@", NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_SUFFIX", @"share", @""),  NSLocalizedStringFromTable(@"SHARE_INSTAGRAM_NOT_INSTALLED", @"share", @"")];
            }
            else if (shareType == ZBShareTypeWhatsApp)
            {
                message = [NSString stringWithFormat:@"%@%@%@%@", NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_SUFFIX", @"share", @""), NSLocalizedStringFromTable(@"SHARE_WHATSAPP_NOT_INSTALLED", @"share", @"")];
            }
            else if (shareType == ZBShareTypeWeixiSession || shareType == ZBShareTypeWeixiTimeline)
            {
                message = [NSString stringWithFormat:@"%@%@%@%@", NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_SUFFIX", @"share", @""), NSLocalizedStringFromTable(@"SHARE_WECHAT_NOT_INSTALLED", @"share", @"")];
                
            }
            else if (shareType == ZBShareTypeQQSpace || shareType==ZBShareTypeQQ)
            {
                message = [NSString stringWithFormat:@"%@%@%@", NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_SUFFIX", @"share", @"")];
            }
            else
            {
                message = [NSString stringWithFormat:@"%@%@%@", NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_NOT_SUPPORT_SUFFIX", @"share", @"")];
            }
            break;
        }
        case kShareServiceFail:
        {
            message = [NSString stringWithFormat:@"%@%@%@", NSLocalizedStringFromTable(@"SHARE_FAIL_PREFIX", @"share", @""), shareName, NSLocalizedStringFromTable(@"SHARE_FAIL_SUFFIX", @"share", @"")];
            break;
        }
        default:
            break;
    }
    
    return message;
}

@end
