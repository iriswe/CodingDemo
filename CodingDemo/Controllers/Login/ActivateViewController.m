//
//  ActivateViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/12.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "ActivateViewController.h"
#import "Input_OnlyText_Cell.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Coding_NetAPIManager.h"
#import "AppDelegate.h"
#import "CodingModel.h"

@interface ActivateViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIButton *footerBtn;
@property (strong, nonatomic) NSString *global_key;

@end

@implementation ActivateViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置用户名";
    //    添加myTableView
    _myTableView = ({
        TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [tableView registerClass:[Input_OnlyText_Cell class] forCellReuseIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text];
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
    self.myTableView.tableHeaderView = [self customHeaderView];
    self.myTableView.tableFooterView=[self customFooterView];
}
- (UIView *)customHeaderView{
    UIView *headerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    headerV.backgroundColor = [UIColor clearColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:12];
    headerLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
    headerLabel.numberOfLines = 0;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"您还未设置过用户名（个性后缀）\n设置后才能正常登录！";
    [headerLabel setCenter:headerV.center];
    [headerV addSubview:headerLabel];
    return headerV;
}
- (UIView *)customFooterView{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    //button
    _footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"马上设置" andFrame:CGRectMake(kLoginPaddingLeftWidth, 20, SCREEN_WIDTH - kLoginPaddingLeftWidth * 2, 45) target:self action:@selector(sendActivate)];
    [footerV addSubview:_footerBtn];
    RAC(self, footerBtn.enabled) = [RACSignal combineLatest:@[RACObserve(self, global_key)] reduce:^id(NSString *global_key){
        return @(global_key.length > 0);
    }];
    return footerV;
}

- (void)sendActivate{
    [self.footerBtn startQueryAnimate];
    [[Coding_NetAPIManager sharedManager] request_ActivateBySetGlobal_key:_global_key block:^(id data, NSError *error) {
        [self.footerBtn stopQueryAnimate];
        if (data) {
            [Login setPreUserEmail:self.global_key];//记住登录账号
            [((AppDelegate *)[UIApplication sharedApplication].delegate) setupTableViewController];
        }
    }];
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Input_OnlyText_Cell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Input_OnlyText_Cell_Text forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
    [cell setPlaceholder:@" 用户名（个性后缀）" value:self.global_key];
    cell.textValueChangedBlock = ^(NSString *valueStr){
        weakSelf.global_key = valueStr;
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kLoginPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
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
