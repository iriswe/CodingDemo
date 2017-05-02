//
//  CodingModel.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/1.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "CodingModel.h"

@implementation CodingModel

@end

#pragma mark - Register
@implementation Register

- (instancetype)init
{
    if (self = [super init]) {
        self.email = @"";
        self.global_key = @"";
    }
    return self;
}
- (NSDictionary *)toParams
{
    return @{@"email" : self.email,
             @"global_key" : self.global_key,
             @"j_captcha" : _j_captcha? _j_captcha: @"",
             @"channel" : [Register channel]};
}

+ (NSString *)channel
{
    return @"coding-ios";
}

@end

#pragma mark - User

@implementation User

- (NSString *)company
{
    if (_company && _company.length > 0) {
        return _company;
    } else {
        return @"未填写";
    }
}

- (NSString *)job_str{
    if (_job_str && _job_str.length > 0) {
        return _job_str;
    }else{
        return @"未填写";
    }
}
- (NSString *)location{
    if (_location && _location.length > 0) {
        return _location;
    }else{
        return @"未填写";
    }
}
- (NSString *)tags_str{
    if (_tags_str && _tags_str.length > 0) {
        return _tags_str;
    }else{
        return @"未添加";
    }
}
- (NSString *)slogan{
    if (_slogan && _slogan.length > 0) {
        return _slogan;
    }else{
        return @"未填写";
    }
}

- (void)setName:(NSString *)name{
    _name = name;
    if (_name) {
        _pinyinName = [_name transformToPinyin];
    }
}

- (NSString *)pinyinName{
    if (!_pinyinName) {
        return @"";
    }
    return _pinyinName;
}

+ (User *)userWithGlobalKey:(NSString *)global_key{
    User *curUser = [[User alloc] init];
    curUser.global_key = global_key;
    return curUser;
}
- (BOOL)isSameToUser:(User *)user{
    if (!user) {
        return NO;
    }
    return ((self.id && user.id && self.id.integerValue == user.id.integerValue)
            || (self.global_key && user.global_key && [self.global_key isEqualToString:user.global_key]));
}
- (NSString *)toUserInfoPath{
    return [NSString stringWithFormat:@"api/user/key/%@", _global_key];
}

- (NSString *)toResetPasswordPath{
    return @"api/user/updatePassword";
}

- (NSDictionary *)toResetPasswordParams{
    return @{@"current_password" : [self.curPassword sha1Str],
             @"password" : [self.resetPassword sha1Str],
             @"confirm_password" : [self.resetPasswordConfirm sha1Str]};
}

- (NSString *)toFllowedOrNotPath{
    NSString *path;
    path = _followed.boolValue ? @"api/user/unfollow" : @"api/user/follow";
    return path;
}
- (NSDictionary *)toFllowedOrNotParams{
    NSDictionary *dict;
    if (_global_key) {
        dict = @{@"users" : _global_key};
    }else if (_id){
        dict = @{@"users" : _id};
    }
    return dict;
}

- (NSString *)toUpdateInfoPath{
    return @"api/user/updateInfo";
}
- (NSDictionary *)toUpdateInfoParams{
    return @{@"id" : _id,
             @"email" : _email? _email: @"",
             @"global_key" : _global_key? _global_key: @"",
             //             暂时没用到
             //             @"introduction" : _introduction,
             //             @"phone" : _phone,
             //             /static/fruit_avatar/Fruit-20.png
             @"lavatar" : _avatar? _avatar: [NSString stringWithFormat:@"/static/fruit_avatar/Fruit-%d.png", (rand()%20)+1],
             @"name" : _name? _name: @"",
             @"sex" : _sex? _sex: [NSNumber numberWithInteger:2],
             @"birthday" : _birthday? _birthday: @"",
             @"location" : _location? _location: @"",
             @"slogan" : _slogan? _slogan: @"",
             @"company" : _company? _company: @"",
             @"job" : _job? _job: [NSNumber numberWithInteger:0],
             @"tags" : _tags? _tags: @""};
}
- (NSString *)toDeleteConversationPath{
    return [NSString stringWithFormat:@"api/message/conversations/%@", self.id.stringValue];
}
- (NSString *)localFriendsPath{
    return @"FriendsPath";
}

- (NSString *)changePasswordTips{
    NSString *tipStr = nil;
    if (!self.curPassword || self.curPassword.length <= 0){
        tipStr = @"请输入当前密码";
    }else if (!self.resetPassword || self.resetPassword.length <= 0){
        tipStr = @"请输入新密码";
    }else if (!self.resetPasswordConfirm || self.resetPasswordConfirm.length <= 0) {
        tipStr = @"请确认新密码";
    }else if (![self.resetPassword isEqualToString:self.resetPasswordConfirm]){
        tipStr = @"两次输入的密码不一致";
    }else if (self.resetPassword.length < 6){
        tipStr = @"新密码不能少于6位";
    }else if (self.resetPassword.length > 64){
        tipStr = @"新密码不得长于64位";
    }
    return tipStr;
}


@end

@implementation Users

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"User", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:9999];
    }
    return self;
}

+(Users *)usersWithOwner:(User *)owner Type:(UsersType)type{
    Users *users = [[Users alloc] init];
    users.owner = owner;
    users.type = type;
    return users;
}

+(Users *)usersWithProjectOwner:(NSString *)owner_name projectName:(NSString *)name Type:(UsersType)type{
    Users *users = [[Users alloc] init];
    users.project_owner_name = owner_name;
    users.project_name = name;
    users.type = type;
    return users;
}

- (NSString *)toPath{
    NSString *path;
    if (_type == UsersTypeFollowers) {
        path = @"api/user/followers";
    }else if (_type == UsersTypeFriends_Message || _type == UsersTypeFriends_Attentive || _type == UsersTypeFriends_At || _type == UsersTypeFriends_Transpond){
        path = @"api/user/friends";
    }
    if (_owner && _owner.global_key) {
        path = [path stringByAppendingFormat:@"/%@", _owner.global_key];
    }
    if (_type == UsersTypeProjectStar) {
        path = [NSString stringWithFormat:@"api/user/%@/project/%@/stargazers", _project_owner_name, _project_name];
    }else if (_type == UsersTypeProjectWatch){
        path = [NSString stringWithFormat:@"api/user/%@/project/%@/watchers", _project_owner_name, _project_name];
    }
    return path;
}

- (NSDictionary *)toParams{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue+1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}

- (void)configWithObj:(Users *)resultA{
    if ([resultA isKindOfClass:[Users class]]) {
        self.page = resultA.page;
        self.pageSize = resultA.pageSize;
        self.totalPage = resultA.totalPage;
        self.totalRow = resultA.totalRow;
        if (_willLoadMore) {
            [self.list addObjectsFromArray:resultA.list];
        }else{
            self.list = [NSMutableArray arrayWithArray:resultA.list];
        }
        self.canLoadMore = self.page.intValue < self.totalPage.intValue;
    }else if ([resultA isKindOfClass:[NSArray class]]){
        self.list = [(NSArray *)resultA mutableCopy];
        self.canLoadMore = NO;
    }
}

- (NSDictionary *)dictGroupedByPinyin{
    if (self.list.count <= 0) {
        return @{@"#" : [NSMutableArray array]};
    }
    
    NSMutableDictionary *groupedDict = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *allKeys = [[NSMutableArray alloc] init];
    for (char c = 'A'; c < 'Z'+1; c++) {
        char key[2];
        key[0] = c;
        key[1] = '\0';
        [allKeys addObject:[NSString stringWithUTF8String:key]];
    }
    [allKeys addObject:@"#"];
    
    for (NSString *keyStr in allKeys) {
        [groupedDict setObject:[[NSMutableArray alloc] init] forKey:keyStr];
    }
    
    [self.list enumerateObjectsUsingBlock:^(User *obj, NSUInteger idx, BOOL *stop) {
        NSString *keyStr = nil;
        NSMutableArray *dataList = nil;
        
        if (obj.pinyinName.length > 1) {
            keyStr = [obj.pinyinName substringToIndex:1];
            if ([[groupedDict allKeys] containsObject:keyStr]) {
                dataList = [groupedDict objectForKey:keyStr];
            }
        }
        
        if (!dataList) {
            keyStr = @"#";
            dataList = [groupedDict objectForKey:keyStr];
        }
        
        [dataList addObject:obj];
        [groupedDict setObject:dataList forKey:keyStr];
    }];
    
    for (NSString *keyStr in allKeys) {
        NSMutableArray *dataList = [groupedDict objectForKey:keyStr];
        if (dataList.count <= 0) {
            [groupedDict removeObjectForKey:keyStr];
        }else if (dataList.count > 1){
            [dataList sortUsingComparator:^NSComparisonResult(User *obj1, User *obj2) {
                return [obj1.pinyinName compare:obj2.pinyinName];
            }];
        }
    }
    
    return groupedDict;
}


@end


#pragma mark - Login
#define kLoginStatus @"login_status"
#define kLoginPreUserEmail @"pre_user_email"
#define kLoginUserDict @"user_dict"
#define kLoginDataListPath @"login_data_list_path.plist"

static User *curLoginUser;

@implementation Login
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.remember_me = [NSNumber numberWithBool:YES];
        self.email = @"";
        self.password = @"";
    }
    return self;
}

- (NSString *)toPath{
    return @"api/v2/account/login";
}

- (NSDictionary *)toParams{
    NSMutableDictionary *params = @{@"account": self.email,
                                    @"password" : [self.password sha1Str],
                                    @"remember_me" : self.remember_me? @"true" : @"false"}.mutableCopy;
    if (self.j_captcha.length > 0) {
        params[@"j_captcha"] = self.j_captcha;
    }
    return params;
}

+ (User *)curLoginUser{
    if (!curLoginUser) {
        NSDictionary *loginData = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginUserDict];
        curLoginUser = loginData? [NSObject objectOfClass:@"User" fromJSON:loginData]: nil;
    }
    return curLoginUser;
}

+ (BOOL)isLogin
{
    NSNumber *loginStatus = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginStatus];
    if ([loginStatus boolValue] && [Login curLoginUser]) {
        User *loginUser = [Login curLoginUser];
      if (loginUser.status && loginUser.status.integerValue == 0) {
        return NO;
    }
    return YES;
} else {
    return NO;
}
}
+ (void)doLogin:(NSDictionary *)loginData
{
    if (loginData) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSNumber numberWithBool:YES] forKey:kLoginStatus];
        [defaults setObject:loginData forKey:kLoginUserDict];
        curLoginUser = [NSObject objectOfClass:@"User" fromJSON:loginData] ;
        [defaults synchronize];
        
//        [Login setXGAccountWithCurUser];
        [self saveLoginData:loginData];

    } else {
        [self doLogout];
    }
}

+ (BOOL)saveLoginData:(NSDictionary *)data
{
    BOOL save = NO;
    if (data) {
        NSMutableDictionary *loginDataList = [self readLoginDataList];
        User *curUser = [NSObject objectOfClass:@"User" fromJSON:data];
        if (curUser.global_key.length > 0) {
            [loginDataList setObject:data forKey:curUser.global_key];
            save = YES;
        }
        if (curUser.email.length > 0) {
            [loginDataList setObject:data forKey:curUser.email];
            save = YES;
        }
        if (curUser.phone.length > 0) {
            [loginDataList setObject:data forKey:curUser.phone];
            save = YES;
        }
        if (save) {
            save = [loginDataList writeToFile:[self loginDataListPath] atomically:YES];
        }
    }
    return save;
}

+ (NSMutableDictionary *)readLoginDataList
{
    NSMutableDictionary *loginDatalist = [NSMutableDictionary dictionaryWithContentsOfFile:[self loginDataListPath]];
    if (!loginDatalist) {
        loginDatalist = [NSMutableDictionary dictionary];
    }
    return loginDatalist;
}

+ (NSString *)loginDataListPath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentPath stringByAppendingString:kLoginDataListPath];
}

+ (void) doLogout
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:NO] forKey:kLoginStatus];
    [defaults synchronize];
    //删掉 coding 的 cookie
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.domain hasSuffix:@".coding.net"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:obj];
        }
    }];
//    [Login setXGAccountWithCurUser];

}

+ (void)setPreUserEmail:(NSString *)emailStr{
    if (emailStr.length <= 0) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:emailStr forKey:kLoginPreUserEmail];
    [defaults synchronize];
}

+ (NSString *)preUserEmail{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:kLoginPreUserEmail];
}
+ (User *)userWithGlobaykeyOrEmail:(NSString *)textStr{
    if (textStr.length <= 0) {
        return nil;
    }
    NSMutableDictionary *loginDataList = [self readLoginDataList];
    NSDictionary *loginData = [loginDataList objectForKey:textStr];
    return [NSObject objectOfClass:@"User" fromJSON:loginData];
}

