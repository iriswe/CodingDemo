//
//  LoginViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/12.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "LoginViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Input_OnlyText_Cell.h"
#import "Login2FATipCell.h"
#import "StartImagesManager.h"
#import "CodingModel.h"
#import "Coding_NetAPIManager.h"
#import "EaseInputTipsView.h"
#import "AppDelegate.h"
#import "RegisterViewController.h"
#import "ActivateViewController.h"
#import "Close2FAViewController.h"
#import "CannotLoginViewController.h"
#import "OTPListViewController.h"

@interface LoginViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIImageView *iconUserView, *bgBlurredView;
@property (strong, nonatomic) UIButton *loginBtn, *buttonFor2FA, *cannotLoginBtn;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) EaseInputTipsView *inputTipsView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;


@property (nonatomic, strong) Login *myLogin;
@property (assign, nonatomic) BOOL captchaNeeded;
@property (assign, nonatomic) BOOL is2FAUI;
@property (strong, nonatomic) NSString *otpCode;
@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myLogin = [[Login alloc] init];
    self.myLogin.email = [Login preUserEmail];
    _captchaNeeded = NO;
    
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Login2FATipCell class] forCellReuseIdentifier:kCellIdentifier_Login2FATipCell];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
        tableView.backgroundView = self.bgBlurredView;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
    [self configBottomView];
    [self showdismissButton:self.showDismissButton];
    [self buttonFor2FA];
    [self refreshCaptchaNeeded];
    [self refreshIconUserImage];
}
#pragma mark HeaderView FooterView
- (UIImageView *)bgBlurredView
{
    if (!_bgBlurredView) {
        //背景图片
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        bgView.contentMode = UIViewContentModeScaleAspectFill;
        UIImage *bgImage = [[StartImagesManager sharedManager] curImage].image;
        CGSize bgImageSize = bgImage.size, bgViewSize = bgView.frame.size;
        if (bgImageSize.width > bgViewSize.width && bgImageSize.height > bgViewSize.height) {
            bgImage = [bgImage cropToSize:bgViewSize usingMode:NYXCropModeCenter];
        }
        bgImage = [bgImage scaleToFitSize:CGSizeMake(bgImage.size.width, bgImage.size.height)];
        bgView.image = bgImage;
        //黑色遮罩
        UIColor *blackColor = [UIColor blackColor];
        [bgView addGradientLayerWithColors:@[(id)[blackColor colorWithAlphaComponent:0.3].CGColor,
                                             (id)[blackColor colorWithAlphaComponent:0.3].CGColor] locations:nil startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)];
        _bgBlurredView = bgView;
    }
        return _bgBlurredView;
}

- (UIView *)customHeaderView
{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT/3)];
    
    _iconUserView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    _iconUserView.contentMode = UIViewContentModeScaleAspectFit;
    _iconUserView.layer.masksToBounds = YES;
    _iconUserView.layer.cornerRadius = _iconUserView.frame.size.width/2;
    _iconUserView.layer.borderWidth = 2;
    _iconUserView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    [headerV addSubview:_iconUserView];
    [_iconUserView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 80));
        make.centerX.equalTo(headerV);
        make.centerY.equalTo(headerV).offset(30);
    }];
    [_iconUserView setImage:[UIImage imageNamed:@"icon_user_monkey"]];
    return headerV;
}

