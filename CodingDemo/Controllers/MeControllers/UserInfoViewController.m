//
//  UserInfoViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/10/10.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "UserInfoViewController.h"
#import "Coding_NetAPIManager.h"
#import "UserHeaderView.h"
#import "RDVTabBarController.h"
#import "UserInfoTextCell.h"
#import "UserInfoIconCell.h"
#import "StartImagesManager.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "FunctionTipsManager.h"
#import "UIScrollView+APParallaxHeader.h"

@interface UserInfoViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) UserHeaderView *headerView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@end

@implementation UserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_isRoot) {
        self.title = @"我";
        _curUser = [Login curLoginUser]? [Login curLoginUser]: [User userWithGlobalKey:@""];
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settingBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(settingBtnClicked:)] animated:YES];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addUserBtn_Nav"] style:UIBarButtonItemStylePlain target:self action:@selector(addUserBtnClicked:)] animated:YES];
    } else {
        self.title = _curUser.name;
    }
    
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.backgroundColor = kColorTableSectionBg;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[UserInfoTextCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoTextCell];
        [tableView registerClass:[UserInfoIconCell class] forCellReuseIdentifier:kCellIdentifier_UserInfoIconCell];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        if (_isRoot) {
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
            tableView.contentInset = insets;
            tableView.scrollIndicatorInsets = insets;
        }
        tableView;
    });
    
    kWeakSelf(self);
    _headerView = [UserHeaderView userHeaderViewWithUser:_curUser image:[StartImagesManager sharedManager].curImage.image];
    _headerView.userIconClicked = ^{
        [weakself userIconClick];
    };
    _headerView.fansCountBtnClicked = ^{
        [weakself fansCountBtnClicked];
    };
    _headerView.followBtnClicked = ^{
        [weakself followBtnClicked];
    };
    _headerView.followsCountBtnClicked = ^{
        [weakself followsCountBtnClicked];
    };
    kLog(@"头视图高度:%f", CGRectGetHeight(_headerView.frame));
    [_myTableView addParallaxWithView:_headerView andHeight:CGRectGetHeight(_headerView.frame)];
    if (![self isMe]) {
        _myTableView.tableFooterView = [self footerV];
    }
    
    _refreshControl = [[ODRefreshControl alloc] initInScrollView:_myTableView];
    [_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)refresh
{
    kWeakSelf(self);
    [[Coding_NetAPIManager sharedManager] request_UserInfo_WithObj:_curUser andBlock:^(id data, NSError *error) {
        [weakself.refreshControl endRefreshing];
        if (data) {
            weakself.curUser = data;
            weakself.headerView.curUser = data;
            weakself.title = _isRoot? @"我": weakself.curUser.name;
            [weakself.myTableView reloadData];
        }
    }];
}


#pragma mark - footerV
- (BOOL)isMe{
    return (_isRoot || [_curUser.global_key isEqualToString:[Login curLoginUser].global_key]);
}

- (UIView *)footerV
{
    UIView *footerV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 72)];
    
    UIButton *footerBtn = [UIButton buttonWithStyle:StrapSuccessStyle andTitle:@"发消息" andFrame:CGRectMake(kPaddingLeftWidth, (CGRectGetHeight(footerV.frame)-44)/2 , SCREEN_WIDTH - 2*kPaddingLeftWidth, 44) target:self action:@selector(messageBtnClicked)];
    [footerV addSubview:footerBtn];
    return footerV;
}

