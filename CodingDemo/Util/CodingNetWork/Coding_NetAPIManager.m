//
//  Coding_NetAPIManager.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/8.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "Coding_NetAPIManager.h"
#import "CodingNetAPIClient.h"
#import "UnReadManager.h"

@implementation Coding_NetAPIManager

static Coding_NetAPIManager *manager = nil;
static dispatch_once_t onceToken;

+(Coding_NetAPIManager *)sharedManager
{
    dispatch_once(&onceToken, ^{
        manager = [[Coding_NetAPIManager alloc] init];
        
    });
    return manager;
}
#pragma mark - Login
- (void)request_Register_V2_WithParams:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/v2/account/register";
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"注册_V2"];
            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_CaptchaNeededWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path  withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_Get label:@"是否需要验证码"];
            
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Login_With2FA:(NSString *)otpCode andBlock:(void (^)(id data, NSError *error))block{
    if (otpCode.length <= 0) {
        return;
    }
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/check_two_factor_auth_code" withParams:@{@"code" : otpCode} withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"登录_2FA码"];
            
            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Login_WithPath:(NSString *)path Params:(id)params andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/unread-count" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data_check, NSError *error_check) {//检查当前账号未设置邮箱和GK
                if (error_check.userInfo[@"msg"][@"user_need_activate"]) {
                    block(nil, error_check);
                }else{
//                    [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"登录_密码"];
                    
                    User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
                    if (curLoginUser) {
                        [Login doLogin:resultData];
                    }
                    block(curLoginUser, nil);
                }
            }];
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_ActivateBySetGlobal_key:(NSString *)global_key block:(void (^)(id data, NSError *error))block{
    NSString *path = @"api/account/global_key/acitvate";
    NSDictionary *params = @{@"global_key": global_key};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        id resultData = [data valueForKeyPath:@"data"];
        if (resultData) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"激活账号_设置GK"];
            
            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (curLoginUser) {
                [Login doLogin:resultData];
            }
            block(curLoginUser, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_SendActivateEmail:(NSString *)email block:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/account/register/email/send" withParams:@{@"email": email} withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            if ([(NSNumber *)data[@"data"] boolValue]) {
//                [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"激活账号_重发激活邮件"];
                
                block(data, nil);
            }else{
                [NSObject showHudTipStr:@"发送失败"];
                block(nil, nil);
            }
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark - 2FA
- (void)post_Close2FAWithPhone:(NSString *)phone code:(NSString *)code block:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/twofa/close" withParams:@{@"phone": phone, @"code": code} withMethodType:Post andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}

- (void)post_Close2FAGeneratePhoneCode:(NSString *)phone block:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/twofa/close/code" withParams:@{@"phone": phone, @"from": @"mart"} withMethodType:Post andBlock:^(id data, NSError *error) {
        block(data, error);
    }];
}


#pragma mark - UnRead
- (void)request_UnReadCountWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/user/unread-count" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_Notification label:@"Tab首页的红点通知"];
            
            id resultData = [data valueForKeyPath:@"data"];
            block(resultData, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_UnReadNotificationsWithBlock:(void (^)(id data, NSError *error))block{
    NSMutableDictionary *notificationDict = [[NSMutableDictionary alloc] init];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : @(0)} withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
            //            @我的
            [notificationDict setObject:[data valueForKeyPath:@"data"] forKey:kUnReadKey_notification_AT];
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : @[@(1), @(2)]} withMethodType:Get andBlock:^(id dataComment, NSError *errorComment) {
                if (dataComment) {
                    //                    评论
                    [notificationDict setObject:[dataComment valueForKeyPath:@"data"] forKey:kUnReadKey_notification_Comment];
                    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/unread-count" withParams:@{@"type" : @[@(4),@(6)]} withMethodType:Get andBlock:^(id dataSystem, NSError *errorSystem) {
                        if (dataSystem) {
                            //                            系统
//                            [MobClick event:kUmeng_Event_Request_Notification label:@"消息页面的红点通知"];
                            
                            [notificationDict setObject:[dataSystem valueForKeyPath:@"data"] forKey:kUnReadKey_notification_System];
                            block(notificationDict, nil);
                        }else{
                            block(nil, errorSystem);
                        }
                    }];
                }else{
                    block(nil, errorComment);
                }
            }];
        }else{
            block(nil, error);
        }
    }];
}


