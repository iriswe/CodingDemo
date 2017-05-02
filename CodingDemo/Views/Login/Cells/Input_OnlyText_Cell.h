//
//  Input_OnlyText_Cell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/1.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_Input_OnlyText_Cell_Text @"Input_OnlyText_Cell_Text"
#define kCellIdentifier_Input_OnlyText_Cell_Captcha @"Input_OnlyText_Cell_Captcha"
#define kCellIdentifier_Input_OnlyText_Cell_Password @"Input_OnlyText_Cell_Password"
#define kCellIdentifier_Input_OnlyText_Cell_Phone @"Input_OnlyText_Cell_Phone"
#define kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix @"Input_OnlyText_Cell_PhoneCode"

#import <UIKit/UIKit.h>

@interface Input_OnlyText_Cell : UITableViewCell

@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, strong) UILabel *countryCodeL;

@property (nonatomic, strong) UITapImageView *captchaView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIButton *clearBtn, *passwordBtn;
@property (nonatomic, strong, readonly) PhoneCodeButton *verify_codeBtn;
@property (strong, nonatomic) UIView *lineView;

@property (assign, nonatomic) BOOL isForLoginVC;

@property (nonatomic, copy) void(^textValueChangedBlock)(NSString *);
@property (nonatomic,copy) void(^editDidBeginBlock)(NSString *);
@property (nonatomic,copy) void(^editDidEndBlock)(NSString *);
@property (nonatomic,copy) void(^phoneCodeBtnClickedBlock)(PhoneCodeButton *);
@property (nonatomic,copy) void(^countryCodeBtnClickedBlock)();

+ (NSString *)randomCellIdentifierOfPhoneCodeType;

- (void)setPlaceholder:(NSString *)phStr value:(NSString *)valueStr;

@end
