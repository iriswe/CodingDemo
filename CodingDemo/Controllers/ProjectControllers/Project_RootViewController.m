//
//  Project_RootViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/14.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "Project_RootViewController.h"
#import "SearchBar.h"
#import "iCarousel.h"
#import "PopFliterMenu.h"
#import "PopMenu.h"
#import "FRDLivelyButton.h"
#import "CodingModel.h"
#import "StartImagesManager.h"
#import "UnReadManager.h"
#import "ProjectListView.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "ProjectListCell.h"
#import "ZXScanCodeViewController.h"
#import "WebViewController.h"
#import "OTPListViewController.h"
#import "SearchViewController.h"

@interface Project_RootViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, iCarouselDelegate, iCarouselDataSource>
@property (strong, nonatomic) NSArray *segmentItems;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (nonatomic, strong) MainSearchBar *mySearchBar;
@property (nonatomic, strong) iCarousel *myCarousel;
@property (nonatomic, strong) PopFliterMenu *myFliterMenu;
@property (nonatomic,assign) NSInteger selectNum;  //筛选状态
@property (nonatomic, strong) PopMenu *myPopMenu;
@property (nonatomic,strong)FRDLivelyButton *rightNavBtn;
@property (nonatomic,strong)UIButton *leftNavBtn;
@property (strong, nonatomic) NSMutableDictionary *myProjectsDict;
@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) UISearchDisplayController *mySearchDisplayController;

@end

@implementation Project_RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initConstantData];
    _useNewStyle = true;
    //添加icarousel
    _myCarousel = ({
        iCarousel *icarousel = [[iCarousel alloc] init];
        icarousel.dataSource = self;
        icarousel.delegate = self;
        icarousel.decelerationRate = 1.0;
        icarousel.scrollSpeed = 1.0;
        icarousel.type = iCarouselTypeLinear;
        icarousel.pagingEnabled = YES;
        icarousel.clipsToBounds = YES;
        icarousel.bounceDistance = 0.2;
        [self.view addSubview:icarousel];
        [icarousel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        icarousel;
    });
    
    //添加搜索框
    _mySearchBar = ({
        MainSearchBar *searchBar = [[MainSearchBar alloc] initWithFrame:CGRectMake(60,7, SCREEN_WIDTH - 115, 31)];
        [searchBar setContentMode:UIViewContentModeLeft];
        [searchBar setPlaceholder:@"搜索"];
        searchBar.delegate = self;
        searchBar.layer.cornerRadius = 15;
        searchBar.layer.masksToBounds = TRUE;
        [searchBar.layer setBorderWidth:8];
        [searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];//设置边框为白色
        [searchBar sizeToFit];
        [searchBar setTintColor:[UIColor whiteColor]];
        [searchBar insertBGColor:[UIColor colorWithHexString:@"0xffffff"]];
        [searchBar setHeight:30];
        [searchBar.scanBtn addTarget:self action:@selector(scanBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        searchBar;
    });
    
    kWeakSelf(_myCarousel);
    _myFliterMenu = [[PopFliterMenu alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREENH_HEIGHT - 64) items:nil];
    kWeakSelf(self);
    _myFliterMenu.clickBlock = ^(NSInteger pageIndex){
        [weakself mobClickFliterMenuIndex:pageIndex];
        if (pageIndex==1000) {
            [weakself goToProjectSquareVC];
        }else
        {
            [weakself fliterBtnClose:TRUE];
            [weak_myCarousel scrollToItemAtIndex:pageIndex animated:NO];
            weakself.selectNum = pageIndex;
        }
        
    };
    
    _myFliterMenu.closeBlock=^(){
        [weakself closeFliter];
    };
    
    //初始化弹出菜单
    NSArray *menuItems = @[
                           [MenuItem itemWithTitle:@"项目" iconName:@"pop_Project" index:0],
                           [MenuItem itemWithTitle:@"任务" iconName:@"pop_Task" index:1],
                           [MenuItem itemWithTitle:@"冒泡" iconName:@"pop_Tweet" index:2],
                           [MenuItem itemWithTitle:@"添加好友" iconName:@"pop_User" index:3],
                           [MenuItem itemWithTitle:@"私信" iconName:@"pop_Message" index:4],
                           [MenuItem itemWithTitle:@"两步验证" iconName:@"pop_2FA" index:5],
                           ];
    if (!_myPopMenu) {
        _myPopMenu = [[PopMenu alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREENH_HEIGHT - 64) items:menuItems];
        _myPopMenu.perRowItemCount = 3;
        _myPopMenu.menuAnimationType = kPopMenuAnimationTypeSina;
    }
    
    @weakify(self);
    _myPopMenu.didSelectedItemCompletion = ^(MenuItem *selectedItem){
        @strongify(self);
        //改下显示style
        if (self.rightNavBtn.buttonStyle != kFRDLivelyButtonStylePlus) {
            [self.rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:YES];
        }
        if (!selectedItem) return;
        //        [MobClick event:kUmeng_Event_Request_ActionOfLocal label:[NSString stringWithFormat:@"首页_添加_%@", selectedItem.title]];
        switch (selectedItem.index) {
            case 0:
                [self goToNewProjectVC];
                break;
            case 1:
                [self goToNewTaskVC];
                break;
            case 2:
                [self goToNewTweetVC];
                break;
            case 3:
                [self goToAddUserVC];
                break;
            case 4:
                [self goToMessageVC];
                break;
            case 5:
                [self goTo2FA];
                break;
            default:
                NSLog(@"%@",selectedItem.title);
                break;
        }
    };
    
    [self setupNavBtn];
    self.icarouselScrollEnabled = NO;
    
    //    [[StartImagesManager sharedManager] handleStartLink];//如果 start_image 有对应的 link 的话，需要进入到相应的 web 页面
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_mySearchBar];
    if (_myCarousel) {
        ProjectListView *listView = (ProjectListView *)_myCarousel.currentItemView;
        if (listView) {
            [listView refreshToQueryData];
        }
    }
    [_myFliterMenu refreshMenuDate];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UnReadManager shareManager] updateUnRead];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mySearchBar removeFromSuperview];
    
    [self closeMenu];
    if (_myFliterMenu.showStatus) {
        [self fliterBtnClose:TRUE];
        [_myFliterMenu dismissMenu];
    }
}


