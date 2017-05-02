//
//  EditTaskViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/22.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "EditTaskViewController.h"
#import "UITTTAttributedLabel.h"
#import "CodingModel.h"
#import "Coding_NetAPIManager.h"
#import "UIMessageInputView.h"

@interface EditTaskViewController ()<TTTAttributedLabelDelegate>
@property (strong, nonatomic) UITableView *myTableView;

//评论
@property (nonatomic, strong) UIMessageInputView *myMsgInputView;
@property (nonatomic, strong) TaskComment *toComment;
@property (nonatomic, strong) UIView *commentSender;
@end

@implementation EditTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _myCopyTask = [Task taskWithTask:_myTask];
    if (_myCopyTask.handleType == TaskHandleTypeEdit) {
        //评论
        _myMsgInputView = [UIMessageInputView messageInputViewWithType:UIMessageInputViewContentTypeTask];
        _myMsgInputView.isAlwaysShow = YES;
        _myMsgInputView.delegate = self;
        
        [self queryToRefreshTaskDetail];
    }
    [self configTitle];
}

- (void)configTitle{
    if (_myCopyTask.handleType > TaskHandleTypeEdit) {
        self.title = @"创建任务";
    }else{
        self.title = _myTask.project.name;
    }
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
