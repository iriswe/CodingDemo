//
//  ProjectTaskListView.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/23.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodingModel.h"
@class ProjectTaskListView;

typedef void(^ProjectTaskBlock)(ProjectTaskListView *taskListView, Task *task);

@interface ProjectTaskListView : UIView <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) Tasks *myTasks;
@property (copy, nonatomic) ProjectTaskBlock block;
@property (strong, nonatomic) UITableView *myTableView;
@property (strong, nonatomic) ODRefreshControl *myRefreshControl;

- (id)initWithFrame:(CGRect)frame tasks:(Tasks *)tasks block:(ProjectTaskBlock)block tabBarHeight:(CGFloat)tabBarHeight;

- (void)setTasks:(Tasks *)tasks;
- (void)refreshToQueryData;
- (void)tabBarItemClicked;
- (void)reloadData;

@end
