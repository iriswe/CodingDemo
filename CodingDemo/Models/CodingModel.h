//
//  CodingModel.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/1.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coding_FileManager.h"
#import "HtmlMedia.h"

@interface CodingModel : NSObject

@end
#pragma mark - Login
@interface Register : NSObject

@property (readwrite, nonatomic, strong) NSString *email, *global_key, *j_captcha, *phone, *code, *password, *confirm_password;

- (NSDictionary *)toParams;
+ (NSString *)channel;

@end

@interface User : NSObject

@property (readwrite, nonatomic, strong) NSString *avatar, *name, *global_key, *path, *slogan, *company, *tags_str, *tags, *location, *job_str, *job, *email, *birthday, *pinyinName;
@property (readwrite, nonatomic, strong) NSString *curPassword, *resetPassword, *resetPasswordConfirm, *phone, *introduction, *phone_country_code, *country;
@property (readwrite, nonatomic, strong) NSNumber *id, *sex, *follow, *followed, *fans_count, *follows_count, *tweets_count, *status, *points_left, *email_validation, *is_phone_validated;
@property (readwrite, nonatomic, strong) NSDate *created_at, *last_logined_at, *last_activity_at, *updated_at;

+ (User *)userWithGlobalKey:(NSString *)global_key;
- (BOOL)isSameToUser:(User *)user;
- (NSString *)toUserInfoPath;
- (NSString *)toResetPasswordPath;
- (NSDictionary *)toResetPasswordParams;
- (NSString *)toFllowedOrNotPath;
- (NSDictionary *)toFllowedOrNotParams;
- (NSString *)toUpdateInfoPath;
- (NSDictionary *)toUpdateInfoParams;
- (NSString *)toDeleteConversationPath;
- (NSString *)localFriendsPath;
- (NSString *)changePasswordTips;
@end

typedef NS_ENUM(NSInteger, UsersType) {
    UsersTypeFollowers = 0,
    UsersTypeFriends_Attentive,
    UsersTypeFriends_Message,
    UsersTypeFriends_At,
    UsersTypeFriends_Transpond,
    
    UsersTypeProjectStar,
    UsersTypeProjectWatch,
    
    UsersTypeTweetLikers,
    UsersTypeAddToProject,
    UsersTypeAddFriend,
};

@interface Users : NSObject
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (assign, nonatomic) UsersType type;
@property (strong, nonatomic) User *owner;
@property (strong, nonatomic) NSString *project_owner_name, *project_name;

- (NSString *)toPath;
- (NSDictionary *)toParams;
- (void)configWithObj:(Users *)resultA;

- (NSDictionary *)dictGroupedByPinyin;

+(Users *)usersWithOwner:(User *)owner Type:(UsersType)type;
+(Users *)usersWithProjectOwner:(NSString *)owner_name projectName:(NSString *)name Type:(UsersType)type;

@end


@interface Login : NSObject

@property (readwrite, nonatomic, strong) NSString *email, *password, *j_captcha;
@property (readwrite, nonatomic, strong) NSNumber *remember_me;

- (NSString *)toPath;
- (NSDictionary *)toParams;
+ (User *)curLoginUser;
+ (BOOL)isLogin;
+ (void)doLogin:(NSDictionary *)loginData;
+ (void)doLogout;
+ (void)setPreUserEmail:(NSString *)emailStr;
+ (NSString *)preUserEmail;
+ (NSMutableDictionary *)readLoginDataList;
+ (User *)userWithGlobaykeyOrEmail:(NSString *)textStr;
- (NSString *)goToLoginTipWithCaptcha:(BOOL)needCaptcha;
+(BOOL)isLoginUserGlobalKey:(NSString *)global_key;

@end
#pragma mark - Project
@interface ProjectCount : NSObject
@property (strong, nonatomic) NSNumber *all, *watched, *created, *joined, *stared, *deploy;
- (void)configWithProjects:(ProjectCount *)ProjectCount;
@end


typedef NS_ENUM(NSInteger, ProjectsType)
{
    ProjectsTypeAll = 0,
    ProjectsTypeCreated,
    ProjectsTypeJoined,
    ProjectsTypeWatched,
    ProjectsTypeStared,
    ProjectsTypeToChoose,
    ProjectsTypeTaProject,
    ProjectsTypeTaStared,
    ProjectsTypeTaWatched,
    ProjectsTypeAllPublic,
};

