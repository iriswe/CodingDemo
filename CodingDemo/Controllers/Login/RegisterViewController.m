//
//  RegisterViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/1.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "RegisterViewController.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Input_OnlyText_Cell.h"
#import "UIBarButtonItem+Common.h"
#import "UIButton+Bootstrap.h"
#import "UITTTAttributedLabel.h"
#import "WebViewController.h"
#import "Input_OnlyText_Cell.h"
#import "CountryViewController.h"
#import "CodingNetAPIClient.h"
#import "Coding_NetAPIManager.h"
#import "CodingModel.h"
#import "AppDelegate.h"

@interface RegisterViewController () <UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate>

@property (nonatomic, assign) RegisterMethodType medthodType;

@property (nonatomic, strong) Register *myRegister;

@property (nonatomic, strong) TPKeyboardAvoidingTableView *tableView;
@property (nonatomic, strong) UIButton *footerBtn;


@property (assign, nonatomic) BOOL captchaNeeded;
@property (strong, nonatomic) NSDictionary *countryCodeDict;
@property (strong, nonatomic) NSString *phoneCodeCellIdentifier;

@end

@implementation RegisterViewController
#pragma mark init
+ (instancetype)initWithRegisterMethodTYpe:(RegisterMethodType)type registerModel:(Register *)obj
{
    RegisterViewController *vc = [self new];
    vc.medthodType = type;
    vc.myRegister = obj;
    return vc;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self refreshCaptchaNeeded];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"注册";
    self.phoneCodeCellIdentifier = [Input_OnlyText_Cell randomCellIdentifierOfPhoneCodeType];
    _captchaNeeded = NO;
    if (!_myRegister) {
        self.myRegister = [Register new];
    }
    
    _tableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Phone];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Captcha];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Password];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:self.phoneCodeCellIdentifier];
//        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        tableView.backgroundColor = [UIColor colorWithHexString:@"0xeeeeee"];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    [self setupNav];
    self.tableView.tableHeaderView = [self setHeaderTableView];
    self.tableView.tableFooterView = [self setFooterView];
    [self configBottomView];

}


#pragma mark tableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = _medthodType ==  RegisterMethodEamil ? 3 : 4;
    return _captchaNeeded ? num + 1 : num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if (_medthodType == RegisterMethodEamil) {
        cellIdentifier = indexPath.row == 3? kCellIdentifier_Input_OnlyText_Cell_Captcha:
                         indexPath.row == 2? kCellIdentifier_Input_OnlyText_Cell_Password:
                         kCellIdentifier_Input_OnlyText_Cell_Text;
    } else {
        cellIdentifier = indexPath.row == 4? kCellIdentifier_Input_OnlyText_Cell_Captcha:
                         indexPath.row == 3? self.phoneCodeCellIdentifier:
                         indexPath.row == 2? kCellIdentifier_Input_OnlyText_Cell_Password:
                         indexPath.row == 1? kCellIdentifier_Input_OnlyText_Cell_Phone:
                         kCellIdentifier_Input_OnlyText_Cell_Text;
    }
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    kWeakSelf(self);
    if (_medthodType == RegisterMethodEamil) {
        if (indexPath.row == 0) {
            [cell setPlaceholder:@" 用户名（个性后缀）" value:self.myRegister.global_key];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakself.myRegister.global_key = valueStr;
            };
        } else if (indexPath.row == 1){
            cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
            [cell setPlaceholder:@" 邮箱" value:self.myRegister.email];
            cell.textValueChangedBlock = ^(NSString *valueStr){
//                weakSelf.inputTipsView.valueStr = valueStr;
//                weakSelf.inputTipsView.active = YES;
                weakself.myRegister.email = valueStr;
            };
            cell.editDidEndBlock = ^(NSString *textStr){
//                weakself.inputTipsView.active = NO;
            };
        } else if (indexPath.row == 2) {
            [cell setPlaceholder:@" 设置密码" value:self.myRegister.password];
            cell.textValueChangedBlock = ^(NSString *passWord){
                weakself.myRegister.password = passWord;
            };
        } else {
            [cell setPlaceholder:@" 验证码" value:self.myRegister.j_captcha];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakself.myRegister.j_captcha = valueStr;
            };
        }
        
    } else {
        if (indexPath.row == 0) {
            [cell setPlaceholder:@" 用户名（个性后缀）" value:self.myRegister.global_key];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakself.myRegister.global_key = valueStr;
            };
        }else if (indexPath.row == 1){
            if (!_countryCodeDict) {
                _countryCodeDict = @{@"country": @"China",
                                     @"country_code": @"86",
                                     @"iso_code": @"cn"};
            }
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            [cell setPlaceholder:@" 手机号" value:self.myRegister.phone];
            cell.countryCodeL.text = [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]];
            cell.countryCodeBtnClickedBlock = ^(){
                [weakself goToCountryCodeVC];
            };
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakself.myRegister.phone = valueStr;
            };
        }else if (indexPath.row == 2){
            [cell setPlaceholder:@" 设置密码" value:self.myRegister.password];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakself.myRegister.password = valueStr;
            };
        }else if (indexPath.row == 3){
            cell.textField.keyboardType = UIKeyboardTypeNumberPad;
            [cell setPlaceholder:@" 手机验证码" value:self.myRegister.code];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakself.myRegister.code = valueStr;
            };
            cell.phoneCodeBtnClickedBlock = ^(PhoneCodeButton *btn){
                [weakself phoneCodeBtnClicked:btn];
            };
        }else{
            [cell setPlaceholder:@" 验证码" value:self.myRegister.j_captcha];
            cell.textValueChangedBlock = ^(NSString *valueStr){
                weakself.myRegister.j_captcha = valueStr;
            };
        }
    }
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
//    cell.backgroundColor = RandomColor;
    return cell;
}