- (void)initConstantData
{
    _segmentItems = @[@"全部项目",@"我创建的", @"我参与的",@"我关注的",@"我收藏的"];
    _myProjectsDict = [[NSMutableDictionary alloc] initWithCapacity:_segmentItems.count];

}



- (void)setIcarouselScrollEnabled:(BOOL)icarouselScrollEnabled
{
    _myCarousel.scrollEnabled = icarouselScrollEnabled;

}



#pragma mark - NavigationItem
- (void)setupNavBtn{
    
    _leftNavBtn = [UIButton new];
    [self addImageBarButtonWithImageName:@"filtertBtn_normal_Nav" button:_leftNavBtn action:@selector(fliterClicked:) isRight:NO];
    //变化按钮
    _rightNavBtn = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(0,0,18.5,18.5)];
    [_rightNavBtn setOptions:@{ kFRDLivelyButtonLineWidth: @(1.0f),
                                kFRDLivelyButtonColor: [UIColor whiteColor]
                                }];
    [_rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:NO];
    [_rightNavBtn addTarget:self action:@selector(addItemClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavBtn];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

-(void)addItemClicked:(id)sender{
    if (_rightNavBtn.buttonStyle == kFRDLivelyButtonStylePlus) {
        if (_myFliterMenu.showStatus) {
            [self fliterBtnClose:TRUE];
            [_myFliterMenu dismissMenu];
        }
        [_rightNavBtn setStyle:kFRDLivelyButtonStyleClose animated:YES];
        [_myPopMenu showMenuAtView:kKeyWindow startPoint:CGPointMake(0, -100) endPoint:CGPointMake(0, -100)];
    } else{
        [self closeMenu];
    }
}

-(void)fliterClicked:(id)sender{
    [self closeMenu];
    if (_myFliterMenu.showStatus) {
        [self fliterBtnClose:TRUE];
        [_myFliterMenu dismissMenu];
    }else
    {
        [self fliterBtnClose:FALSE];
        _myFliterMenu.selectNum = _selectNum >= 3?_selectNum+1 : _selectNum;
        UIView *presentView = [[[UIApplication sharedApplication].keyWindow rootViewController] view];
        [_myFliterMenu showMenuAtView:presentView];
    }
}

-(void)closeMenu{
    [_rightNavBtn setStyle:kFRDLivelyButtonStylePlus animated:YES];
    if ([_myPopMenu isShowed]) {
        [_myPopMenu dismissMenu];
    }
}

-(void)addImageBarButtonWithImageName:(NSString*)imageName button:(UIButton*)aBtn action:(SEL)action isRight:(BOOL)isR
{
    UIImage *image = [UIImage imageNamed:imageName];
    CGRect frame = CGRectMake(0,0, image.size.width, image.size.height);
    
    aBtn.frame=frame;
    [aBtn setImage:image forState:UIControlStateNormal];
    [aBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aBtn];
    
    if (isR)
    {
        [self.navigationItem setRightBarButtonItem:barButtonItem];
    }else
    {
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
    }
}

- (void)mobClickFliterMenuIndex:(NSInteger)index{
    static NSArray *menuList;
    if (!menuList) {
        menuList = @[@"全部项目",
                     @"我创建的",
                     @"我参与的",
                     @"我关注的",
                     @"我收藏的",
                     @"项目广场"];
    }
//    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:[NSString stringWithFormat:@"首页_筛选_%@", menuList.count > index? menuList[index]: menuList.lastObject]];
}


#pragma mark - gotoVC
- (void)goToNewProjectVC{
//    UIStoryboard *newProjectStoryboard = [UIStoryboard storyboardWithName:@"NewProject" bundle:nil];
//    UIViewController *newProjectVC = [newProjectStoryboard instantiateViewControllerWithIdentifier:@"NewProjectVC"];
//    [self.navigationController pushViewController:newProjectVC animated:YES];
}
- (void)goToNewTaskVC{
    __weak typeof(self) weakSelf = self;
//    ProjectToChooseListViewController *chooseVC = [[ProjectToChooseListViewController alloc] init];
//    chooseVC.projectChoosedBlock = ^(ProjectToChooseListViewController *blockChooseVC, Project *project){
//        [weakSelf goToNewTaskFromVC:blockChooseVC withPro:project];
//    };
//    [self.navigationController pushViewController:chooseVC animated:YES];
}

//- (void)goToNewTaskFromVC:(ProjectToChooseListViewController *)proListVC withPro:(Project *)project{
//    EditTaskViewController *taskVC = [EditTaskViewController new];
//    taskVC.myTask = [Task taskWithProject:project andUser:[Login curLoginUser]];
//    taskVC.myTask.handleType = TaskHandleTypeAddWithoutProject;
//    __weak typeof(self) weakSelf = self;
//    taskVC.doneBlock = ^(EditTaskViewController *vc){
//        [vc.navigationController popToViewController:weakSelf animated:YES];
//    };
//    [proListVC.navigationController pushViewController:taskVC animated:YES];
//}

- (void)goToNewTweetVC{
//    TweetSendViewController *vc = [[TweetSendViewController alloc] init];
//    vc.sendNextTweet = ^(Tweet *nextTweet){
//        [nextTweet saveSendData];//发送前保存草稿
//        [[Coding_NetAPIManager sharedManager] request_Tweet_DoTweet_WithObj:nextTweet andBlock:^(id data, NSError *error) {
//            if (data) {
//                [Tweet deleteSendData];//发送成功后删除草稿
//            }
//        }];
//    };
//    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
//    [self.parentViewController presentViewController:nav animated:YES completion:nil];
}

- (void)goTo2FA{
//    OTPListViewController *vc = [OTPListViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToProject:(Project *)project{
//    NProjectViewController *vc = [[NProjectViewController alloc] init];
//    vc.myProject = project;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToAddUserVC{
//    AddUserViewController *vc = [[AddUserViewController alloc] init];
//    vc.type = AddUserTypeFollow;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToMessageVC{
//    UsersViewController *vc = [[UsersViewController alloc] init];
//    vc.curUsers = [Users usersWithOwner:[Login curLoginUser] Type:UsersTypeFriends_Message];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goToProjectSquareVC{
//    ProjectSquareViewController *vc=[ProjectSquareViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
}

-(void)closeFliter{
    if ([_myFliterMenu showStatus]) {
        [_myFliterMenu dismissMenu];
        [self fliterBtnClose:TRUE];
    }
}

-(void)fliterBtnClose:(BOOL)status{
    [_leftNavBtn setImage:status?[UIImage imageNamed:@"filtertBtn_normal_Nav"]:[UIImage imageNamed:@"filterBtn_selected_Nav"] forState:UIControlStateNormal];
}


#pragma mark - iCarousel M
- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    return _segmentItems.count;
}
- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    Projects *curPros = [_myProjectsDict objectForKey:[NSNumber numberWithUnsignedInteger:index]];
    if (!curPros) {
        curPros = [self projectsWithIndex:index];
        [_myProjectsDict setObject:curPros forKey:[NSNumber numberWithUnsignedInteger:index]];
    }
    ProjectListView *listView = (ProjectListView *)view;
    if (listView) {
        [listView setProjects:curPros];
    }else{
        kWeakSelf(self);
        listView = [[ProjectListView alloc] initWithFrame:carousel.bounds projects:curPros block:^(Project *project) {
            [weakself goToProject:project];
            kLog(@"\n=====%@", project.name);
        } tabBarHeight:CGRectGetHeight(self.rdv_tabBarController.tabBar.frame)];
        
        listView.clickButtonBlock=^(EaseBlankPageType curType) {
            switch (curType) {
                case EaseBlankPageTypeProject_ALL:
                case EaseBlankPageTypeProject_CREATE:
                case EaseBlankPageTypeProject_JOIN:
                    [weakself goToNewProjectVC];
                    break;
                case EaseBlankPageTypeProject_WATCHED:
                case EaseBlankPageTypeProject_STARED:
                    [weakself goToProjectSquareVC];
                    break;
                default:
                    break;
            }
        };
        //使用新系列Cell样式
        listView.useNewStyle=_useNewStyle;
    }
    [listView setSubScrollsToTop:(index == carousel.currentItemIndex)];
    return listView;
}
- (Projects *)projectsWithIndex:(NSUInteger)index{
    return [Projects projectsWithType:index andUser:nil];
}
- (void)carouselDidScroll:(iCarousel *)carousel{
    [self.view endEditing:YES];
    if (_mySegmentControl) {
        float offset = carousel.scrollOffset;
        if (offset > 0) {
            [_mySegmentControl moveIndexWithProgress:offset];
        }
    }
}
- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    if (_mySegmentControl) {
        _mySegmentControl.currentIndex = carousel.currentItemIndex;
    }
    if (_oldSelectedIndex != carousel.currentItemIndex) {
        _oldSelectedIndex = carousel.currentItemIndex;
        ProjectListView *curView = (ProjectListView *)carousel.currentItemView;
        [curView refreshToQueryData];
    }
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj setSubScrollsToTop:(obj == carousel.currentItemView)];
    }];
}

