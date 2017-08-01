//
//  SpotHTTPManager.m
//  Pods
//
//  Created by gogovan on 31/07/2017.
//
//

#import "SpotHTTPManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "HYFoundation.h"
#import "AFNetworking.h"
#import "SpotFile.h"

#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...) (void)0
#endif

static NSString * const kLogStartRequest    = @"↗️ >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
static NSString * const kLogStartResponse   = @"↘️ >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
static NSString * const kLogStartError      = @"❌ >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
static NSString * const kLogEnd             = @"⏹ <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<";

static NSString * const kCacheHeaderField       = @"headerFields";
static NSString * const kCacheResponseObject    = @"responseObject";

@interface SpotHTTPManager ()
/** sessionTask */
@property (nonatomic, strong) NSURLSessionTask *sessionTask;
@end

@implementation SpotHTTPManager

#pragma mark - Public Methods
+ (instancetype)manager {
    return [[self alloc] init];
}

+ (instancetype)managerWithDomain:(NSString *)domain {
    SpotHTTPManager *manager = [self manager];
    manager.domain = domain;
    
    //    [self monitorNetwork];
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeoutInterval = 30;
        self.domain = nil;
        self.sharedParameters = nil;
        self.signString = nil;
        self.signKey = nil;
    }
    return self;
}



- (void)requestWithDomain:(NSString *)domain
                     path:(NSString *)path
                   method:(SpotHTTPMethod)methodType
         sharedParameters:(NSDictionary *)sharedParameters
                 printLog:(BOOL)print
               parameters:(NSDictionary *)parameters
                diskCache:(BOOL)cache