- (NSString *)goToLoginTipWithCaptcha:(BOOL)needCaptcha{
    if (!_email || _email.length <= 0) {
        return @"请填写「手机号码/电子邮箱/个性后缀」";
    }
    if (!_password || _password.length <= 0) {
        return @"请填写密码";
    }
    if (needCaptcha && (!_j_captcha || _j_captcha.length <= 0)) {
        return @"请填写验证码";
    }
    return nil;
}

+(BOOL)isLoginUserGlobalKey:(NSString *)global_key{
    if (global_key.length <= 0) {
        return NO;
    }
    return [[self curLoginUser].global_key isEqualToString:global_key];
}
@end

#pragma mark - Project

#pragma mark - ProjectCount

@implementation ProjectCount
- (void)configWithProjects:(ProjectCount *)ProjectCount
{
    self.all = ProjectCount.all;
    self.watched = ProjectCount.watched;
    self.created = ProjectCount.created;
    self.joined = ProjectCount.joined;
    self.stared = ProjectCount.stared;
    self.deploy = ProjectCount.deploy;
}

@end

#pragma mark Projects

@implementation Projects
- (instancetype)init
{
    self = [super init];
    if (self) {
        _canLoadMore = NO;
        _isLoading = NO;
        _willLoadMore = NO;
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Project", @"list", nil];
    }
    return self;
}

+ (Projects *)projectsWithType:(ProjectsType)type andUser:(User *)user{
    Projects *pros = [[Projects alloc] init];
    pros.type = type;
    pros.curUser = user;
    
    pros.page = [NSNumber numberWithInteger:1];
    pros.pageSize = [NSNumber numberWithInteger:9999];
    return pros;
}

- (NSDictionary *)toParams
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"page": [NSNumber numberWithInteger:_willLoadMore? self.page.integerValue + 1: 1], @"pageSize": self.pageSize, @"type" : [self typeStr]}];
    if (self.type == ProjectsTypeAll) {
        [params setObject:@"hot" forKey:@"sort"];
    }
    return params;
}

- (NSString *)typeStr
{
    NSString *typeStr;
    switch (_type) {
        case  ProjectsTypeAll:
        case  ProjectsTypeToChoose:
            typeStr = @"all";
            break;
        case  ProjectsTypeJoined:
            typeStr = @"joined";
            break;
        case  ProjectsTypeCreated:
            typeStr = @"created";
            break;
        case  ProjectsTypeTaProject:
            typeStr = @"project";
            break;
        case  ProjectsTypeTaStared:
            typeStr = @"stared";
            break;
        case  ProjectsTypeTaWatched:
            typeStr = @"watched";
            break;
        case  ProjectsTypeWatched:
            typeStr = @"watched";
            break;
        case  ProjectsTypeStared:
            typeStr = @"stared";
            break;
        default:
            typeStr = @"all";
            break;
    }
    return typeStr;
}

- (NSString *)toPath{
    NSString *path;
    if (self.type == ProjectsTypeAllPublic) {
        path = @"api/public/all";
    }else if (self.type >= ProjectsTypeTaProject && self.type < ProjectsTypeAllPublic) {
        path = [NSString stringWithFormat:@"api/user/%@/public_projects", _curUser.global_key];
    }else{
        path = @"api/projects";
    }
    return path;
}

- (void)configWithProjects:(Projects *)responsePros{
    self.page = responsePros.page;
    self.totalRow = responsePros.totalRow;
    self.totalPage = responsePros.totalPage;
    self.canLoadMore = (self.page.integerValue < self.totalPage.integerValue);
    
    NSArray *projectList = responsePros.list;
    if (self.type == ProjectsTypeToChoose) {
        projectList = [projectList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"is_public == %d", NO]];
    }
    if (!projectList) {
        return;
    }
    
    if (_willLoadMore) {
        [self.list addObjectsFromArray:projectList];
    }else{
        self.list = [NSMutableArray arrayWithArray:projectList];
    }
}
- (NSArray *)pinList{
    NSArray *list = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pin.intValue == 1"];
    list = [self.list filteredArrayUsingPredicate:predicate];
    return list;
}
- (NSArray *)noPinList{
    NSArray *list = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pin.intValue == 0"];
    list = [self.list filteredArrayUsingPredicate:predicate];
    return list;
}


@end

#pragma mark Project
@implementation Project
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isStaring = _isWatching = _isLoadingMember = _isLoadingDetail = NO;
        _recommended = [NSNumber numberWithInteger:0];
    }
    return self;
}

- (void)setBackend_project_path:(NSString *)backend_project_path{
    if ([backend_project_path hasPrefix:@"/team/"]) {
        backend_project_path = [backend_project_path stringByReplacingOccurrencesOfString:@"/team/" withString:@"/user/"];
    }
    _backend_project_path = backend_project_path;
}

- (void)setFull_name:(NSString *)full_name
{
    _full_name = full_name;
    NSArray *components = [_full_name componentsSeparatedByString:@"/"];
    if (components.count == 2) {
        if (!_owner_user_name) {
            _owner_user_name = components[0];
        }
        if (_name) {
            _name = components[1];
        }
    }
}

+ (Project *)project_All
{
    Project *p = [[Project alloc] init];
    p.id = [NSNumber numberWithInteger:-1];
    return p;
}


+ (Project *)project_FeedBack
{
    Project *p = [[Project alloc] init];
    p.id = [NSNumber numberWithInteger:38894];
    p.is_public = [NSNumber numberWithBool:YES];
    return p;
}

-(NSString *)toProjectPath{
    return @"api/project";
}

-(NSDictionary *)toCreateParams{
    
    NSString *type;
    if ([self.is_public isEqual:@YES]) {
        type = @"1";
    }else{
        type = @"2";
    }
    
    return @{@"name":self.name,
             @"description":self.description_mine,
             @"type":type,
             @"gitEnabled":@"true",
             @"gitReadmeEnabled": _gitReadmeEnabled.boolValue? @"true": @"false",
             @"gitIgnore":@"no",
             @"gitLicense":@"no",
             //             @"importFrom":@"no",
             @"vcsType":@"git"};
}

-(NSString *)toUpdatePath{
    return [self toProjectPath];
}

-(NSDictionary *)toUpdateParams{
    return @{@"name":self.name,
             @"description":self.description_mine,
             @"id":self.id
             //             @"default_branch":[NSNull null]
             };
}

-(NSString *)toUpdateIconPath{
    return [NSString stringWithFormat:@"api/project/%@/project_icon",self.id];
}

-(NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/user/%@/project/%@",self.owner_user_name, self.name];
}

- (NSString *)toMembersPath{
    if ([_id isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"api/project/%d/members", self.id.intValue];
    }else{
        return [NSString stringWithFormat:@"api/user/%@/project/%@/members", _owner_user_name, _name];
    }
}
- (NSDictionary *)toMembersParams{
    return @{@"page" : [NSNumber numberWithInteger:1],
             @"pageSize" : [NSNumber numberWithInteger:500]};
}
- (NSString *)toUpdateVisitPath{
    if (self.owner_user_name.length > 0 && self.name.length > 0) {
        return [NSString stringWithFormat:@"api/user/%@/project/%@/update_visit", self.owner_user_name, self.name];
    }else{
        return [NSString stringWithFormat:@"api/project/%d/update_visit", self.id.intValue];
    }
}
- (NSString *)toDetailPath{
    return [NSString stringWithFormat:@"api/user/%@/project/%@", self.owner_user_name, self.name];
}
- (NSString *)localMembersPath{
    return [NSString stringWithFormat:@"%@_MembersPath", self.id.stringValue];
}

- (NSString *)toBranchOrTagPath:(NSString *)path{
    return [NSString stringWithFormat:@"api/user/%@/project/%@/git/%@", self.owner_user_name, self.name, path];
}


@end

#pragma mark ProjectMember
@implementation ProjectMember
+ (ProjectMember *)member_All{
    ProjectMember *mem = [[ProjectMember alloc] init];
    mem.user_id = [NSNumber numberWithInteger:-1];
    mem.user = nil;
    return mem;
}
- (NSString *)editAlias{
    if (!_editAlias) {
        _editAlias = _alias ?: @"";
    }
    return _editAlias;
}
- (NSNumber *)editType{
    if (!_editType) {
        _editType = _type;
    }
    return _editType;
}
- (NSString *)toQuitPath{
    return [NSString stringWithFormat:@"api/project/%d/quit", _project_id.intValue];
}
- (NSString *)toKickoutPath{
    return [NSString stringWithFormat:@"api/project/%@/kickout/%@", _project_id.stringValue, _user_id.stringValue];
}
@end

#pragma mark ProjectActivities

@implementation ProjectActivities

- (instancetype)init
{
    self = [super init];
    if (self) {
        _listGroups = [[NSMutableArray alloc] init];
        _list = [[NSMutableArray alloc] init];
        _canLoadMore = YES;
        _willLoadMore = _isLoading = NO;
        _last_id = kDefaultLastId;
    }
    return self;
}

+ (ProjectActivities *)proActivitiesWithPro:(Project *)project type:(ProjectActivityType)type{
    ProjectActivities *proActs = [[ProjectActivities alloc] init];
    
    proActs.isOfUser = NO;
    
    proActs.curProject = project;
    proActs.project_id = project.id;
    
    proActs.curUser = nil;
    proActs.user_id = project.owner_id;
    
    switch (type) {
        case ProjectActivityTypeAll:
            proActs.type = @"all";
            break;
        case ProjectActivityTypeTask:
            proActs.type = @"task";
            break;
        case ProjectActivityTypeTopic:
            proActs.type = @"topic";
            break;
        case ProjectActivityTypeFile:
            proActs.type = @"file";
            break;
        case ProjectActivityTypeCode:
            proActs.type = @"code";
            break;
        case ProjectActivityTypeOther:
            proActs.type = @"other";
            break;
        default:
            proActs.type = @"all";
            break;
    }
    return proActs;
}

+ (ProjectActivities *)proActivitiesWithPro:(Project *)project user:(User *)user{
    ProjectActivities *proActs = [[ProjectActivities alloc] init];
    
    proActs.isOfUser = YES;
    
    proActs.curProject = project;
    proActs.project_id = project.id;
    
    proActs.curUser = user;
    proActs.user_id = user.id;
    proActs.type = @"user";
    
    return proActs;
}


- (NSString *)toPath{
    NSString *path;
    if (_isOfUser) {
        path = [self toPathOfUser];
    }else{
        path = [self toPathOfType];
    }
    return path;
}
- (NSDictionary *)toParams{
    NSDictionary *params;
    if (_isOfUser) {
        params = [self toParamsOfUser];
    }else{
        params = [self toParamsOfType];
    }
    return params;
}
- (NSString *)toPathOfType{
    return [NSString stringWithFormat:@"api/project/%@/activities", _project_id.stringValue];
}
- (NSDictionary *)toParamsOfType{
    return @{@"last_id" : _willLoadMore? self.last_id:kDefaultLastId,
             @"user_id" : self.user_id,
             @"type" : self.type};
}
- (NSString *)toPathOfUser{
    return [NSString stringWithFormat:@"api/project/%@/activities/user/%@", _project_id.stringValue, _user_id.stringValue];
}
- (NSDictionary *)toParamsOfUser{
    return @{@"last_id" : _willLoadMore? self.last_id:kDefaultLastId};
}

- (void)configWithProActList:(NSArray *)responseA{
    if (responseA && [responseA count] > 0) {
        self.canLoadMore = YES;
        ProjectActivity *lastProAct = [responseA lastObject];
        self.last_id = lastProAct.id;
        
        
        if (self.willLoadMore) {
            [_list addObjectsFromArray:responseA];
        }else{
            self.list = [NSMutableArray arrayWithArray:responseA];
        }
        [self refreshListGroupWithArray:responseA isAdd:self.willLoadMore];
    }else{
        self.canLoadMore = NO;
    }
}

- (void)refreshListGroupWithArray:(NSArray *)responseA isAdd:(BOOL)isAdd{
    if (!isAdd) {
        [_listGroups removeAllObjects];
    }
    for (NSUInteger i = 0; i< [responseA count]; i++) {
        ProjectActivity *curProAct = [responseA objectAtIndex:i];
        NSUInteger location = [_list indexOfObject:curProAct];
        if (location != NSNotFound) {
            ListGroupItem *item = _listGroups.lastObject;
            if (item && [item.date isSameDay:curProAct.created_at]) {
                [item addOneItem];
            }else{
                item = [ListGroupItem itemWithDate:curProAct.created_at andLocation:location];
                [item addOneItem];
                [_listGroups addObject:item];
            }
        }
    }
}
@end
#pragma mark ProjectActivity
@implementation ProjectActivity
@synthesize actionStr = _actionStr, contentStr = _contentStr;
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = @{@"commits": @"Commit",
                              @"labels": @"ProjectTag",
                              };
        _actionMediaItems = [[NSMutableArray alloc] init];
        _contentMediaItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setComment_content:(NSString *)comment_content{
    if (comment_content) {
        _comment_content = [comment_content stringByRemoveHtmlTag];
    }else{
        _comment_content = @"";
    }
}

