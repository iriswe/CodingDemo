//
//  ProjectListView.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/20.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodingModel.h"

typedef void(^ProjectListViewBlock)(Project *project);
@interface ProjectListView : UIView <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic,assign)BOOL useNewStyle;
@property(copy, nonatomic) void(^clickButtonBlock)(EaseBlankPageType curType);

- (id)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(ProjectListViewBlock)block tabBarHeight:(CGFloat)tabBarHeight;
- (void)setProjects:(Projects *)projects;
- (void)refreshUI;
- (void)refreshToQueryData;
- (void)tabBarItemClicked;

@end
