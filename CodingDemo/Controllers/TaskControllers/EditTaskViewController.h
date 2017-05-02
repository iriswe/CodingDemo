//
//  EditTaskViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/22.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"

@interface EditTaskViewController : BaseViewController
@property (strong, nonatomic) Task *myTask, *myCopyTask;
@property (copy, nonatomic) void(^taskChangedBlock)();
@property (copy, nonatomic) void(^doneBlock)(EditTaskViewController *vc);
- (void)queryToRefreshTaskDetail;
@end