- (NSString *)ref_type{
    if ([_ref_type isEqualToString:@"tag"]) {
        return @"标签";
    }else if ([_ref_type isEqualToString:@"branch"]){
        return @"分支";
    }else{
        return _ref_type;
    }
}

- (void)addActionUser:(User *)curUser{
    if (curUser) {
        [_actionStr appendString:@" "];
        [HtmlMedia addMediaItemUser:curUser toString:_actionStr andMediaItems:_actionMediaItems];
        [_actionStr appendString:@" "];
    }
}

//- (void)addActionLinkStr:(NSString *)linkStr{
//    [HtmlMedia addLinkStr:linkStr type:HtmlMediaItemType_CustomLink toString:_actionStr andMediaItems:_actionMediaItems];
//}

//- (void)addContentLinkStr:(NSString *)linkStr{
//    if (linkStr.length > 0) {
//        [_contentStr appendString:@" "];
//        [HtmlMedia addLinkStr:linkStr type:HtmlMediaItemType_CustomLink toString:_contentStr andMediaItems:_contentMediaItems];
//        [_contentStr appendString:@" "];
//    }
//}

- (NSMutableString *)actionStr{
    if (!_actionStr) {
        _actionStr = [[NSMutableString alloc] init];
        if ([_target_type isEqualToString:@"ProjectMember"]) {
            if ([_action isEqualToString:@"quit"]) {
                [self addActionUser:_target_user];
                [_actionStr appendFormat:@"%@项目", _action_msg];
            }else{
                [self addActionUser:_user];
                [_actionStr appendFormat:@"%@项目成员", _action_msg];
            }
        }else if ([_target_type isEqualToString:@"Task"]){
            [self addActionUser:_user];
            if ([_action isEqualToString:@"update_priority"]) {
                [_actionStr appendFormat:@"更新了任务「%@」的优先级", _task.title];
            }else if ([_action isEqualToString:@"update_deadline"]) {
                if (_task.deadline && _task.deadline.length > 0) {
                    [_actionStr appendFormat:@"更新了任务「%@」的截止日期", _task.title];
                }else{
                    [_actionStr appendFormat:@"移除了任务「%@」的截止日期", _task.title];
                }
            }else if ([_action isEqualToString:@"update_description"]) {
                [_actionStr appendFormat:@"更新了任务「%@」的描述", _task.title];
            }else{
                [_actionStr saveAppendString:_action_msg];
                if (_origin_task.owner) {
                    [self addActionUser:_origin_task.owner];
                    [_actionStr appendString:@"的"];
                }
                [_actionStr appendString:@"任务"];
                
                if ([_action isEqualToString:@"reassign"]) {
                    [_actionStr appendString:@"给"];
                    [self addActionUser:_task.owner];
                }
            }
        }else if ([_target_type isEqualToString:@"TaskComment"]){
            [self addActionUser:_user];
            [_actionStr appendFormat:@"%@任务「%@」的评论", _action_msg, _task.title];
        }else if ([_target_type isEqualToString:@"Project"] && [_action isEqualToString:@"transfer"]){
            [self addActionUser:_user];
            [_actionStr appendFormat:@"将项目「%@」%@", _project.full_name, _action_msg];
            [self addActionUser:_target_user];
        }else{
            [self addActionUser:_user];
            [_actionStr saveAppendString:_action_msg];
            if ([_target_type isEqualToString:@"ProjectTopic"]){
                [_actionStr appendString:@"讨论"];
                if ([_action isEqualToString:@"comment"]) {
                    [_actionStr appendFormat:@"「%@」", _project_topic.parent.title];
                }
            }else if ([_target_type isEqualToString:@"ProjectFile"]){
                [_actionStr appendString:[_type isEqualToString:@"dir"]? @"文件夹": @"文件"];
            }else if ([_target_type isEqualToString:@"ProjectFileComment"]){
                [_actionStr appendFormat:@"文件「%@」的评论", _projectFile.title];
            }else if ([_target_type isEqualToString:@"Depot"]){
                if ([_action isEqualToString:@"push"]) {
                    [_actionStr appendFormat:@"项目 %@ 「%@」", self.ref_type, _ref];
                }else if ([_action isEqualToString:@"fork"]){
                    [_actionStr appendFormat:@"项目「%@」到 「%@」", _source_depot.name, _depot.name];
                }
            }else{
                [_actionStr appendString:@"项目"];
                if ([_target_type isEqualToString:@"Project"]){
                }else if ([_target_type isEqualToString:@"QcTask"]){
                    [_actionStr appendFormat:@"「%@」的质量分析任务", _project.full_name];
                }else if ([_target_type isEqualToString:@"ProjectStar"]){
                    [_actionStr appendFormat:@"「%@」", _project.full_name];
                }else if ([_target_type isEqualToString:@"ProjectWatcher"]){
                    [_actionStr appendFormat:@"「%@」", _project.full_name];
                }else if ([_target_type isEqualToString:@"PullRequestBean"]){
                    [_actionStr appendFormat:@"「%@」中的 Pull Request", _depot.name];
                }else if ([_target_type isEqualToString:@"PullRequestComment"]){
                    [_actionStr appendFormat:@"「%@」中的 Pull Request 「%@」", _depot.name, _pull_request_title];
                }else if ([_target_type isEqualToString:@"MergeRequestBean"]){
                    [_actionStr appendFormat:@"「%@」中的 Merge Request", _depot.name];
                }else if ([_target_type isEqualToString:@"MergeRequestComment"]){
                    [_actionStr appendFormat:@"「%@」中的 Merge Request 「%@」", _depot.name, _merge_request_title];
                }else if ([_target_type isEqualToString:@"CommitLineNote"]){
                    [_actionStr appendFormat:@"「%@」的 %@「%@」", _project.full_name, _line_note.noteable_type, _line_note.noteable_title];
                }
            }
        }
    }
    return _actionStr;
}

- (NSMutableString *)contentStr{
    if (!_contentStr) {
        _contentStr = [[NSMutableString alloc] init];
        
        if ([_target_type isEqualToString:@"Task"]) {
            if ([_action isEqualToString:@"update_priority"]) {
                if (_task.priority && _task.priority.intValue < kTaskPrioritiesDisplay.count) {
                    [_contentStr appendFormat:@"「%@」", kTaskPrioritiesDisplay[_task.priority.intValue]];
                }
            }else if ([_action isEqualToString:@"update_deadline"] && _task.deadline && _task.deadline.length > 0) {
                [_contentStr appendFormat:@"「%@」", [NSDate convertStr_yyyy_MM_ddToDisplay:_task.deadline]];
            }else if ([_action isEqualToString:@"update_description"]) {
                [_contentStr saveAppendString:_task.description_mine];
            }else{
                [_contentStr saveAppendString:_task.title];
            }
        }else if ([_target_type isEqualToString:@"TaskComment"]){
            if (_taskComment.content) {
                [_contentStr saveAppendString:_taskComment.content];
            }
        }else if ([_target_type isEqualToString:@"ProjectTopic"]){
            if ([_action isEqualToString:@"comment"]) {
                [_contentStr saveAppendString:_project_topic.content];
            }else{
                [_contentStr saveAppendString:_project_topic.title];
            }
        }else if ([_target_type isEqualToString:@"ProjectFile"]){
            [_contentStr saveAppendString:_file.name];
        }else if ([_target_type isEqualToString:@"ProjectFileComment"]){
            [_contentStr saveAppendString:_projectFileComment.content];
        }else if ([_target_type isEqualToString:@"Depot"]){
            if (_commits && [_commits count] > 0) {
                Commit *curCommit = _commits.firstObject;
                [_contentStr saveAppendString:curCommit.contentStr];
                for (int i = 1; i<[_commits count]; i++) {
                    curCommit = [_commits objectAtIndex:i];
                    [_contentStr appendFormat:@"\n%@",curCommit.contentStr];
                }
            }
        }else{
            if ([_target_type isEqualToString:@"ProjectMember"]) {
                if ([_action isEqualToString:@"quit"]) {
                    [_contentStr saveAppendString:_project.full_name];
                }else{
                    [_contentStr saveAppendString:_target_user.name];
                }
            }else if ([_target_type isEqualToString:@"Project"]){
                [_contentStr saveAppendString:_project.full_name];
            }else if ([_target_type isEqualToString:@"QcTask"]){
                [_contentStr saveAppendString:_qc_task.link];
            }else if ([_target_type isEqualToString:@"ProjectStar"]){
                [_contentStr saveAppendString:_project.full_name];
            }else if ([_target_type isEqualToString:@"ProjectWatcher"]){
                [_contentStr saveAppendString:_project.full_name];
            }else if ([_target_type isEqualToString:@"PullRequestBean"]){
                [_contentStr saveAppendString:_pull_request_title];
            }else if ([_target_type isEqualToString:@"PullRequestComment"]){
                [_contentStr saveAppendString:_comment_content];
            }else if ([_target_type isEqualToString:@"MergeRequestBean"]){
                [_contentStr saveAppendString:_merge_request_title];
            }else if ([_target_type isEqualToString:@"MergeRequestComment"]){
                [_contentStr saveAppendString:_comment_content];
            }else if ([_target_type isEqualToString:@"CommitLineNote"]){
                [_contentStr appendFormat:@"%@", _line_note.content];
            }else{
                [_contentStr appendString:@"**未知**"];
            }
        }
    }
    return _contentStr;
}
@end

#pragma mark - Task


@implementation Tasks
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Task", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _type = TaskQueryTypeAll;//processing.done
    }
    return self;
}

+ (Tasks *)tasksWithPro:(Project *)project owner:(User *)owner queryType:(TaskQueryType)type{
    Tasks *tasks = [[Tasks alloc] init];
    tasks.owner = owner;
    tasks.backend_project_path = project.backend_project_path;
    tasks.type = type;
    tasks.entranceType = TaskEntranceTypeProject;
    return tasks;
}
+ (Tasks *)tasksWithPro:(Project *)project queryType:(TaskQueryType)type{
    Tasks *tasks = [[Tasks alloc] init];
    tasks.project = project;
    tasks.type = type;
    tasks.entranceType = TaskEntranceTypeMine;
    return tasks;
}

- (NSString *)queryType{
    NSString *queryType;
    switch (_type) {
        case TaskQueryTypeAll:
            queryType = @"all";
            break;
        case TaskQueryTypeProcessing:
            queryType = @"processing";
            break;
        case TaskQueryTypeDone:
            queryType = @"done";
            break;
        default:
            queryType = @"all";
            break;
    }
    return queryType;
}

- (NSDictionary *)toParams{
    if (_entranceType == TaskEntranceTypeProject) {
        return [self toParams_Project];
    }else{
        return [self toParams_Mine];
    }
}

- (NSString *)toRequestPath{
    if (_entranceType == TaskEntranceTypeProject) {
        return [self toRequestPath_Project];
    }else{
        return [self toRequestPath_Mine];
    }
}


- (NSDictionary *)toParams_Project{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue +1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}
- (NSString *)toRequestPath_Project{
    NSString *path;
    if (!_owner || !_owner.global_key) {
        path = [NSString stringWithFormat:@"api%@/tasks/%@", self.backend_project_path, self.queryType];
    }else{
        path = [NSString stringWithFormat:@"api%@/tasks/user/%@/%@", self.backend_project_path, _owner.global_key, self.queryType];
    }
    return path;
}

- (NSDictionary *)toParams_Mine{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue +1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}
- (NSString *)toRequestPath_Mine{
    NSString *path;
    if (_project && _project.id.intValue != -1) {
        path = [NSString stringWithFormat:@"api/tasks/project/%d/%@", _project.id.intValue, self.queryType];
    }else{
        path = [NSString stringWithFormat:@"api/tasks/%@", self.queryType];
    }
    return path;
}

