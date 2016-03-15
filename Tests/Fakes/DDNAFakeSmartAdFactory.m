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

- (DDNASmartAdAgent *)buildSmartAdAgentWithWaterfall:(DDNASmartAdWaterfall *)waterfall delegate:(id<DDNASmartAdAgentDelegate>)delegate
{
    if (self.fakeSmartAdAgent) {
        self.fakeSmartAdAgent.delegate = delegate;
        return self.fakeSmartAdAgent;
    } else {
        return [super buildSmartAdAgentWithWaterfall:waterfall delegate:delegate];
    }
}

@end
