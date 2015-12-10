//
//  DDNAFakeSmartAdFactory.m
//  SmartAds
//
//  Created by David White on 21/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import "DDNAFakeSmartAdFactory.h"
#import <DeltaDNA/DDNANetworkRequest.h>
#import <DeltaDNA/DDNAEngageService.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdAgent.h>


@implementation DDNAFakeSmartAdFactory

- (DDNANetworkRequest *)buildNetworkRequestWithURL:(NSURL *)URL jsonPayload:(NSString *)jsonPayload delegate:(id<DDNANetworkRequestDelegate>)delegate
{
    if (self.fakeNetworkRequest) {
        self.fakeNetworkRequest.delegate = delegate;
        return self.fakeNetworkRequest;
    } else {
        return [super buildNetworkRequestWithURL:URL jsonPayload:jsonPayload delegate:delegate];
    }
}

- (DDNAEngageService *)buildEngageService
{
    if (self.fakeEngageService) {
        return self.fakeEngageService;
    } else {
        return [super buildEngageService];
    }
}

- (DDNASmartAdAgent *)buildSmartAdAgentWithWaterfall:(NSArray *)waterfall delegate:(id<DDNASmartAdAgentDelegate>)delegate
{
    if (self.fakeSmartAdAgent) {
        self.fakeSmartAdAgent.delegate = delegate;
        return self.fakeSmartAdAgent;
    } else {
        return [super buildSmartAdAgentWithWaterfall:waterfall delegate:delegate];
    }
}

@end
