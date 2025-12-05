//
//  OpenAdWrapper.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2025/10/18.
//

#import <Foundation/Foundation.h>
#import "CfgCenter.h"
#import "OpenAdWrapper.h"
#import "PriorityOpenAdWrapper.h"
#ifdef AD_ADMOB
#import "AdmobOpenAdWrapper.h"
#endif
#ifdef AD_APPLOVIN_MAX
#import "MaxOpenAdWrapper.h"
#endif

@implementation OpenAdWrapper

+(OpenAdWrapper*) createAD:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* type = config[@"type"];
    OpenAdWrapper * ad = nil;
    
    if([type isEqualToString:@"priority"]) {
        ad = [self createPriorityAd: config vc:vc];
#ifdef AD_ADMOB
    } else if ([type isEqualToString:@"admob"] || [type isEqualToString:@"google"]) {
        ad = [self createAdmobAd: config vc:vc];
#endif
#ifdef AD_APPLOVIN_MAX
    } else if ([type isEqualToString:@"max"]) {
        ad = [self createApplovinAd: config vc:vc];
#endif
    }
    
    return ad;
}

+(OpenAdWrapper*) createPriorityAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    
    NSArray* adlist = [config objectForKey:@"ads"];
    
    NSMutableArray* ads = [self createAdFromList:adlist vc:vc];
    
    if(ads.count == 0)
        return nil;
    
    PriorityOpenAdWrapper* sequence = [[PriorityOpenAdWrapper alloc] initWithRootView:vc adlist:ads];
    return sequence;
}

+(NSMutableArray*) createAdFromList:(NSArray*) config vc: (AdmobViewController*)vc {
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    
    for(int i=0; i<config.count; i++) {
        OpenAdWrapper* ad = [self createAD:config[i] vc: vc];
        if(ad != NULL) {
            [ret addObject:ad];
        }
    }
    return ret;
}

#ifdef AD_ADMOB
+(OpenAdWrapper*) createAdmobAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* adid = config[@"id"];
    
    if([adid length] == 0) {
        return nil;
    }
    
    AdmobOpenAdWrapper* admob = [[AdmobOpenAdWrapper alloc] initWithRootView:vc adid:adid];
    return admob;
}

#endif

#ifdef AD_APPLOVIN_MAX
+(OpenAdWrapper*) createApplovinAd:(NSDictionary*) config vc: (AdmobViewController*)vc {
    NSString* adid = config[@"id"];
    
    if([adid length] == 0) {
        return nil;
    }
    
    MaxOpenAdWrapper* applovin = [[MaxOpenAdWrapper alloc] initWithRootView:vc adid:adid];
    return applovin;
}
#endif

@end
