//
//  SpotFile.m
//  Pods
//
//  Created by gogovan on 01/08/2017.
//
//

#import "SpotFile.h"

@implementation SpotFile
+ (instancetype)fileWithFileURL:(NSURL *)fileURL
                               name:(NSString *)name
                           fileName:(NSString *)fileName
                           mimeType:(NSString *)mimeType {
    SpotFile *item = [[self alloc] init];
    item.fileURL = fileURL;
    item.name = name;
    item.fileName = fileName;
    item.mimeType = mimeType;
    return item;
}

+ (instancetype)fileWithFileData:(NSData *)fileData
                                name:(NSString *)name
                            fileName:(NSString *)fileName
                            mimeType:(NSString *)mimeType {
    SpotFile *item = [[self alloc] init];
    item.fileData = fileData;
    item.name = name;
    item.fileName = fileName;
    item.mimeType = mimeType;
    return item;
}
@end