- (void)configWithTasks:(Tasks *)resultA{
    self.page = resultA.page;
    self.totalPage = resultA.totalPage;
    self.totalRow = resultA.totalRow;
    
    if (_willLoadMore) {
        [self.list addObjectsFromArray:resultA.list];
    }else{
        self.list = [NSMutableArray arrayWithArray:resultA.list];
    }
    
    self.canLoadMore = self.page.intValue < self.totalPage.intValue;
    
    if (_list.count > 0) {
        NSPredicate *donePredicate = [NSPredicate predicateWithFormat:@"status.intValue == %d", 2];
        NSPredicate *processingPredicate = [NSPredicate predicateWithFormat:@"status.intValue == %d", 1];
        _doneList = [self.list filteredArrayUsingPredicate:donePredicate];
        _processingList = [self.list filteredArrayUsingPredicate:processingPredicate];
    }else{
        _doneList = _processingList = nil;
    }
}

@end


@implementation Task
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectTag", @"labels", nil];
        _watchers = @[].mutableCopy;
        
        _handleType = TaskHandleTypeEdit;
        _isRequesting = _isRequestingDetail = _isRequestingCommentList = NO;
        _needRefreshDetail = NO;
    }
    return self;
}
- (void)setOwner:(User *)owner{
    if (owner != _owner) {
        _owner = owner;
        _owner_id = owner.id;
    }
}

- (void)setLabels:(NSMutableArray *)labels{
    //过滤掉服务器传过来的脏数据
    [labels filterUsingPredicate:[NSPredicate predicateWithFormat:@"name.length > 0"]];
    _labels = labels;
}

- (void)setDescription_mine:(NSString *)description_mine{
    if (_description_mine != description_mine) {
        HtmlMedia *htmlMedia = [HtmlMedia htmlMediaWithString:description_mine showType:MediaShowTypeImageAndMonkey];
        _description_mine = htmlMedia.contentDisplay;
    }
}

- (void)setDeadline:(NSString *)deadline{
    _deadline = deadline;
    if (deadline && deadline.length >= 10) {
        _deadline_date = [NSDate dateFromString:deadline withFormat:@"yyyy-MM-dd"];
    }else{
        _deadline_date = nil;
    }
}

+ (Task *)taskWithProject:(Project *)project andUser:(User *)user{
    Task *curTask = [[Task alloc] init];
    curTask.project = project;
    curTask.creator = [Login curLoginUser];
    curTask.owner = user;
    curTask.status = [NSNumber numberWithInt:1];
    curTask.handleType = project != nil? TaskHandleTypeAddWithProject: TaskHandleTypeAddWithoutProject;
    curTask.priority = [NSNumber numberWithInt:1];
    curTask.content = @"";
    curTask.has_description = [NSNumber numberWithBool:NO];
    curTask.task_description = [Task_Description defaultDescription];
    return curTask;
}
+ (Task *)taskWithTask:(Task *)task{
    Task *curTask = [[Task alloc] init];
    [curTask copyDataFrom:task];
    return curTask;
}
+ (Task *)taskWithBackend_project_path:(NSString *)backend_project_path andId:(NSString *)taskId{
    Task *curTask = [[Task alloc] init];
    curTask.backend_project_path = backend_project_path;
    curTask.id = [NSNumber numberWithInteger:taskId.integerValue];
    curTask.needRefreshDetail = YES;
    return curTask;
}
- (BOOL)isSameToTask:(Task *)task{
    if (!task) {
        return NO;
    }
    return ([self.content isEqualToString:task.content]
            && [self.owner.global_key isEqualToString:task.owner.global_key]
            && self.priority.intValue == task.priority.intValue
            && self.status.intValue == task.status.intValue
            && ((!self.deadline && !task.deadline) || [self.deadline isEqualToString:task.deadline])
            && [ProjectTag tags:self.labels isEqualTo:task.labels]
            );
}

- (User *)hasWatcher:(User *)watcher{
    for (User *user in self.watchers) {
        if ([user.id isEqual:watcher.id]) {
            return user;
        }
    }
    return nil;
}

- (void)copyDataFrom:(Task *)task{
    self.id = task.id;
    self.backend_project_path = task.backend_project_path;
    self.project = task.project;
    self.creator = task.creator;
    self.owner = task.owner;
    self.owner_id = task.owner_id;
    self.status = task.status;
    self.content = task.content;
    self.title = task.title;
    self.created_at = task.created_at;
    self.updated_at = task.updated_at;
    self.handleType = task.handleType;
    self.isRequesting = task.isRequesting;
    self.isRequestingDetail = task.isRequestingDetail;
    self.isRequestingCommentList = task.isRequestingCommentList;
    self.priority = task.priority;
    self.comments = task.comments;
    self.needRefreshDetail = task.needRefreshDetail;
    self.deadline = task.deadline;
    self.number = task.number;
    
    self.has_description = task.has_description;
    self.task_description = task.task_description;
    self.labels = [task.labels mutableCopy];
    self.watchers = [task.watchers mutableCopy];
}

//任务状态
- (NSString *)toEditTaskStatusPath{
    return [NSString stringWithFormat:@"api/task/%d/status", self.id.intValue];
}
-(NSDictionary *)toEditStatusParams{
    return @{@"status" : self.status};
}
-(NSDictionary *)toChangeStatusParams{
    NSNumber *status = [NSNumber numberWithInteger:(_status.integerValue != 1? 1 : 2)];
    return @{@"status" : status};
}

//更新任务
- (NSString *)toUpdatePath{
    return [NSString stringWithFormat:@"api/task/%@/update", self.id.stringValue];
}
-(NSDictionary *)toUpdateParamsWithOld:(Task *)oldTask{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //内容
    if (self.content && ![self.content isEqualToString:oldTask.content]) {
        [params setObject:self.content forKey:@"content"];
    }
    //执行者
    if (self.owner_id && self.owner_id.integerValue != oldTask.owner_id.integerValue) {
        [params setObject:self.owner_id forKey:@"owner_id"];
    }
    //优先级
    if (self.priority && self.priority.integerValue != oldTask.priority.integerValue) {
        [params setObject:self.priority forKey:@"priority"];
    }
    //阶段
    if (self.status && self.status.integerValue != oldTask.status.integerValue) {
        [params setObject:self.status forKey:@"status"];
    }
    //截止日期
    if ((oldTask.deadline && self.deadline && ![self.deadline isEqualToString:oldTask.deadline])
        || (!oldTask.deadline && self.deadline)) {
        [params setObject:self.deadline forKey:@"deadline"];
    }else if (oldTask.deadline && !self.deadline){
        [params setObject:@"" forKey:@"deadline"];
    }
    return params;
}

//更新任务描述
- (NSString *)toUpdateDescriptionPath{
    return [NSString stringWithFormat:@"api/task/%d/description", self.id.intValue];
}
//添加新任务
- (NSString *)toAddTaskPath{
    return [NSString stringWithFormat:@"api%@/task", self.backend_project_path];
}
- (NSDictionary *)toAddTaskParams{
    NSMutableDictionary *params = [@{@"content" : [self.content aliasedString],
                                     @"owner_id" : self.owner.id,
                                     @"priority" : self.priority} mutableCopy];
    
    if (self.deadline.length >= 10) {
        params[@"deadline"] = self.deadline;
    }
    if (self.task_description.markdown.length > 0) {
        params[@"description"] = [self.task_description.markdown aliasedString];
    }
    if (self.labels.count > 0) {
        params[@"labels"] = [self.labels valueForKey:@"id"];
    }
    if (self.watchers.count > 0) {
        params[@"watchers"] = [self.watchers valueForKey:@"id"];
    }
    return params;
}
//删除任务
- (NSString *)toDeleteTaskPath{
    return [NSString stringWithFormat:@"api%@/task/%ld", self.backend_project_path, (long)self.id.integerValue];
}

//任务评论列表
- (NSString *)toCommentListPath{
    return [NSString stringWithFormat:@"api/task/%ld/comments", (long)self.id.integerValue];
}
- (NSDictionary *)toCommentListParams{
    return @{@"page" : [NSNumber numberWithInt:1],
             @"pageSize" : [NSNumber numberWithInt:500]};
}

//任务动态列表
- (NSString *)toActivityListPath{
    return [NSString stringWithFormat:@"api/activity/task/%ld", (long)self.id.integerValue];
}

//任务详情
- (NSString *)toTaskDetailPath{
    return [NSString stringWithFormat:@"api%@/task/%ld", self.backend_project_path, (long)self.id.integerValue];
}

//任务描述
- (NSString *)toDescriptionPath{
    return [NSString stringWithFormat:@"api/task/%@/description", self.id.stringValue];
}
//任务关联资源
- (NSString *)toResourceReferencePath{
    return [NSString stringWithFormat:@"api%@/resource_reference/%ld", self.backend_project_path, (long)self.number.integerValue];
}
//任务关注者列表
- (NSString *)toWatchersPath{
    return [NSString stringWithFormat:@"api%@/task/%@/watchers", self.backend_project_path, self.id.stringValue];
}

- (NSString *)backend_project_path{
    if (!_backend_project_path || _backend_project_path.length <= 0) {
        if (self.project && self.project.backend_project_path && self.project.backend_project_path.length > 0) {
            _backend_project_path = self.project.backend_project_path;
        }
    }
    return _backend_project_path;
}
//评论任务
- (NSString *)toDoCommentPath{
    return [NSString stringWithFormat:@"api/task/%ld/comment", (long)self.id.integerValue];
}
- (NSDictionary *)toDoCommentParams{
    if (_nextCommentStr) {
        return @{@"content" : [_nextCommentStr aliasedString]};
    }else{
        return nil;
    }
}

- (NSString *)toEditLabelsPath{
    return [NSString stringWithFormat:@"api%@/task/%@/labels", self.backend_project_path, _id.stringValue];
}

@end

@implementation Task_Description

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.markdown = @"";
        self.description_mine = @"";
    }
    return self;
}

+ (instancetype)defaultDescription{
    return [[Task_Description alloc] init];
}

+ (instancetype)descriptionWithMdStr:(NSString *)mdStr{
    Task_Description *taskD = [Task_Description defaultDescription];
    taskD.markdown = mdStr;
    return taskD;
}

@end

@implementation TaskComment
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeCode];
        _content = _htmlMedia.contentDisplay;
    }
}
@end

@implementation ProjectTopicActivity
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeImageAndMonkey];
        _content = _htmlMedia.contentDisplay;
    }
}
@end

@implementation File

@end

@implementation QcTask

- (NSString *)link{
    return [NSString stringWithFormat:@"[%@]", [_link stringByRemoveHtmlTag]];
}

@end

@implementation Depot

@end

@implementation ProjectLineNoteActivity
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeImageAndMonkey];
        _content = _htmlMedia.contentDisplay;
    }
}

- (NSString *)noteable_type{
    if ([_noteable_type isEqualToString:@"Commit"]) {
        return @"Commit";
    }else if ([_noteable_type isEqualToString:@"MergeRequestBean"]) {
        return @"MergeRequest";
    }else if ([_noteable_type isEqualToString:@"PullRequestBean"]) {
        return @"PullRequest";
    }else {
        return @"(⊙_⊙)?";
    }
}
@end



@implementation Commit
- (NSString *)contentStr{
    NSString *contentStr;
    if (_sha && _sha.length > 0) {
        contentStr = [NSString stringWithFormat:@"%@ : [%@] %@", _committer.name, [_sha substringToIndex:10], _short_message];
    }
    return contentStr;
}

- (void)setShort_message:(NSString *)short_message{
    if (short_message.length <= 0) {
        _short_message = short_message;
        return;
    }
    HtmlMedia *htmlHedia = [HtmlMedia htmlMediaWithString:short_message showType:MediaShowTypeCode];
    _short_message = htmlHedia.contentDisplay;
}

@end

@implementation Committer

@end

@implementation FileComment
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeCode];
        _content = _htmlMedia.contentDisplay;
    }
}
@end

@interface ProjectFile ()
@property (strong, nonatomic) NSString *project_name, *project_owner_name;
@property (strong, nonatomic, readwrite) NSString *diskFileName;
@end

@implementation ProjectFile

-(id)copyWithZone:(NSZone*)zone {
    ProjectFile *file = [[[self class] allocWithZone:zone] init];
    file.project_owner_name = [_project_owner_name copy];
    file.project_name = [_project_name copy];
    file.diskFileName = [_diskFileName copy];
    file.owner = [_owner copy];
    file.share_url = [_share_url copy];
    file.title = [_title copy];
    file.storage_type = [_storage_type copy];
    file.storage_key = [_storage_key copy];
    file.preview = [_preview copy];
    file.owner_preview = [_owner_preview copy];
    file.fileType = [_fileType copy];
    file.name = [_name copy];
    file.number = [_number copy];
    file.project_id = [_project_id copy];
    file.size = [_size copy];
    file.current_user_role_id = [_current_user_role_id copy];
    file.type = [_type copy];
    file.parent_id = [_parent_id copy];
    file.owner_id = [_owner_id copy];
    file.file_id = [_file_id copy];
    file.created_at = [_created_at copy];
    file.updated_at = [_updated_at copy];
    file.id=[_id copy];
    file.path=[_path copy];
    return file;
}