- (UIView *)customFooterView
{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    _loginBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"登录" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, SCREEN_WIDTH - kLoginPaddingLeftWidth * 2, 45) target:self action:@selector(sendLogin)];
    [footerV addSubview:_loginBtn];
    RAC(self, loginBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myLogin.email),
                                                             RACObserve(self, myLogin.password),
                                                             RACObserve(self, myLogin.j_captcha),
                                                             RACObserve(self, captchaNeeded),
                                                             RACObserve(self, is2FAUI),
                                                             RACObserve(self, otpCode)] reduce:^id (NSString *email,
                                                                  NSString *password,
                                                                  NSString *j_captcha,
                                                                  NSNumber *captchaNeeded,
                                                                  NSNumber *is2FAUI,
                                                                  NSString *otpCode){
                                                                 if (is2FAUI && is2FAUI.boolValue) {
                                                                     return @(otpCode.length > 0);
                                                                 } else {
                                                                     if ((captchaNeeded && captchaNeeded.boolValue) && (!j_captcha || j_captcha.length <= 0)) {
                                                                         return @(NO);
                                                                     }else{
                                                                         return @((email && email.length > 0) && (password && password.length > 0));
                                                                     }
                                                                 }
                                                             }];
    
    _cannotLoginBtn = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [button setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
        
        [button setTitle:@"找回密码" forState:UIControlStateNormal];
        [footerV addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100, 30));
            make.centerX.equalTo(footerV);
            make.top.equalTo(_loginBtn.mas_bottom).offset(20);
        }];
        button;
    });
    [_cannotLoginBtn addTarget:self action:@selector(cannotLoginBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return footerV;

}

- (void)sendLogin
{
    NSString *tipMsg = _is2FAUI? [self loginTipFor2FA]: [_myLogin goToLoginTipWithCaptcha:_captchaNeeded];
    if (tipMsg) {
        kTipAlert(@"%@", tipMsg);
        return;
    }
    [self.view endEditing:YES];
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:
                              UIActivityIndicatorViewStyleGray];
        CGSize captchaViewSize = _loginBtn.bounds.size;
        _activityIndicator.hidesWhenStopped = YES;
        [_activityIndicator setCenter:CGPointMake(captchaViewSize.width/2, captchaViewSize.height/2)];
        [_loginBtn addSubview:_activityIndicator];
    }
    [_activityIndicator startAnimating];
    
    __weak typeof(self) weakSelf = self;
    _loginBtn.enabled = NO;
    
    if (_is2FAUI) {
        [[Coding_NetAPIManager sharedManager] request_Login_With2FA:self.otpCode andBlock:^(id data, NSError *error) {
            weakSelf.loginBtn.enabled = YES;
            [weakSelf.activityIndicator stopAnimating];
            if (data) {
                [Login setPreUserEmail:self.myLogin.email];//记住登录账号
                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTableViewController];
            }else{
                NSString *status_expired = error.userInfo[@"msg"][@"user_login_status_expired"];
                if (status_expired.length > 0) {
                    [weakSelf changeUITo2FAWithGK:nil];
                }
            }
        }];

    } else {
        [[Coding_NetAPIManager sharedManager] request_Login_WithPath:[self.myLogin toPath] Params:[self.myLogin toParams] andBlock:^(id data, NSError *error) {
            weakSelf.loginBtn.enabled = YES;
            [weakSelf.activityIndicator stopAnimating];
            if (data) {
                [Login setPreUserEmail:self.myLogin.email];//记住登录账号
                [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTableViewController];
                [self doSomethingAfterLogin];
            }else{
                NSString *global_key = error.userInfo[@"msg"][@"two_factor_auth_code_not_empty"];
                if (global_key.length > 0) {
                    [weakSelf changeUITo2FAWithGK:global_key];
                }else if (error.userInfo[@"msg"][@"user_need_activate"]){
                    [NSObject showError:error];
                    ActivateViewController *vc = [ActivateViewController new];
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    [NSObject showError:error];
                    [weakSelf refreshCaptchaNeeded];
                }
            }
        }];
    }

}

- (void)doSomethingAfterLogin{
    User *curUser = [Login curLoginUser];
    if (curUser.email.length > 0 && !curUser.email_validation.boolValue) {
        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"激活邮箱" message:@"该邮箱尚未激活，请尽快去邮箱查收邮件并激活账号。如果在收件箱中没有看到，请留意一下垃圾邮件箱子（T_T）"];
        [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertView bk_addButtonWithTitle:@"重发激活邮件" handler:nil];
        [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
            if (index == 1) {
                [self sendActivateEmail];
            }
        }];
        [alertView show];
        
    }
}

- (void)sendActivateEmail{
    [[Coding_NetAPIManager sharedManager] request_SendActivateEmail:[Login curLoginUser].email block:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"邮件已发送"];
        }
    }];
}

- (NSString *)loginTipFor2FA{
    NSString *tipStr = nil;
    if (self.otpCode.length <= 0) {
        tipStr = @"动态验证码不能为空";
    }else if (![self.otpCode isPureInt] || self.otpCode.length != 6){
        tipStr = @"动态验证码必须是一个6位数字";
    }
    return tipStr;
}

- (void)cannotLoginBtnClicked:(UIButton *)btn
{
    UIViewController *vc;
    if (_is2FAUI) {
        vc = [Close2FAViewController vcWithPhone:self.myLogin.email sucessBlock:^(UIViewController *vc) {
            self.is2FAUI = NO;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
    }else{
        vc = [CannotLoginViewController vcWithMethodType:0 stepIndex:0 userStr:(([self.myLogin.email isPhoneNO] || [self.myLogin.email isEmail])? self.myLogin.email: nil)];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configBottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREENH_HEIGHT - 55, SCREEN_WIDTH, 55)];
        _bottomView.backgroundColor = [UIColor clearColor];
        UIButton *registerBtn = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
            [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [button setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:0.5 alpha:0.5] forState:UIControlStateHighlighted];
            
            [button setTitle:@"去注册" forState:UIControlStateNormal];
            [_bottomView addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100, 30));
                make.centerX.equalTo(_bottomView);
                make.top.equalTo(_bottomView);
            }];
            button;
        });
        [registerBtn addTarget:self action:@selector(goRegisterVC:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_bottomView];
    }
}

