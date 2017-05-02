//
//  UnReadManager.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/14.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "UnReadManager.h"
#import "Coding_NetAPIManager.h"

@implementation UnReadManager
static UnReadManager *shared_manager = nil;
static dispatch_once_t pred;
+ (instancetype)shareManager
{
    dispatch_once(&pred, ^{
        
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

- (void)updateUnRead
{
    [[Coding_NetAPIManager sharedManager] request_UnReadCountWithBlock:^(id data, NSError *error) {
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict = (NSDictionary *)data;
            self.messages = [dataDict objectForKey:kUnReadKey_messages];
            self.notifications = [dataDict objectForKey:kUnReadKey_notifications];
            self.project_update_count = [dataDict objectForKey:kUnReadKey_project_update_count];
            //更新应用角标
            NSInteger unreadCount = self.messages.integerValue
            +self.notifications.integerValue;
            [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount;
        }
    }];

}
@end