@interface Projects : NSObject
@property (strong, nonatomic) User *curUser;
@property (assign, nonatomic) ProjectsType type;
//请求
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
//解析
@property (readwrite, nonatomic, strong) NSNumber *totalPage, *totalRow;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (strong, nonatomic, readonly) NSArray *pinList, *noPinList;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;

+ (Projects *)projectsWithType:(ProjectsType)type andUser:(User *)user;
- (NSDictionary *)toParams;
- (NSString *)toPath;
- (void)configWithProjects:(Projects *)responsePros;
@end

@interface Project : NSObject
@property (readwrite, nonatomic, strong) NSString *icon, *name, *owner_user_name, *backend_project_path, *full_name, *description_mine, *path, *parent_depot_path, *current_user_role,*project_path;
@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *is_public, *un_read_activities_count, *done, *processing, *star_count, *stared, *watch_count, *watched, *fork_count, *forked, *recommended, *pin, *current_user_role_id, *type, *gitReadmeEnabled;
@property (assign, nonatomic) BOOL isStaring, isWatching, isLoadingMember, isLoadingDetail;

@property (strong, nonatomic) User *owner;
@property (strong, nonatomic) NSDate *created_at,*updated_at;

+ (Project *)project_All;
+ (Project *)project_FeedBack;

- (NSString *)toProjectPath;
- (NSDictionary *)toCreateParams;

- (NSString *)toUpdatePath;
- (NSDictionary *)toUpdateParams;

- (NSString *)toUpdateIconPath;

- (NSString *)toDeletePath;

- (NSString *)toMembersPath;
- (NSDictionary *)toMembersParams;

- (NSString *)toUpdateVisitPath;
- (NSString *)toDetailPath;

- (NSString *)localMembersPath;

- (NSString *)toBranchOrTagPath:(NSString *)path;
@end

@interface ProjectMember : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id, *project_id, *user_id, *type, *done, *processing;//type:80是member，100是creater
@property (readwrite, nonatomic, strong) User *user;
@property (readwrite, nonatomic, strong) NSDate *created_at, *last_visit_at;
@property (strong, nonatomic) NSString *alias, *editAlias;
@property (strong, nonatomic) NSNumber *editType;
+ (ProjectMember *)member_All;
- (NSString *)toQuitPath;
- (NSString *)toKickoutPath;
@end

typedef NS_ENUM(NSInteger, ProjectActivityType)
{
    ProjectActivityTypeAll = 0,
    ProjectActivityTypeTask,
    ProjectActivityTypeTopic,
    ProjectActivityTypeFile,
    ProjectActivityTypeCode,
    ProjectActivityTypeOther
};


@interface ProjectActivities : NSObject
@property (readwrite, nonatomic, strong) NSNumber *project_id, *last_id, *user_id;
@property (readwrite, nonatomic, strong) NSString *type;

@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSMutableArray *list, *listGroups;
@property (readwrite, nonatomic, strong) Project *curProject;
@property (readwrite, nonatomic, strong) User *curUser;
@property (assign, nonatomic) BOOL isOfUser;

+ (ProjectActivities *)proActivitiesWithPro:(Project *)project type:(ProjectActivityType)type;
+ (ProjectActivities *)proActivitiesWithPro:(Project *)project user:(User *)user;
- (NSString *)toPath;
- (NSDictionary *)toParams;

- (void)configWithProActList:(NSArray *)responseA;
@end

@class Task,Task_Description, ProjectTopicActivity, TaskComment, File, QcTask, Depot, ProjectLineNoteActivity, Commit, File, FileComment, ProjectFile, ResourceReference;
@interface ProjectActivity : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id;
@property (readwrite, nonatomic, strong) NSString *target_type, *action, *action_msg, *type, *ref, *ref_type, *ref_path, *pull_request_title, *merge_request_title, *comment_content, *merge_request_path, *pull_request_path, *version;
@property (readwrite, nonatomic, strong) User *user, *target_user, *watcher;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) Task *origin_task, *task;
@property (readwrite, nonatomic, strong) TaskComment *taskComment, *origin_taskComment;
@property (readwrite, nonatomic, strong) Project *project;
@property (readwrite, nonatomic, strong) ProjectTopicActivity *project_topic;
@property (readwrite, nonatomic, strong) File *file;
@property (readwrite, nonatomic, strong) QcTask *qc_task;
@property (readwrite, nonatomic, strong) Depot *depot, *source_depot;
@property (readwrite, nonatomic, strong) NSMutableArray *commits, *labels;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) ProjectLineNoteActivity *line_note;
@property (strong, nonatomic) Commit *commit;
@property (strong, nonatomic) FileComment *projectFileComment;
@property (strong, nonatomic) ProjectFile *projectFile;