#pragma mark - Project
- (void)request_ProjectsCatergoryAndCounts_WithObj:(ProjectCount *)pCount andBlock:(void (^)(ProjectCount *data, NSError *error))block
{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/project_count" withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_RootList label:@"筛选列表"];
            
            id resultData = [data valueForKeyPath:@"data"];
            ProjectCount *prosC = [NSObject objectOfClass:@"ProjectCount" fromJSON:resultData];
            block(prosC, nil);
        }else{
            block(nil, error);
        }
    }];
    
}

- (void)request_Projects_WithObj:(Projects *)projects andBlock:(void (^)(Projects *data, NSError *error))block{
    projects.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[projects toPath] withParams:[projects toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        projects.isLoading = NO;
        if (data) {
//            [MobClick event:kUmeng_Event_Request_RootList label:@"项目列表"];
            
            id resultData = [data valueForKeyPath:@"data"];
            Projects *pros = [NSObject objectOfClass:@"Projects" fromJSON:resultData];
            block(pros, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Project_Pin:(Project *)project andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/user/projects/pin"];
    NSDictionary *params = @{@"ids": project.id.stringValue};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:project.pin.boolValue? Delete: Post andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"设置常用项目"];
            
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_ProjectsHaveTasks_WithObj:(Projects *)projects andBlock:(void (^)(id data, NSError *error))block
{
    projects.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/projects" withParams:[projects toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        
        if (data) {
            id resultData = [data valueForKeyPath:@"data"];
            Projects *pros = [NSObject objectOfClass:@"Projects" fromJSON:resultData];
            [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/tasks/projects/count" withParams:nil withMethodType:Get andBlock:^(id datatasks, NSError *errortasks) {
                projects.isLoading = NO;
                if (datatasks) {
//                    [MobClick event:kUmeng_Event_Request_RootList label:@"有任务的项目列表"];
                    
                    NSMutableArray *list = [[NSMutableArray alloc] init];
                    NSArray *taskProArray = [datatasks objectForKey:@"data"];
                    for (NSDictionary *dict in taskProArray) {
                        for (Project *curPro in pros.list) {
                            if (curPro.id.intValue == ((NSNumber *)[dict objectForKey:@"project"]).intValue) {
                                curPro.done = [dict objectForKey:@"done"];
                                curPro.processing = [dict objectForKey:@"processing"];
                                [list addObject:curPro];
                            }
                        }
                    }
                    pros.list = list;
                    block(pros, nil);
                }else{
                    block(nil, error);
                }
            }];
        }else{
            projects.isLoading = NO;
            block(nil, error);
        }
    }];
}

#pragma mark - Task

- (void)request_ProjectTaskList_WithObj:(Tasks *)tasks andBlock:(void (^)(Tasks *data, NSError *error))block{
    tasks.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tasks toRequestPath] withParams:[tasks toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tasks.isLoading = NO;
        if (data) {
//            [MobClick event:kUmeng_Event_Request_RootList label:@"任务_列表"];
            
            id resultData = [data valueForKeyPath:@"data"];
            Tasks *resultTasks = [NSObject objectOfClass:@"Tasks" fromJSON:resultData];
            block(resultTasks, nil);
        }else{
            block(nil, error);
        }
        
    }];
}

