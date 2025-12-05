//
//  PriorityOpenAdWrapper.m
//  Unity-iPhone
//
//  Created by 昭 陈 on 2025/10/18.
//

#import <Foundation/Foundation.h>
#import "PriorityOpenAdWrapper.h"

@implementation PriorityOpenAdWrapper {
    NSMutableArray* adlist;
}

@synthesize delegate;

- (id)initWithRootView:(AdmobViewController*) rootview adlist:(NSArray* )ads {
    self = [super init];
    
    if(self)
    {
        //add ads
        adlist = [[NSMutableArray alloc] init];
        self.RootViewController = rootview;
        
        for(int i=0; i<ads.count; i++) {
            [adlist addObject:ads[i]];
            ((OpenAdWrapper*)ads[i]).delegate = self;
        }
    }
    
    return self;
}

-(void) init_ad {
    for(OpenAdWrapper* ad in adlist)
    {
        [ad init_ad];
    }
}

-(OpenAdWrapper* ) getFirstAd:(int) place
{
    if([adlist count] == 0)
        return nil;
    
    for(int i =0; i < [adlist count]; i++)
    {
        if([[adlist objectAtIndex:i] isAdReady:place])
        {
            NSLog(@"[ADUNION] -------Show Priority open Ad %d", i);
            return [adlist objectAtIndex:i];
        }
    }
    return nil;
}

/* 展示广告 */
-(BOOL) showAd:(UIViewController*)viewController placeid:(int)place {
    OpenAdWrapper* ad = [self getFirstAd:place];
    if(ad != nil)
        return [ad showAd:viewController placeid:place];
    return NO;
}

-(BOOL) isAdReady:(int)place {
    for(int i =0; i < [adlist count]; i++)
    {
        if([[adlist objectAtIndex:i] isAdReady:place])
            return TRUE;
    }
    return FALSE;
}

- (void) delayInitAfterNetworkFinish {
    for(OpenAdWrapper* ad in adlist) {
        [ad delayInitAfterNetworkFinish];
    }
}

#pragma mark -
#pragma mark FullScreenAdWrapperDelegate

- (void)AdDidClose:(FullScreenAdWrapper*) ad {
    if(delegate != nil) {
        [delegate AdDidClose: ad];
    }
}

- (void)AdDidOpen:(FullScreenAdWrapper*) ad {
    if(delegate != nil) {
        [delegate AdDidOpen: ad];
    }
}

- (void)AdDidReceive:(FullScreenAdWrapper*) ad {
    if(delegate != nil) {
        [delegate AdDidReceive: ad];
    }
}

- (void)AdFailToReceivedWithError:(FullScreenAdWrapper*) ad error:(NSString *)error {
    if(delegate != nil) {
        [delegate AdFailToReceivedWithError: ad error:error];
    }
}

- (void)AdWillLeaveApplication:(FullScreenAdWrapper*) ad {
    if(delegate != nil) {
        [delegate AdWillLeaveApplication: ad];
    }
}

@end
