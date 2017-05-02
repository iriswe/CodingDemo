//
//  ProjectTaskListView.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/23.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//



#import "ProjectTaskListView.h"
#import "ProjectTaskListViewCell.h"
#import "Coding_NetAPIManager.h"

@implementation ProjectTaskListView
- (void)tabBarItemClicked{
    if (_myTableView.contentOffset.y > 0) {
        [_myTableView setContentOffset:CGPointZero animated:YES];
    }else if (!self.myRefreshControl.isAnimating){
        [self.myRefreshControl beginRefreshing];
        [self.myTableView setContentOffset:CGPointMake(0, -44)];
        [self refresh];
    }
}
- (void)reloadData{
    if (self.myTableView) {
        [self.myTableView reloadData];
    }
}
- (id)initWithFrame:(CGRect)frame tasks:(Tasks *)tasks block:(ProjectTaskBlock)block tabBarHeight:(CGFloat)tabBarHeight
{
    self = [super initWithFrame:frame];
    if (self) {
        _myTasks = tasks;
        _block = block;
        _myTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.delegate = self;
            tableView.dataSource = self;
            [tableView registerClass:[ProjectTaskListViewCell class] forCellReuseIdentifier:kCellIdentifier_ProjectTaskList];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [self addSubview:tableView];
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            if (tabBarHeight != 0) {
                UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, tabBarHeight, 0);
                tableView.contentInset = insets;
                tableView.scrollIndicatorInsets = insets;
            }
            tableView;
        });
        
        _myRefreshControl = [[ODRefreshControl alloc] initInScrollView:self.myTableView];
        [_myRefreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        kWeakSelf(self);
        [_myTableView addInfiniteScrollingWithActionHandler:^{
            [weakself refreshMore];
        }];
        if (_myTasks.list.count > 0) {
            [_myTableView reloadData];
        }else{
            [self sendRequest];
        }

    }
    return self;
}

- (void)setTasks:(Tasks *)tasks{
    if (_myTasks != tasks) {
        self.myTasks = tasks;
        [_myTableView reloadData];
        [_myTableView.infiniteScrollingView stopAnimating];
        _myTableView.showsInfiniteScrolling = self.myTasks.canLoadMore;
        if (self.myTasks.list.count > 0) {
            [self configBlankPage:EaseBlankPageTypeTask hasData:YES hasError:NO reloadButtonBlock:nil];
        }
        [self refreshFirst];
    }
}

- (void)refreshToQueryData{
    [self refresh];
}

- (void)refreshFirst{
    if (_myTasks && !_myTasks.list) {
        [self refresh];
    }
}

- (void)refresh{
    if (_myTasks.isLoading) {
        return;
    }
    _myTasks.willLoadMore = NO;
    [self sendRequest];
}

- (void)refreshMore{
    if (_myTasks.isLoading || !_myTasks.canLoadMore) {
        [_myTableView.infiniteScrollingView stopAnimating];
        return;
    }
    _myTasks.willLoadMore = YES;
    [self sendRequest];
}

- (void)sendRequest
{
    if (_myTasks.list.count <= 0) {
        [self beginLoading];
    }
    kWeakSelf(self);
    [[Coding_NetAPIManager sharedManager] request_ProjectTaskList_WithObj:_myTasks andBlock:^(Tasks *data, NSError *error) {
        [weakself endLoading];
        [weakself.myRefreshControl endRefreshing];
        [weakself.myTableView.infiniteScrollingView stopAnimating];
        if (data) {
            [weakself.myTasks configWithTasks:data];
            [weakself.myTableView reloadData];
            weakself.myTableView.showsInfiniteScrolling = weakself.myTasks.canLoadMore;
        }
        [weakself configBlankPage:EaseBlankPageTypeTask hasData:(weakself.myTasks.list.count > 0) hasError:(error != nil) reloadButtonBlock:^(id sender) {
            [weakself refresh];
        }];
        
    }];
  
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSections];
}

- (NSInteger)numberOfSections
{
    NSInteger num = 0;
    if (_myTasks.processingList.count > 0) {
        num++;
    }
    if (_myTasks.doneList.count > 0) {
        num++;
    }
    return num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = 0;
    if (section == 0) {
        if (_myTasks.processingList.count > 0) {
            num = _myTasks.processingList.count;
        }else{
            num = _myTasks.doneList.count;
        }
    }else{
        num = _myTasks.doneList.count;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectTaskListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectTaskList forIndexPath:indexPath];
    
    NSArray *dataList = [self tableDataListInSection:indexPath.section];
    kWeakSelf(self);
    cell.task = [dataList objectAtIndex:indexPath.row];
    cell.checkViewClickedBlock = ^(Task *task){
        if (task.isRequesting) {
            return ;
        } else {
            task.isRequesting = YES;
        }
        //ChangeTaskStatus后，task对象的status属性会直接在请求结束后被修改
        [[Coding_NetAPIManager sharedManager] request_ChangeTaskStatus:task andBlock:^(id data, NSError *error) {
            [weakself.myTableView reloadData];
            task.isRequesting = NO;
        }];
    };
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:48];
    return cell;
}

- (NSArray *)tableDataListInSection:(NSInteger)section{
    NSArray *dataList;
    if (section == 0) {
        if (_myTasks.processingList.count > 0) {
            dataList = _myTasks.processingList;
        }else{
            dataList = _myTasks.doneList;
        }
    }else{
        dataList = _myTasks.doneList;
    }
    return dataList;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dataList = [self tableDataListInSection:indexPath.section];
    return [ProjectTaskListViewCell cellHeightWithObj:[dataList objectAtIndex:indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dataList = [self tableDataListInSection:indexPath.section];
    if (_block) {
        Task *curTask = [dataList objectAtIndex:indexPath.row];
        _block(self, curTask);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kScaleFrom_iPhone5_Desgin(24);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *headerStr;
    if (section == 0) {
        if (_myTasks.processingList.count > 0) {
            headerStr = @"进行中的任务";
        }else{
            headerStr = @"已完成的任务";
        }
    }else{
        headerStr = @"已完成的任务";
    }
    return [tableView getHeaderViewWithStr:headerStr andBlock:^(id obj) {
    }];
}






@end