- (void)goToCountryCodeVC
{
    kWeakSelf(self);
    CountryViewController *vc = [[CountryViewController alloc] init];
    vc.selectedBlock = ^(NSDictionary *dic){
        weakself.countryCodeDict = dic;
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)phoneCodeBtnClicked:(PhoneCodeButton *)btn
{
    if (![_myRegister.phone isPhoneNO]) {
        [NSObject showHudTipStr:@"手机号码格式有误"];
        return;
    }
    btn.enabled = NO;
    NSDictionary *params = @{@"phone": _myRegister.phone, @"phoneCountryCode": [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]]};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/register/generate_phone_code" withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [NSObject showHudTipStr:@"验证码发送成功"];
            [btn startUpTimer];
        } else {
            [btn invalidateTimer];
        }
        
    }];
    
}


#pragma mark tableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

#pragma mark headerTableView And footerTableView Bottom
- (UIView *)setHeaderTableView
{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.15*SCREENH_HEIGHT)];
    headerV.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"加入Coding，体验云端开发之美！";
    headerLabel.center = headerV.center;
    [headerV addSubview:headerLabel];
    return headerV;
}

- (UIView *)setFooterView
{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    //button
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"注册" andFrame:CGRectMake(18, 20, SCREEN_WIDTH - 18 * 2, 45) target:self action:@selector(sendRegister)];
    [footerV addSubview:_footerBtn];
    
    //RAC判断注册按钮是否可点击
    kWeakSelf(self);
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, myRegister.global_key),
                                                              RACObserve(self, myRegister.phone),
                                                              RACObserve(self, myRegister.email),
                                                              RACObserve(self, myRegister.password),
                                                              RACObserve(self, myRegister.code),
                                                              RACObserve(self, myRegister.j_captcha),
                                                              RACObserve(self, captchaNeeded)] reduce:^id (NSString *global_key,                                                                                                                                 NSString *phone,                                                                                                                                 NSString *email,                                                                                                                                 NSString *password,                                                                                                                                 NSString *code,                                                                                                                                 NSString *j_captcha,                                                                                                                    NSNumber *captchaNeeded){
                                                                  BOOL enabled = (global_key.length > 0 &&
                                                                                  password.length > 0 &&
                                                                                  (!captchaNeeded.boolValue || j_captcha.length > 0) &&
                                                                                  ((weakself.medthodType == RegisterMethodEamil && email.length > 0) ||
                                                                                   (weakself.medthodType == RegisterMethodPhone && phone.length > 0 && code.length > 0)));
                                                                  return @(enabled);
                                                                  
                                                              }];
    
    UITTTAttributedLabel *label = ({
        UITTTAttributedLabel *label = [[UITTTAttributedLabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        label.numberOfLines = 0;
        label.textColor = [UIColor colorWithHexString:@"0x999999"];
        label.linkAttributes = kLinkAttributes;
        label.activeLinkAttributes = kLinkAttributesActive;
        label.delegate = self;
        label;
    });
    NSString *tipStr = @"注册 Coding 账号表示您已同意进入:acfun";
    label.text = tipStr;
    [label addLinkToTransitInformation:@{@"actionStr" : @"gotoServiceTermsVC"} withRange:[tipStr rangeOfString:@"进入:acfun"]];
        label.frame = CGRectMake(CGRectGetMinX(_footerBtn.frame), CGRectGetMaxY(_footerBtn.frame) +12, CGRectGetWidth(_footerBtn.frame), 12);
    [footerV addSubview:label];
    return footerV;
}

- (void)gotoServiceTermsVC
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"acfun" ofType:@"html"];
    WebViewController *vc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:path]];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)sendRegister
{
    if (![_myRegister.global_key isGK]) {
        [NSObject showHudTipStr:@"个性后缀仅支持英文字母、数字、横线(-)以及下划线(_)"];
        return;
    }
    kWeakSelf(self);
    NSMutableDictionary *params = @{@"channel": [Register channel],
                                     @"global_key": _myRegister.global_key,
                                     @"password": [_myRegister.password sha1Str],
                                     @"confirm": [_myRegister.password sha1Str]}.mutableCopy;
    if (_medthodType == RegisterMethodEamil) {
        params[@"email"] = _myRegister.email;
    } else {
        params[@"phone"] = _myRegister.phone;
        params[@"code"] = _myRegister.code;
        params[@"country"] = _countryCodeDict[@"iso_code"];
        params[@"phoneCountryCode"] = [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]];
    }
    if (_captchaNeeded) {
        params[@"j_captcha"] = _myRegister.j_captcha;
    }
    [self.footerBtn startQueryAnimate];
    [[Coding_NetAPIManager sharedManager] request_Register_V2_WithParams:params andBlock:^(id data, NSError *error) {
        if (data) {
            [self.view endEditing:YES];
            [Login setPreUserEmail:self.myRegister.global_key];//记住登录账号
            [((AppDelegate *)[UIApplication sharedApplication].delegate) setupLoginViewController];
            if (weakself.medthodType == RegisterMethodEamil) {
            kTipAlert(@"欢迎注册 Coding，请尽快去邮箱查收邮件并激活账号。如若在收件箱中未看到激活邮件，请留意一下垃圾邮件箱(T_T)。");
            } else {
                [self refreshCaptchaNeeded];
                
            }
        }
    }];
    
}

