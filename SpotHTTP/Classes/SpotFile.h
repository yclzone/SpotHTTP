//
//  SpotFile.h
//  Pods
//
//  Created by gogovan on 01/08/2017.
//
//

#import <Foundation/Foundation.h>

@interface SpotFile : NSObject

/** URL */
@property (nonatomic, strong) NSURL *fileURL;
/** data */
@property (nonatomic, strong) NSData *fileData;
/** 参数名 */
@property (nonatomic, copy) NSString *name;
/** 文件名 */
@property (nonatomic, copy) NSString *fileName;
/** MIME类型 */
@property (nonatomic, copy) NSString *mimeType;

+ (instancetype)fileWithFileURL:(NSURL *)fileURL
                               name:(NSString *)name
                           fileName:(NSString *)fileName
                           mimeType:(NSString *)mimeType;

+ (instancetype)fileWithFileData:(NSData *)fileData
                                name:(NSString *)name
                            fileName:(NSString *)fileName
                            mimeType:(NSString *)mimeType;
@end
