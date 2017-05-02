//
//  NSURL+Common.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/12.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Common)
+(BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
- (NSDictionary *)queryParams;
@end
