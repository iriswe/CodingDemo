//
//  Coding_NetAPIManager.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/8.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodingModel.h"

@interface Coding_NetAPIManager : NSObject

+(Coding_NetAPIManager *)sharedManager;

#pragma mark - Login & Register
- (void)request_Register_V2_WithParams:(NSDictionary *)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_CaptchaNeededWithPath:(NSString *)path andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Login_With2FA:(NSString *)otpCode andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Login_WithPath:(NSString *)path Params:(id)params andBlock:(void (^)(id data, NSError *error))block;
- (void)request_ActivateBySetGlobal_key:(NSString *)global_key block:(void (^)(id data, NSError *error))block;
- (void)request_SendActivateEmail:(NSString *)email block:(void (^)(id data, NSError *error))block;

- (void)post_Close2FAWithPhone:(NSString *)phone code:(NSString *)code block:(void (^)(id data, NSError *error))block;
- (void)post_Close2FAGeneratePhoneCode:(NSString *)phone block:(void (^)(id data, NSError *error))block;

#pragma mark - UnRead
- (void)request_UnReadCountWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_UnReadNotificationsWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_PrivateMessages:(PrivateMessages *)priMsgs andBlock:(void (^)(id data, NSError *error))block;
#pragma mark - Project
- (void)request_ProjectsCatergoryAndCounts_WithObj:(ProjectCount *)pCount andBlock:(void (^)(ProjectCount *data, NSError *error))block;

- (void)request_Projects_WithObj:(Projects *)projects andBlock:(void (^)(Projects *data, NSError *error))block;
- (void)request_ProjectsHaveTasks_WithObj:(Projects *)projects andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Project_Pin:(Project *)project andBlock:(void (^)(id data, NSError *error))block;

#pragma mark - Task
- (void)request_ProjectTaskList_WithObj:(Tasks *)tasks andBlock:(void (^)(Tasks *data, NSError *error))block;
- (void)request_ChangeTaskStatus:(Task *)task andBlock:(void (^)(id data, NSError *error))block;
#pragma mark - Tweet
- (void)request_Tweets_WithObj:(Tweets *)tweets andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoLike_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoComment_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoTweet_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_DoProjectTweet_WithPro:(NSNumber *)pro_id content:(NSString *)content andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Likers_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_LikesAndRewards_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Comments_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Delete_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_TweetComment_Delete_WithTweet:(Tweet *)tweet andComment:(Comment *)comment andBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_Detail_WithObj:(Tweet *)tweet andBlock:(void (^)(id data, NSError *error))block;
- (void)request_PublicTweetsWithTopic:(NSInteger)topicID last_id:(NSNumber *)last_id andBlock:(void (^)(id data, NSError *error))block;
#pragma mark - Topic
- (void)request_TopicAdlistWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_HotTopiclistWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_DefautsHotTopicNamelistWithBlock:(void (^)(id data, NSError *error))block;
- (void)request_Tweet_WithSearchString:(NSString *)strSearch andPage:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block;

- (void)requestWithSearchString:(NSString *)strSearch typeStr:(NSString*)type andPage:(NSInteger)page andBlock:(void (^)(id data, NSError *error))block;

- (void)request_TopicDetailsWithTopicID:(NSInteger)topicID block:(void (^)(id data, NSError *error))block;
- (void)request_TopTweetWithTopicID:(NSInteger)topicID block:(void (^)(id data, NSError *error))block;

- (void)request_JoinedTopicsWithUserGK:(NSString *)userGK page:(NSInteger)page block:(void (^)(id data, BOOL hasMoreData, NSError *error))block;
- (void)request_WatchedTopicsWithUserGK:(NSString *)userGK page:(NSInteger)page block:(void (^)(id data, BOOL hasMoreData, NSError *error))block;

- (void)request_Topic_DoWatch_WithUrl:(NSString *)url andBlock:(void (^)(id data, NSError *error))block;
- (void)request_BannersWithBlock:(void (^)(id data, NSError *error))block;
#pragma mark - Message

- (void)request_CodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block;
- (void)request_markReadWithCodingTipIdStr:(NSString *)tipIdStr andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeletePrivateMessage:(PrivateMessage *)curMsg andBlock:(void (^)(id data, NSError *error))block;
- (void)request_DeletePrivateMessagesWithObj:(PrivateMessage *)curObj andBlock:(void (^)(id data, NSError *error))block;
- (void)request_markReadWithCodingTips:(CodingTips *)curTips andBlock:(void (^)(id data, NSError *error))block;
#pragma mark - User
- (void)request_UserInfo_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;
- (void)request_FollowedOrNot_WithObj:(User *)curUser andBlock:(void (^)(id data, NSError *error))block;

@end
