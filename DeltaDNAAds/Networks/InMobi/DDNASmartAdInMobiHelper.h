//
//  DDNASmartAdInMobiHelper.h
//  
//
//  Created by David White on 01/12/2015.
//
//

#import <Foundation/Foundation.h>

@interface DDNASmartAdInMobiHelper : NSObject

+ (instancetype)sharedInstance;

- (void)startWithAccountID:(NSString *)accountID;

- (NSString *)getVersion;

@end
