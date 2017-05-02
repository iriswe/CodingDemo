//
//  CannotLoginViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/12.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"
typedef NS_ENUM(NSInteger, CannotLoginMethodType) {
    CannotLoginMethodEamil = 0,
    CannotLoginMethodPhone
};

@interface CannotLoginViewController : BaseViewController
+ (instancetype)vcWithMethodType:(CannotLoginMethodType)methodType stepIndex:(NSUInteger)stepIndex userStr:(NSString *)userStr;
@end