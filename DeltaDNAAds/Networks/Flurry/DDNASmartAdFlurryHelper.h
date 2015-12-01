//
//  DDNASmartAdFlurryHelper.h
//  
//
//  Created by David White on 30/11/2015.
//
//

#import <Foundation/Foundation.h>

@interface DDNASmartAdFlurryHelper : NSObject

+ (instancetype)sharedInstance;

- (void)startSessionWithApiKey:(NSString *)apiKey testMode:(BOOL)testMode;

- (NSString *)getFlurryAgentVersion;

@end
