//
//  DDNASmartAdStatus.h
//  
//
//  Created by David White on 05/11/2015.
//
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, DDNASmartAdRequestResultCode) {
    DDNASmartAdRequestResultCodeLoaded          = 0,
    DDNASmartAdRequestResultCodeNoFill          = 1 << 0,
    DDNASmartAdRequestResultCodeNetwork         = 1 << 1,
    DDNASmartAdRequestResultCodeTimeout         = 1 << 2,
    DDNASmartAdRequestResultCodeMaxRequests     = 1 << 3,
    DDNASmartAdRequestResultCodeConfiguration   = 1 << 4,
    DDNASmartAdRequestResultCodeError           = 1 << 5
};

@interface DDNASmartAdRequestResult : NSObject

@property (nonatomic, assign, readonly) DDNASmartAdRequestResultCode code;
@property (nonatomic, copy, readonly) NSString *desc;
@property (nonatomic, copy) NSString *error;

+ (instancetype)resultWith:(DDNASmartAdRequestResultCode)code;
+ (instancetype)resultWith:(DDNASmartAdRequestResultCode)code error:(NSString *)error;

@end

typedef NS_ENUM(NSInteger, DDNASmartAdShowResultCode) {
    DDNASmartAdShowResultCodeFulfilled,
    DDNASmartAdShowResultCodeNoAdAvailable,
    DDNASmartAdShowResultCodeAdShowPoint,
    DDNASmartAdShowResultCodeAdSessionLimitReached,
    DDNASmartAdShowResultCodeMinTimeNotElapsed,
    DDNASmartAdShowResultCodeNotReady,
    DDNASmartAdShowResultCodeEngageFailed
};

@interface DDNASmartAdShowResult : NSObject

@property (nonatomic, assign, readonly) DDNASmartAdShowResultCode code;
@property (nonatomic, copy, readonly) NSString *desc;

+ (instancetype)resultWith:(DDNASmartAdShowResultCode)code;

@end

typedef NS_ENUM(NSInteger, DDNASmartAdClosedResultCode) {
    DDNASmartAdClosedResultCodeSuccess,
    DDNASmartAdClosedResultCodeExpired,
    DDNASmartAdClosedResultCodeError,
    DDNASmartAdClosedResultCodeNotReady
};

@interface DDNASmartAdClosedResult : NSObject

@property (nonatomic, assign, readonly) DDNASmartAdClosedResultCode code;
@property (nonatomic, copy, readonly) NSString *desc;

+ (instancetype)resultWith: (DDNASmartAdClosedResultCode)code;

@end