@property (readonly, nonatomic, strong) NSMutableArray *actionMediaItems, *contentMediaItems;
@property (readonly, nonatomic, strong) NSMutableString *actionStr, *contentStr;
@end


typedef NS_ENUM(NSInteger, TaskHandleType) {
    TaskHandleTypeEdit = 0,
    TaskHandleTypeAddWithProject,
    TaskHandleTypeAddWithoutProject
};


typedef NS_ENUM(NSInteger, TaskQueryType){
    TaskQueryTypeAll = 0,
    TaskQueryTypeProcessing,
    TaskQueryTypeDone
};

typedef NS_ENUM(NSInteger, TaskEntranceType){
    TaskEntranceTypeProject = 0,
    TaskEntranceTypeMine,
};

@interface Tasks : NSObject

@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (readwrite, nonatomic, strong) NSString *backend_project_path;//从Project中取来的
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (strong, nonatomic) NSArray *doneList, *processingList;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) Project *project;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (assign, nonatomic) TaskQueryType type;
@property (assign, nonatomic) TaskEntranceType entranceType;

+ (Tasks *)tasksWithPro:(Project *)project owner:(User *)owner queryType:(TaskQueryType)type;
+ (Tasks *)tasksWithPro:(Project *)project queryType:(TaskQueryType)type;

- (NSString *)queryType;
- (NSDictionary *)toParams;
- (NSString *)toRequestPath;

- (void)configWithTasks:(Tasks *)resultA;

@end

@interface Task : NSObject
@property (readwrite, nonatomic, strong) User *owner, *creator;
@property (readwrite, nonatomic, strong) NSString *title, *content, *backend_project_path, *deadline, *path, *description_mine,*descript;
@property (readwrite, nonatomic, strong) NSDate *created_at, *updated_at;
@property (readonly, nonatomic, strong) NSDate *deadline_date;
@property (readwrite, nonatomic, strong) Project *project;
@property (readwrite, nonatomic, strong) NSNumber *id, *status, *owner_id, *priority, *comments, *has_description, *number,*resource_id;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSMutableArray *activityList, *labels, *watchers;
@property (nonatomic, assign) TaskHandleType handleType;
@property (nonatomic, assign) BOOL isRequesting, isRequestingDetail, isRequestingCommentList, needRefreshDetail;
@property (readwrite, nonatomic, strong) NSString *nextCommentStr;
@property (strong, nonatomic) Task_Description *task_description;
@property (strong, nonatomic) ResourceReference *resourceReference;

+ (Task *)taskWithProject:(Project *)project andUser:(User *)user;
+ (Task *)taskWithBackend_project_path:(NSString *)backend_project_path andId:(NSString *)taskId;
+ (Task *)taskWithTask:(Task *)task;
- (BOOL)isSameToTask:(Task *)task;
- (User *)hasWatcher:(User *)watcher;

//任务状态
- (NSString *)toEditTaskStatusPath;
-(NSDictionary *)toEditStatusParams;
-(NSDictionary *)toChangeStatusParams;
//更新任务
- (NSString *)toUpdatePath;
-(NSDictionary *)toUpdateParamsWithOld:(Task *)oldTask;
//更新任务描述
- (NSString *)toUpdateDescriptionPath;
//添加新任务
- (NSString *)toAddTaskPath;
- (NSDictionary *)toAddTaskParams;
//删除任务
- (NSString *)toDeleteTaskPath;
//任务评论列表
- (NSString *)toCommentListPath;
- (NSDictionary *)toCommentListParams;
//任务动态列表
- (NSString *)toActivityListPath;
//任务详情
- (NSString *)toTaskDetailPath;
//任务描述
- (NSString *)toDescriptionPath;
//任务关联资源
- (NSString *)toResourceReferencePath;
//任务关注者列表
- (NSString *)toWatchersPath;
//评论任务
- (NSString *)toDoCommentPath;
- (NSDictionary *)toDoCommentParams;