+(ProjectFile *)fileWithFileId:(NSNumber *)fileId andProjectId:(NSNumber *)project_id{
    ProjectFile *file = [[ProjectFile alloc] init];
    file.file_id = fileId;
    file.project_id = project_id;
    return file;
}

- (instancetype)initWithFileId:(NSNumber *)fileId inProject:(NSString *)project_name ofUser:(NSString *)project_owner_name{
    self = [super init];
    if (self) {
        _file_id = fileId;
        _project_id = nil;
        _project_name = project_name;
        _project_owner_name = project_owner_name;
    }
    return self;
}

- (void)setOwner_preview:(NSString *)owner_preview{
    _owner_preview = owner_preview;
    if (!_project_id && owner_preview.length > 0) {
        NSString *project_id;
        project_id = [[[[owner_preview componentsSeparatedByString:@"project/"] lastObject] componentsSeparatedByString:@"/"] firstObject];
        _project_id = @(project_id.integerValue);
    }
}

- (BOOL)isEmpty{
    return !(self.storage_key && self.storage_key.length > 0);
}

- (DownloadState)downloadState{
    DownloadState state = DownloadStateDefault;
    if ([self hasBeenDownload]) {
        state = DownloadStateDownloaded;
    }else{
        Coding_DownloadTask *cDownloadTask = [self cDownloadTask];
        if (cDownloadTask) {
            if (cDownloadTask.task.state == NSURLSessionTaskStateRunning) {
                state = DownloadStateDownloading;
            }else if (cDownloadTask.task.state == NSURLSessionTaskStateSuspended) {
                state = DownloadStatePausing;
            }else{
                [Coding_FileManager cancelCDownloadTaskForKey:self.storage_key];
            }
        }
    }
    return state;
}

- (NSString *)downloadPath{
    NSString *path = [NSString stringWithFormat:@"%@api/project/%@/files/%@/download", [NSObject baseURLStr], _project_id.stringValue, _file_id.stringValue];
    return path;
}

- (NSString *)diskFileName{
    if (!_diskFileName) {
        _diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@|%@", _name, _project_id.stringValue, _storage_type, _storage_key];
    }
    return _diskFileName;
}

- (Coding_DownloadTask *)cDownloadTask{
    return [Coding_FileManager cDownloadTaskForKey:_storage_key];
}
- (NSURL *)hasBeenDownload{
    return [Coding_FileManager diskDownloadUrlForKey:_storage_key];
}

- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/project/%@/file/delete", _project_id.stringValue];
}
- (NSDictionary *)toDeleteParams{
    return @{@"fileIds" : @[_file_id.stringValue]};
}
- (NSDictionary *)toMoveToParams{
    return @{@"fileId" : @[_file_id.stringValue]};
}

- (NSString *)toDetailPath{
    NSString *path;
    if (!_project_id) {
        path = [NSString stringWithFormat:@"api/user/%@/project/%@/files/%@/view", _project_owner_name, _project_name, _file_id.stringValue];
    }else{
        path = [NSString stringWithFormat:@"api/project/%@/files/%@/view", _project_id.stringValue, _file_id.stringValue];
    }
    return path;
}

- (NSString *)toActivityListPath{
    return [NSString stringWithFormat:@"api/project/%@/file/%@/activities", _project_id.stringValue, _file_id.stringValue];
}

- (NSString *)toHistoryListPath{
    return [NSString stringWithFormat:@"api/project/%@/files/%@/histories", _project_id.stringValue, _file_id.stringValue];
}

- (NSDictionary *)toShareParams{
    return @{
             @"projectId": _project_id,
             @"resourceId": _file_id,
             @"resourceType": @0,
             @"accessType": @0
             };
}
@end

@implementation ResourceReference
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = @{@"Task": @"ResourceReferenceItem",
                              @"MergeRequestBean": @"ResourceReferenceItem",
                              @"ProjectTopic": @"ResourceReferenceItem",
                              @"ProjectFile": @"ResourceReferenceItem",
                              };
        
    }
    return self;
}
- (NSMutableArray *)itemList{
    if (!_itemList) {
        _itemList = [NSMutableArray new];
        [_itemList addObjectsFromArray:_Task];
        [_itemList addObjectsFromArray:_ProjectTopic];
        [_itemList addObjectsFromArray:_ProjectFile];
        [_itemList addObjectsFromArray:_MergeRequestBean];
    }
    return _itemList;
}
@end

@implementation ResourceReferenceItem

@end

@implementation ListGroupItem
+(ListGroupItem *)itemWithDate:(NSDate *)date andLocation:(NSUInteger)location{
    ListGroupItem *item = [[ListGroupItem alloc] init];
    item.date = date;
    item.location = location;
    item.length = 0;
    item.hide = NO;
    return item;
}
- (void)addOneItem{
    _length++;
}
- (void)deleteOneItem{
    _length--;
}
@end

@implementation ProjectTag

- (instancetype)init
{
    self = [super init];
    if (self) {
        _id = @(0);
        _count = @(0);
        _owner_id = [Login curLoginUser].id;
        _name = @"";
    }
    return self;
}

- (NSString *)color{
    if (_color.length <= 0) {
        _color = [NSString stringWithFormat:@"#%@", [[UIColor randomColor] hexStringFromColor]];
    }
    return _color;
}

+ (instancetype)tagWithName:(NSString *)name{
    ProjectTag *tag = [[self alloc] init];
    tag.name = name;
    return tag;
}

+ (BOOL)tags:(NSArray *)aTags isEqualTo:(NSArray *)bTags{
    if (aTags.count == 0 && bTags.count == 0) {
        return YES;
    }
    BOOL isSame = YES;
    if (aTags.count != bTags.count ||
        (aTags.count == 0 && bTags.count == 0)) {
        isSame = NO;
    }else{
        for (ProjectTag *mdTag in aTags) {
            BOOL tempHasOne = NO;
            for (ProjectTag *tempTag in bTags) {
                tempHasOne = (tempTag.id.integerValue == mdTag.id.integerValue);
                if (tempHasOne) {
                    break;
                }
            }
            isSame = tempHasOne;
            if (!isSame) {
                break;
            }
        }
    }
    return isSame;
}
+ (instancetype)tags:(NSArray *)aTags hasTag:(ProjectTag *)curTag{
    ProjectTag *resultTag = nil;
    for (ProjectTag *tempTag in aTags) {
        if (tempTag.id.integerValue == curTag.id.integerValue) {
            resultTag = tempTag;
            break;
        }
    }
    return resultTag;
}
@end

@interface FileVersion ()
@property (strong, nonatomic, readwrite) NSString *diskFileName;
@end

@implementation FileVersion
- (NSString *)diskFileName{
    if (!_diskFileName) {
        _diskFileName = [NSString stringWithFormat:@"%@|||%@|||%@|%@", _name, _project_id.stringValue, _storage_type, _storage_key];
    }
    return _diskFileName;
}
- (NSString *)downloadPath{
    return [NSString stringWithFormat:@"%@api/project/%@/files/histories/%@/download", [NSObject baseURLStr], _project_id, _history_id];
}

- (NSString *)toRemarkPath{
    return [NSString stringWithFormat:@"api/project/%@/files/%@/histories/%@/remark", _project_id.stringValue, _file_id.stringValue, _history_id.stringValue];
}
- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/project/%@/files/histories/%@", _project_id.stringValue, _history_id.stringValue];
}

//download
- (DownloadState)downloadState{
    DownloadState state = DownloadStateDefault;
    if ([self hasBeenDownload]) {
        state = DownloadStateDownloaded;
    }else{
        Coding_DownloadTask *cDownloadTask = [self cDownloadTask];
        if (cDownloadTask) {
            if (cDownloadTask.task.state == NSURLSessionTaskStateRunning) {
                state = DownloadStateDownloading;
            }else if (cDownloadTask.task.state == NSURLSessionTaskStateSuspended) {
                state = DownloadStatePausing;
            }else{
                [Coding_FileManager cancelCDownloadTaskForKey:self.storage_key];
            }
        }
    }
    return state;
}
- (Coding_DownloadTask *)cDownloadTask{
    return [Coding_FileManager cDownloadTaskForKey:_storage_key];
}
- (NSURL *)hasBeenDownload{
    return [Coding_FileManager diskDownloadUrlForKey:_storage_key];
}
@end


#pragma mark - Tweet

@implementation Tweets

- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Tweet", @"list", nil];
    }
    return self;
}


+ (Tweets *)tweetsWithType:(TweetType)tweetType{
    Tweets *tweets = [[Tweets alloc] init];
    tweets.tweetType = tweetType;
    tweets.canLoadMore = NO;
    tweets.isLoading = NO;
    tweets.willLoadMore = NO;
    return tweets;
}
+ (Tweets *)tweetsWithUser:(User *)curUser{
    Tweets *tweets = [Tweets tweetsWithType:TweetTypeUserSingle];
    tweets.curUser = curUser;
    return tweets;
}
+ (Tweets *)tweetsWithProject:(Project *)curPro{
    Tweets *tweets = [Tweets tweetsWithType:TweetTypeProject];
    tweets.curPro = curPro;
    return tweets;
}

- (NSString *)toPath{
    NSString *requstPath;
    switch (_tweetType) {
        case TweetTypePublicHot:
        case TweetTypePublicTime:
            requstPath = @"api/tweet/public_tweets";
            break;
        case TweetTypeUserFriends:
            requstPath = @"api/activities/user_tweet";
            break;
        case TweetTypeUserSingle:
            requstPath = @"api/tweet/user_public";
            break;
        case TweetTypeProject:
            requstPath = [NSString stringWithFormat:@"api/project/%@/tweet", _curPro.id.stringValue];
        default:
            break;
    }
    return requstPath;
}

- (NSDictionary *)toParams{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:2];
    switch (_tweetType) {
        case TweetTypePublicHot:
            [params setObject:@"hot" forKey:@"sort"];
            break;
        case TweetTypePublicTime:
            [params setObject:@"time" forKey:@"sort"];
            break;
        case TweetTypeUserFriends:
            break;
        case TweetTypeUserSingle:
            if (_curUser && _curUser.global_key) {
                [params setObject:_curUser.global_key forKey:@"global_key"];
            }else if ([Login curLoginUser].id) {
                [params setObject:[Login curLoginUser].global_key forKey:@"global_key"];
            }
            break;
        default:
            break;
    }
    params[@"last_time"] = _willLoadMore? @((NSUInteger)([_last_time timeIntervalSince1970] * 1000)): nil;//冒泡广场、朋友圈、个人，都已经改成用 time 了
    params[@"last_id"] = _willLoadMore? _last_id: nil;//项目内冒泡还在用 id
    return params;
}

- (void)configWithTweets:(NSArray *)responseA{
    if (responseA && [responseA count] > 0) {
        self.canLoadMore = (_tweetType != TweetTypePublicHot);
        Tweet *lastTweet = [responseA lastObject];
        _last_time = lastTweet.sort_time;
        _last_id = lastTweet.id;
        if (_willLoadMore) {
            [_list addObjectsFromArray:responseA];
        }else{
            self.list = [NSMutableArray arrayWithArray:responseA];
        }
    }else{
        self.canLoadMore = NO;
        if (!_willLoadMore) {
            self.list = [NSMutableArray array];
        }
    }
}

@end



static Tweet *_tweetForSend = nil;

@implementation Tweet
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Comment", @"comment_list",
                             @"User", @"like_users",
                             @"User", @"reward_users", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _contentHeight = 1;
    }
    return self;
}

- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeNone];
        _content = _htmlMedia.contentDisplay;
    }
}

- (NSString *)address{
    if (!_address || _address.length == 0) {
        return @"未填写";
    }else{
        return _address;
    }
}

- (void)changeToLiked:(NSNumber *)liked{
    if (!liked) {
        return;
    }
    if (!_liked || ![_liked isEqualToNumber:liked]) {
        _liked = liked;
        User *cur_user = [Login curLoginUser];
        NSPredicate *finalPredicate = [NSPredicate predicateWithFormat:@"global_key == %@", cur_user.global_key];
        if (_liked.boolValue) {//喜欢
            if (!_like_users) {
                _like_users = [NSMutableArray arrayWithObject:cur_user];
                _likes = [NSNumber numberWithInteger:_likes.integerValue +1];
            }else{
                NSArray *fliterArray = [_like_users filteredArrayUsingPredicate:finalPredicate];
                if (!fliterArray || [fliterArray count] <= 0) {
                    [_like_users insertObject:cur_user atIndex:0];
                    _likes = [NSNumber numberWithInteger:_likes.integerValue +1];
                }
            }
        }else{//不喜欢
            if (_like_users) {
                NSArray *fliterArray = [_like_users filteredArrayUsingPredicate:finalPredicate];
                if (fliterArray && [fliterArray count] > 0) {
                    [_like_users removeObjectsInArray:fliterArray];
                    _likes = [NSNumber numberWithInteger:_likes.integerValue -1];
                }
            }
        }
    }
}