- (void)goRegisterVC:(UIButton *)btn
{
    RegisterViewController *vc = [RegisterViewController initWithRegisterMethodTYpe:RegisterMethodPhone registerModel:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 2FA
- (void)changeUITo2FAWithGK:(NSString *)global_key{
    self.otpCode = [OTPListViewController otpCodeWithGK:global_key];
    self.is2FAUI = global_key.length > 0;
    if (self.otpCode) {
        [self sendLogin];
    }
}
- (void)showdismissButton:(BOOL)willShow{
    self.dismissButton.hidden = !willShow;
    if (!self.dismissButton && willShow) {
        self.dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 50, 50)];
        [self.dismissButton setImage:[UIImage imageNamed:@"dismissBtn_Nav"] forState:UIControlStateNormal];
        [self.dismissButton addTarget:self action:@selector(dismissButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.dismissButton];
    }
}

- (void)dismissButtonClicked
{
    if (self.is2FAUI) {
        self.is2FAUI = NO;
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIButton *)buttonFor2FA{
    if (!_buttonFor2FA) {
        _buttonFor2FA = ({
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 20, 90, 50)];
            [button.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateHighlighted];
            
            [button setTitle:@"  两步验证" forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"twoFABtn_Nav"] forState:UIControlStateNormal];
            button;
        });
        [_buttonFor2FA addTarget:self action:@selector(goTo2FAVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_buttonFor2FA];
    }
    return _buttonFor2FA;
}

- (void)goTo2FAVC
{
    OTPListViewController *vc = [OTPListViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark refresh
- (void)refreshCaptchaNeeded
{
    kWeakSelf(self);
    [[Coding_NetAPIManager sharedManager] request_CaptchaNeededWithPath:@"api/captcha/login" andBlock:^(id data, NSError *error) {
        if (data) {
            NSNumber *captchaNeededResult = (NSNumber *)data;
            if (captchaNeededResult) {
                weakself.captchaNeeded = captchaNeededResult.boolValue;
            }
            [weakself.myTableView reloadData];
        }
        
    }];
}

- (void)refreshIconUserImage{
    NSString *textStr = self.myLogin.email;
    if (textStr) {
        User *curUser = [Login userWithGlobaykeyOrEmail:textStr];
        if (curUser && curUser.avatar) {
            [self.iconUserView sd_setImageWithURL:[curUser.avatar urlImageWithCodePathResizeToView:self.iconUserView] placeholderImage:[UIImage imageNamed:@"icon_user_monkey"]];
            return;
        }
    }
    [self.iconUserView setImage:[UIImage imageNamed:@"icon_user_monkey"]];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _is2FAUI? 2: _captchaNeeded? 3: 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_is2FAUI && indexPath.row == 0) {
        Login2FATipCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Login2FATipCell forIndexPath:indexPath];
        cell.tipLabel.text = @"  您的账户开启了两步验证，请输入动态验证码登录  ";
        return cell;
    }
    
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:(indexPath.row > 1? kCellIdentifier_Input_OnlyText_Cell_Captcha: kCellIdentifier_Input_OnlyText_Cell_Text) forIndexPath:indexPath];
    cell.isForLoginVC = YES;
    
    __weak typeof(self) weakSelf = self;
    if (_is2FAUI) {
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        [cell setPlaceholder:@" 动态验证码" value:self.otpCode];
        cell.textValueChangedBlock = ^(NSString *valueStr){
            weakSelf.otpCode = valueStr;
        };
    }else{
        if (indexPath.row == 0) {
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            [cell setPlaceholder:@" 手机号码/电子邮箱/个性后缀" value:self.myLogin.email];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.inputTipsView.valueStr = valueStr;
                weakSelf.inputTipsView.active = YES;
                weakSelf.myLogin.email = valueStr;
                [weakSelf refreshIconUserImage];
            };
            cell.editDidBeginBlock = ^(NSString *valueStr){
                weakSelf.inputTipsView.valueStr = valueStr;
                weakSelf.inputTipsView.active = YES;
            };
            cell.editDidEndBlock = ^(NSString *textStr){
                weakSelf.inputTipsView.active = NO;
            };
        }else if (indexPath.row == 1){
            [cell setPlaceholder:@" 密码" value:self.myLogin.password];
            cell.textField.secureTextEntry = YES;
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myLogin.password = valueStr;
            };
        }else{
            [cell setPlaceholder:@" 验证码" value:self.myLogin.j_captcha];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakSelf.myLogin.j_captcha = valueStr;
            };
        }
    }
    return cell;
}

#pragma viewLife
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_inputTipsView) {
        _inputTipsView = ({
            EaseInputTipsView *tipsView = [EaseInputTipsView tipsViewWithType:EaseInputTipsViewTypeLogin];
            tipsView.valueStr = nil;
            
            __weak typeof(self) weakSelf = self;
            tipsView.selectedStringBlock = ^(NSString *valueStr){
                [weakSelf.view endEditing:YES];
                weakSelf.myLogin.email = valueStr;
                [weakSelf refreshIconUserImage];
                [weakSelf.myTableView reloadData];
            };
            UITableViewCell *cell = [_myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [tipsView setY:CGRectGetMaxY(cell.frame) - 0.5];
            
            [_myTableView addSubview:tipsView];
            tipsView;
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end