- (NSString *)toEditLabelsPath;

//- (void)addNewComment:(TaskComment *)comment;
//- (void)deleteComment:(TaskComment *)comment;
@end

@interface Task_Description : NSObject
@property (strong, nonatomic) NSString *description_mine, *markdown;
+ (instancetype)defaultDescription;
+ (instancetype)descriptionWithMdStr:(NSString *)mdStr;

@end

@class HtmlMedia;
@interface TaskComment : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *taskId;
@property (readwrite, nonatomic, strong) NSString *content;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (readwrite, nonatomic, strong) NSDate *created_at;

@end

@interface ProjectTopicActivity : NSObject
@property (readwrite, nonatomic, strong) NSString *title, *content, *path;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (readwrite, nonatomic, strong) ProjectTopicActivity *parent;

@end

@interface File : NSObject
@property (readwrite, nonatomic, strong) NSString *name, *path;
@end

@interface QcTask : NSObject
@property (readwrite, nonatomic, strong) NSString *link;
@property (readwrite, nonatomic, strong) User *user;

@end

@interface Depot : NSObject
@property (strong, nonatomic) NSNumber *id;
@property (readwrite, nonatomic, strong) NSString *name, *path, *depot_path, *default_branch;
@end

@interface ProjectLineNoteActivity : NSObject
@property (readwrite, strong, nonatomic) NSString *noteable_id, *noteable_title, *noteable_url, *content, *path, *noteable_type;
@property (readwrite, strong, nonatomic) NSNumber *id;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@end

@class Committer;
@interface Commit : NSObject
@property (readwrite, nonatomic, strong) NSString *sha, *short_message, *ref, *ref_path;
@property (strong, nonatomic) NSString *fullMessage, *shortMessage, *allMessage, *commitId;
@property (strong, nonatomic) NSDate *commitTime;
@property (strong, nonatomic) NSNumber *notesCount;
@property (readwrite, nonatomic, strong) Committer *committer;
- (NSString *)contentStr;
@end

@interface Committer : NSObject
@property (readwrite, nonatomic, strong) NSString *avatar, *name, *link, *email;
@end

@interface FileComment : NSObject
@property (readwrite, nonatomic, strong) NSNumber *id;
@property (readwrite, nonatomic, strong) NSString *content;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;

@property (strong, nonatomic) NSDate *created_at;
@end



typedef NS_ENUM(NSInteger, DownloadState){
    DownloadStateDefault = 0,
    DownloadStateDownloading,
    DownloadStatePausing,
    DownloadStateDownloaded
};

@class Coding_DownloadTask;

@interface ProjectFile : NSObject
@property (readwrite, nonatomic, strong) NSDate *created_at, *updated_at;
@property (readwrite, nonatomic, strong) NSNumber *id,*file_id, *owner_id, *parent_id, *type, *current_user_role_id, *size, *project_id, *number;
@property (readwrite, nonatomic, strong) NSString *name, *fileType, *owner_preview, *preview, *storage_key, *storage_type, *title, *share_url,*path;
@property (readwrite, nonatomic, strong) User *owner;
@property (strong, nonatomic, readonly) NSString *diskFileName;

+(ProjectFile *)fileWithFileId:(NSNumber *)fileId andProjectId:(NSNumber *)project_id;
- (instancetype)initWithFileId:(NSNumber *)fileId inProject:(NSString *)project_name ofUser:(NSString *)project_owner_name;

- (BOOL)isEmpty;

- (DownloadState)downloadState;
- (Coding_DownloadTask *)cDownloadTask;
- (NSURL *)hasBeenDownload;

- (NSString *)downloadPath;

- (NSString *)toDeletePath;
- (NSDictionary *)toDeleteParams;

- (NSDictionary *)toMoveToParams;

- (NSString *)toDetailPath;

- (NSString *)toActivityListPath;

- (NSString *)toHistoryListPath;

- (NSDictionary *)toShareParams;
@end


@interface ResourceReference : NSObject
@property (strong, nonatomic) NSMutableArray *Task, *MergeRequestBean, *ProjectTopic, *ProjectFile, *itemList;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;

