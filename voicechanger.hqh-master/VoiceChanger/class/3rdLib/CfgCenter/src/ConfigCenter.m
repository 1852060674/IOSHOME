//
//  ConfigCenter.m
//  version 3.3
//
//  Created by 昭 陈 on 2016/11/25.
//  Copyright © 2016年 昭 陈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfigCenter.h"
#import "CfgCenter.h"

//http
#define TIME_OUT_INTERVAL 10
#define SHIFT_OFFSET 43

@implementation ConfigCenter
{
    NSString* host;
    NSInteger appid;
    
    BOOL isuding;
    NSDictionary* adconfig;
    NSDictionary* rtconfig;
    NSDictionary* ntconfig;
    NSDictionary* exconfig;
    NSDictionary* rewardAdConfig;
    
    NSDictionary* defaultad;
    NSDictionary* defaultrt;
    NSDictionary* defaultrad;
    
    long valid;
    long udtime;
    
    NSString* contryCode;
    NSString* languageCode;
}

+(NSString*) getContryCode {
    NSLocale *currentLocale = [NSLocale currentLocale];
    return [currentLocale objectForKey:NSLocaleCountryCode];
}

+(NSString*) getLanguageCode {
    NSLocale *currentLocale = [NSLocale currentLocale];
    return [currentLocale objectForKey:NSLocaleLanguageCode];
}

-(id) initWithDefault:(NSString*) config appid: (NSInteger) app {
    self = [super init];
    if(self != nil) {
        host = @"magicword.online:8089";
#ifdef DEBUG
        host = @"magicword.online:8089";
#endif
        isuding = false;
        appid = app;
        valid = 86400;
        udtime = 0;
        
        contryCode = [ConfigCenter getContryCode];
        languageCode = [ConfigCenter getLanguageCode];
        
        [self parseDefaultConfig:config];
        
        [self loadConfig];
    }
    
    return self;
}

-(NSDictionary*) getAdConfig:(BOOL)usdefault {
    if(usdefault)
        return defaultad;
    return adconfig;
}

-(NSDictionary*) getRewardAdConfig:(BOOL)usdefault {
    if(usdefault)
        return defaultrad;
    return rewardAdConfig;
}

-(NSDictionary*) getRtConfig:(BOOL)usdefault {
    if(usdefault)
        return defaultrt;
    return rtconfig;
}

-(NSDictionary*) getNtConfig{
    return ntconfig;
}

-(NSDictionary*) getExConfig {
    return exconfig;
}

-(void)loadConfig
{
    NSData* data = [self readFromLocal];
    if(data == nil)
        return;
    
    NSInteger length = [data length];
    char *byteData = (char*)malloc(length);
    memcpy(byteData, [data bytes], length);
    
    [self decodeData:byteData length:length];
    
    [self udconfig:byteData length:length];
}

#pragma mark -
#pragma mark download config from server

//从服务器获取数据
-(void) checkUD:(CfgCenterSettings*) settings {
    long now_time = time(NULL);
    
    long firstin = [settings getAppFirstInTime];
#ifndef DEBUG
    if(now_time - firstin < 1800)
        return;
    
    if(now_time < udtime+valid)
        return;
    
    long lastgrttime = [settings getLastUdTime];
    if(now_time - lastgrttime < 1800)
        return;
#endif
    
    if(isuding)
        return;
    isuding = TRUE;
    
    [settings setLastUdTime:now_time];
    
    long opencount = [settings getAppOpenCount];
    //id:appid, v:version, f:firstInTime, ot:openCount
    NSDictionary* parameters = @{@"id": [NSString stringWithFormat: @"%ld", (long)appid],
                                 @"v": [CfgCenterSettings getVersionStr],
                                 @"cv": CFGCENTER_VERSION,
                                 @"f": [NSString stringWithFormat: @"%ld", firstin],
                                 @"vu": [NSString stringWithFormat: @"%ld", [settings getValidUseCount]],
                                 @"c": [NSString stringWithFormat: @"%@", contryCode.lowercaseString],
                                 @"l": [NSString stringWithFormat: @"%@", languageCode.lowercaseString],
                                 @"oc": [NSString stringWithFormat: @"%ld", opencount]};
    NSString* url = [NSString stringWithFormat:@"http://%@/ios/useslog", host];
#ifdef DEBUG
    url = [NSString stringWithFormat:@"http://%@/cgi-bin/ios_debug/useslog_debug", host];
#endif
    NSURLRequest* request = [self HTTPGETRequestForURL:[NSURL URLWithString:url] parameters:parameters];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if ([data length] > 0 && error == nil)
            [self receivedData:data];
        else if ([data length] == 0 && error == nil)
            [self emptyReply];
        else if (error != nil && error.code == NSURLErrorTimedOut)
            [self timedOut];
        else if (error != nil)
            [self downloadError:error];
        
        isuding = FALSE;
    }];
    
    [task resume];
}

