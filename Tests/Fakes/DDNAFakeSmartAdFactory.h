//
//  DDNAFakeSmartAdFactory.h
//  SmartAds
//
//  Created by David White on 21/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <DeltaDNA/DeltaDNA.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdFactory.h>


@interface DDNAFakeSmartAdFactory : DDNASmartAdFactory

@property (nonatomic, strong) DDNANetworkRequest *fakeNetworkRequest;   // override, else returns default

@property (nonatomic, strong) DDNAEngageService *fakeEngageService;

@property (nonatomic, strong) DDNASmartAdAgent *fakeSmartAdAgent;

@end
