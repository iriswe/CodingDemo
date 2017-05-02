//
//  MyTask_RootViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/14.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "MyTask_RootViewController.h"
#import "XTSegmentControl.h"
#import "iCarousel.h"
#import "FRDLivelyButton.h"
#import "EditTaskViewController.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTaskListView.h"
#import "RDVTabBarController.h"

@interface MyTask_RootViewController () <iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) Projects *myProjects;
@property (strong, nonatomic) NSMutableDictionary *myProTksDict;
@property (strong, nonatomic) NSMutableArray *myProjectList;

@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (strong, nonatomic) iCarousel *myCarousel;
@end

@implementation MyTask_RootViewController

- (void)tabBarItemClicked{
    [super tabBarItemClicked];
    if (_myCarousel.currentItemView && [_myCarousel.currentItemView isKindOfClass:[ProjectTaskListView class]]) {
        ProjectTaskListView *listView = (ProjectTaskListView *)_myCarousel.currentItemView;
        [listView tabBarItemClicked];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的任务";
    _myProjects = [Projects projectsWithType:ProjectsTypeAll andUser:nil];
    _myProTksDict = [NSMutableDictionary dictionaryWithCapacity:1];
    _myProjectList = [NSMutableArray arrayWithObjects:[Project project_All], nil];
    
    _myCarousel = ({
        iCarousel *carousel = [[iCarousel alloc] init];
        carousel.dataSource = self;
        carousel.delegate = self;
        carousel.decelerationRate = 1.0;
        carousel.scrollSpeed = 1.0;
        carousel.type = iCarouselTypeLinear;
        carousel.pagingEnabled = YES;
        carousel.clipsToBounds = YES;
        carousel.bounceDistance = 0.2;
        [self.view addSubview:carousel];
        [carousel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(70, 0, 0, 0));
        }];
        carousel;
    });
    
    FRDLivelyButton *rightButton = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(0,0,18.5,18.5)];
    [rightButton setOptions:@{kFRDLivelyButtonLineWidth: @(1.0f), kFRDLivelyButtonColor: [UIColor whiteColor]}];
    [rightButton setStyle:kFRDLivelyButtonStylePlus animated:NO];
    [rightButton addTarget:self action:@selector(addItemClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)addItemClicked
{
    EditTaskViewController *vc = [EditTaskViewController new];
    
    NSInteger curIndex = _myCarousel.currentItemIndex;
    Project *defaultPro = curIndex > 0? _myProjectList[curIndex]: nil;
    vc.myTask = [Task taskWithProject:defaultPro andUser:defaultPro? [Login curLoginUser]: nil];
    vc.myTask.handleType = TaskHandleTypeAddWithoutProject;
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self resetCurView];
}

- (void)resetCurView{
    if (!_myProjects.isLoading) {
        kWeakSelf(self);
        [[Coding_NetAPIManager sharedManager] request_ProjectsHaveTasks_WithObj:_myProjects andBlock:^(id data, NSError *error) {
            if (data) {
                [weakself configSegmentControlWithData:data];
            }
        }];
    }
}

- (void)configSegmentControlWithData:(Projects *)freshProjects
{
    BOOL dataHasChanged = NO;
    for (Project *freshPro in freshProjects.list) {
        BOOL hasFreshPro = NO;
        for (Project *oldPro in self.myProjectList) {
            if (freshPro.id.integerValue == oldPro.id.integerValue) {
                hasFreshPro = YES;
                break;
            }
        }
        if (!hasFreshPro) {
            dataHasChanged = YES;
            break;
        }
    }
    
    if (dataHasChanged) {
        self.myProjectList = [[NSMutableArray alloc] initWithObjects:[Project project_All], nil];
        [self.myProjectList addObjectsFromArray:freshProjects.list];
        
        //重置滑块
        if (_mySegmentControl) {
            [_mySegmentControl removeFromSuperview];
        }
        
        kWeakSelf(self);
        CGRect segmentFrame = CGRectMake(0, 0, SCREEN_WIDTH, 70.0);
        _mySegmentControl = [[XTSegmentControl alloc] initWithFrame:segmentFrame Items:_myProjectList selectedBlock:^(NSInteger index) {
            [weakself.myCarousel scrollToItemAtIndex:index animated:NO];
        }];
        [self.view addSubview:_mySegmentControl];
        
        if (_myCarousel.currentItemIndex != 0) {
            _myCarousel.currentItemIndex = 0;
        }
        [_myCarousel reloadData];
    }
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return _myProjectList.count;
}


- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    Project *curPro = [_myProjectList objectAtIndex:index];
    Tasks *curTasks = [_myProTksDict objectForKey:curPro.id];
    if (!curTasks) {
        curTasks = [Tasks tasksWithPro:curPro queryType:TaskQueryTypeAll];
        [_myProTksDict setObject:curTasks forKey:curPro.id];
    }
    ProjectTaskListView *taskView = (ProjectTaskListView *)view;
    if (taskView) {
        [taskView setTasks:curTasks];
    } else {
        kWeakSelf(self);
         taskView = [[ProjectTaskListView alloc] initWithFrame:carousel.bounds tasks:curTasks block:^(ProjectTaskListView *taskListView, Task *task) {
            EditTaskViewController *vc = [[EditTaskViewController alloc] init];
            vc.myTask = task;
            vc.taskChangedBlock = ^(){
                [taskListView refreshToQueryData];
            };
            [weakself.navigationController pushViewController:vc animated:YES];
        } tabBarHeight:CGRectGetHeight(self.rdv_tabBarController.tabBar.frame)];
    }
    return taskView;
}

- (void)carouselDidScroll:(iCarousel *)carousel
{
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
    ProjectTaskListView *curView = (ProjectTaskListView *)carousel.currentItemView;
    [curView refreshToQueryData];
    [carousel.visibleItemViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        [view setSubScrollsToTop:(view == carousel.currentItemView)];
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
