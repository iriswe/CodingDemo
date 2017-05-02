//
//  CodingNetAPIClient.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/6.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

typedef enum {
    Get = 0,
    Post,
    Put,
    Delete
} NetworkMethod;

@interface CodingNetAPIClient : AFHTTPRequestOperationManager

+(id)sharedJsonClient;
+ (id)changeJsonClient;

- (void)requestJsonDataWithPath:(NSString *)aPath withParams:(NSDictionary*)params withMethodType:(NetworkMethod)method andBlock:(void (^)(id data, NSError *error))block;
- (void)requestJsonDataWithPath:(NSString *)aPath withParams:(NSDictionary*)params withMethodType:(NetworkMethod)method autoShowError:(BOOL)autoShowError andBlock:(void (^)(id data, NSError *error))block;
@end
