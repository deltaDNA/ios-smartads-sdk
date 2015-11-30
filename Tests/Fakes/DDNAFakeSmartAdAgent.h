//
//  DDNAFakeSmartAdAgent.h
//  SmartAds
//
//  Created by David White on 28/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <DeltaDNA/DeltaDNA.h>
#import <DeltaDNAAds/DDNASmartAdAgent.h>

@interface DDNAFakeSmartAdAgent : DDNASmartAdAgent

- (void)closeAd;

- (void)closeAdWithReward:(BOOL)reward;

@end
