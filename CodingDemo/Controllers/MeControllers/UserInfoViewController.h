//
//  UserInfoViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/10/10.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"

@interface UserInfoViewController : BaseViewController
@property (nonatomic, assign) BOOL isRoot;
@property (nonatomic, strong) User *curUser;
@property (nonatomic, copy) void(^followChanged)(User *user);
@end