- (NSInteger)numOfComments{
    return MIN(_comment_list.count +1,
               MIN(_comments.intValue,
                   6));
}
- (BOOL)hasMoreComments{
    return (_comments.intValue > _comment_list.count || _comments.intValue > 5);
}

- (NSArray *)like_reward_users{
    NSMutableArray *like_reward_users = _like_users.count > 0? _like_users.mutableCopy: @[].mutableCopy;//点赞的人多，用点赞的人列表做基
    [_reward_users enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(User *obj, NSUInteger idx, BOOL *stop) {
        __block NSInteger originalIndex = NSNotFound;
        [like_reward_users enumerateObjectsUsingBlock:^(User *obj_, NSUInteger idx_, BOOL *stop_) {
            if ([obj.global_key isEqualToString:obj_.global_key]) {
                originalIndex = idx_;
            }
        }];
        if (originalIndex != NSNotFound) {
            [like_reward_users exchangeObjectAtIndex:originalIndex withObjectAtIndex:0];
        }else{
            [like_reward_users insertObject:obj atIndex:0];
        }
    }];
    return like_reward_users;
}
- (BOOL)hasLikesOrRewards{
    return (_likes.integerValue + _rewards.integerValue) > 0;
}
- (BOOL)hasMoreLikesOrRewards{
    return (_like_users.count + _reward_users.count == 10 && _likes.integerValue + _rewards.integerValue > 10);
    //    return (_likes.integerValue > _like_users.count || _rewards.integerValue > _reward_users.count);
}
- (BOOL)rewardedBy:(User *)user{
    for (User *obj in _reward_users) {
        if ([obj.global_key isEqualToString:user.global_key]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)toDoLikePath{
    NSString *doLikePath;
    doLikePath = [NSString stringWithFormat:@"api/tweet/%d/%@", self.id.intValue, (!_liked.boolValue? @"unlike":@"like")];
    return doLikePath;
}

- (NSString *)toDoCommentPath{
    if (self.project_id) {
        return [NSString stringWithFormat:@"api/project/%@/tweet/%@/comment", self.project_id.stringValue, self.id.stringValue];
    }else{
        return [NSString stringWithFormat:@"api/tweet/%d/comment", self.id.intValue];
    }
}
- (NSDictionary *)toDoCommentParams{
    return @{@"content" : [self.nextCommentStr aliasedString]};
}


- (NSString *)toLikesAndRewardsPath{
    return [NSString stringWithFormat:@"api/tweet/%d/allLikesAndRewards", _id.intValue];
}
- (NSDictionary *)toLikesAndRewardsParams{
    return @{@"page" : [NSNumber numberWithInteger:1],
             @"pageSize" : [NSNumber numberWithInteger:500]};
}

- (NSString *)toLikersPath{
    return [NSString stringWithFormat:@"api/tweet/%d/likes", _id.intValue];
}
- (NSDictionary *)toLikersParams{
    return @{@"page" : [NSNumber numberWithInteger:1],
             @"pageSize" : [NSNumber numberWithInteger:500]};
}
- (NSString *)toCommentsPath{
    NSString *path;
    if (self.project_id) {
        path = [NSString stringWithFormat:@"api/project/%@/tweet/%@/comments", self.project_id.stringValue, self.id.stringValue];
    }else{
        path = [NSString stringWithFormat:@"api/tweet/%d/comments", _id.intValue];
    }
    return path;
}
- (NSDictionary *)toCommentsParams{
    return @{@"page" : [NSNumber numberWithInteger:1],
             @"pageSize" : [NSNumber numberWithInteger:500]};
}
- (NSString *)toDeletePath{
    if (self.project_id) {
        return [NSString stringWithFormat:@"api/project/%@/tweet/%@", self.project_id.stringValue, self.id.stringValue];
    }else{
        return [NSString stringWithFormat:@"api/tweet/%d", self.id.intValue];
    }
}
- (NSString *)toDetailPath{
    NSString *path;
    if (self.project_id) {
        path = [NSString stringWithFormat:@"api/project/%@/tweet/%@", self.project_id.stringValue, self.id.stringValue];
    }else if (self.project){
        //需要先去获取project_id
    }else if (self.user_global_key) {
        path = [NSString stringWithFormat:@"api/tweet/%@/%@", self.user_global_key, self.id.stringValue];
    }else{
        path = [NSString stringWithFormat:@"api/tweet/%@/%@", self.owner.global_key, self.id.stringValue];
    }
    return path;
}

+(Tweet *)tweetForSend{
    if (!_tweetForSend) {
        _tweetForSend = [[Tweet alloc] init];
        [_tweetForSend loadSendData];
    }
    return _tweetForSend;
}

- (void)saveSendData{
    NSString *dataPath = [NSString stringWithFormat:@"%@_tweetForSend", [Login curLoginUser].global_key];
    NSMutableDictionary *tweetImagesDict = [NSMutableDictionary new];
    for (int i = 0; i < [self.tweetImages count]; i++) {
        TweetImage *tImg = [self.tweetImages objectAtIndex:i];
        if (tImg.image) {
            NSString *imgNameStr = [NSString stringWithFormat:@"%@_%d.jpg", dataPath, i];
            if (tImg.assetURL.absoluteString) {
                [tweetImagesDict setObject:tImg.assetURL.absoluteString forKey:imgNameStr];
            }
            [NSObject saveImage:tImg.image imageName:imgNameStr inFolder:dataPath];
        }
    }
    [NSObject saveResponseData:@{@"content" : _tweetContent? _tweetContent: @"",
                                 @"locationData" : _locationData? [_locationData objectDictionary] : @"",
                                 @"tweetImagesDict" : tweetImagesDict,
                                 } toPath:dataPath];
}

- (void)loadSendData{
    NSString *dataPath = [NSString stringWithFormat:@"%@_tweetForSend", [Login curLoginUser].global_key];
    
    self.tweetContent = @"";
    NSDictionary *contentDict = [NSObject loadResponseWithPath:dataPath];
    NSDictionary *tweetImagesDict = [contentDict objectForKey:@"tweetImagesDict"];
    if (contentDict) {
        self.tweetContent = [contentDict objectForKey:@"content"];
        self.locationData = [NSObject objectOfClass:@"TweetSendLocationResponse" fromJSON:[contentDict objectForKey:@"locationData"]];
    }
    _tweetImages = [NSMutableArray new];
    _selectedAssetURLs = [NSMutableArray new];
    [tweetImagesDict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSURL *assetURL = [NSURL URLWithString:obj];
        NSData *imageData = [NSObject loadImageDataWithName:key inFolder:dataPath];
        if (imageData) {
            TweetImage *tImg = [TweetImage tweetImageWithAssetURL:assetURL andImage:[UIImage imageWithData:imageData]];
            [self.tweetImages addObject:tImg];
            [self.selectedAssetURLs addObject:assetURL];
        }
    }];
}

+ (void)deleteSendData{
    _tweetForSend = nil;
    NSString *dataPath = [NSString stringWithFormat:@"%@_tweetForSend", [Login curLoginUser].global_key];
    [NSObject deleteImageCacheInFolder:dataPath];
    [NSObject deleteResponseCacheForPath:dataPath];
}

+(Tweet *)tweetWithGlobalKey:(NSString *)user_global_key andPPID:(NSString *)pp_id{
    Tweet *tweet = [[Tweet alloc] init];
    tweet.id = [NSNumber numberWithInteger:pp_id.integerValue];
    tweet.user_global_key = user_global_key;
    return tweet;
}
+(Tweet *)tweetInProject:(Project *)project andPPID:(NSString *)pp_id{
    Tweet *tweet = [[Tweet alloc] init];
    tweet.id = [NSNumber numberWithInteger:pp_id.integerValue];
    tweet.project = project;
    return tweet;
}

- (NSDictionary *)toDoTweetParams{
    NSMutableString *contentStr = [[NSMutableString alloc] initWithString:_tweetContent? _tweetContent: @""];
    if (_tweetImages.count > 0) {
        [contentStr appendString:@"\n"];
    }
    for (TweetImage *imageItem in _tweetImages) {
        if (imageItem.imageStr && imageItem.imageStr.length > 0) {
            [contentStr appendString:imageItem.imageStr];
        }
    }
    NSDictionary *params;
    if (_locationData) {
        params = @{@"content" : contentStr,
                   @"location": _locationData.displayLocaiton,
                   @"coord": [NSString stringWithFormat:@"%@,%@,%i", _locationData.lat, _locationData.lng, _locationData.isCustomLocaiton],
                   @"address": _locationData.address? _locationData.address: @""};
    }else{
        params = @{@"content" : contentStr};
    }
    return params;
}
- (BOOL)isAllImagesDoneSucess{
    for (TweetImage *imageItem in _tweetImages) {
        if (imageItem.imageStr.length <= 0) {
            return NO;
        }
    }
    return YES;
}
- (void)addNewComment:(Comment *)comment{
    if (!comment) {
        return;
    }
    if (_comment_list) {
        [_comment_list insertObject:comment atIndex:0];
    }else{
        _comment_list = [NSMutableArray arrayWithObject:comment];
    }
    _comments = [NSNumber numberWithInteger:_comments.integerValue +1];
}
- (void)deleteComment:(Comment *)comment{
    if (_comment_list) {
        NSUInteger index = [_comment_list indexOfObject:comment];
        if (index != NSNotFound) {
            [_comment_list removeObjectAtIndex:index];
            _comments = [NSNumber numberWithInteger:_comments.integerValue -1];
        }
    }
}

- (NSString *)toShareLinkStr{
    NSString *shareLinkStr;
    if (_project) {
        shareLinkStr = [NSString stringWithFormat:@"%@u/%@/p/%@?pp=%@", [NSObject baseURLStr], _project.owner_user_name, _project.name, _id.stringValue];
    }else{
        shareLinkStr = [NSString stringWithFormat:@"%@u/%@/pp/%@", kBaseUrlStr_Phone, _owner.global_key, _id];
    }
    return shareLinkStr;
}

#pragma mark ALAsset
- (void)setSelectedAssetURLs:(NSMutableArray *)selectedAssetURLs{
    NSMutableArray *needToAdd = [NSMutableArray new];
    NSMutableArray *needToDelete = [NSMutableArray new];
    [self.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![selectedAssetURLs containsObject:obj]) {
            [needToDelete addObject:obj];
        }
    }];
    [needToDelete enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteASelectedAssetURL:obj];
    }];
    [selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![self.selectedAssetURLs containsObject:obj]) {
            [needToAdd addObject:obj];
        }
    }];
    [needToAdd enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addASelectedAssetURL:obj];
    }];
}

- (BOOL)isProjectTweet{
    return self.project_id != nil;
}
- (void)addASelectedAssetURL:(NSURL *)assetURL{
    if (!_selectedAssetURLs) {
        _selectedAssetURLs = [NSMutableArray new];
    }
    if (!_tweetImages) {
        _tweetImages = [NSMutableArray new];
    }
    
    [_selectedAssetURLs addObject:assetURL];
    
    NSMutableArray *tweetImages = [self mutableArrayValueForKey:@"tweetImages"];//为了kvo
    TweetImage *tweetImg = [TweetImage tweetImageWithAssetURL:assetURL];
    [tweetImages addObject:tweetImg];
}

- (void)deleteASelectedAssetURL:(NSURL *)assetURL{
    [self.selectedAssetURLs removeObject:assetURL];
    NSMutableArray *tweetImages = [self mutableArrayValueForKey:@"tweetImages"];//为了kvo
    [tweetImages enumerateObjectsUsingBlock:^(TweetImage *obj, NSUInteger idx, BOOL *stop) {
        if (obj.assetURL == assetURL) {
            [tweetImages removeObject:obj];
            *stop = YES;
        }
    }];
}

- (void)deleteATweetImage:(TweetImage *)tweetImage{
    NSMutableArray *tweetImages = [self mutableArrayValueForKey:@"tweetImages"];//为了kvo
    [tweetImages removeObject:tweetImage];
    if (tweetImage.assetURL) {
        [self.selectedAssetURLs removeObject:tweetImage.assetURL];
    }
}

@end