#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchResults) {
        return [self.searchResults count];
    }else{
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectList forIndexPath:indexPath];
    [cell setProject:[self.searchResults objectAtIndex:indexPath.row] hasSWButtons:NO hasBadgeTip:YES hasIndicator:YES];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectListCell cellHeight];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.mySearchBar resignFirstResponder];
    [self goToProject:[self.searchResults objectAtIndex:indexPath.row]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self goToSearchVC];
    return NO;
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchProjectWithStr:searchText];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchProjectWithStr:searchBar.text];
}
- (void)searchProjectWithStr:(NSString *)string{
    self.searchString = string;
    [self updateFilteredContentForSearchString:string];
    [self.mySearchDisplayController.searchResultsTableView reloadData];
}
- (void)updateFilteredContentForSearchString:(NSString *)searchString{
    // start out with the entire list
    Projects *curPros = [_myProjectsDict objectForKey:@0];
    if (curPros) {
        self.searchResults = [curPros.list mutableCopy];
    }else{
        self.searchResults = nil;
    }
    
    // strip out all the leading and trailing spaces
    NSString *strippedStr = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedStr.length > 0)
    {
        searchItems = [strippedStr componentsSeparatedByString:@" "];
    }
    
    // build all the "AND" expressions for each value in the searchString
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems)
    {
        // each searchString creates an OR predicate for: name, global_key
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        // name field matching
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        //        owner_user_name field matching
        lhs = [NSExpression expressionForKeyPath:@"owner_user_name"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        // at this OR predicate to ourr master AND predicate
        NSCompoundPredicate *orMatchPredicates = (NSCompoundPredicate *)[NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    NSCompoundPredicate *finalCompoundPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    
    self.searchResults = [[self.searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
}
#pragma mark - Search
- (void)searchItemClicked:(id)sender{
    [_mySearchBar setX:20];
    if (!_mySearchDisplayController) {
        _mySearchDisplayController = ({
            UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
            searchVC.searchResultsTableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.mySearchBar.frame), 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
            searchVC.searchResultsTableView.tableFooterView = [[UIView alloc] init];
            [searchVC.searchResultsTableView registerClass:[ProjectListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectList];
            searchVC.searchResultsDataSource = self;
            searchVC.searchResultsDelegate = self;
//            if (kHigher_iOS_6_1) {
                searchVC.displaysSearchBarInNavigationBar = NO;
//            }
            searchVC;
        });
    }
    
    [_mySearchBar becomeFirstResponder];
}
-(void)searchAction{
    if (!_mySearchDisplayController) {
        _mySearchDisplayController = ({
            UISearchDisplayController *searchVC = [[UISearchDisplayController alloc] initWithSearchBar:_mySearchBar contentsController:self];
            searchVC.searchResultsTableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.mySearchBar.frame), 0, CGRectGetHeight(self.rdv_tabBarController.tabBar.frame), 0);
            searchVC.searchResultsTableView.tableFooterView = [[UIView alloc] init];
            [searchVC.searchResultsTableView registerClass:[ProjectListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectList];
            searchVC.searchResultsDataSource = self;
            searchVC.searchResultsDelegate = self;
//            if (kHigher_iOS_6_1) {
                searchVC.displaysSearchBarInNavigationBar = NO;
//            }
            searchVC;
        });
    }
}
-(void)goToSearchVC{
    [self closeFliter];
    [self closeMenu];
    SearchViewController *vc = [SearchViewController new];
    BaseNavigationController *searchNav = [[BaseNavigationController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:searchNav animated:NO completion:nil];
}

#pragma mark scan QR-Code
- (void)scanBtnClicked{
//    [MobClick event:kUmeng_Event_Request_ActionOfLocal label:@"首页_扫描二维码"];
    ZXScanCodeViewController *vc = [ZXScanCodeViewController new];
    __weak typeof(self) weakSelf = self;
    vc.scanResultBlock = ^(ZXScanCodeViewController *vc, NSString *resultStr){
        [weakSelf dealWithScanResult:resultStr ofVC:vc];
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)dealWithScanResult:(NSString *)resultStr ofVC:(ZXScanCodeViewController *)vc{
    if ([OTPListViewController handleScanResult:resultStr ofVC:vc]) {
        return;
    }
    UIViewController *nextVC  = [BaseViewController analyseVCFromLinkStr:resultStr];
    NSURL *URL = [NSURL URLWithString:resultStr];
    if (nextVC) {
        [self.navigationController pushViewController:nextVC animated:YES];
    }else if ([[URL host] hasSuffix:@"coding.net"]){
        //网页
        WebViewController *webVc = [WebViewController webVCWithUrlStr:resultStr];
        [self.navigationController pushViewController:webVc animated:YES];
    }else if ([[UIApplication sharedApplication] canOpenURL:URL]){
        UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"可能存在风险，是否打开此链接？\n「%@」", resultStr]];
        [alertV bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertV bk_addButtonWithTitle:@"打开链接" handler:nil];
        [alertV bk_setWillDismissBlock:^(UIAlertView *al, NSInteger index) {
            if (index == 1) {
                [[UIApplication sharedApplication] openURL:URL];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
        [alertV show];
    }else if (resultStr.length > 0){
        UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"已识别此二维码内容为：\n「%@」", resultStr]];
        [alertV bk_setCancelButtonWithTitle:@"取消" handler:nil];
        [alertV bk_addButtonWithTitle:@"复制链接" handler:nil];
        [alertV bk_setWillDismissBlock:^(UIAlertView *al, NSInteger index) {
            if (index == 1) {
                [[UIPasteboard generalPasteboard] setString:resultStr];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertV show];
    }else{
        UIAlertView *alertV = [UIAlertView bk_alertViewWithTitle:@"无效条码" message:@"未检测到条码信息"];
        [alertV bk_addButtonWithTitle:@"重试" handler:^{
            if (![vc isScaning]) {
                [vc startScan];
            }
        }];
        [alertV show];
    }
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
