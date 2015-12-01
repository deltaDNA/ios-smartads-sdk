//
//  DDNASmartAdStatus.h
//  
//
//  Created by David White on 05/11/2015.
//
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, DDNASmartAdRequestResultCode) {
    DDNASmartAdRequestResultCodeLoaded,
    DDNASmartAdRequestResultCodeNoFill,
    DDNASmartAdRequestResultCodeError,
    DDNASmartAdRequestResultCodeInvalid,
    DDNASmartAdRequestResultCodeNetwork,
    DDNASmartAdRequestResultCodeConfiguration
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