#pragma mark - Tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_curUser.global_key isEqualToString:[Login curLoginUser].global_key]? 4: 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row = 0;
    if (section == 0) {
        row = [self isMe]? 0: 3;
    }else if (section == 1){
        row = 1;
    }else if (section == 2){
        row = [self isMe]? 4: 3;
    }else if (section == 3){
        row = 1;
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UserInfoTextCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoTextCell forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                [cell setTitle:@"所在地" value:_curUser.location];
                break;
            case 1:
                [cell setTitle:@"座右铭" value:_curUser.slogan];
                break;
            default:
                [cell setTitle:@"个性标签" value:_curUser.tags_str];
                break;
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    } else {
        UserInfoIconCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_UserInfoIconCell forIndexPath:indexPath];
        if (indexPath.section == 1) {
            [cell setTitle:@"详细信息" icon:@"user_info_detail"];
        }else if (indexPath.section == 2){
            if (indexPath.row == 0) {
                [cell setTitle:[self isMe]? @"我的项目": @"Ta的项目" icon:@"user_info_project"];
            }else if(indexPath.row == 1){
                [cell setTitle:[self isMe]? @"我的冒泡": @"Ta的冒泡" icon:@"user_info_tweet"];
            }else if (indexPath.row == 2){
                [cell setTitle:[self isMe]? @"我的话题": @"Ta的话题" icon:@"user_info_topic"];
            }else{
                [cell setTitle:@"本地文件" icon:@"user_info_file"];
            }
        }else{
            [cell setTitle:@"我的码币" icon:@"user_info_point"];
            if ([[FunctionTipsManager shareManager] needToTip:kFunctionTipStr_Me_Points]) {
                [cell addTipIcon];
            }
        }
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0;
    if (indexPath.section == 0) {
        cellHeight = [UserInfoTextCell cellHeight];
    }else{
        cellHeight = [UserInfoIconCell cellHeight];
    }
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (![self isMe]
        && section == [self numberOfSectionsInTableView:self.myTableView] -1) {
        return 0.5;
    }
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    footerView.backgroundColor = kColorTableSectionBg;
    return footerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.section == 1) {
//        [self goToDetailInfo];
//    }else if (indexPath.section == 2){
//        if (indexPath.row == 0) {
//            [self goToProjects];
//        }else if(indexPath.row == 1){
//            [self goToTweets];
//        }else if (indexPath.row == 2){
//            [self goToTopic];
//        }else{
//            [self goToLocalFolders];
//        }
//    }else if (indexPath.section == 3){
//        if ([[FunctionTipsManager shareManager] needToTip:kFunctionTipStr_Me_Points]) {
//            [[FunctionTipsManager shareManager] markTiped:kFunctionTipStr_Me_Points];
//            UserInfoIconCell *cell = (UserInfoIconCell *)[tableView cellForRowAtIndexPath:indexPath];
//            [cell removeTip];
//        }
//        [self goToPoint];
//    }

}

#pragma mark - cell select
- (void)goToProjects{
//    ProjectListViewController *vc = [[ProjectListViewController alloc] init];
//    vc.curUser = _curUser;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToDetailInfo{
//    if ([self isMe]) {
//        SettingMineInfoViewController *vc = [[SettingMineInfoViewController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
//    }else{
//        UserInfoDetailViewController *vc = [[UserInfoDetailViewController alloc] init];
//        vc.curUser = self.curUser;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
}
- (void)goToTweets{
//    UserOrProjectTweetsViewController *vc = [[UserOrProjectTweetsViewController alloc] init];
//    vc.curTweets = [Tweets tweetsWithUser:_curUser];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToTopic {
//    CSMyTopicVC *vc = [[CSMyTopicVC alloc] init];
//    vc.curUser = _curUser;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToLocalFolders{
//    LocalFoldersViewController *vc = [LocalFoldersViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToPoint{
//    PointRecordsViewController *vc = [PointRecordsViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Nav
- (void)settingBtnClicked:(id)sender{
//    SettingViewController *vc = [[SettingViewController alloc] init];
//    vc.myUser = self.curUser;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addUserBtnClicked:(id)sender{
//    AddUserViewController *vc = [[AddUserViewController alloc] init];
//    vc.type = AddUserTypeFollow;
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Btn Clicked
- (void)fansCountBtnClicked{
    if (_curUser.id.integerValue == 93) {//Coding官方账号
        return;
    }
//    UsersViewController *vc = [[UsersViewController alloc] init];
//    vc.curUsers = [Users usersWithOwner:_curUser Type:UsersTypeFollowers];
//    [self.navigationController pushViewController:vc animated:YES];
}
- (void)followsCountBtnClicked{
    if (_curUser.id.integerValue == 93) {//Coding官方账号
        return;
    }
//    UsersViewController *vc = [[UsersViewController alloc] init];
//    vc.curUsers = [Users usersWithOwner:_curUser Type:UsersTypeFriends_Attentive];
//    [self.navigationController pushViewController:vc animated:YES];
}
- (void)userIconClick
{
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.url = [_curUser.avatar urlWithCodePath];
    
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = 0;
    browser.photos = [NSArray arrayWithObject:photo];
    [browser show];
}

- (void)messageBtnClicked{
//    ConversationViewController *vc = [[ConversationViewController alloc] init];
//    vc.myPriMsgs = [PrivateMessages priMsgsWithUser:_curUser];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)followBtnClicked{
    kWeakSelf(self);
    [[Coding_NetAPIManager sharedManager] request_FollowedOrNot_WithObj:_curUser andBlock:^(id data, NSError *error) {
        if (data) {
            weakself.curUser.followed = [NSNumber numberWithBool:!_curUser.followed.boolValue];
            weakself.headerView.curUser = weakself.curUser;
            if (weakself.followChanged) {
                weakself.followChanged(weakself.curUser);
            }
        }
    }];
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