constructingBodyWithBlock:(SpotConstructingBodyHandler)bodyHandler
        completionHandler:(SpotCompletionHandler)handlerBlock {
    
    self.completionHandler = handlerBlock;
    self.bodyHandler = bodyHandler;
    self.sharedParameters = sharedParameters;
    self.cacheToDisk = cache;
    self.printLog = print;
    
    cache = NO;
    
    AFHTTPSessionManager *manager = [self sharedSessionManager];
    manager.requestSerializer.timeoutInterval = self.timeoutInterval;
    NSSet *acceptableContentTypes = manager.responseSerializer.acceptableContentTypes;
    manager.responseSerializer.acceptableContentTypes = [acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html",
                                                                                                              @"text/plain"]];
    
    NSString *baseURLString = [self baseURLWithDomain:domain path:path];
    
    NSMutableDictionary *fullParameters = [NSMutableDictionary dictionary];
    [fullParameters addEntriesFromDictionary:parameters];
    
    /** 参数拼接 */
    if (sharedParameters) {
        
        [fullParameters addEntriesFromDictionary:sharedParameters];
    }
   
    /*
     
     //  // 签名
     //    if (self.signString) {
     //        // 请求加密（添加加密字段 sign）
     //        NSString *method = [self methodNameWithMethod:methodType];
     //
     //
     //                NSDictionary *signedParameters = [fullParameters hy_dictionaryWithMethod:method
     //                                                                               urlString:baseURLString
     //                                                                                    sign:self.signString
     //                                                                                  forKey:self.signKey];
     //                fullParameters = [signedParameters mutableCopy];
     //    }
     //    
     */
    self.parameters = fullParameters;
    
    NSString *action = fullParameters[@"action"];
    if (!action.length) {
        action = path;
    }
    
    
    NSString *fullRequestURLString = [self requestURLWithDomain:domain
                                                           path:path
                                                      parameter:fullParameters
                                              requestSerializer:manager.requestSerializer
                                                       printLog:print];
    
    //    NSURLSessionTask *task = nil;
    
    switch (methodType) {
        case SpotHTTPMethodGET: {
            //            NSString *filePath = [self filePathWithURL:fullRequestURLString];
            //            NSError *readError = nil;
            //            NSData *date = [NSData dataWithContentsOfFile:filePath options:0 error:&readError];
            //            if (!readError && date && cache) {
            //                NSLog(@"从缓存文件加载：%@", filePath);
            //                id cachedResponseObject = [NSJSONSerialization JSONObjectWithData:date options:0 error:nil];
            //                id headerFields = [cachedResponseObject valueForKey:kCacheHeaderField];
            //                id responseObject = [cachedResponseObject valueForKey:kCacheResponseObject];
            //                [self handlePrint:print
            //                       requestURL:fullRequestURLString
            //                           action:action
            //                     headerFields:headerFields
            //                         response:responseObject
            //                            error:nil
            //                      writeToDisk:NO
            //                          handler:handlerBlock];
            //            } else {
            //                NSLog(@"从网络加载：");
            //            }
            
            self.sessionTask = [manager GET:baseURLString parameters:fullParameters progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self handleRequestURL:fullRequestURLString
                                action:action
                        responseObject:responseObject
                                 error:nil];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self handleRequestURL:fullRequestURLString
                                action:action
                        responseObject:nil
                                 error:error];
            }];
            
            
            
            break;
        }
        case SpotHTTPMethodPOST: {
            //            NSString *filePath = [self filePathWithURL:fullRequestURLString];
            //            NSError *readError = nil;
            //            NSData *date = [NSData dataWithContentsOfFile:filePath options:0 error:&readError];
            //            if (!readError && date && cache) {
            //                NSLog(@"从缓存文件加载：%@", filePath);
            //                id cachedResponseObject = [NSJSONSerialization JSONObjectWithData:date options:0 error:nil];
            //                id headerFields = [cachedResponseObject valueForKey:kCacheHeaderField];
            //                id responseObject = [cachedResponseObject valueForKey:kCacheResponseObject];
            //                [self handlePrint:print
            //                       requestURL:fullRequestURLString
            //                           action:action
            //                     headerFields:headerFields
            //                         response:cachedResponseObject
            //                            error:nil
            //                      writeToDisk:NO
            //                          handler:handlerBlock];
            //            }
            //            else {
            //                NSLog(@"从网络加载：");
            //            }
            
            
            if (bodyHandler) {
                [manager.requestSerializer setValue:@"multipart/form-data"
                                 forHTTPHeaderField:@"Content-Type"];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                manager.responseSerializer.acceptableContentTypes = [acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html",
                                                                                                                          @"text/plain"]];
                self.sessionTask = [manager POST:baseURLString parameters:fullParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    if (bodyHandler) {
                        NSArray *items = bodyHandler();
                        
                        [self handleFiles:items formData:formData];
                        
                    }
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    [self handleRequestURL:fullRequestURLString
                                    action:action
                            responseObject:responseObject
                                     error:nil];
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    [self handleRequestURL:fullRequestURLString
                                    action:action
                            responseObject:nil
                                     error:error];
                }];
            } else {
                
                self.sessionTask = [manager POST:baseURLString parameters:fullParameters progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    [self handleRequestURL:fullRequestURLString
                                    action:action
                            responseObject:responseObject
                                     error:nil];
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    [self handleRequestURL:fullRequestURLString
                                    action:action
                            responseObject:nil
                                     error:error];
                }];
            }
            
            
            break;
        }
            
            
        case SpotHTTPMethodDELETE: {
            self.sessionTask = [manager DELETE:baseURLString parameters:fullParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self handleRequestURL:fullRequestURLString
                                action:action
                        responseObject:responseObject
                                 error:nil];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self handleRequestURL:fullRequestURLString
                                action:action
                        responseObject:nil
                                 error:error];
            }];
            break;
        }
        case SpotHTTPMethodHEAD: {
            self.sessionTask = [manager HEAD:baseURLString parameters:fullParameters success:^(NSURLSessionDataTask * _Nonnull task) {
                [self handleRequestURL:fullRequestURLString
                                action:action
                        responseObject:nil
                                 error:nil];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestURL:fullRequestURLString
                                action:action
                        responseObject:nil
                                 error:error];
            }];
            
            break;
        }
        case SpotHTTPMethodPATCH: {
            self.sessionTask = [manager PATCH:baseURLString parameters:fullParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self handleRequestURL:fullRequestURLString
                                action:action
                        responseObject:responseObject
                                 error:nil];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self handleRequestURL:fullRequestURLString
                                action:action
                        responseObject:nil
                                 error:error];
            }];
            break;
        }
        case SpotHTTPMethodPUT: {
            self.sessionTask = [manager PUT:baseURLString parameters:fullParameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [self handleRequestURL:fullRequestURLString
                                action:action
                        responseObject:responseObject
                                 error:nil];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [self handleRequestURL:fullRequestURLString
                                action:action
                        responseObject:nil
                                 error:error];
            }];
            break;
        }
    }
    
}