@implementation TweetImage
+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL{
    TweetImage *tweetImg = [[TweetImage alloc] init];
    tweetImg.uploadState = TweetImageUploadStateInit;
    tweetImg.assetURL = assetURL;
    
    void (^selectAsset)(ALAsset *) = ^(ALAsset *asset){
        if (asset) {
            UIImage *highQualityImage = [UIImage fullScreenImageALAsset:asset];
            UIImage *thumbnailImage = [UIImage imageWithCGImage:[asset thumbnail]];
            dispatch_async(dispatch_get_main_queue(), ^{
                tweetImg.image = highQualityImage;
                tweetImg.thumbnailImage = thumbnailImage;
            });
        }
    };
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    @weakify(assetsLibrary);
    [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            selectAsset(asset);
        }else{
            @strongify(assetsLibrary);
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stopG) {
                    if([result.defaultRepresentation.url isEqual:assetURL]) {
                        selectAsset(result);
                        *stop = YES;
                        *stopG = YES;
                    }
                }];
            } failureBlock:^(NSError *error) {
                [NSObject showHudTipStr:@"读取图片失败"];
            }];
        }
    }failureBlock:^(NSError *error) {
        [NSObject showHudTipStr:@"读取图片失败"];
    }];
    return tweetImg;
    
}

+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL andImage:(UIImage *)image{
    TweetImage *tweetImg = [[TweetImage alloc] init];
    tweetImg.uploadState = TweetImageUploadStateInit;
    tweetImg.assetURL = assetURL;
    tweetImg.image = image;
    tweetImg.thumbnailImage = [image scaledToSize:CGSizeMake(kScaleFrom_iPhone5_Desgin(70), kScaleFrom_iPhone5_Desgin(70)) highQuality:YES];
    return tweetImg;
}

@end



NSString * const kBaiduAPIPlacePath = @"/place/v2/search";
NSString * const kBaiduAPIGeosearchPath = @"/geosearch/v3/nearby";
NSString * const kBaiduAPIGeosearchPathCreate = @"/geodata/v3/poi/create";

NSString * const kBaiduAPIUrl = @"http://api.map.baidu.com";


#pragma mark AFNet
static NSString * const kCodingCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";
static NSString * CodingPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kCodingCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";
    
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kCodingCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kCodingCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}
static NSString * CodingPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    return (__bridge_transfer  NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kCodingCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}
extern NSArray * CodingQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray * CodingQueryStringPairsFromKeyAndValue(NSString *key, id value);



@interface CodingQueryStringPair : NSObject
@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (id)initWithField:(id)field value:(id)value;

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;
@end

@implementation CodingQueryStringPair

- (id)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.field = field;
    self.value = value;
    
    return self;
}

//NSUTF8StringEncoding
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return CodingPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding);
    } else {
        return [NSString stringWithFormat:@"%@=%@", CodingPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding), CodingPercentEscapedQueryStringValueFromStringWithEncoding([self.value description], stringEncoding)];
    }
}

@end

NSArray * CodingQueryStringPairsFromDictionary(NSDictionary *dictionary) {
    return CodingQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray * CodingQueryStringPairsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:CodingQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            //------------------------------------------------------------
            //edited by easeeeeeeeee(modify)
            //            [mutableQueryStringComponents addObjectsFromArray:AFQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
            [mutableQueryStringComponents addObjectsFromArray:CodingQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@", key], nestedValue)];
            //------------------------------------------------------------
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:CodingQueryStringPairsFromKeyAndValue(key, obj)];
        }
    } else {
        [mutableQueryStringComponents addObject:[[CodingQueryStringPair alloc] initWithField:key value:value]];
    }
    
    return mutableQueryStringComponents;
}



static NSString * CodingQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (CodingQueryStringPair *pair in CodingQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutablePairs componentsJoinedByString:@"&"];
}

static NSString *CodingGetSN(NSString *path, NSString *sk, NSDictionary *parameters){
    
    NSString *uri = [path stringByAppendingFormat:@"?%@",CodingQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding)];
    NSString *baseString = [[uri stringByAppendingString:sk] URLEncoding];
    
    return [baseString md5Str];
}

#pragma mark -


@implementation TweetSendCreateLocation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ak = kBaiduAK;
        self.geotable_id = kBaiduGeotableId;
        self.coord_type = @"3";
        self.filter = @"";
        self.query = @"";
        self.radius = @(2000);
        self.page_size = @20;
        self.page_index = @0;
        User *user = [Login curLoginUser]? [Login curLoginUser]: [User userWithGlobalKey:@""];
        self.user_id = user.id;
        
    }
    return self;
}


- (NSDictionary *)toCreateParams
{
    NSMutableDictionary *dict = [@{@"ak":self.ak,@"geotable_id":self.geotable_id,@"coord_type":self.coord_type,@"radius":self.radius,@"address":self.address,@"latitude":self.latitude,@"longitude":self.longitude,@"title":self.title,@"user_id":self.user_id} mutableCopy];
    
    NSString *sn = CodingGetSN(kBaiduAPIGeosearchPathCreate,kBaiduSK,dict);
    
    [dict setValue:sn forKey:@"sn"];
    
    return dict;
    
}

- (NSDictionary *)toSearchParams
{
    self.filter = [NSString stringWithFormat:@"%@:[%@]",@"user_id",self.user_id];
    NSString *location = [NSString stringWithFormat:@"%@,%@",self.longitude,self.latitude];
    
    NSMutableDictionary *dict = [@{@"ak":self.ak,@"geotable_id":self.geotable_id,@"coord_type":self.coord_type,@"q":self.query,@"radius":self.radius,@"filter":self.filter,@"page_index":self.page_index,@"page_size":self.page_size,@"location":location} mutableCopy];
    
    
    NSString *sn = CodingGetSN(kBaiduAPIGeosearchPath,kBaiduSK,dict);
    
    kLog(@"%@",sn);
    
    [dict setValue:sn forKey:@"sn"];
    
    return dict;
}

@end

@implementation TweetSendLocationRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ak = kBaiduAK;
        self.query = @"$美食$休闲娱乐$宾馆$公司企业$旅游景点$道路$生活服务$医疗";
        self.page_num = @(0);
        self.page_size = @(20);
        self.scope = @"1";
        self.radius = @(2000);
        self.output = @"json";
    }
    return self;
}

- (NSDictionary *)toParams
{
    NSString *locationStr = [NSString stringWithFormat:@"%@,%@",self.lat,self.lng];
    
    NSMutableDictionary *dict = [@{@"ak":self.ak,@"output":self.output,@"query":self.query,@"page_size":self.page_size,@"page_num":self.page_num,@"scope":self.scope,@"location":locationStr,@"radius":self.radius} mutableCopy];
    
    NSString *sn = CodingGetSN(kBaiduAPIPlacePath,kBaiduSK,dict);
    
    kLog(@"%@",sn);
    
    [dict setValue:sn forKey:@"sn"];
    
    return dict;
}

@end

@implementation TweetSendLocationResponse
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.address = @"";
        self.cityName = @"";
        self.region = @"";
        self.title = @"";
        self.address = @"";
    }
    return self;
}

- (NSString *)address
{
    if (_address.length <= 0) {
        _address = [NSString stringWithFormat:@"%@,%@",self.cityName,self.region];
    }
    return _address;
}

- (NSString *)displayLocaiton
{
    NSString *locationStr = @"";
    NSRange range = [self.cityName rangeOfString:@"市"];
    
    if(range.location != NSNotFound){
        self.cityName = [self.cityName substringToIndex:range.location];
    }
    if (self.title.length > 0) {
        locationStr = [NSString stringWithFormat:@"%@ · %@",self.cityName,self.title];
    }else{
        locationStr = self.cityName;
    }
    if (locationStr.length > 32) {
        locationStr = [locationStr substringWithRange:NSMakeRange(0, 31)];
        locationStr = [locationStr stringByAppendingString:@"…"];
    }
    
    return locationStr;
}


@end

@implementation TweetSendLocationClient

+ (TweetSendLocationClient *)sharedJsonClient
{
    static TweetSendLocationClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TweetSendLocationClient alloc] initWithBaseURL:[NSURL URLWithString:kBaiduAPIUrl]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", nil];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return self;
}

- (void)requestPlaceAPIWithParams:(TweetSendLocationRequest *)obj andBlock:(void (^)(id data, NSError *error))block
{
    [self GET:kBaiduAPIPlacePath parameters:[obj toParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        kLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIPlacePath, responseObject);
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        kLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIPlacePath, error);
        [NSObject showError:error];
        block(nil, error);
    }];
}

- (void)requestGeodataCreateWithParams:(TweetSendCreateLocation *)obj andBlock:(void (^)(id data, NSError *error))block
{
    [self POST:kBaiduAPIGeosearchPathCreate parameters:[obj toCreateParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        kLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPathCreate, responseObject);
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        kLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPathCreate, error);
        [NSObject showError:error];
        block(nil, error);
    }];
}

- (void)requestGeodataSearchCustomerWithParams:(TweetSendCreateLocation *)obj andBlock:(void (^)(id data, NSError *error))block
{
    [self GET:kBaiduAPIGeosearchPath parameters:[obj toSearchParams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        kLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPath, responseObject);
        id error = [self handleResponse:responseObject];
        if (error) {
            block(nil, error);
        }else{
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        kLog(@"\n===========response===========\n%@:\n%@", kBaiduAPIGeosearchPath, error);
        [NSObject showError:error];
        block(nil, error);
    }];
}

@end

@implementation Comment
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeAll];
        _content = _htmlMedia.contentDisplay;
    }
}
@end
#pragma mark - Message
@interface PrivateMessages ()
@property (strong, nonatomic) NSNumber *p_lastId;
@end

@implementation PrivateMessages
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"PrivateMessage", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = _isPolling = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _curFriend = nil;
    }
    return self;
}

- (NSMutableArray *)list{
    if (!_list) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (NSMutableArray *)nextMessages{
    if (!_nextMessages) {
        _nextMessages = [[NSMutableArray alloc] init];
    }
    return _nextMessages;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (NSMutableArray *)reset_dataList{
    [self.dataList removeAllObjects];
    if (_list.count > 0) {
        self.dataList = [_list mutableCopy];
    }
    if (_nextMessages.count > 0) {
        [self.dataList insertObjects:_nextMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _nextMessages.count)]];
    }
    return _dataList;
}

+ (PrivateMessages *)priMsgsWithUser:(User *)user{
    PrivateMessages *priMsgs = [[PrivateMessages alloc] init];
    priMsgs.curFriend = user;
    return priMsgs;
}

+ (id)analyzeResponseData:(NSDictionary *)responseData{
    id data = [responseData valueForKeyPath:@"data"];
    if (!data) {//旧数据直接保存的data属性
        data = responseData;
    }
    id resultA = nil;
    if ([data isKindOfClass:[NSArray class]]) {
        resultA = [NSObject arrayFromJSON:data ofObjects:@"PrivateMessage"];
    }else if (data){
        resultA = [NSObject objectOfClass:@"PrivateMessages" fromJSON:data];
    }
    return resultA;
}

- (NSString *)localPrivateMessagesPath{
    NSString *path;
    if (_curFriend) {
        path = [NSString stringWithFormat:@"conversations_%@", _curFriend.global_key];
    }else{
        path = @"conversations";
    }
    return path;
}
- (NSString *)toPath{
    NSString *path;
    if (_curFriend) {
        path = [NSString stringWithFormat:@"api/message/conversations/%@/prev", _curFriend.global_key];
    }else{
        path = @"api/message/conversations";
    }
    return path;
}
- (NSDictionary *)toParams{
    NSDictionary *params = nil;
    if (_curFriend) {
        NSNumber *prevId = kDefaultLastId;
        if (_willLoadMore && _list.count > 0) {
            PrivateMessage *prev_Msg = [_list lastObject];
            prevId = prev_Msg.id;
        }
        params = @{@"id" : prevId,
                   @"pageSize" : _pageSize};
    }else{
        params = @{@"page" : _willLoadMore? [NSNumber numberWithInt:_page.intValue +1]: [NSNumber numberWithInt:1],
                   @"pageSize" : _pageSize};
    }
    return params;
}

- (NSString *)toPollPath{
    return [NSString stringWithFormat:@"api/message/conversations/%@/last", _curFriend.global_key];
}
- (NSDictionary *)toPollParams{
    return @{@"id" : self.p_lastId};
}

- (void)freshLastId:(NSNumber *)last_id{
    self.p_lastId = last_id;
}


- (NSNumber *)p_lastId{
    if (!_p_lastId) {
        _p_lastId = @0;
        [_list enumerateObjectsUsingBlock:^(PrivateMessage *obj, NSUInteger idx, BOOL *stop) {
            if (obj.id.integerValue > 0) {
                _p_lastId = obj.id;
                *stop = YES;
            }
        }];
    }
    return _p_lastId;
}

