//
//  SpotHTTPManager.h
//  Pods
//
//  Created by gogovan on 31/07/2017.
//
//

#import <Foundation/Foundation.h>
//#import "AFNetworking.h"


@class SpotFile;

typedef NS_ENUM(NSUInteger, SpotHTTPMethod) {
    SpotHTTPMethodGET = 0,
    SpotHTTPMethodPOST,
    SpotHTTPMethodHEAD,
    SpotHTTPMethodDELETE,
    SpotHTTPMethodPATCH,
    SpotHTTPMethodPUT,
};

typedef void (^SpotCompletionHandler)(NSDictionary *headerFields, id responseObject, NSError *networkError);
typedef void (^SpotSuccessHandler)(NSDictionary *headerFields, id responseObject);
typedef void (^SpotFailureHandler)(NSDictionary *headerFields, NSError *error);
typedef NSArray<SpotFile *> * (^SpotConstructingBodyHandler)(void);

@interface SpotHTTPManager : NSObject

@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSDictionary *sharedParameters;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, assign) BOOL cacheToDisk;
@property (nonatomic, assign) BOOL printLog;

#pragma mark - 签名
@property (nonatomic, copy) NSString *signString;
@property (nonatomic, copy) NSString *signKey;


@property (nonatomic, copy) SpotCompletionHandler completionHandler;
@property (nonatomic, copy) SpotSuccessHandler successHandler;
@property (nonatomic, copy) SpotFailureHandler FailureHandler;
@property (nonatomic, copy) SpotConstructingBodyHandler bodyHandler;



+ (instancetype)manager;
+ (instancetype)managerWithDomain:(NSString *)domain;

- (void)requestWithDomain:(NSString *)domain
                     path:(NSString *)path
                   method:(SpotHTTPMethod)methodType
         sharedParameters:(NSDictionary *)sharedParameters
                 printLog:(BOOL)print
               parameters:(NSDictionary *)parameters
                diskCache:(BOOL)cache
constructingBodyWithBlock:(SpotConstructingBodyHandler)bodyHandler
        completionHandler:(SpotCompletionHandler)handlerBlock;

//+ (void)monitorNetwork;
@end
