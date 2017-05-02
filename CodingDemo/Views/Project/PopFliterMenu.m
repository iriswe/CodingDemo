//
//  PopFliterMenu.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/19.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "PopFliterMenu.h"
#import "CodingModel.h"
#import "Coding_NetAPIManager.h"

@interface PopFliterMenu () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) ProjectCount *pCount;
@property (nonatomic, strong) XHRealTimeBlur *realTimeBlur;

@end

@implementation PopFliterMenu

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items
{
    self = [super initWithFrame:frame];
    if (self) {
    self.items = @[@{@"all":@""},@{@"created":@""},@{@"joined":@""},@{@"watched":@""},@{@"stared":@""}].mutableCopy;
        self.pCount = [ProjectCount new];
        self.showStatus = FALSE;
        [self config];
    }
    return self;
}

- (void)config
{
    self.backgroundColor = [UIColor clearColor];
    
    _realTimeBlur = [[XHRealTimeBlur alloc] initWithFrame:self.bounds];
    _realTimeBlur.blurStyle = XHBlurStyleTranslucentWhite;
    _realTimeBlur.showDuration = 0.1;
    _realTimeBlur.disMissDuration = 0.2;
    kWeakSelf(self);
    _realTimeBlur.willShowBlurViewcomplted = ^{
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        alphaAnimation.fromValue = @0.0;
        alphaAnimation.toValue = @1.0;
        alphaAnimation.duration = 0.3;
        [weakself.tableview.layer addAnimation:alphaAnimation forKey:@"alphaAnimationS"];
    };
    
    _realTimeBlur.willDismissBlurViewCompleted = ^{
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        alphaAnimation.fromValue = @1.0;
        alphaAnimation.toValue = @0.0;
        alphaAnimation.duration = 0.2f;
        [weakself.tableview.layer addAnimation:alphaAnimation forKey:@"alphaAnimationE"];
    };
    _realTimeBlur.didDismissBlurViewCompleted = ^(BOOL finished){
        [weakself removeFromSuperview];
    };
    
    _realTimeBlur.hasTapGestureEnable = YES;
    
    _tableview = ({
        UITableView *tableview=[[UITableView alloc] initWithFrame:self.bounds];
        tableview.backgroundColor=[UIColor clearColor];
        tableview.delegate=self;
        tableview.dataSource=self;
        [tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        tableview.tableFooterView=[UIView new];
        tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
        tableview;
    });
    [self addSubview:_tableview];
    
    _tableview.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    int contentHeight = 320;
    if ((SCREENH_HEIGHT - 64) > contentHeight) {
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,64 + contentHeight , SCREEN_WIDTH, SCREENH_HEIGHT - 64 - contentHeight)];
        contentView.backgroundColor=[UIColor clearColor];
        [self addSubview:contentView];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedContentView:)];
        [contentView addGestureRecognizer:tapGestureRecognizer];
    }

}

- (void)didClickedContentView:(id)sender
{
    _closeBlock();
}

#pragma mark -- TableViewDelegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *titleLab=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
    titleLab.font=[UIFont systemFontOfSize:15];
    [cell.contentView addSubview:titleLab];
    if (0 == indexPath.section) {
        titleLab.textColor = (indexPath.row == _selectNum)? [UIColor colorWithHexString: @"0x3BBD79"]: [UIColor colorWithHexString: @"0x222222"];
        titleLab.text = [self formatTitleStr: [_items objectAtIndex: indexPath.row]];
    }else if (indexPath.section == 1) {
        if(indexPath.row == 0){
            [titleLab removeFromSuperview];
            UIView *seperatorLine = [[UIView alloc] initWithFrame:CGRectMake(20, 15, self.bounds.size.width - 40, 0.5)];
            seperatorLine.backgroundColor = [UIColor colorWithHexString: @"0xcccccc"];
            [cell.contentView addSubview: seperatorLine];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            titleLab.textColor = (indexPath.row + 3 == _selectNum)? [UIColor colorWithHexString: @"0x3BBD79"]: [UIColor colorWithHexString: @"0x222222"];
            titleLab.text = [self formatTitleStr:[_items objectAtIndex: 3 + indexPath.row - 1]];
        }
    } else {
        if(indexPath.row == 0){
            [titleLab removeFromSuperview];
            UIView *seperatorLine = [[UIView alloc] initWithFrame: CGRectMake(20, 15, self.bounds.size.width - 40, 0.5)];
            seperatorLine.backgroundColor = [UIColor colorWithHexString: @"0xcccccc"];
            [cell.contentView addSubview:seperatorLine];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            [titleLab setX:45];
            titleLab.textColor = [UIColor colorWithHexString:@"0x727f8d"];
            titleLab.text = @"项目广场";
            UIImageView *projectSquareIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 25-8, 16, 16)];
            projectSquareIcon.image = [UIImage imageNamed:@"fliter_square"];
            [cell.contentView addSubview:projectSquareIcon];
        }
    }
    return cell;
}