- (void)request_ChangeTaskStatus:(Task *)task andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[task toEditTaskStatusPath] withParams:[task toChangeStatusParams] withMethodType:Put andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"任务_完成or开启"];
            
            task.status = [NSNumber numberWithInteger:(task.status.integerValue != 1? 1 : 2)];
            block(task, nil);
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark Tweet
- (void)request_Tweets_WithObj:(Tweets *)tweets andBlock:(void (^)(id data, NSError *error))block{
    tweets.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweets toPath] withParams:[tweets toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        tweets.isLoading = NO;
        
        if (data) {
//            [MobClick event:kUmeng_Event_Request_RootList label:@"冒泡_列表"];
            id resultData = [data valueForKeyPath:@"data"];
            NSArray *resultA = [NSObject arrayFromJSON:resultData ofObjects:@"Tweet"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_Tweet_DoLike_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDoLikePath] withParams:nil withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_点赞"];
            
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Tweet_DoComment_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDoCommentPath] withParams:[tweet toDoCommentParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_评论_添加"];
            
            id resultData = [data valueForKeyPath:@"data"];
            Comment *comment = [NSObject objectOfClass:@"Comment" fromJSON:resultData];
            block(comment, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_Tweet_Delete_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[tweet toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_删除"];
            
            [NSObject showHudTipStr:@"删除成功"];
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_TweetComment_Delete_WithTweet:(Tweet *)tweet andComment:(Comment *)comment andBlock:(void (^)(id data, NSError *error))block{
    NSString *path = [NSString stringWithFormat:@"api/tweet/%d/comment/%d", tweet.id.intValue, comment.id.intValue];
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"冒泡_评论_删除"];
            
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}



#pragma mark - Topic
- (void)request_BannersWithBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/banner/type/app" withParams:nil withMethodType:Get autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_Get label:@"冒泡列表_Banner"];
            
            data = [data valueForKey:@"data"];
            NSArray *resultA = [NSArray arrayFromJSON:data ofObjects:@"CodingBanner"];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block{
    priMsgs.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[priMsgs toPath] withParams:[priMsgs toParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        priMsgs.isLoading = NO;
        if (data) {
//            if (priMsgs.curFriend) {
//                [MobClick event:kUmeng_Event_Request_Get label:@"私信_列表"];
//            }else{
//                [MobClick event:kUmeng_Event_Request_RootList label:@"会话列表"];
//            }
//            
            id resultA = [PrivateMessages analyzeResponseData:data];
            block(resultA, nil);
            
            if (priMsgs.curFriend && priMsgs.curFriend.global_key) {//标记为已读
                [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"api/message/conversations/%@/read", priMsgs.curFriend.global_key] withParams:nil withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
                    if (data) {
                        [[UnReadManager shareManager] updateUnRead];
                    }
                }];
            }
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark - Message
- (void)request_CodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block{
    curTips.isLoading = YES;
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curTips toTipsPath] withParams:[curTips toTipsParams] withMethodType:Get andBlock:^(id data, NSError *error) {
        curTips.isLoading = NO;
        if (data) {
//            [MobClick event:kUmeng_Event_Request_Get label:@"消息通知_列表"];
            
            id resultData = [data valueForKeyPath:@"data"];
            CodingTips *resultA = [NSObject objectOfClass:@"CodingTips" fromJSON:resultData];
            block(resultA, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_markReadWithCodingTipIdStr:(NSString *)tipIdStr andBlock:(void (^)(id data, NSError *error))block{
    if (tipIdStr.length <= 0) {
        return;
    }
    NSDictionary *params = @{@"id" : tipIdStr};
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/mark-read" withParams:params withMethodType:Post autoShowError:NO andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"消息通知_标记某条消息为已读"];
            
            block(data, nil);
            [[UnReadManager shareManager] updateUnRead];
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_DeletePrivateMessage:(PrivateMessage *)curMsg andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curMsg toDeletePath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"私信_删除"];
            
            block(curMsg, nil);
        }else{
            block(nil, error);
        }
    }];
}
- (void)request_DeletePrivateMessagesWithObj:(PrivateMessage *)curObj andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curObj.friend toDeleteConversationPath] withParams:nil withMethodType:Delete andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"会话_删除"];
            
            block(curObj, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_markReadWithCodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:@"api/notification/mark-read" withParams:[curTips toMarkReadParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"消息通知_标记某类型全部为已读"];
            
            block(data, nil);
            [[UnReadManager shareManager] updateUnRead];
        }else{
            block(nil, error);
        }
    }];
}

#pragma mark - User
- (void)request_UserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toUserInfoPath] withParams:nil withMethodType:Get andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_RootList label:@"用户信息"];
            
            id resultData = [data valueForKeyPath:@"data"];
            User *user = [NSObject objectOfClass:@"User" fromJSON:resultData];
            if (user.id.intValue == [Login curLoginUser].id.intValue) {
                [Login doLogin:resultData];
            }
            block(user, nil);
        }else{
            block(nil, error);
        }
    }];
}

- (void)request_FollowedOrNot_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block{
    [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:[curUser toFllowedOrNotPath] withParams:[curUser toFllowedOrNotParams] withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
//            [MobClick event:kUmeng_Event_Request_ActionOfServer label:@"关注某人"];
            
            block(data, nil);
        }else{
            block(nil, error);
        }
    }];
}
@end