- (void)refreshCaptchaNeeded
{
    kWeakSelf(self);
    [[Coding_NetAPIManager sharedManager] request_CaptchaNeededWithPath:@"api/captcha/register" andBlock:^(id data, NSError *error) {
        if (data) {
            NSNumber *captchaNeededResult = (NSNumber *)data;
            if (captchaNeededResult) {
                weakself.captchaNeeded = captchaNeededResult.boolValue;
            }
            [weakself.tableView reloadData];
        }
    }];

}

- (void)setupNav
{
    kLog(@"===========注册界面子控制器数量===========\n%lu", self.navigationController.childViewControllers.count);
    if (self.navigationController.childViewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem= [UIBarButtonItem itemWithBtnTitle:@"取消" target:self action:@selector(cancelRegister)];
    }
}

- (void)cancelRegister
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)configBottomView
{
    UIView *bottomView = [UIView new];
    bottomView.backgroundColor = self.tableView.backgroundColor;
    
    UIButton *bottomBtn = ({
        UIButton *button = [UIButton new];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
        [button setTitle:_medthodType == RegisterMethodEamil? @"手机号注册": @"邮箱注册" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(changeMethodType) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [bottomView addSubview:bottomBtn];
    [bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomView).insets(UIEdgeInsetsMake(0, 0, 30, 0));
    }];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
}

- (void)changeMethodType
{
    if (_medthodType == RegisterMethodPhone) {
        RegisterViewController *vc = [RegisterViewController initWithRegisterMethodTYpe:RegisterMethodEamil registerModel:_myRegister];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    [self gotoServiceTermsVC];
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