#pragma mark - Tools

- (AFHTTPSessionManager *)sharedSessionManager {
    static AFHTTPSessionManager *sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionManager = [AFHTTPSessionManager manager];
    });
    return sessionManager;
}

- (NSString *)baseURLWithDomain:(NSString *)domain path:(NSString *)path {
    
    while ([domain hasSuffix:@"/"]) {
        domain = [domain substringToIndex:domain.length-1];
    }
    
    while (![path hasPrefix:@"/"]) {
        path = [@"/" stringByAppendingString:path];
    }
    
    while ([path hasSuffix:@"?"]) {
        path = [path substringToIndex:path.length-1];
    }
    
    NSString *baseURLString = [NSString stringWithFormat:@"%@%@", domain, path];
    return baseURLString;
}

/**
 打印请求URL
 */
- (NSString *)requestURLWithDomain:(NSString *)domain
                              path:(NSString *)path
                         parameter:(NSDictionary *)parameters
                 requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                          printLog:(BOOL)print {
    
    //    NSArray *keys = [parameters allKeys];
    //    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    //        return [obj1 compare:obj2];
    //    }];
    
    NSString *queryString = nil;
    if (parameters.count) {
        queryString = [parameters hy_queryString];
    }
    
    NSString *baseURLString = [self baseURLWithDomain:domain path:path];
    
    NSString *requestURL = baseURLString;
    if (queryString.length) {
        requestURL = [requestURL stringByAppendingString:[NSString stringWithFormat:@"?%@", queryString]];
    }
    
    if (print) {
        NSLog(@"\n%@ 请求\naction = %@, \nrequestHeader = %@, \nURL = %@\n%@\n\n",
              kLogStartRequest, path, requestSerializer.HTTPRequestHeaders, requestURL, kLogEnd);
    }
    return requestURL;
    
}

- (void)handleFiles:(NSArray<SpotFile *> *)files
           formData:(id<AFMultipartFormData>)formData {
    for (SpotFile *item in files) {
        if (item.fileData) {
            [formData appendPartWithFileData:item.fileData
                                        name:item.name
                                    fileName:item.fileName
                                    mimeType:item.mimeType];
        }
        
        if (item.fileURL) {
            [formData appendPartWithFileURL:item.fileURL
                                       name:item.name
                                   fileName:item.fileName
                                   mimeType:item.mimeType
                                      error:nil];
        }
    }
}