- (NSString *)formatTitleStr:(NSDictionary *)aDic
{
    NSString *keyStr = [[aDic allKeys] firstObject];
    NSMutableString *convertStr = [NSMutableString new];
    if ([keyStr isEqualToString:@"all"]) {
        [convertStr appendString:@"全部项目"];
    } else if([keyStr isEqualToString:@"created"]) {
        [convertStr appendString:@"我创建的"];
    }else if ([keyStr isEqualToString:@"joined"]) {
        [convertStr appendString:@"我参与的"];
    }else if ([keyStr isEqualToString:@"watched"]) {
        [convertStr appendString:@"我关注的"];
    }else if ([keyStr isEqualToString:@"stared"]) {
        [convertStr appendString:@"我收藏的"];
    }else
    {
        NSLog(@"-------------error type:%@",keyStr);
    }
    if ([[aDic objectForKey:keyStr] length]>0) {
        [convertStr appendString:[NSString stringWithFormat:@" (%@)",[aDic objectForKey:keyStr]]];
    }
    return [convertStr copy];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ((indexPath.row == 0) && (indexPath.section == 1)) || ((indexPath.row == 0) && (indexPath.section == 2))? 30.5: 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        _selectNum = indexPath.row;
        [self dismissMenu];
        _clickBlock([self convertToProjectType]);
    }else if (indexPath.section == 1) {
        if(indexPath.row == 0){
            _closeBlock();
            return;
        }
        _selectNum=indexPath.row + 3 - 1;
        [self dismissMenu];
        _clickBlock([self convertToProjectType]);
    }else
    {
        if(indexPath.row == 0){
            _closeBlock();
            return;
        }
        _clickBlock(1000);
        _closeBlock();
    }
}


- (NSInteger)convertToProjectType
{
    switch (_selectNum) {
        case 0:
            return ProjectsTypeAll;
            break;
        case 1:
            return ProjectsTypeCreated;
            break;
        case 2:
            return ProjectsTypeJoined;
            break;
        case 3:
            return ProjectsTypeWatched;
            break;
        case 4:
            return ProjectsTypeStared;
            break;
        default:
            NSLog(@"type error");
            return ProjectsTypeAll;
            break;
    }

}

#pragma mark - method
- (void)showMenuAtView:(UIView *)containerView {
    _showStatus = YES;
    [containerView addSubview:self];
    [_realTimeBlur showBlurViewAtView:self];
    [_tableview reloadData];
}

- (void)dismissMenu
{
    UIView *presentView = [[[UIApplication sharedApplication].keyWindow rootViewController] view];
    if ([[[presentView subviews] firstObject] isMemberOfClass:NSClassFromString(@"RDVTabBar")]) {
        [presentView bringSubviewToFront:[presentView.subviews firstObject]];
    }
    _showStatus = NO;
    [_realTimeBlur disMiss];
}

- (void)refreshMenuDate
{
    __weak typeof(self) weakSelf = self;
    [[Coding_NetAPIManager sharedManager] request_ProjectsCatergoryAndCounts_WithObj:_pCount andBlock:^(ProjectCount *data, NSError *error) {
        if (data) {
            [weakSelf.pCount configWithProjects:data];
            [weakSelf updateDateSource:weakSelf.pCount];
            [weakSelf.tableview reloadData];
        }
        if(error)
        {
            NSLog(@"get count error");
        }
    }];
}

//更新数据源
-(void)updateDateSource:(ProjectCount*)pCount
{
    _items = @[@{@"all":[pCount.all stringValue]},@{@"created":[pCount.created stringValue]},@{@"joined":[pCount.joined  stringValue]},@{@"watched":[pCount.watched stringValue]},@{@"stared":[pCount.stared stringValue]}].mutableCopy;
}

@end
