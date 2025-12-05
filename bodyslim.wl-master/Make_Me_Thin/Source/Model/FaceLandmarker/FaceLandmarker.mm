//
//  FaceLandmarker.m
//  Make_Me_Thin
//
//  Created by ZB_Mac on 16/4/12.
//  Copyright © 2016年 ZB_Mac. All rights reserved.
//

#import "FaceLandmarker.h"
#import "LuxandLandmark.h"
#import "UIImage+Rotation.h"
#import "UIImage+mat.h"
#import "CGPointUtility.h"
#import "APIKey+APISecret.h"

#ifdef ENABLE_LUXAND
#import "LuxandFaceSDK.h"
#endif

#ifdef ENABLE_ZB
#import "ZBFaceAligment.h"
#endif

@interface FaceLandmarker()
    @property BOOL luxandInit;
    @property BOOL faceppInit;
    @property BOOL scaleImage;
    @property CGFloat scaleImageRatio;
@end

@implementation FaceLandmarker
+(FaceLandmarker *)defaultLandmarker
{
    static dispatch_once_t once;
    static FaceLandmarker* manger = nil;
    dispatch_once(&once, ^{
        manger = [[FaceLandmarker alloc] init];
    });
    return manger;
}

-(FaceLandmarker *)init
{
    self = [super init];
    
    if (self) {
        _scaleImage = YES;
    }
    
    return self;
}

-(void)clear
{
#ifdef ENABLE_LUXAND
    [self finalizeLuxand];
#endif
}

#pragma mark -- Detection Entrance

-(void)asynLandmarkImage:(UIImage *)image withMethodList:(NSArray *)methods andEndBlock:(void (^)(NSArray* landmarks))endBlock;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block NSArray *array;
        for (NSInteger idx=0; idx<methods.count; ++idx) {
            LandmarkMethod method = (LandmarkMethod)[methods[idx] integerValue];
            
            switch (method) {
                case LandmarkMethodFacepp:
                {
                    dispatch_group_t detectGroup = dispatch_group_create();
                    
                    dispatch_group_enter(detectGroup);
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        
                        array = [self landmarkImageWithFacepp:image];
                        
                        dispatch_group_leave(detectGroup);
                    });
                    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(16.0 * NSEC_PER_SEC));
                    
                    dispatch_group_wait(detectGroup, timeout);
                    
                    break;
                }
                case LandmarkMethodLuxand:
#ifdef ENABLE_LUXAND
                    array = [self landmarkImageWithLuxand:image];
#else
                    exit(-1);
#endif
                    break;
                case LandmarkMethodCI:
                    array = [self landmarkImageWithCI:image];
                    break;
                case LandmarkMethodGuess:
                    array = [self landmarkImageWithGuess:image];
                    break;
                case LandmarkMethodZB:
#ifdef ENABLE_ZB
                    array = [self landmarkImageWithZB:image];
#else
                    exit(-1);
#endif
                    break;
                default:
                    break;
            }
            
//            if (array.count>0)
//            {
                break;
//            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (endBlock) {
                endBlock(array);
            }
        });
    });
}

-(NSArray *)landmarkImage:(UIImage *)image withMethodList:(NSArray *)methods
{
    NSArray *array;
    for (NSInteger idx=0; idx<methods.count; ++idx) {
        LandmarkMethod method = (LandmarkMethod)[methods[idx] integerValue];
        
        switch (method) {
            case LandmarkMethodFacepp:
                array = [self landmarkImageWithFacepp:image];
                break;
            case LandmarkMethodLuxand:
#ifdef ENABLE_LUXAND
                array = [self landmarkImageWithLuxand:image];
#else
                exit(-1);
#endif
                break;
            case LandmarkMethodCI:
                array = [self landmarkImageWithCI:image];
                break;
            case LandmarkMethodGuess:
                array = [self landmarkImageWithGuess:image];
                break;
            case LandmarkMethodZB:
#ifdef ENABLE_ZB
                array = [self landmarkImageWithZB:image];
#else
                exit(-1);
#endif
                break;
            default:
                break;
        }
        
        if (array.count > 0) {
            break;
        }
    }
    
    return array;
}

#pragma mark -- LandmarkMethodFacepp
-(NSDictionary*) postWithUrl: (NSString*)url image: (NSData*) imageData params: (NSDictionary*)params {
    
    // create request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    
    // set Content-Type in HTTP header
    
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    NSString *boundary = [NSString stringWithFormat:@"Boundary-%@", uuidStr];
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [[NSMutableData alloc] init];
    
    // add image data
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image_file\"; filename=\"image.jpeg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    NSMutableString *urlString = [NSMutableString stringWithString:url];
    if (params) {
        [urlString appendString:@"?"];
        NSArray *allKeys = params.allKeys;
        for (NSInteger idx=0; idx<allKeys.count; ++idx) {
            if (idx!=0) {
                [urlString appendFormat:@"&%@=%@", allKeys[idx], params[allKeys[idx]]];
            } else {
                [urlString appendFormat:@"%@=%@", allKeys[idx], params[allKeys[idx]]];
            }
        }
    }
    
    // set URL
    [request setURL: [NSURL URLWithString:urlString]];
    
    NSHTTPURLResponse* urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    
    NSDictionary *result = nil;
    
    if (responseData && urlResponse.statusCode == 200) {
        result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
    }
    
    return result;
}

