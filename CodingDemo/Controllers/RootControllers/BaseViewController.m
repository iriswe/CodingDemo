//
//  BaseViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/8/31.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"
#import "TweetDetailViewController.h"
#import "CodingModel.h"
#import "RootTabViewController.h"

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColorTableBG;
    
}

- (void)tabBarItemClicked{
    kLog(@"\ntabBarItemClicked : %@", NSStringFromClass([self class]));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


+ (UIViewController *)analyseVCFromLinkStr:(NSString *)linkStr{
    return [self analyseVCFromLinkStr:linkStr analyseMethod:AnalyseMethodTypeForceCreate isNewVC:nil];
}

+ (UIViewController *)analyseVCFromLinkStr:(NSString *)linkStr analyseMethod:(AnalyseMethodType)methodType isNewVC:(BOOL *)isNewVC{
    kLog(@"\n analyseVCFromLinkStr : %@", linkStr);
    
    if (!linkStr || linkStr.length <= 0) {
        return nil;
    }else if (!([linkStr hasPrefix:@"/"] ||
                [linkStr hasPrefix:kCodingAppScheme] ||
                [linkStr hasPrefix:kBaseUrlStr_Phone] ||
                [linkStr hasPrefix:[NSObject baseURLStr]])){
        return nil;
    }
    
    UIViewController *analyseVC = nil;
    UIViewController *presentingVC = nil;
    BOOL analyseVCIsNew = YES;
    if (methodType != AnalyseMethodTypeForceCreate) {
        presentingVC = [BaseViewController presentingVC];
    }
    
    NSString *userRegexStr = @"/u/([^/]+)$";//AT某人
    NSString *userTweetRegexStr = @"/u/([^/]+)/bubble$";//某人的冒泡
    NSString *ppRegexStr = @"/u/([^/]+)/pp/([0-9]+)";//冒泡
    NSString *pp_projectRegexStr = @"/[ut]/([^/]+)/p/([^\?]+)[\?]pp=([0-9]+)$";//项目内冒泡(含团队项目)
    NSString *topicRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/topic/(\\d+)";//讨论(含团队项目)
    NSString *taskRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/task/(\\d+)";//任务(含团队项目)
    NSString *fileRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/attachment/([^/]+)/preview/(\\d+)";//文件(含团队项目)
    NSString *gitMRPRCommitRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/git/(merge|pull|commit)/([^/#]+)";//MR(含团队项目)
    NSString *conversionRegexStr = @"/user/messages/history/([^/]+)$";//私信
    NSString *pp_topicRegexStr = @"/pp/topic/([0-9]+)$";//话题
    NSString *codeRegexStr = @"/[ut]/([^/]+)/p/([^/]+)/git/blob/([^/]+)[/]?([^?]*)";//代码(含团队项目)
    NSString *twoFARegexStr = @"/app_intercept/show_2fa";//两步验证
    NSString *projectRegexStr = @"/[ut]/([^/]+)/p/([^/]+)";//项目(含团队项目)
    NSArray *matchedCaptures = nil;
    if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:ppRegexStr]).count > 0){
        //冒泡
        NSString *user_global_key = matchedCaptures[1];
        NSString *pp_id = matchedCaptures[2];
        if ([presentingVC isKindOfClass:[TweetDetailViewController class]]) {
            TweetDetailViewController *vc = (TweetDetailViewController *)presentingVC;
            //            if ([vc.curTweet.id.stringValue isEqualToString:pp_id]
            //                && [vc.curTweet.owner.global_key isEqualToString:user_global_key]) {
            //                [vc refreshTweet];
            analyseVCIsNew = NO;
            analyseVC = vc;
            //            }
        }
        if (!analyseVC) {
            TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
            //            vc.curTweet = [Tweet tweetWithGlobalKey:user_global_key andPPID:pp_id];
            analyseVC = vc;
        }
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:pp_projectRegexStr]).count > 0){
        //项目内冒泡
        NSString *owner_user_global_key = matchedCaptures[1];
        NSString *project_name = matchedCaptures[2];
        NSString *pp_id = matchedCaptures[3];
        Project *curPro = [Project new];
        curPro.owner_user_name = owner_user_global_key;
        curPro.name = project_name;
        TweetDetailViewController *vc = [[TweetDetailViewController alloc] init];
        //        vc.curTweet = [Tweet tweetInProject:curPro andPPID:pp_id];
        analyseVC = vc;
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:gitMRPRCommitRegexStr]).count > 0){
        //MR
        NSString *path = [matchedCaptures[0] stringByReplacingOccurrencesOfString:@"https://coding.net" withString:@""];
        
        if ([matchedCaptures[3] isEqualToString:@"commit"]) {
            //            if ([presentingVC isKindOfClass:[CommitFilesViewController class]]) {
            //                CommitFilesViewController *vc = (CommitFilesViewController *)presentingVC;
            //                if ([vc.commitId isEqualToString:matchedCaptures[3]] &&
            //                    [vc.projectName isEqualToString:matchedCaptures[2]] &&
            //                    [vc.ownerGK isEqualToString:matchedCaptures[1]]) {
            //                    [vc refresh];
            //                    analyseVCIsNew = NO;
            //                    analyseVC = vc;
            //                }
            //            }
            //            if (!analyseVC) {
            //                analyseVC = [CommitFilesViewController vcWithPath:path];
            //            }
        }else{
            //            if ([presentingVC isKindOfClass:[PRDetailViewController class]]) {
            //                PRDetailViewController *vc = (PRDetailViewController *)presentingVC;
            //                if ([vc.curMRPR.path isEqualToString:path]) {
            //                    [vc refresh];
            //                    analyseVCIsNew = NO;
            //                    analyseVC = vc;
            //                }
            //            }
            //            if (!analyseVC) {
            //                if([path rangeOfString:@"merge"].location == NSNotFound) {
            //                    analyseVC = [PRDetailViewController vcWithPath:path];
            //                } else {
            //                    analyseVC = [MRDetailViewController vcWithPath:path];
            //                }
            //            }
        }
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:topicRegexStr]).count > 0){
        //讨论
        //        NSString *topic_id = matchedCaptures[3];
        //        if ([presentingVC isKindOfClass:[TopicDetailViewController class]]) {
        //            TopicDetailViewController *vc = (TopicDetailViewController *)presentingVC;
        //            if ([vc.curTopic.id.stringValue isEqualToString:topic_id]) {
        //                [vc refreshTopic];
        //                analyseVCIsNew = NO;
        //                analyseVC = vc;
        //            }
        //        }
        //        if (!analyseVC) {
        //            TopicDetailViewController *vc = [[TopicDetailViewController alloc] init];
        //            vc.curTopic = [ProjectTopic topicWithId:[NSNumber numberWithInteger:topic_id.integerValue]];
        //            analyseVC = vc;
        //        }
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:taskRegexStr]).count > 0){
        //        //任务
        //        NSString *user_global_key = matchedCaptures[1];
        //        NSString *project_name = matchedCaptures[2];
        //        NSString *taskId = matchedCaptures[3];
        //        NSString *backend_project_path = [NSString stringWithFormat:@"/user/%@/project/%@", user_global_key, project_name];
        //        if ([presentingVC isKindOfClass:[EditTaskViewController class]]) {
        //            EditTaskViewController *vc = (EditTaskViewController *)presentingVC;
        //            if ([vc.myTask.backend_project_path isEqualToString:backend_project_path]
        //                && [vc.myTask.id.stringValue isEqualToString:taskId]) {
        //                [vc queryToRefreshTaskDetail];
        //                analyseVCIsNew = NO;
        //                analyseVC = vc;
        //            }
        //        }
        //        if (!analyseVC) {
        //            EditTaskViewController *vc = [[EditTaskViewController alloc] init];
        //            vc.myTask = [Task taskWithBackend_project_path:[NSString stringWithFormat:@"/user/%@/project/%@", user_global_key, project_name] andId:taskId];
        //            @weakify(vc);
        //            vc.taskChangedBlock = ^(){
        //                @strongify(vc);
        //                [vc dismissViewControllerAnimated:YES completion:nil];
        //            };
        //            analyseVC = vc;
        //        }
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:fileRegexStr]).count > 0){
        //文件
        //        NSString *user_global_key = matchedCaptures[1];
        //        NSString *project_name = matchedCaptures[2];
        //        NSString *fileId = matchedCaptures[4];
        //        if ([presentingVC isKindOfClass:[FileViewController class]]) {
        //            FileViewController *vc = (FileViewController *)presentingVC;
        //            if (vc.curFile.file_id.integerValue == fileId.integerValue) {
        //                [vc requestFileData];
        //                analyseVCIsNew = NO;
        //                analyseVC = vc;
        //            }
        //        }
        //        if (!analyseVC) {
        //            ProjectFile *curFile = [[ProjectFile alloc] initWithFileId:@(fileId.integerValue) inProject:project_name ofUser:user_global_key];
        //            FileViewController *vc = [FileViewController vcWithFile:curFile andVersion:nil];
        //            analyseVC = vc;
        //        }
    }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:conversionRegexStr]).count > 0) {
        //私信
        //        NSString *user_global_key = matchedCaptures[1];
        //        if ([presentingVC isKindOfClass:[ConversationViewController class]]) {
        //            ConversationViewController *vc = (ConversationViewController *)presentingVC;
        //            if ([vc.myPriMsgs.curFriend.global_key isEqualToString:user_global_key]) {
        //                [vc doPoll];
        //                analyseVCIsNew = NO;
        //                analyseVC = vc;
        //            }
        //        }
        //        if (!analyseVC) {
        //            ConversationViewController *vc = [[ConversationViewController alloc] init];
        //            vc.myPriMsgs = [PrivateMessages priMsgsWithUser:[User userWithGlobalKey:user_global_key]];
        //            analyseVC = vc;
        //        }
    }else if (methodType != AnalyseMethodTypeJustRefresh){
        //        if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:userRegexStr]).count > 0) {
        //            //AT某人
        //            NSString *user_global_key = matchedCaptures[1];
        //            UserInfoViewController *vc = [[UserInfoViewController alloc] init];
        //            vc.curUser = [User userWithGlobalKey:user_global_key];
        //            analyseVC = vc;
        //        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:userTweetRegexStr]).count > 0){
        //            //某人的冒泡
        //            UserOrProjectTweetsViewController *vc = [[UserOrProjectTweetsViewController alloc] init];
        //            NSString *user_global_key = matchedCaptures[1];
        //            vc.curTweets = [Tweets tweetsWithUser:[User userWithGlobalKey:user_global_key]];
        //            analyseVC = vc;
        //        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:pp_topicRegexStr]).count > 0){
        //            //话题
        //            NSString *pp_topic_id = matchedCaptures[1];
        //            CSTopicDetailVC *vc = [CSTopicDetailVC new];
        //            vc.topicID = pp_topic_id.integerValue;
        //            analyseVC = vc;
        //        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:codeRegexStr]).count > 0){
        //            //代码
        //            NSString *user_global_key = matchedCaptures[1];
        //            NSString *project_name = matchedCaptures[2];
        //            NSString *ref = matchedCaptures[3];
        //            NSString *path = matchedCaptures.count >= 5? matchedCaptures[4]: @"";
        //
        //            Project *curPro = [[Project alloc] init];
        //            curPro.owner_user_name = user_global_key;
        //            curPro.name = project_name;
        //            CodeFile *codeFile = [CodeFile codeFileWithRef:ref andPath:path];
        //            CodeViewController *vc = [CodeViewController codeVCWithProject:curPro andCodeFile:codeFile];
        //            analyseVC = vc;
        //        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:twoFARegexStr]).count > 0){
        //            //两步验证
        //            analyseVC = [OTPListViewController new];
        //        }else if ((matchedCaptures = [linkStr captureComponentsMatchedByRegex:projectRegexStr]).count > 0){
        //            //项目
        //            NSString *user_global_key = matchedCaptures[1];
        //            NSString *project_name = matchedCaptures[2];
        //            Project *curPro = [[Project alloc] init];
        //            curPro.owner_user_name = user_global_key;
        //            curPro.name = project_name;
        //            NProjectViewController *vc = [[NProjectViewController alloc] init];
        //            vc.myProject = curPro;
        //            analyseVC = vc;
        //        }
    }
    if (isNewVC) {
        *isNewVC = analyseVCIsNew;
    }
    return analyseVC;
}


+ (UIViewController *)presentingVC{
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[RootTabViewController class]]) {
        result = [(RootTabViewController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
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