- (BOOL)p_addMsg:(PrivateMessage *)aMsg{
    NSInteger curId = aMsg.id.integerValue;
    
    __block NSInteger add_index;
    __block BOOL needToAdd = NO;
    
    if (self.list.count > 0) {
        [self.list enumerateObjectsUsingBlock:^(PrivateMessage *obj, NSUInteger idx, BOOL *stop) {
            if (curId == obj.id.integerValue) {
                needToAdd = NO;
                *stop = YES;
            }else if (curId > obj.id.integerValue){
                needToAdd = YES;
                add_index = idx;
                *stop = YES;
            }
        }];
        if (needToAdd) {
            [self.list insertObject:aMsg atIndex:add_index];
        }
    }else{
        needToAdd = YES;
        [self.list addObject:aMsg];
    }
    return needToAdd;
}

- (void)configWithObj:(id)anObj{
    if ([anObj isKindOfClass:[PrivateMessages class]]) {
        PrivateMessages *priMsgs = (PrivateMessages *)anObj;
        self.page = priMsgs.page;
        self.pageSize = priMsgs.pageSize;
        self.totalPage = priMsgs.totalPage;
        if (!_willLoadMore) {
            [self.list removeAllObjects];
        }
        [self.list addObjectsFromArray:priMsgs.list];
        self.canLoadMore = _page.intValue < _totalPage.intValue;
    }else if ([anObj isKindOfClass:[NSArray class]]){
        NSArray *list = (NSArray *)anObj;
        if (!_willLoadMore) {
            [self.list removeAllObjects];
        }
        [self.list addObjectsFromArray:list];
        self.canLoadMore = list.count > 0;
    }
    [self reset_dataList];
}

- (void)configWithPollArray:(NSArray *)pollList{
    if (pollList.count <= 0) {
        return;
    }
    
    __block BOOL hasNewData = NO;
    __weak typeof(self) weakSelf = self;
    [pollList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PrivateMessage *obj, NSUInteger idx, BOOL *stop) {
        if ([weakSelf p_addMsg:obj]) {
            hasNewData = YES;
        }
    }];
    if (hasNewData) {
        [self reset_dataList];
    }
}

- (void)sendNewMessage:(PrivateMessage *)nextMsg{
    [self p_addObj:nextMsg toArray:self.nextMessages];
    [self reset_dataList];
}
- (void)p_addObj:(id)anObj toArray:(NSMutableArray *)list{
    if (!anObj || !list) {
        return;
    }
    NSUInteger index = [list indexOfObject:anObj];
    if (index == NSNotFound) {
        [list insertObject:anObj atIndex:0];
    }else if (index != 0){
        [list exchangeObjectAtIndex:index withObjectAtIndex:0];
    }
}

- (void)sendSuccessMessage:(PrivateMessage *)sucessMsg andOldMessage:(PrivateMessage *)oldMsg{
    if (!sucessMsg || !oldMsg) {
        kLog(@"sucessMsg and oldMsg should not be nil");
        return;
    }
    [self.nextMessages removeObject:oldMsg];
    [self p_addMsg:sucessMsg];
    [self reset_dataList];
}
- (void)deleteMessage:(PrivateMessage *)msg{
    [self.list removeObject:msg];
    [self.nextMessages removeObject:msg];
    [self reset_dataList];
}
@end

@implementation PrivateMessage
- (instancetype)init
{
    self = [super init];
    if (self) {
        _sendStatus = PrivateMessageStatusSendSucess;
        _id = @(-1);
    }
    return self;
}

- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeCode];
        if (_htmlMedia.contentDisplay.length <= 0 && _htmlMedia.imageItems.count <= 0 && !_nextImg) {
            _content = @"    ";//占位
        }else{
            _content = _htmlMedia.contentDisplay;
        }
    }
}
- (BOOL)hasMedia{
    return self.nextImg || (self.htmlMedia && self.htmlMedia.imageItems.count> 0);
}
- (BOOL)isSingleBigMonkey{
    BOOL isSingleBigMonkey = NO;
    if (self.content.length == 0) {
        if (_htmlMedia.imageItems.count == 1) {
            HtmlMediaItem *item = [_htmlMedia.imageItems firstObject];
            if (item.type == HtmlMediaItemType_EmotionMonkey) {
                isSingleBigMonkey = YES;
            }
        }
    }
    return isSingleBigMonkey;
}
+ (instancetype)privateMessageWithObj:(id)obj andFriend:(User *)curFriend{
    PrivateMessage *nextMsg = [[PrivateMessage alloc] init];
    nextMsg.sender = [Login curLoginUser];
    nextMsg.friend = curFriend;
    nextMsg.sendStatus = PrivateMessageStatusSending;
    nextMsg.created_at = [NSDate date];
    
    if ([obj isKindOfClass:[NSString class]]) {
        nextMsg.content = obj;
        nextMsg.extra = @"";
    }else if ([obj isKindOfClass:[UIImage class]]){
        nextMsg.nextImg = obj;
        nextMsg.content = @"";
        nextMsg.extra = @"";
    }else if ([obj isKindOfClass:[VoiceMedia class]]){
        nextMsg.voiceMedia = obj;
        //        nextMsg.content = @"";
        nextMsg.extra = @"";
    }else if ([obj isKindOfClass:[PrivateMessage class]]){
        PrivateMessage *originalMsg = (PrivateMessage *)obj;
        NSMutableString *content = [[NSMutableString alloc] initWithString:originalMsg.content];
        NSMutableString *extra = [[NSMutableString alloc] init];
        if (originalMsg.htmlMedia.mediaItems && originalMsg.htmlMedia.mediaItems.count > 0) {
            for (HtmlMediaItem *item in originalMsg.htmlMedia.mediaItems) {
                if (item.type == HtmlMediaItemType_Image) {
                    if (extra.length > 0) {
                        [extra appendFormat:@",%@", item.src];
                    }else{
                        [extra appendString:item.src];
                    }
                }else if (item.type == HtmlMediaItemType_EmotionMonkey){
                    [content appendFormat:@" :%@: ", item.title];
                }
            }
        }
        nextMsg.content = content;
        nextMsg.extra = extra;
    }
    
    return nextMsg;
};

- (NSString *)toSendPath{
    return @"api/message/send";
}
- (NSDictionary *)toSendParams{
    return @{@"content" : _content? [_content aliasedString]: @"",
             @"extra" : _extra? _extra: @"",
             @"receiver_global_key" : _friend.global_key};
}


- (NSString *)toDeletePath{
    return [NSString stringWithFormat:@"api/message/%ld", _id.longValue];
}

@end
@implementation VoiceMedia
@end

@implementation CodingTips
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"CodingTip", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _type = 0;
    }
    return self;
}

- (void)setOnlyUnread:(BOOL)onlyUnread{
    if (_onlyUnread != onlyUnread) {
        _onlyUnread = onlyUnread;
        //初始化数据
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _canLoadMore = YES;
        if (_list) {
            [_list removeAllObjects];
        }
    }
}

+(CodingTips *)codingTipsWithType:(NSInteger)type{
    CodingTips *tips = [[CodingTips alloc] init];
    tips.type = type;
    return tips;
}

- (void)configWithObj:(CodingTips *)tips{
    self.page = tips.page;
    self.pageSize = tips.pageSize;
    self.totalPage = tips.totalPage;
    if (_willLoadMore) {
        [self.list addObjectsFromArray:tips.list];
    }else{
        self.list = [NSMutableArray arrayWithArray:tips.list];
    }
    _canLoadMore = _page.intValue < _totalPage.intValue;
}

- (NSString *)toTipsPath{
    NSString *path;
    if (_onlyUnread) {
        path = @"api/notification/unread-list";
    }else{
        path = @"api/notification";
    }
    return path;
}
- (NSDictionary *)toTipsParams{
    NSDictionary *params;
    if (_type == 0) {
        params = @{@"type" : @(0),
                   @"page" : _willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1]: [NSNumber numberWithInteger:1],
                   @"pageSize" : _pageSize};
    }else if (_type == 1){
        params = @{@"type" : @[@(1), @(2)],
                   @"page" : _willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1]: [NSNumber numberWithInteger:1],
                   @"pageSize" : _pageSize};
    }else if (_type == 2){
        params = @{@"type" : @[@(4), @(6)],
                   @"page" : _willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1]: [NSNumber numberWithInteger:1],
                   @"pageSize" : _pageSize};
    }
    return params;
}

- (NSDictionary *)toMarkReadParams{
    NSDictionary *params;
    if (_type == 0) {
        params = @{@"type" : @(0),
                   @"all" : @(1)};
    }else if (_type == 1){
        params = @{@"type" : @[@(1), @(2)],
                   @"all" : @(1)};
    }else if (_type == 2){
        params = @{@"type" : @(4),
                   @"all" : @(1)};
    }
    return params;
}
@end

@implementation CodingTip

- (void)setId:(NSNumber *)id{
    if ([id isKindOfClass:[NSString class]]){
        _id = @([(NSString *)id integerValue]);
    }else{
        _id = id;
    }
}

- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeImageAndMonkey];
        _content = _htmlMedia.contentDisplay;
    }
    if (_target_type.length > 0) {
        [self adjust];
    }
}

- (void)setTarget_type:(NSString *)target_type{
    _target_type = target_type;
    if (_content.length > 0) {
        [self adjust];
    }
}

- (void)adjust{
    //根据 content、target_type 去重组数据
    if ([_target_type isEqualToString:@"Depot"]) {//您导入的仓库（xxx）成功。点击查看：<a>playmore</a>
        _user_item = [HtmlMediaItem htmlMediaItemWithTypeATUser:[Login curLoginUser] mediaRange:NSMakeRange(0, 0)];
    }else if ([_target_type isEqualToString:@"Task"] && _htmlMedia.mediaItems.count == 1){//任务提醒
        _user_item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_CustomLink];
        _user_item.linkStr = @"任务提醒";
        _user_item.href = [(HtmlMediaItem *)_htmlMedia.mediaItems.firstObject href];
    }else if ([_target_type isEqualToString:@"Tweet"] && _htmlMedia.mediaItems.count == 1){//冒泡推荐
        _user_item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_CustomLink];
        _user_item.linkStr = @"冒泡提醒";
        _user_item.href = [(HtmlMediaItem *)_htmlMedia.mediaItems.firstObject href];
    }else if ([_target_type isEqualToString:@"User"] && _htmlMedia.mediaItems.count <= 0){
        _user_item = [HtmlMediaItem htmlMediaItemWithType:HtmlMediaItemType_CustomLink];
        _user_item.linkStr = @"账号提醒";
    }else{
        _user_item = [_htmlMedia.mediaItems firstObject];
        [_htmlMedia removeItem:_user_item];
    }
    if (_htmlMedia.mediaItems.count > 0) {
        _target_item = [_htmlMedia.mediaItems lastObject];
        [_htmlMedia removeItem:_target_item];
    }
    _target_type_ColorName = [[CodingTip p_color_dict] objectForKey:_target_type];
    if (_target_type_ColorName.length <= 0) {
        _target_type_ColorName = @"0x379FD3";
    }
    _target_type_imageName = [NSString stringWithFormat:@"tipIcon_%@", _target_type];
    _content = _htmlMedia.contentDisplay;
}

+ (NSDictionary *)p_color_dict{
    static NSDictionary *color_dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color_dict = @{
                       @"BranchMember" : @"0x1AB6D9",
                       @"CommitLineNote" : @"",
                       @"Depot" : @"",
                       @"MergeRequestBean" : @"0x4E74B7",
                       @"MergeRequestComment" : @"0x4E74B7",
                       @"Project" : @"0xF8BE46",
                       @"ProjectFileComment" : @"",
                       @"ProjectMember" : @"0x1AB6D9",
                       @"ProjectPayment" : @"",
                       @"ProjectTopic" : @"0x2FAEEA",
                       @"ProjectTweet" : @"0xFB8638",
                       @"ProjectTweetComment" : @"0xFB8638",
                       @"tweetReward" : @"0xFB8638",
                       @"TweetReward" : @"0xFB8638",
                       @"PullRequestBean" : @"0x49C9A7",
                       @"PullRequestComment" : @"0x49C9A7",
                       @"QcTask" : @"0x3C8CEA",
                       @"Task" : @"0x379FD3",
                       @"TaskComment" : @"0x379FD3",
                       @"Tweet" : @"0xFB8638",
                       @"TweetComment" : @"0xFB8638",
                       @"TweetLike" : @"0xFF5847",
                       @"User" : @"0x496AB3",
                       @"UserFollow" : @"0x3BBD79",
                       };
    });
    return color_dict;
}
@end
