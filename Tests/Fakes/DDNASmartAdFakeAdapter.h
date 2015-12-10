//
//  DDNASmartAdMockAdapter.h
//  SmartAds
//
//  Created by David White on 13/10/2015.
//  Copyright © 2015 deltadna. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DeltaDNAAds/SmartAds/DDNASmartAdAdapter.h>

@interface DDNASmartAdFakeAdapter : DDNASmartAdAdapter

//@property (nonatomic, weak) id<DDNASmartAdAdapterDelegate> delegate;

//@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL failRequest;
@property (nonatomic, assign, readonly,getter=isShowing) BOOL showing;
@property (nonatomic, assign, readonly) BOOL failOpen;

- (instancetype)initWithName: (NSString *)name failRequest: (BOOL)failRequest;

- (instancetype)initWithName:(NSString *)name failRequest:(BOOL)failRequest failOpen:(BOOL)failOpen;

- (void)clickAdAndLeaveApplication: (BOOL)didLeave;

- (void)closeAd;

@end