@end

@interface ResourceReferenceItem : NSObject
@property (strong, nonatomic) NSString *target_type, *title, *link;
@property (strong, nonatomic) NSNumber *code, *target_id;
@end


@interface ListGroupItem : NSObject
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) NSUInteger location, length;
@property (assign, nonatomic) BOOL hide;

+(ListGroupItem *)itemWithDate:(NSDate *)date andLocation:(NSUInteger)location;
- (void)addOneItem;
- (void)deleteOneItem;

@end

typedef NS_ENUM(NSUInteger, ProjectTagType){
    ProjectTagTypeTopic = 0,
    ProjectTagTypeTask,
};

@interface ProjectTag : NSObject

@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *count;
@property (readwrite, nonatomic, strong) NSString *name, *color;

+ (instancetype)tagWithName:(NSString *)name;
+ (BOOL)tags:(NSArray *)aTags isEqualTo:(NSArray *)bTags;
+ (instancetype)tags:(NSArray *)aTags hasTag:(ProjectTag *)curTag;

@end

@interface FileVersion : NSObject
@property (strong, nonatomic) NSNumber *file_id, *history_id, *owner_id, *parent_id, *size, *type, *version, *action, *project_id;
@property (strong, nonatomic) NSString *action_msg, *name, *remark, *storage_key, *storage_type, *fileType, *preview, *owner_preview;
@property (strong, nonatomic) NSDate *created_at;
@property (readwrite, nonatomic, strong) User *owner;

@property (strong, nonatomic, readonly) NSString *diskFileName;

- (NSString *)downloadPath;

- (NSString *)toRemarkPath;
- (NSString *)toDeletePath;

//download
- (DownloadState)downloadState;
- (Coding_DownloadTask *)cDownloadTask;
- (NSURL *)hasBeenDownload;
@end

#pragma mark - Tweet

@class TweetImage, TweetSendLocationResponse, Comment;


typedef NS_ENUM(NSInteger, TweetType)
{
    TweetTypePublicTime = 0,
    TweetTypeUserFriends,
    TweetTypePublicHot,
    TweetTypeUserSingle,
    TweetTypeProject
};


@interface Tweets : NSObject
@property (strong, nonatomic, readonly) NSDate *last_time;
@property (readonly, nonatomic, strong) NSNumber *last_id;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (assign, nonatomic) TweetType tweetType;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (readwrite, nonatomic, strong) User *curUser;
@property (strong, nonatomic) Project *curPro;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSNumber *totalPage, *totalRow;
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize;

+ (Tweets *)tweetsWithType:(TweetType)tweetType;
+ (Tweets *)tweetsWithUser:(User *)curUser;
+ (Tweets *)tweetsWithProject:(Project *)curPro;
- (void)configWithTweets:(NSArray *)responseA;

- (NSString *)toPath;
- (NSDictionary *)toParams;

@end


@interface Tweet : NSObject
@property (readwrite, nonatomic, strong) NSString *content, *device, *location, *coord, *address;
@property (readwrite, nonatomic, strong) NSNumber *liked, *rewarded, *activity_id, *id, *comments, *likes, *rewards;
@property (readwrite, nonatomic, strong) NSDate *created_at, *sort_time;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) NSMutableArray *comment_list, *like_users, *reward_users;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (nonatomic,strong) TweetSendLocationResponse *locationData;

@property (readwrite, nonatomic, strong) NSMutableArray *tweetImages;//对 selectedAssetURLs 操作即可，最好不要直接赋值。。应用跳转带的图片会直接对 tweetImages赋值
@property (readwrite, nonatomic, strong) NSMutableArray *selectedAssetURLs;
@property (readwrite, nonatomic, strong) NSString *tweetContent;
@property (readwrite, nonatomic, strong) NSString *nextCommentStr;
@property (strong, nonatomic) NSString *callback;
@property (assign, nonatomic) CGFloat contentHeight;

@property (strong, nonatomic) NSString *user_global_key;
@property (strong, nonatomic) Project *project;
@property (strong, nonatomic) NSNumber *project_id;

- (BOOL)isProjectTweet;

- (void)addASelectedAssetURL:(NSURL *)assetURL;
- (void)deleteASelectedAssetURL:(NSURL *)assetURL;
- (void)deleteATweetImage:(TweetImage *)tweetImage;

