//
//  CountryViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/6.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "CountryViewController.h"
#import "CountryCodeCell.h"

@interface CountryViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (strong, nonatomic) UISearchBar *mySearchBar;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) NSDictionary *countryCodeListDict, *searchResults;
@property (strong, nonatomic) NSMutableArray *keyList;
@end

@implementation CountryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.title = @"选择国家或地区";
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor colorWithHexString:@"0xeeeeee"];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[CountryCodeCell class] forCellReuseIdentifier:kCellIdentifier_CountryCodeCell];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexColor = [UIColor colorWithHexString:@"0x666666"];
        [self.view addSubview:tableView];
        [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        tableView;
    });
    _mySearchBar = ({
        UISearchBar *searchBar = [UISearchBar new];
        searchBar.delegate = self;
        [searchBar sizeToFit];
        [searchBar setPlaceholder:@"国家/地区名称"];
        searchBar;
    });
    [self setupData];
    
    _myTableView.tableHeaderView = _mySearchBar;
    _myTableView.tableFooterView = [UIView new];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.myTableView) {
        [_mySearchBar resignFirstResponder];
    }
}

#pragma mark SetData

- (void)setupData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"country" ofType:@"plist"];
    _countryCodeListDict = _searchResults = [NSDictionary dictionaryWithContentsOfFile:path];
    [self p_updateKeyList];
}

- (void)p_updateKeyList
{
    _keyList = [[_searchResults allKeys] mutableCopy];
    [_keyList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 isEqualToString:@"#"]) {
            return NSOrderedAscending;
        } else if([obj2 isEqualToString:@"#"]) {
            return NSOrderedDescending;
        } else {
            return [obj1 compare:obj2];
        }
    }];
}

#pragma mark TableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _keyList.count - 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(NSDictionary *)_searchResults[_keyList[section+ 1]] count];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index > 0? index - 1: index;

}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _keyList;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = self.myTableView.backgroundColor;
    UILabel *titleL = [UILabel new];
    titleL.font = [UIFont systemFontOfSize:12];
    titleL.textColor = [UIColor colorWithHexString:@"0x999999"];
    titleL.text = [_keyList[section+ 1] isEqualToString:@"#"]? @"常用": _keyList[section+ 1];
    [view addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view).insets(UIEdgeInsetsMake(4, 15, 4, 15));
    }];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CountryCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_CountryCodeCell];
    if (cell == nil) {
        cell = [[CountryCodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier_CountryCodeCell];
    }
    cell.countryCodeDict = _searchResults[_keyList[indexPath.section+ 1]][indexPath.row];
    return cell;
}

#pragma mark TableViewDelete

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, (SCREEN_WIDTH - cell.contentView.frame.size.width) + 15);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_selectedBlock) {
        _selectedBlock(_searchResults[_keyList[indexPath.section+ 1]][indexPath.row]);
    }
    [self.navigationController popViewControllerAnimated:YES];
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
