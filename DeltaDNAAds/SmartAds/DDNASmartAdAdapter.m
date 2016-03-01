//
//  DDNASmartAdAdapter.m
//  
//
//  Created by David White on 12/11/2015.
//
//

#import "DDNASmartAdAdapter.h"

@interface DDNASmartAdAdapter ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, assign) NSInteger eCPM;

@end

@implementation DDNASmartAdAdapter

- (instancetype)initWithName:(NSString *)name version:(NSString *)version eCPM:(NSInteger)eCPM waterfallIndex:(NSInteger)waterfallIndex
{
    if ((self = [super init])) {
        self.name = name;
        self.version = version;
        self.eCPM = eCPM;
        self.waterfallIndex = waterfallIndex;
        self.score = 0;
    }
    return self;
}

- (instancetype)initWithConfiguration:(NSDictionary *)configuration waterfallIndex:(NSInteger)waterfallIndex
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)requestAd
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)showAdFromViewController:(UIViewController *)viewController
{
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SmartAdAdapter %@ %@", self.name, self.version];
}

@end