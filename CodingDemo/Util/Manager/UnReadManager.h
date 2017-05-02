//
//  UnReadManager.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/14.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnReadManager : NSObject
@property (strong, nonatomic) NSNumber *messages, *notifications, *project_update_count;
+ (instancetype)shareManager;
- (void)updateUnRead;
@end