- (void)handleRequestURL:(NSString *)requestURL
                  action:(NSString *)action
          responseObject:(id)responseObject
                   error:(NSError *)error {
    
    // 响应头
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self.sessionTask.response;
    
    // URL解码
    NSMutableDictionary *headerFields = httpResponse.allHeaderFields.mutableCopy;
    NSArray *allKeys = headerFields.allKeys;
    for (NSString *oneKey in allKeys) {
        id oneValue = headerFields[oneKey];
        if ( [oneValue isKindOfClass:[NSString class]] && [oneValue containsString:@"%"]) {
            oneValue = [oneValue stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            headerFields[oneKey] = oneValue;
        }
    }
    
    NSInteger statusCode = httpResponse.statusCode;
    NSString *statusCodeString = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
    if (!statusCodeString.length) {
        statusCodeString = @"";
    }
    
    
    if (error) { // 请求失败
        // 失败回调
        if (self.FailureHandler) {
            self.FailureHandler(headerFields, error);
        }
        
        // 合并回调
        if (self.completionHandler) {
            self.completionHandler(headerFields, nil, error);
        }
        
        if (self.printLog) {
            NSLog(@"\n%@ \naction = %@, \nstatus: (%zd)%@, \nERROR = (%zd)%@: %@\n%@\n\n",
                  kLogStartError, action, statusCode, statusCodeString, error.code, error.localizedDescription, error.userInfo, kLogEnd);
        }
        
    } else { // 请求成功
        
        NSString *headerJSONString = json2String(headerFields);
        if (!headerJSONString.length) {
            headerJSONString = @"";
        }
        
        NSString *validResponseJSON = nil;
        id validResponseObject = nil;
        
        
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSError *jsonError = nil;
            validResponseObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
            
            if (!jsonError && validResponseObject) {
                // 转成JSON字符串, 用于打印（直接打印字典，中文需转码）
                NSString *jsonString = json2String(validResponseObject);
                
                validResponseJSON = jsonString;
                
            } else {
                // 转字符串
                NSString *responString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                validResponseObject = responString;
                validResponseJSON = responString;
            }
        } else {
            if ([NSJSONSerialization isValidJSONObject:responseObject]) {
                
                
                // 转成JSON字符串, 用于打印（直接打印字典，中文需转码）
                NSString *jsonString = json2String(responseObject);
                
                validResponseJSON = jsonString;
                validResponseObject = responseObject;
            } else {
                validResponseJSON = responseObject;
                validResponseObject = responseObject;
            }
        }
        
        
        if (self.successHandler) {
            self.successHandler(headerFields, validResponseObject);
        }
        
        if (self.completionHandler) {
            self.completionHandler(headerFields, validResponseObject, nil);
        }
        
        if (self.cacheToDisk) {// 写入缓存
            [self saveToFileWithURL:requestURL
                             header:headerFields
                           response:responseObject
                              error:error
                            handler:nil];
        }
        
        if (self.printLog) {
            NSLog(@"\n%@ \naction = %@, \nresponseHeader: %@, \nresponseObject = \n%@\n%@\n\n",
                  kLogStartResponse, action, headerJSONString, validResponseJSON, kLogEnd);
        }
        
    }
}

//static NSString * methodNameWithMethod(SpotHTTPMethod methodType) {
//    
//    NSString *method = @"";
//    switch (methodType) {
//        case SpotHTTPMethodGET: {
//            method = @"GET";
//            break;
//        }
//        case SpotHTTPMethodPOST: {
//            method = @"POST";
//            break;
//        }
//        case SpotHTTPMethodPUT: {
//            method = @"PUT";
//            
//            break;
//        }
//        case SpotHTTPMethodHEAD: {
//            method = @"HEAD";
//            
//            break;
//        }
//        case SpotHTTPMethodPATCH: {
//            method = @"PATCH";
//            
//            break;
//        }
//        case SpotHTTPMethodDELETE: {
//            method = @"DELETE";
//            
//            break;
//        }
//        default:
//            break;
//    }
//    
//    return method;
//}

static NSString *json2String(id json) {
    // 转成JSON字符串, 用于打印（直接打印字典，中文需转码）
    NSString *jsonString = [json hy_JSONStringWithType:HYJSONTypeFormated];
    // 去除转义
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/"
                                                       withString:@"/"];
    return jsonString;
}

#pragma mark DiskCache

/**
 生成请求路径的MD5值，生成缓存文件路径
 */
- (NSString *)filePathWithURL:(NSString *)requestURL {
    NSString *fileName = [requestURL hy_md5];
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", fileName]];
    return filePath;
}

- (void)saveToFileWithURL:(NSString *)requestURL
                   header:(id)headerField
                 response:(id)responseObject
                    error:(NSError *)error
                  handler:(SpotCompletionHandler)handlerBlock {
    
    if (responseObject && [NSJSONSerialization isValidJSONObject:responseObject]) {
        
        NSDictionary *cache = @{kCacheHeaderField: headerField ? : @{},
                                kCacheResponseObject : responseObject ? : @{}
                                };
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:cache
                                                           options:0
                                                             error:nil];
        
        NSString *filePath = [self filePathWithURL:requestURL];
        
        NSError *writeError = nil;
        if ([jsonData writeToFile:filePath options:0 error:&writeError]) {
            //            NSLog(@"写入缓存文件：%@", filePath);
        } else {
            //            NSLog(@"写入缓存文件失败 %@", writeError.localizedDescription);
        }
        
    }
    
}


@end
