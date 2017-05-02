//
//  SendRewardManager.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendRewardManager : NSObject
+ (instancetype)handleTweet:(Tweet *)curTweet completion:(void(^)(Tweet *curTweet, BOOL sendSucess))block;
@end