- (NSURLRequest *)HTTPGETRequestForURL:(NSURL *)url parameters:(NSDictionary *)parameters
{
    NSString *URLFellowString = [@"?"stringByAppendingString:[self HTTPBodyWithParameters:parameters]];
    NSString *finalURLString = [[url.absoluteString stringByAppendingString:URLFellowString]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *finalURL = [NSURL URLWithString:finalURLString];
    
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc]initWithURL:finalURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIME_OUT_INTERVAL];
    [URLRequest setHTTPMethod:@"GET"];
    
    return URLRequest;
    
}

- (NSString *)HTTPBodyWithParameters:(NSDictionary *)parameters
{
    NSMutableArray *parametersArray = [[NSMutableArray alloc]init];
    for (NSString *key in [parameters allKeys]) {
        id value = [parameters objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [parametersArray addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
        }
    }
    
    return [parametersArray componentsJoinedByString:@"&"];
}

-(void) receivedData:(NSData*) data{
    NSInteger length = [data length];
    char *byteData = (char*)malloc(length);
    memcpy(byteData, [data bytes], length);
    
    [self saveToLocal:data];
    
    [self decodeData:byteData length:length];
    
    [self udconfig:byteData length:length];
    
    free(byteData);
}

-(void) emptyReply {
    //nothing
}

-(void) timedOut {
    //nothing
}

-(void) downloadError:(NSError*) error {
    //nothing
}


#pragma mark -
#pragma mark parse config from local

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

-(void)saveToLocal:(NSData*) data {
    NSString* filePath = [self documentsPathForFileName:@"config.db"];
    
    [data writeToFile:filePath atomically:YES];
}

-(NSData*)readFromLocal{
    NSString* filePath = [self documentsPathForFileName:@"config.db"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        return data;
    }
    else
    {
        NSLog(@"File not exits");
        return nil;
    }
}

-(void)decodeData: (char*)bytedata length: (long)length {
    for(long i=0;i<length;i++) {
        bytedata[i] = (bytedata[i] + SHIFT_OFFSET)%256;
    }
}

-(void)udconfig: (char*) data length: (long)length {
    
    NSError *error;
    NSData *response = [NSData dataWithBytes:data length:length];
    
    @try {
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
        int retcode = [jsonDict[@"retcode"] intValue];
        if(retcode == 0) {
            return;
        }
        
        adconfig = [jsonDict objectForKey:@"ad"];
        rtconfig = [jsonDict objectForKey:@"rt"];
        ntconfig = [jsonDict objectForKey:@"nt"];
        exconfig = [jsonDict objectForKey:@"ex"];
        rewardAdConfig = [jsonDict objectForKey:@"rewardad"];
        
        valid = [jsonDict[@"vd"] intValue];
        udtime = [jsonDict[@"t"] longValue];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)parseDefaultConfig: (NSString*) data {
    NSError *error;
    NSData *response = [data dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    
    defaultad = [jsonDict objectForKey:@"ad"];
    defaultrt = [jsonDict objectForKey:@"rt"];
    defaultrad = [jsonDict objectForKey:@"rewardad"];
    
    valid = [jsonDict[@"vd"] intValue];
    udtime = [jsonDict[@"t"] longValue];
    
    if(defaultad == nil || defaultrt == nil)
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must provide a valid default config"]
                                     userInfo:nil];
}

@end
