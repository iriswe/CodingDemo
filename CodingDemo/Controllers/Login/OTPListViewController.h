//
//  OTPListViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/12.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"

@interface OTPListViewController : BaseViewController
+ (NSString *)otpCodeWithGK:(NSString *)global_key;
+ (BOOL)handleScanResult:(NSString *)resultStr ofVC:(UIViewController *)vc;
@end
