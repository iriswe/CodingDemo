//
//  SendRewardManager.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "SendRewardManager.h"
#import "Coding_NetAPIManager.h"
#import "CodingModel.h"
//#import "SettingPhoneViewController.h"
@interface SendRewardManager ()
@property (strong, nonatomic) Tweet *curTweet;
@property (copy, nonatomic) void(^completion)(Tweet *curTweet, BOOL sendSucess);
@property (strong, nonatomic) NSString *tipStr;


@property (strong, nonatomic) UIView *bgView, *contentView;
@property (strong, nonatomic) UIImageView *userImgV;
@property (strong, nonatomic) UIButton *closeBtn, *submitBtn, *tipBgView;
@property (strong, nonatomic) UILabel *titleL, *tipL, *bottomL;
@property (strong, nonatomic) UITextField *passwordF;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (assign, nonatomic) BOOL isSubmitting, isNeedPassword;
@end
@implementation SendRewardManager

@end