- (NSInteger)numOfComments;
- (BOOL)hasMoreComments;

- (NSArray *)like_reward_users;
- (BOOL)hasLikesOrRewards;
- (BOOL)hasMoreLikesOrRewards;
- (BOOL)rewardedBy:(User *)user;

- (NSString *)toDoLikePath;
- (void)changeToLiked:(NSNumber *)liked;

- (NSString *)toDoCommentPath;
- (NSDictionary *)toDoCommentParams;

- (NSString *)toLikesAndRewardsPath;
- (NSDictionary *)toLikesAndRewardsParams;

- (NSString *)toLikersPath;
- (NSDictionary *)toLikersParams;

- (NSString *)toCommentsPath;
- (NSDictionary *)toCommentsParams;

- (NSString *)toDeletePath;
- (NSString *)toDetailPath;

+(Tweet *)tweetForSend;

- (void)saveSendData;
- (void)loadSendData;
+ (void)deleteSendData;

+(Tweet *)tweetWithGlobalKey:(NSString *)user_global_key andPPID:(NSString *)pp_id;
+(Tweet *)tweetInProject:(Project *)project andPPID:(NSString *)pp_id;

- (NSDictionary *)toDoTweetParams;
- (BOOL)isAllImagesDoneSucess;
- (void)addNewComment:(Comment *)comment;
- (void)deleteComment:(Comment *)comment;

- (NSString *)toShareLinkStr;
@end


typedef NS_ENUM(NSInteger, TweetImageUploadState)
{
    TweetImageUploadStateInit = 0,
    TweetImageUploadStateIng,
    TweetImageUploadStateSuccess,
    TweetImageUploadStateFail
};

@interface TweetImage : NSObject
@property (readwrite, nonatomic, strong) UIImage *image, *thumbnailImage;
@property (strong, nonatomic) NSURL *assetURL;
@property (assign, nonatomic) TweetImageUploadState uploadState;
@property (readwrite, nonatomic, strong) NSString *imageStr;
+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL;
+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL andImage:(UIImage *)image;
@end


@interface TweetSendCreateLocation : NSObject

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *latitude;
@property (nonatomic,strong) NSString *longitude;
@property (nonatomic,strong) NSString *coord_type;
@property (nonatomic,strong) NSString *geotable_id;
@property (nonatomic,strong) NSString *ak;

@property (nonatomic,strong) NSString *filter;
@property (nonatomic,strong) NSString *sortby;
@property (nonatomic,strong) NSString *query;
@property (nonatomic,strong) NSString *province;
@property (nonatomic,strong) NSString *city;
@property (nonatomic,strong) NSString *district;
@property (nonatomic,strong) NSString *tags;
@property (nonatomic,strong) NSArray *location;
@property (nonatomic,strong) NSNumber *radius;
@property (nonatomic, strong) NSNumber *page_size;
@property (nonatomic, strong) NSNumber *page_index;

@property (nonatomic,strong) NSString *uid;
@property (nonatomic,strong) NSNumber *user_id;

- (NSDictionary *)toCreateParams;

- (NSDictionary *)toSearchParams;

@end


@interface TweetSendLocationRequest : NSObject

@property (nonatomic, strong) NSString *query;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSString *output;
@property (nonatomic, strong) NSString *scope;
@property (nonatomic, strong) NSString *filter;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSNumber *page_size;
@property (nonatomic, strong) NSNumber *page_num;
@property (nonatomic, strong) NSNumber *radius;

@property (nonatomic, strong) NSString *ak;

@end


@interface TweetSendLocationResponse : NSObject

@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *region;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSDictionary *detailed;

//@property (nonatomic, strong, readonly) NSString *displayLocaiton;
- (NSString *)displayLocaiton;
/**
 *  是否用户自定义位置
 */
@property (nonatomic) BOOL isCustomLocaiton;

@end


@interface TweetSendLocationClient : AFHTTPRequestOperationManager

+ (TweetSendLocationClient *)sharedJsonClient;
/**
 *  请求百度API获取周边信息
 *
 *  @param obj
 *  @param block
 */
- (void)requestPlaceAPIWithParams:(TweetSendLocationRequest *)obj andBlock:(void (^)(id data, NSError *error))block;
/**
 *  请求创建位置
 *  status:0 成功，其他为失败
 *
 *  @param obj
 *  @param block
 */