-(NSArray *)landmarkImageWithFacepp:(UIImage *)image;
{
    if (_scaleImage) {
        _scaleImageRatio = 512.0/MAX(image.size.width, image.size.height);
        image = [image rotateAndScale:_scaleImageRatio];
    }
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);//image为要上传的图片(UIImage)
    NSString *postUrl = nil;
    NSDictionary *dict = nil;
    if ([self isInChina])
    {
        postUrl = _CN_SERVER_ADDRESS;//URL
        dict = @{
                               @"api_key":_API_KEY_CN,
                               @"api_secret":_API_SECRET_CN,
                               @"return_landmark":@"1",
                               @"return_attributes":@"gender,age,headpose,ethnicity",
                               };
    }
    else
    {
        postUrl = _US_SERVER_ADDRESS;//URL
        dict = @{
                               @"api_key":_API_KEY_US,
                               @"api_secret":_API_SECRET_US,
                               @"return_landmark":@"1",
                               @"return_attributes":@"gender,age,headpose,ethnicity",
                               };
    }
    
    const int MAX_TRY_CNT = 8;
    
    __block NSDictionary *result = nil;
    result = [self postWithUrl:postUrl image:imageData params:dict];
    for (int tryCnt = 0; !result; ++tryCnt) {
        if (tryCnt < MAX_TRY_CNT) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                result = [self postWithUrl:postUrl image:imageData params:dict];
            });
        } else {
            return nil;
        }
    }

    NSArray *faces = result[@"faces"];

    NSMutableArray *landmarks = [NSMutableArray array];

    for (NSInteger idx=0; idx<faces.count; ++idx) {
        NSDictionary *face = faces[idx];

        LuxandLandmark *landmark = [[LuxandLandmark alloc] init];
        landmark.resultSource = LandmarkSourceFacePP;
        landmark.resultValid = YES;
        
        NSDictionary *firstFaceFeatures = face[@"landmark"];

        CGPoint point;
        // 原始图片中眉毛轮廓点
        point.x = [firstFaceFeatures[@"left_eyebrow_left_corner"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eyebrow_left_corner"][@"y"] doubleValue];
        
        landmark.leftEyeBrowLeft = point;
        point.x = [firstFaceFeatures[@"left_eyebrow_lower_left_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eyebrow_lower_left_quarter"][@"y"] doubleValue];
        
        landmark.leftEyeBrowLeftQuater = point;
        point.x = [firstFaceFeatures[@"left_eyebrow_lower_middle"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eyebrow_lower_middle"][@"y"] doubleValue];
        
        landmark.leftEyeBrowMiddle = point;
        point.x = [firstFaceFeatures[@"left_eyebrow_lower_right_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eyebrow_lower_right_quarter"][@"y"] doubleValue];
        
        landmark.leftEyeBrowRightQuater = point;
        point.x = [firstFaceFeatures[@"left_eyebrow_right_corner"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eyebrow_right_corner"][@"y"] doubleValue];
        
        landmark.leftEyeBrowRight = point;
        point.x = [firstFaceFeatures[@"left_eyebrow_upper_left_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eyebrow_upper_left_quarter"][@"y"] doubleValue];
        
        
        //                    landmark.leftEyeBrowUpperLeftQuater = point;
        //                    point.x = [firstFaceFeatures[@"left_eyebrow_upper_middle"][@"x"] doubleValue];
        //                    point.y = [firstFaceFeatures[@"left_eyebrow_upper_middle"][@"y"] doubleValue];
        //
        //                    landmark.leftEyeBrowUpperMiddle = point;
        //                    point.x = [firstFaceFeatures[@"left_eyebrow_upper_right_quarter"][@"x"] doubleValue];
        //                    point.y = [firstFaceFeatures[@"left_eyebrow_upper_right_quarter"][@"y"] doubleValue];
        //
        //                    landmark.leftEyeBrowUpperRightQuater = point;
        
        point.x = [firstFaceFeatures[@"right_eyebrow_left_corner"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eyebrow_left_corner"][@"y"] doubleValue];
        
        landmark.rightEyeBrowLeft = point;
        point.x = [firstFaceFeatures[@"right_eyebrow_lower_left_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eyebrow_lower_left_quarter"][@"y"] doubleValue];
        
        landmark.rightEyeBrowLeftQuater = point;
        point.x = [firstFaceFeatures[@"right_eyebrow_lower_middle"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eyebrow_lower_middle"][@"y"] doubleValue];
        
        landmark.rightEyeBrowMiddle = point;
        point.x = [firstFaceFeatures[@"right_eyebrow_lower_right_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eyebrow_lower_right_quarter"][@"y"] doubleValue];
        
        landmark.rightEyeBrowRightQuater = point;
        point.x = [firstFaceFeatures[@"right_eyebrow_right_corner"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eyebrow_right_corner"][@"y"] doubleValue];
        
        landmark.rightEyeBrowRight = point;
        
        //                    point.x = [firstFaceFeatures[@"right_eyebrow_upper_left_quarter"][@"x"] doubleValue];
        //                    point.y = [firstFaceFeatures[@"right_eyebrow_upper_left_quarter"][@"y"] doubleValue];
        //
        //                    landmark.rightEyeBrowUpperLeftQuater = point;
        //                    point.x = [firstFaceFeatures[@"right_eyebrow_upper_middle"][@"x"] doubleValue];
        //                    point.y = [firstFaceFeatures[@"right_eyebrow_upper_middle"][@"y"] doubleValue];
        //
        //                    landmark.rightEyeBrowUpperMiddle = point;
        //                    point.x = [firstFaceFeatures[@"right_eyebrow_upper_right_quarter"][@"x"] doubleValue];
        //                    point.y = [firstFaceFeatures[@"right_eyebrow_upper_right_quarter"][@"y"] doubleValue];
        //
        //                    landmark.rightEyeBrowUpperRightQuater = point;
        
        
        // 原始图片中眼睛轮廓点
        point.x = [firstFaceFeatures[@"left_eye_left_corner"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eye_left_corner"][@"y"] doubleValue];
        
        landmark.leftEyeLeft = point;
        point.x = [firstFaceFeatures[@"left_eye_bottom"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eye_bottom"][@"y"] doubleValue];
        
        landmark.leftEyeBottom = point;
        point.x = [firstFaceFeatures[@"left_eye_right_corner"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eye_right_corner"][@"y"] doubleValue];
        
        landmark.leftEyeRight = point;
        point.x = [firstFaceFeatures[@"left_eye_top"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eye_top"][@"y"] doubleValue];
        
        landmark.leftEyeTop = point;
        point.x = [firstFaceFeatures[@"left_eye_center"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eye_center"][@"y"] doubleValue];
        
        landmark.leftEyeCenter = point;
        point.x = [firstFaceFeatures[@"left_eye_lower_left_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eye_lower_left_quarter"][@"y"] doubleValue];
        
        landmark.leftEyeLowerLeftQuarter = point;
        point.x = [firstFaceFeatures[@"left_eye_lower_right_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eye_lower_right_quarter"][@"y"] doubleValue];
        
        landmark.leftEyeLowerRightQuarter = point;
        point.x = [firstFaceFeatures[@"left_eye_upper_left_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eye_upper_left_quarter"][@"y"] doubleValue];
        
        landmark.leftEyeUpperLeftQuarter = point;
        point.x = [firstFaceFeatures[@"left_eye_upper_right_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"left_eye_upper_right_quarter"][@"y"] doubleValue];
        
        landmark.leftEyeUpperRightQuarter = point;
        //                    point.x = [firstFaceFeatures[@"left_eye_pupil"][@"x"] doubleValue];
        //                    point.y = [firstFaceFeatures[@"left_eye_pupil"][@"y"] doubleValue];
        //
        //                    landmark.leftEyePupil = point;
        
        point.x = [firstFaceFeatures[@"right_eye_left_corner"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eye_left_corner"][@"y"] doubleValue];
        
        landmark.rightEyeLeft = point;
        point.x = [firstFaceFeatures[@"right_eye_bottom"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eye_bottom"][@"y"] doubleValue];
        
        landmark.rightEyeBottom = point;
        point.x = [firstFaceFeatures[@"right_eye_right_corner"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eye_right_corner"][@"y"] doubleValue];
        
        landmark.rightEyeRight = point;
        point.x = [firstFaceFeatures[@"right_eye_top"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eye_top"][@"y"] doubleValue];
        
        landmark.rightEyeTop = point;
        point.x = [firstFaceFeatures[@"right_eye_center"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eye_center"][@"y"] doubleValue];
        
        landmark.rightEyeCenter = point;
        point.x = [firstFaceFeatures[@"right_eye_lower_left_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eye_lower_left_quarter"][@"y"] doubleValue];
        
        landmark.rightEyeLowerLeftQuarter = point;
        point.x = [firstFaceFeatures[@"right_eye_lower_right_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eye_lower_right_quarter"][@"y"] doubleValue];
        
        landmark.rightEyeLowerRightQuarter = point;
        point.x = [firstFaceFeatures[@"right_eye_upper_left_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eye_upper_left_quarter"][@"y"] doubleValue];
        
        landmark.rightEyeUpperLeftQuarter = point;
        point.x = [firstFaceFeatures[@"right_eye_upper_right_quarter"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"right_eye_upper_right_quarter"][@"y"] doubleValue];
        
        landmark.rightEyeUpperRightQuarter = point;
        //                                    point.x = [firstFaceFeatures[@"right_eye_pupil"][@"x"] doubleValue];
        //                                    point.y = [firstFaceFeatures[@"right_eye_pupil"][@"y"] doubleValue];
        //
        //                                    landmark.rightEyePupil = point;
        
        // 原始图片中鼻子轮廓点
        point.x = [firstFaceFeatures[@"nose_tip"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"nose_tip"][@"y"] doubleValue];
        
        landmark.noseTip = point;
        point.x = [firstFaceFeatures[@"nose_contour_lower_middle"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"nose_contour_lower_middle"][@"y"] doubleValue];
        
        landmark.noseLowerMiddleContour = point;
        point.x = [firstFaceFeatures[@"nose_left"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"nose_left"][@"y"] doubleValue];
        
        landmark.noseLeft = point;
        //                                    point.x = [firstFaceFeatures[@"nose_contour_left1"][@"x"] doubleValue];
        //                                    point.y = [firstFaceFeatures[@"nose_contour_left1"][@"y"] doubleValue];
        //
        //                                    landmark.noseLeftContour1 = point;
        point.x = [firstFaceFeatures[@"nose_contour_left2"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"nose_contour_left2"][@"y"] doubleValue];
        
        landmark.noseLeftContour2 = point;
        point.x = [firstFaceFeatures[@"nose_contour_left3"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"nose_contour_left3"][@"y"] doubleValue];
        
        landmark.noseLeftContour3 = point;
        point.x = [firstFaceFeatures[@"nose_right"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"nose_right"][@"y"] doubleValue];
        
        landmark.noseRight = point;
        //                                    point.x = [firstFaceFeatures[@"nose_contour_right1"][@"x"] doubleValue];
        //                                    point.y = [firstFaceFeatures[@"nose_contour_right1"][@"y"] doubleValue];
        //
        //                                    landmark.noseRightContour1 = point;
        point.x = [firstFaceFeatures[@"nose_contour_right2"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"nose_contour_right2"][@"y"] doubleValue];
        
        landmark.noseRightContour2 = point;
        point.x = [firstFaceFeatures[@"nose_contour_right3"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"nose_contour_right3"][@"y"] doubleValue];
        
        landmark.noseRightContour3 = point;
        
        // 原始图片中嘴巴轮廓点
        point.x = [firstFaceFeatures[@"mouth_left_corner"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_left_corner"][@"y"] doubleValue];
        
        landmark.mouthLeft = point;
        point.x = [firstFaceFeatures[@"mouth_right_corner"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_right_corner"][@"y"] doubleValue];
        
        landmark.mouthRight = point;
        
        point.x = [firstFaceFeatures[@"mouth_lower_lip_bottom"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_lower_lip_bottom"][@"y"] doubleValue];
        
        landmark.mouthLowerLipBottom = point;
        point.x = [firstFaceFeatures[@"mouth_lower_lip_left_contour1"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_lower_lip_left_contour1"][@"y"] doubleValue];
        
        landmark.mouthLowerLipLeftContour1 = point;
        //                                    point.x = [firstFaceFeatures[@"mouth_lower_lip_left_contour2"][@"x"] doubleValue];
        //                                    point.y = [firstFaceFeatures[@"mouth_lower_lip_left_contour2"][@"y"] doubleValue];
        //
        //                                    landmark.mouthLowerLipLeftContour2 = point;
        point.x = [firstFaceFeatures[@"mouth_lower_lip_left_contour3"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_lower_lip_left_contour3"][@"y"] doubleValue];
        
        landmark.mouthLowerLipLeftContour3 = point;
        point.x = [firstFaceFeatures[@"mouth_lower_lip_right_contour1"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_lower_lip_right_contour1"][@"y"] doubleValue];
        
        landmark.mouthLowerLipRightContour1 = point;
        //                                    point.x = [firstFaceFeatures[@"mouth_lower_lip_right_contour2"][@"x"] doubleValue];
        //                                    point.y = [firstFaceFeatures[@"mouth_lower_lip_right_contour2"][@"y"] doubleValue];
        //
        //                                    landmark.mouthLowerLipRightContour2 = point;
        point.x = [firstFaceFeatures[@"mouth_lower_lip_right_contour3"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_lower_lip_right_contour3"][@"y"] doubleValue];
        
        landmark.mouthLowerLipRightContour3 = point;
        point.x = [firstFaceFeatures[@"mouth_lower_lip_top"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_lower_lip_top"][@"y"] doubleValue];
        
        landmark.mouthLowerLipTop = point;
        
        point.x = [firstFaceFeatures[@"mouth_upper_lip_bottom"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_upper_lip_bottom"][@"y"] doubleValue];
        
        landmark.mouthUpperLipBottom = point;
        //                                    point.x = [firstFaceFeatures[@"mouth_upper_lip_left_contour1"][@"x"] doubleValue];
        //                                    point.y = [firstFaceFeatures[@"mouth_upper_lip_left_contour1"][@"y"] doubleValue];
        //
        //                                    landmark.mouthUpperLipLeftContour1 = point;
        point.x = [firstFaceFeatures[@"mouth_upper_lip_left_contour2"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_upper_lip_left_contour2"][@"y"] doubleValue];
        
        landmark.mouthUpperLipLeftContour2 = point;
        point.x = [firstFaceFeatures[@"mouth_upper_lip_left_contour3"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_upper_lip_left_contour3"][@"y"] doubleValue];
        
        landmark.mouthUpperLipLeftContour3 = point;
        //                                    point.x = [firstFaceFeatures[@"mouth_upper_lip_right_contour1"][@"x"] doubleValue];
        //                                    point.y = [firstFaceFeatures[@"mouth_upper_lip_right_contour1"][@"y"] doubleValue];
        //
        //                                    landmark.mouthUpperLipRightContour1 = point;
        point.x = [firstFaceFeatures[@"mouth_upper_lip_right_contour2"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_upper_lip_right_contour2"][@"y"] doubleValue];
        
        landmark.mouthUpperLipRightContour2 = point;
        point.x = [firstFaceFeatures[@"mouth_upper_lip_right_contour3"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_upper_lip_right_contour3"][@"y"] doubleValue];
        
        landmark.mouthUpperLipRightContour3 = point;
        point.x = [firstFaceFeatures[@"mouth_upper_lip_top"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"mouth_upper_lip_top"][@"y"] doubleValue];
        
        landmark.mouthUpperLipTop = point;
        
        // 原始图像中脸部轮廓点
        point.x = [firstFaceFeatures[@"contour_left1"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_left1"][@"y"] doubleValue];
        
        landmark.contourLeft1 = point;
        point.x = [firstFaceFeatures[@"contour_left2"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_left2"][@"y"] doubleValue];
        
        landmark.contourLeft2 = point;
        point.x = [firstFaceFeatures[@"contour_left3"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_left3"][@"y"] doubleValue];
        
        landmark.contourLeft3 = point;
        point.x = [firstFaceFeatures[@"contour_left4"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_left4"][@"y"] doubleValue];
        
        landmark.contourLeft4 = point;
        point.x = [firstFaceFeatures[@"contour_left5"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_left5"][@"y"] doubleValue];
        
        landmark.contourLeft5 = point;
        point.x = [firstFaceFeatures[@"contour_left6"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_left6"][@"y"] doubleValue];
        
        landmark.contourLeft6 = point;
        point.x = [firstFaceFeatures[@"contour_left7"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_left7"][@"y"] doubleValue];
        
        landmark.contourLeft7 = point;
        point.x = [firstFaceFeatures[@"contour_left8"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_left8"][@"y"] doubleValue];
        
        landmark.contourLeft8 = point;
        point.x = [firstFaceFeatures[@"contour_left9"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_left9"][@"y"] doubleValue];
        
        landmark.contourLeft9 = point;
        
        point.x = [firstFaceFeatures[@"contour_right1"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_right1"][@"y"] doubleValue];
        
        landmark.contourRight1 = point;
        point.x = [firstFaceFeatures[@"contour_right2"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_right2"][@"y"] doubleValue];
        
        landmark.contourRight2 = point;
        point.x = [firstFaceFeatures[@"contour_right3"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_right3"][@"y"] doubleValue];
        
        landmark.contourRight3 = point;
        point.x = [firstFaceFeatures[@"contour_right4"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_right4"][@"y"] doubleValue];
        
        landmark.contourRight4 = point;
        point.x = [firstFaceFeatures[@"contour_right5"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_right5"][@"y"] doubleValue];
        
        landmark.contourRight5 = point;
        point.x = [firstFaceFeatures[@"contour_right6"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_right6"][@"y"] doubleValue];
        
        landmark.contourRight6 = point;
        point.x = [firstFaceFeatures[@"contour_right7"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_right7"][@"y"] doubleValue];
        
        landmark.contourRight7 = point;
        point.x = [firstFaceFeatures[@"contour_right8"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_right8"][@"y"] doubleValue];
        
        landmark.contourRight8 = point;
        point.x = [firstFaceFeatures[@"contour_right9"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_right9"][@"y"] doubleValue];
        
        landmark.contourRight9 = point;
        
        point.x = [firstFaceFeatures[@"contour_chin"][@"x"] doubleValue];
        point.y = [firstFaceFeatures[@"contour_chin"][@"y"] doubleValue];
        
        landmark.contourChin = point;
        
        CGPoint eyeCenter = [CGPointUtility pointFromPoint:landmark.rightEyeCenter toPoint:landmark.leftEyeCenter byRatio:0.5];
        
        landmark.contourForeHead = [CGPointUtility pointFromPoint:eyeCenter translateByVector:[CGPointUtility vectorFromPoint:landmark.contourChin toPoint:eyeCenter]];
        
        if (_scaleImage) {
            [landmark scaleLandmarkByRatio:1/_scaleImageRatio];
        }
        
        [landmarks addObject:landmark];
    }

    return landmarks;
}

#pragma mark -- LandmarkMethodLuxand
#ifdef ENABLE_LUXAND
-(NSString *) getLuxandKey:(BOOL)forceRemote
{
    NSString *KEY = @"luxandkey_internal";
    NSString *TRY_KEY = @"luxandkey_lasttry_time_internal";
    NSString *URL_LUXAND_KEY = @"http://www.fruitcasino.online/facedetection/luxandkey.txt";
    
    NSString *luxandKey = [[NSUserDefaults standardUserDefaults] objectForKey:KEY];
    long now = time(NULL);
    long lasttry = [[NSUserDefaults standardUserDefaults] integerForKey:TRY_KEY];
    
    if ((!luxandKey || forceRemote) && now-lasttry>600) {
        NSURL *url = [NSURL URLWithString:URL_LUXAND_KEY];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        if (data) {
            luxandKey = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            [[NSUserDefaults standardUserDefaults] setInteger:now forKey:TRY_KEY];
            
            if (luxandKey.length > 10) {
                [[NSUserDefaults standardUserDefaults] setObject:luxandKey forKey:KEY];
            }
        }
    }
    
    return luxandKey;
}

-(BOOL)initializeLuxand
{
    if (_luxandInit) {
        return YES;
    }
    
    const char *key = "v1xYVzEkWN2+pz+kUOMsjvUlKCiqKgIoIBtskNA27yASbJM+5yKlMJ2KFVIMNXqM6AabDPWAgNTFGz92k915IhMPREDDeuqMm0HSBn7WOUygJcssygpRRiHv7O9iJJyTnAdniryGHYJllhdBhKA28jut9aZyv3JyTK9nRZMqsNw=";
    int res = FSDK_ActivateLibrary(key);

    if (res != 0) {
        NSString *remoteKey = [self getLuxandKey:NO];
        key = [remoteKey UTF8String];
        res = FSDK_ActivateLibrary(key);
        NSLog(@"activation result %d\n", res);
        if (res != 0) {
            NSString *remoteKey_2 = [self getLuxandKey:YES];
            if (![remoteKey isEqualToString:remoteKey_2]) {
                key = [remoteKey UTF8String];
                res = FSDK_ActivateLibrary(key);
                NSLog(@"activation result %d\n", res);
            }
        }
    }

    if (res == 0) {
        char licenseInfo[1024];
        FSDK_GetLicenseInfo(licenseInfo);
        //        NSLog(@"license: %s\n", licenseInfo);
        res = FSDK_Initialize((char *)"");
        //        NSLog(@"init result %d\n", res);
        if (res == 0) {
            int threadcount = 0;
            res = FSDK_GetNumThreads(&threadcount);
            //            NSLog(@"thread count %d\n", threadcount);
            if (res == 0) {
                FSDK_SetFaceDetectionParameters(false, false, 120);
                FSDK_SetFaceDetectionThreshold(5);
            }
        }
    }
    
    _luxandInit = (res == 0);
    return res==0;
}

-(void)finalizeLuxand
{
    if (_luxandInit) {
        FSDK_Finalize();
        _luxandInit = NO;
    }
}

-(NSArray *)landmarkImageWithLuxand:(UIImage *)image
{
    unsigned char *ptr = [UIImage data8UC4WithImage:image];
    
    NSArray *array = [self landmarkFaceUsingLuxandWith8UC4Buffer:ptr andWidth:image.size.width andHeight:image.size.height andWidthStep:image.size.width*4];
    //    [UIImage destoryBuffer:ptr];
    delete [] ptr;
    return array;
}

-(NSArray *)landmarkFaceUsingLuxandWith8UC4Buffer:(unsigned char *)buffer andWidth:(int)width andHeight:(int)height andWidthStep:(int)widthStep
{
    if (!_luxandInit) {
        [self initializeLuxand];
        if (!_luxandInit) {
            return nil;
        }
    }
    
    // Load image to FaceSDK
    HImage fsdk_img;
    
    int res = FSDK_LoadImageFromBuffer(&fsdk_img, buffer, width, height, widthStep, FSDK_IMAGE_COLOR_32BIT);
    
    if (res != FSDKE_OK) {
        [self finalizeLuxand];
        return nil;
    }
    
    // Detect face
    BOOL have_face = NO;
    
    int faceCount;
    TFacePosition faceposes[10];
    res = FSDK_DetectMultipleFaces(fsdk_img, &faceCount, faceposes, sizeof(faceposes));
    if (res == FSDKE_OK || (res == FSDKE_INSUFFICIENT_BUFFER_SIZE && faceCount!=0)) {
        have_face = YES;
    }
    
    // Detect features
    BOOL have_features = NO;
    FSDK_Features features;
    NSMutableArray *array = [NSMutableArray array];
    if (have_face) {
        for (int idx=0; idx<faceCount; ++idx) {
            res = FSDK_DetectFacialFeaturesInRegion(fsdk_img, faceposes+idx, &features);
            if (res == FSDKE_OK) {
                have_features = YES;
                LuxandLandmark *landmark;
                if (have_features) {
                    landmark = [self landmarksWithFeature:features];
                    
                    landmark.resultSource = LandmarkSourceLuxand;
                    landmark.imageWidth = width;
                    landmark.imageHeight = height;
                    
                    [array addObject:landmark];
                }
            }
        }
    }
    
    // Unload image from FaceSDK
    FSDK_FreeImage(fsdk_img);
    [self finalizeLuxand];
    return array;
}

-(LuxandLandmark *)landmarksWithFeature:(FSDK_Features) features
{
    LuxandLandmark *landmark = [LuxandLandmark new];
    landmark.resultValid = YES;
    
    landmark.leftEyeBrowLeft = CGPointMake(features[FSDKP_LEFT_EYEBROW_OUTER_CORNER].x, features[FSDKP_LEFT_EYEBROW_OUTER_CORNER].y);
    landmark.leftEyeBrowLeftQuater = CGPointMake(features[FSDKP_LEFT_EYEBROW_MIDDLE_LEFT].x, features[FSDKP_LEFT_EYEBROW_MIDDLE_LEFT].y);
    landmark.leftEyeBrowMiddle = CGPointMake(features[FSDKP_LEFT_EYEBROW_MIDDLE].x, features[FSDKP_LEFT_EYEBROW_MIDDLE].y);
    landmark.leftEyeBrowRightQuater = CGPointMake(features[FSDKP_LEFT_EYEBROW_MIDDLE_RIGHT].x, features[FSDKP_LEFT_EYEBROW_MIDDLE_RIGHT].y);
    landmark.leftEyeBrowRight = CGPointMake(features[FSDKP_LEFT_EYEBROW_INNER_CORNER].x, features[FSDKP_LEFT_EYEBROW_INNER_CORNER].y);
    
    landmark.rightEyeBrowLeft = CGPointMake(features[FSDKP_RIGHT_EYEBROW_INNER_CORNER].x, features[FSDKP_RIGHT_EYEBROW_INNER_CORNER].y);
    landmark.rightEyeBrowLeftQuater = CGPointMake(features[FSDKP_RIGHT_EYEBROW_MIDDLE_LEFT].x, features[FSDKP_RIGHT_EYEBROW_MIDDLE_LEFT].y);
    landmark.rightEyeBrowMiddle = CGPointMake(features[FSDKP_RIGHT_EYEBROW_MIDDLE].x, features[FSDKP_RIGHT_EYEBROW_MIDDLE].y);
    landmark.rightEyeBrowRightQuater = CGPointMake(features[FSDKP_RIGHT_EYEBROW_MIDDLE_RIGHT].x, features[FSDKP_RIGHT_EYEBROW_MIDDLE_RIGHT].y);
    landmark.rightEyeBrowRight = CGPointMake(features[FSDKP_RIGHT_EYEBROW_OUTER_CORNER].x, features[FSDKP_RIGHT_EYEBROW_OUTER_CORNER].y);
    
    landmark.leftEyeCenter = CGPointMake(features[FSDKP_LEFT_EYE].x, features[FSDKP_LEFT_EYE].y);
    landmark.leftEyeLeft = CGPointMake(features[FSDKP_LEFT_EYE_OUTER_CORNER].x, features[FSDKP_LEFT_EYE_OUTER_CORNER].y);
    landmark.leftEyeUpperLeftQuarter = CGPointMake(features[FSDKP_LEFT_EYE_UPPER_LINE1].x, features[FSDKP_LEFT_EYE_UPPER_LINE1].y);
    landmark.leftEyeTop = CGPointMake(features[FSDKP_LEFT_EYE_UPPER_LINE2].x, features[FSDKP_LEFT_EYE_UPPER_LINE2].y);
    landmark.leftEyeUpperRightQuarter = CGPointMake(features[FSDKP_LEFT_EYE_UPPER_LINE3].x, features[FSDKP_LEFT_EYE_UPPER_LINE3].y);
    landmark.leftEyeRight = CGPointMake(features[FSDKP_LEFT_EYE_INNER_CORNER].x, features[FSDKP_LEFT_EYE_INNER_CORNER].y);
    landmark.leftEyeLowerRightQuarter = CGPointMake(features[FSDKP_LEFT_EYE_LOWER_LINE1].x, features[FSDKP_LEFT_EYE_LOWER_LINE1].y);
    landmark.leftEyeBottom = CGPointMake(features[FSDKP_LEFT_EYE_LOWER_LINE2].x, features[FSDKP_LEFT_EYE_LOWER_LINE2].y);
    landmark.leftEyeLowerLeftQuarter = CGPointMake(features[FSDKP_LEFT_EYE_LOWER_LINE3].x, features[FSDKP_LEFT_EYE_LOWER_LINE3].y);
    landmark.leftEyePupilLeft = CGPointMake(features[FSDKP_LEFT_EYE_LEFT_IRIS_CORNER].x, features[FSDKP_LEFT_EYE_LEFT_IRIS_CORNER].y);
    landmark.leftEyePupilRight = CGPointMake(features[FSDKP_LEFT_EYE_RIGHT_IRIS_CORNER].x, features[FSDKP_LEFT_EYE_RIGHT_IRIS_CORNER].y);
    
    landmark.rightEyeCenter = CGPointMake(features[FSDKP_RIGHT_EYE].x, features[FSDKP_RIGHT_EYE].y);
    landmark.rightEyeRight = CGPointMake(features[FSDKP_RIGHT_EYE_OUTER_CORNER].x, features[FSDKP_RIGHT_EYE_OUTER_CORNER].y);
    landmark.rightEyeUpperRightQuarter = CGPointMake(features[FSDKP_RIGHT_EYE_UPPER_LINE1].x, features[FSDKP_RIGHT_EYE_UPPER_LINE1].y);
    landmark.rightEyeTop = CGPointMake(features[FSDKP_RIGHT_EYE_UPPER_LINE2].x, features[FSDKP_RIGHT_EYE_UPPER_LINE2].y);
    landmark.rightEyeUpperLeftQuarter = CGPointMake(features[FSDKP_RIGHT_EYE_UPPER_LINE3].x, features[FSDKP_RIGHT_EYE_UPPER_LINE3].y);
    landmark.rightEyeLeft = CGPointMake(features[FSDKP_RIGHT_EYE_INNER_CORNER].x, features[FSDKP_RIGHT_EYE_INNER_CORNER].y);
    landmark.rightEyeLowerLeftQuarter = CGPointMake(features[FSDKP_RIGHT_EYE_LOWER_LINE1].x, features[FSDKP_RIGHT_EYE_LOWER_LINE1].y);
    landmark.rightEyeBottom = CGPointMake(features[FSDKP_RIGHT_EYE_LOWER_LINE2].x, features[FSDKP_RIGHT_EYE_LOWER_LINE2].y);
    landmark.rightEyeLowerRightQuarter = CGPointMake(features[FSDKP_RIGHT_EYE_LOWER_LINE3].x, features[FSDKP_RIGHT_EYE_LOWER_LINE3].y);
    landmark.rightEyePupilLeft = CGPointMake(features[FSDKP_RIGHT_EYE_LEFT_IRIS_CORNER].x, features[FSDKP_RIGHT_EYE_LEFT_IRIS_CORNER].y);
    landmark.rightEyePupilRight = CGPointMake(features[FSDKP_RIGHT_EYE_RIGHT_IRIS_CORNER].x, features[FSDKP_RIGHT_EYE_RIGHT_IRIS_CORNER].y);
    
    landmark.noseTip = CGPointMake(features[FSDKP_NOSE_TIP].x, features[FSDKP_NOSE_TIP].y);
    landmark.noseTop = CGPointMake(features[FSDKP_NOSE_BRIDGE].x, features[FSDKP_NOSE_BRIDGE].y);
    landmark.noseLowerMiddleContour = CGPointMake(features[FSDKP_NOSE_BOTTOM].x, features[FSDKP_NOSE_BOTTOM].y);
    landmark.noseLeft = CGPointMake(features[FSDKP_NOSE_LEFT_WING_OUTER].x, features[FSDKP_NOSE_LEFT_WING_OUTER].y);
    landmark.noseLeftContour2 = CGPointMake(features[FSDKP_NOSE_LEFT_WING].x, features[FSDKP_NOSE_LEFT_WING].y);
    landmark.noseLeftContour3 = CGPointMake(features[FSDKP_NOSE_LEFT_WING_LOWER].x, features[FSDKP_NOSE_LEFT_WING_LOWER].y);
    landmark.noseRight = CGPointMake(features[FSDKP_NOSE_RIGHT_WING_OUTER].x, features[FSDKP_NOSE_RIGHT_WING_OUTER].y);
    landmark.noseRightContour2 = CGPointMake(features[FSDKP_NOSE_RIGHT_WING].x, features[FSDKP_NOSE_RIGHT_WING].y);
    landmark.noseRightContour3 = CGPointMake(features[FSDKP_NOSE_RIGHT_WING_LOWER].x, features[FSDKP_NOSE_RIGHT_WING_LOWER].y);
    
    landmark.cheekLeft1 = CGPointMake(features[FSDKP_NASOLABIAL_FOLD_LEFT_UPPER].x, features[FSDKP_NASOLABIAL_FOLD_LEFT_UPPER].y);
    landmark.cheekLeft2 = CGPointMake(features[FSDKP_NASOLABIAL_FOLD_LEFT_LOWER].x, features[FSDKP_NASOLABIAL_FOLD_LEFT_LOWER].y);
    landmark.cheekRight1 = CGPointMake(features[FSDKP_NASOLABIAL_FOLD_RIGHT_UPPER].x, features[FSDKP_NASOLABIAL_FOLD_RIGHT_UPPER].y);
    landmark.cheekRight2 = CGPointMake(features[FSDKP_NASOLABIAL_FOLD_RIGHT_LOWER].x, features[FSDKP_NASOLABIAL_FOLD_RIGHT_LOWER].y);
    
    landmark.mouthRight = CGPointMake(features[FSDKP_MOUTH_LEFT_CORNER].x, features[FSDKP_MOUTH_LEFT_CORNER].y);
    landmark.mouthUpperLipLeftContour2 = CGPointMake(features[FSDKP_MOUTH_LEFT_TOP].x, features[FSDKP_MOUTH_LEFT_TOP].y);
    landmark.mouthUpperLipLeftContour3 = CGPointMake(features[FSDKP_MOUTH_LEFT_TOP_INNER].x, features[FSDKP_MOUTH_LEFT_TOP_INNER].y);
    landmark.mouthUpperLipTop = CGPointMake(features[FSDKP_MOUTH_TOP].x, features[FSDKP_MOUTH_TOP].y);
    landmark.mouthUpperLipBottom = CGPointMake(features[FSDKP_MOUTH_TOP_INNER].x, features[FSDKP_MOUTH_TOP_INNER].y);
    landmark.mouthUpperLipRightContour2 = CGPointMake(features[FSDKP_MOUTH_RIGHT_TOP].x, features[FSDKP_MOUTH_RIGHT_TOP].y);
    landmark.mouthUpperLipRightContour3 = CGPointMake(features[FSDKP_MOUTH_RIGHT_TOP_INNER].x, features[FSDKP_MOUTH_RIGHT_TOP_INNER].y);
    landmark.mouthLeft = CGPointMake(features[FSDKP_MOUTH_RIGHT_CORNER].x, features[FSDKP_MOUTH_RIGHT_CORNER].y);
    landmark.mouthLowerLipLeftContour3 = CGPointMake(features[FSDKP_MOUTH_LEFT_BOTTOM].x, features[FSDKP_MOUTH_LEFT_BOTTOM].y);
    landmark.mouthLowerLipLeftContour1 = CGPointMake(features[FSDKP_MOUTH_LEFT_BOTTOM_INNER].x, features[FSDKP_MOUTH_LEFT_BOTTOM_INNER].y);
    landmark.mouthLowerLipTop = CGPointMake(features[FSDKP_MOUTH_BOTTOM_INNER].x, features[FSDKP_MOUTH_BOTTOM_INNER].y);
    landmark.mouthLowerLipBottom = CGPointMake(features[FSDKP_MOUTH_BOTTOM].x, features[FSDKP_MOUTH_BOTTOM].y);
    landmark.mouthLowerLipRightContour1 = CGPointMake(features[FSDKP_MOUTH_RIGHT_BOTTOM_INNER].x, features[FSDKP_MOUTH_RIGHT_BOTTOM_INNER].y);
    landmark.mouthLowerLipRightContour3 = CGPointMake(features[FSDKP_MOUTH_RIGHT_BOTTOM].x, features[FSDKP_MOUTH_RIGHT_BOTTOM].y);
    
    landmark.contourChin = CGPointMake(features[FSDKP_CHIN_BOTTOM].x, features[FSDKP_CHIN_BOTTOM].y);
    landmark.contourLeft6 = CGPointMake(features[FSDKP_FACE_CONTOUR2].x, features[FSDKP_FACE_CONTOUR2].y);
    landmark.contourLeft8 = CGPointMake(features[FSDKP_FACE_CONTOUR1].x, features[FSDKP_FACE_CONTOUR1].y);
    landmark.contourLeft9 = CGPointMake(features[FSDKP_CHIN_LEFT].x, features[FSDKP_CHIN_LEFT].y);
    landmark.contourRight6 = CGPointMake(features[FSDKP_FACE_CONTOUR12].x, features[FSDKP_FACE_CONTOUR12].y);
    landmark.contourRight8 = CGPointMake(features[FSDKP_FACE_CONTOUR13].x, features[FSDKP_FACE_CONTOUR13].y);
    landmark.contourRight9 = CGPointMake(features[FSDKP_CHIN_RIGHT].x, features[FSDKP_CHIN_RIGHT].y);
    
    CGPoint eyeVector = [CGPointUtility vectorFromPoint:landmark.rightEyeCenter toPoint:landmark.leftEyeCenter byRatio:0.5];
    CGPoint eyeCenter = [CGPointUtility pointFromPoint:landmark.rightEyeCenter toPoint:landmark.leftEyeCenter byRatio:0.5];
    //    CGPoint mouthCenter = [CGPointUtility pointFromPoint:landmark.mouthLeft toPoint:landmark.mouthRight byRatio:0.5];
    
    landmark.contourLeft1 = [CGPointUtility pointFromPoint:landmark.leftEyeCenter translateByVector:eyeVector];
    landmark.contourRight1 = [CGPointUtility pointFromPoint:landmark.rightEyeCenter translateByMinusVector:eyeVector];
    landmark.contourForeHead = [CGPointUtility pointFromPoint:eyeCenter translateByVector:[CGPointUtility vectorFromPoint:landmark.contourChin toPoint:eyeCenter]];
//    landmark.contourLeft6 = [CGPointUtility pointFromPoint:landmark.contourLeft7 toPoint:landmark.contourLeft8 byRatio:-1.0];
//    landmark.contourRight6 = [CGPointUtility pointFromPoint:landmark.contourRight7 toPoint:landmark.contourRight8 byRatio:-1.0];
    
    return landmark;
}
#endif
#pragma mark -- LandmarkMethodCI
-(NSArray *)landmarkImageWithCI:(UIImage *)image
{
    CIImage* ciimage = [CIImage imageWithCGImage:image.CGImage];
    NSDictionary* opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:opts];
    NSArray* features = [detector featuresInImage:ciimage];
    
    NSMutableArray *array = [NSMutableArray array];
    
    //    if ([features count] == 1)
    for (NSInteger idx=0; idx<features.count; ++idx) {
        CIFaceFeature *faceFeature = features[0];
        CGPoint rightEyeP, leftEyeP, mouthP;
        
        if (faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition && faceFeature.hasMouthPosition) {
            
            // estimate face feature rects
            rightEyeP = faceFeature.rightEyePosition;
            leftEyeP = faceFeature.leftEyePosition;
            mouthP = faceFeature.mouthPosition;
            
            rightEyeP.y = image.size.height-rightEyeP.y;
            leftEyeP.y = image.size.height-leftEyeP.y;
            mouthP.y = image.size.height-mouthP.y;
            
            LuxandLandmark *landmark = [[LuxandLandmark alloc] init];
            landmark.leftEyeCenter = leftEyeP;
            landmark.rightEyeCenter = rightEyeP;
            landmark.mouthLowerLipTop = mouthP;
            
            CGPoint eyeVector = [CGPointUtility vectorFromPoint:leftEyeP toPoint:rightEyeP];
            CGPoint eyeCenter = [CGPointUtility pointFromPoint:leftEyeP toPoint:rightEyeP byRatio:0.5];
            
            landmark.mouthLeft = [CGPointUtility pointFromPoint:mouthP translateByVector:eyeVector withRatio:-0.4];
            landmark.mouthRight = [CGPointUtility pointFromPoint:mouthP translateByVector:eyeVector withRatio:0.4];
            landmark.contourChin = [CGPointUtility pointFromPoint:mouthP toPoint:eyeCenter byRatio:-0.5];
            
            
            landmark.contourLeft1 = [CGPointUtility pointFromPoint:landmark.leftEyeCenter translateByVector:eyeVector withRatio:-0.6];
            landmark.contourRight1 = [CGPointUtility pointFromPoint:landmark.rightEyeCenter translateByVector:eyeVector withRatio:0.6];
            landmark.contourForeHead = [CGPointUtility pointFromPoint:eyeCenter translateByVector:[CGPointUtility vectorFromPoint:landmark.contourChin toPoint:eyeCenter]];
            
            landmark.contourLeft5 = [CGPointUtility pointFromPoint:landmark.mouthLowerLipTop translateByVector:eyeVector withRatio:-0.5];
            landmark.contourRight5 = [CGPointUtility pointFromPoint:landmark.mouthLowerLipTop translateByVector:eyeVector withRatio:0.5];
            
            landmark.mouthUpperLipTop = [CGPointUtility pointFromPoint:landmark.mouthLowerLipTop toPoint:landmark.contourChin byRatio:-0.2];
            landmark.contourLeft6 = [CGPointUtility pointFromPoint:landmark.mouthUpperLipTop translateByVector:eyeVector withRatio:-0.7];
            landmark.contourRight6 = [CGPointUtility pointFromPoint:landmark.mouthUpperLipTop translateByVector:eyeVector withRatio:0.7];
            
            landmark.noseTip = [CGPointUtility pointFromPoint:landmark.mouthLowerLipTop toPoint:eyeCenter byRatio:1.0/3.0];
            
            landmark.resultValid = YES;
            landmark.resultSource = LandmarkSourceCI;
            landmark.imageWidth = image.size.width;
            landmark.imageHeight = image.size.height;
            
            [array addObject:landmark];
        }
    }
    
    return [array copy];
}

#pragma mark -- LandmarkMethodGuess

-(NSArray *)landmarkImageWithGuess:(UIImage *)image
{
    CGSize size = image.size;
    
    LuxandLandmark *landmark = [LuxandLandmark new];
    
    landmark.imageWidth = size.width;
    landmark.imageHeight = size.height;
    
    CGPoint rightEyeP, leftEyeP, mouthP;
    
    CGRect _faceRectInImage = CGRectMake(0, 0, size.width, size.height);
    leftEyeP = CGPointMake(_faceRectInImage.origin.x + _faceRectInImage.size.width/3.f,
                           _faceRectInImage.origin.y + _faceRectInImage.size.height*1/2.f);
    rightEyeP = CGPointMake(_faceRectInImage.origin.x + _faceRectInImage.size.width*2/3.f,
                            _faceRectInImage.origin.y + _faceRectInImage.size.height*1/2.f);
    
    CGPoint eyeVector = [CGPointUtility vectorFromPoint:leftEyeP toPoint:rightEyeP];
    CGPoint eyeCenter = [CGPointUtility pointFromPoint:leftEyeP toPoint:rightEyeP byRatio:0.5];
    
    mouthP = CGPointMake(eyeCenter.x+eyeVector.y, eyeCenter.y+eyeVector.x);
    // estimate face feature rects
    
    
    landmark.leftEyeCenter = leftEyeP;
    landmark.rightEyeCenter = rightEyeP;
    
    landmark.mouthLeft = [CGPointUtility pointFromPoint:mouthP translateByVector:eyeVector withRatio:-0.4];
    landmark.mouthRight = [CGPointUtility pointFromPoint:mouthP translateByVector:eyeVector withRatio:0.4];
    
    landmark.contourChin = [CGPointUtility pointFromPoint:mouthP toPoint:eyeCenter byRatio:-0.5];
    
    
    landmark.contourLeft1 = [CGPointUtility pointFromPoint:landmark.leftEyeCenter translateByVector:eyeVector withRatio:-0.6];
    landmark.contourRight1 = [CGPointUtility pointFromPoint:landmark.rightEyeCenter translateByVector:eyeVector withRatio:0.6];
    landmark.contourForeHead = [CGPointUtility pointFromPoint:eyeCenter translateByVector:[CGPointUtility vectorFromPoint:landmark.contourChin toPoint:eyeCenter]];
    landmark.resultValid = YES;
    landmark.resultSource = LandmarkSourceGuess;
    landmark.imageWidth = image.size.width;
    landmark.imageHeight = image.size.height;
    
    NSMutableArray *landmarks = [NSMutableArray array];
    
    return [landmarks copy];
}

#pragma mark -- LandmarkMethodZB
#ifdef ENABLE_ZB
-(NSArray *)landmarkImageWithZB:(UIImage *)image {
    NSArray *temp = [ZBFaceAligment aligmentFaceImage:image];
    
    NSMutableArray *array = [NSMutableArray array];

    for (int idx=0; idx<temp.count; ++idx) {
        FaceLandmarks *ZBlandmark = temp.firstObject;
        
        LuxandLandmark *landmark = [LuxandLandmark new];
        landmark.resultValid = YES;
        landmark.resultSource = LandmarkSourceZB;
        landmark.imageWidth = image.size.width;
        landmark.imageHeight = image.size.height;
        
        landmark.leftEyeLeft = [ZBlandmark.landmarks[g_leftEye_left] CGPointValue];
        landmark.leftEyeRight = [ZBlandmark.landmarks[g_leftEye_right] CGPointValue];
        landmark.rightEyeLeft = [ZBlandmark.landmarks[g_rightEye_left] CGPointValue];
        landmark.rightEyeRight = [ZBlandmark.landmarks[g_rightEye_right] CGPointValue];
        landmark.noseLeft = [ZBlandmark.landmarks[g_nose_bottom_left] CGPointValue];
        landmark.noseLowerMiddleContour = [ZBlandmark.landmarks[g_nose_bottom] CGPointValue];
        landmark.noseRight = [ZBlandmark.landmarks[g_nose_bottom_right] CGPointValue];
        landmark.mouthLeft = [ZBlandmark.landmarks[g_mouth_left] CGPointValue];
        landmark.mouthRight = [ZBlandmark.landmarks[g_mouth_right] CGPointValue];
        landmark.mouthUpperLipTop = [ZBlandmark.landmarks[g_mouth_top] CGPointValue];
        landmark.mouthLowerLipBottom = [ZBlandmark.landmarks[g_mouth_bottom] CGPointValue];
        landmark.contourChin = [ZBlandmark.landmarks[g_contour_chin] CGPointValue];
        landmark.contourLeft6 = [ZBlandmark.landmarks[g_contour_left_1] CGPointValue];
        landmark.contourLeft8 = [ZBlandmark.landmarks[g_contour_left_2] CGPointValue];
        landmark.contourRight6 = [ZBlandmark.landmarks[g_contour_right_1] CGPointValue];
        landmark.contourRight8 = [ZBlandmark.landmarks[g_contour_right_2] CGPointValue];
        
        landmark.leftEyeCenter = [CGPointUtility pointFromPoint:landmark.leftEyeLeft toPoint:landmark.leftEyeRight byRatio:0.5];
        landmark.leftEyeTop = [CGPointUtility pointFromPoint:landmark.leftEyeCenter translateByVector:[CGPointUtility rotateVector:[CGPointUtility vectorFromPoint:landmark.leftEyeLeft toPoint:landmark.leftEyeRight] byRotationAngle:M_PI_2] withRatio:0.5];
        landmark.leftEyeBottom = [CGPointUtility pointFromPoint:landmark.leftEyeCenter translateByVector:[CGPointUtility rotateVector:[CGPointUtility vectorFromPoint:landmark.leftEyeLeft toPoint:landmark.leftEyeRight] byRotationAngle:-M_PI_2] withRatio:0.5];
        
        landmark.rightEyeCenter = [CGPointUtility pointFromPoint:landmark.rightEyeLeft toPoint:landmark.rightEyeRight byRatio:0.5];
        landmark.rightEyeTop = [CGPointUtility pointFromPoint:landmark.rightEyeCenter translateByVector:[CGPointUtility rotateVector:[CGPointUtility vectorFromPoint:landmark.rightEyeLeft toPoint:landmark.rightEyeRight] byRotationAngle:M_PI_2] withRatio:0.5];
        landmark.rightEyeBottom = [CGPointUtility pointFromPoint:landmark.rightEyeCenter translateByVector:[CGPointUtility rotateVector:[CGPointUtility vectorFromPoint:landmark.rightEyeLeft toPoint:landmark.rightEyeRight] byRotationAngle:-M_PI_2] withRatio:0.5];
        
        landmark.noseTip = [CGPointUtility pointFromPoint:landmark.noseLowerMiddleContour toPoint:[CGPointUtility pointFromPoint:landmark.leftEyeCenter toPoint:landmark.rightEyeCenter byRatio:0.5] byRatio:0.25];
        
        landmark.mouthLowerLipTop = [CGPointUtility pointFromPoint:landmark.mouthLeft toPoint:landmark.mouthRight byRatio:0.5];
        
        CGPoint eyeVector = [CGPointUtility vectorFromPoint:landmark.rightEyeCenter toPoint:landmark.leftEyeCenter byRatio:0.5];
        CGPoint eyeCenter = [CGPointUtility pointFromPoint:landmark.rightEyeCenter toPoint:landmark.leftEyeCenter byRatio:0.5];
        
        landmark.contourLeft1 = [CGPointUtility pointFromPoint:landmark.leftEyeCenter translateByVector:eyeVector];
        landmark.contourRight1 = [CGPointUtility pointFromPoint:landmark.rightEyeCenter translateByMinusVector:eyeVector];
        landmark.contourForeHead = [CGPointUtility pointFromPoint:eyeCenter translateByVector:[CGPointUtility vectorFromPoint:landmark.contourChin toPoint:eyeCenter]];
        
        [array addObject:landmark];
    }
    
    return [array copy];
}
#endif

#pragma mark -
-(BOOL)isInChina {
    BOOL result = NO;
    
    //NSString* localeStr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    if([[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Chongqing"].location == 0 ||
       [[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Harbin"].location == 0 ||
       [[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Hong_Kong"].location == 0 ||
       [[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Macau"].location == 0 ||
       [[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Shanghai"].location == 0 ||
       [[[NSTimeZone localTimeZone] name] rangeOfString:@"Asia/Taipei"].location == 0)
    {
        result = YES;
    }
    return result;
}

@end