- (void)requestGeodataCreateWithParams:(TweetSendCreateLocation *)obj andBlock:(void (^)(id data, NSError *error))block;

/**
 *  查找自定义位置
 *
 *  @param obj
 *  @param block
 */
- (void)requestGeodataSearchCustomerWithParams:(TweetSendCreateLocation *)obj andBlock:(void (^)(id data, NSError *error))block;


//- (NSString *)CodingQueryStringFromParametersWithEncoding:(NSDictionary *)parameters encoding: (NSStringEncoding)stringEncoding;

@end

typedef NS_ENUM(NSInteger, CommentSendType) {
    CommentSendTypeSuccess = 0,
    CommentSendTypeIng,
    CommentSendTypeFail
};

@interface Comment : NSObject
@property (readwrite, nonatomic, strong) NSString *content;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) NSNumber *id, *owner_id, *tweet_id;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;


@end

#pragma mark - Message
@class PrivateMessage, VoiceMedia;
@interface PrivateMessages : NSObject
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading, isPolling;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSMutableArray *list, *nextMessages, *dataList;
@property (readwrite, nonatomic, strong) User *curFriend;
+ (PrivateMessages *)priMsgsWithUser:(User *)user;
+ (id)analyzeResponseData:(NSDictionary *)responseData;

- (NSString *)localPrivateMessagesPath;
- (NSString *)toPath;
- (NSDictionary *)toParams;

- (NSString *)toPollPath;
- (NSDictionary *)toPollParams;

- (void)configWithObj:(id)anObj;
- (void)configWithPollArray:(NSArray *)pollList;
- (void)sendNewMessage:(PrivateMessage *)nextMsg;
- (void)sendSuccessMessage:(PrivateMessage *)sucessMsg andOldMessage:(PrivateMessage *)oldMsg;
- (void)deleteMessage:(PrivateMessage *)msg;

- (void)freshLastId:(NSNumber *)last_id;

@end

typedef NS_ENUM(NSInteger, PrivateMessageSendStatus) {
    PrivateMessageStatusSendSucess = 0,
    PrivateMessageStatusSending,
    PrivateMessageStatusSendFail
};

@interface PrivateMessage : NSObject
@property (readwrite, nonatomic, strong) NSString *content, *extra, *file;
@property (readwrite, nonatomic, strong) User *friend, *sender;
@property (readwrite, nonatomic, strong) NSNumber *count, *unreadCount, *id, *read_at, *status, *duration, *played;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;
@property (assign, nonatomic) PrivateMessageSendStatus sendStatus;
@property (strong, nonatomic) UIImage *nextImg;
@property (strong, nonatomic) VoiceMedia *voiceMedia;

- (BOOL)hasMedia;
- (BOOL)isSingleBigMonkey;

+ (instancetype)privateMessageWithObj:(id)obj andFriend:(User *)curFriend;

- (NSString *)toSendPath;
- (NSDictionary *)toSendParams;

- (NSString *)toDeletePath;

@end

@interface VoiceMedia : NSObject

@property (nonatomic, strong) NSString *file;
@property (nonatomic, assign) NSTimeInterval duration;

@end



@interface CodingTips : NSObject
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow, *unreadCount;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSMutableArray *list;
@property (assign, nonatomic) NSInteger type;
@property (assign, nonatomic) BOOL onlyUnread;

+(CodingTips *)codingTipsWithType:(NSInteger)type;
- (NSString *)toTipsPath;
- (NSDictionary *)toTipsParams;
- (void)configWithObj:(CodingTips *)tips;

- (NSDictionary *)toMarkReadParams;

@end

@class HtmlMediaItem;
@interface CodingTip : NSObject

@property (readwrite, nonatomic, strong) NSNumber *status;
@property (strong, nonatomic) NSNumber *id;
@property (readwrite, nonatomic, strong) NSDate *created_at;
@property (readwrite, nonatomic, strong) NSString *content, *target_type;
@property (readwrite, nonatomic, strong) HtmlMedia *htmlMedia;

@property (strong, nonatomic) HtmlMediaItem *target_item, *user_item;
@property (strong, nonatomic) NSString *target_type_imageName, *target_type_ColorName;
@end
