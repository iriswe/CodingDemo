//
//  NSObject+Common.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/8/31.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kPath_ImageCache @"ImageCache"
#define kPath_ResponseCache @"ResponseCache"
#define kHUDQueryViewTag 101
#define kBaseURLStr @"https://coding.net/"

#import "NSObject+Common.h"
#import "AppDelegate.h"
#import "CodingModel.h"
#import "HtmlMedia.h"
#import "Coding-Swift.h"
#import "CodingNetAPIClient.h"

@implementation NSObject (Common)

#pragma mark Tip
+ (NSString *)tipFromError:(NSError *)error{
    if (error && error.userInfo) {
        NSMutableString *tipStr = [[NSMutableString alloc] init];
        if ([error.userInfo objectForKey:@"msg"]) {
            NSArray *msgArray = [[error.userInfo objectForKey:@"msg"] allValues];
            NSUInteger num = [msgArray count];
            for (int i = 0; i < num; i++) {
                NSString *msgStr = [msgArray objectAtIndex:i];
                HtmlMedia *media = [HtmlMedia htmlMediaWithString:msgStr showType:MediaShowTypeAll];
                msgStr = media.contentDisplay;
                if (i+1 < num) {
                    [tipStr appendString:[NSString stringWithFormat:@"%@\n", msgStr]];
                }else{
                    [tipStr appendString:msgStr];
                }
            }
        } else {
            if ([error.userInfo objectForKey:@"NSLocalizedDescription"]) {
                tipStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            } else {
                [tipStr appendFormat:@"ErrorCode%ld", (long)error.code];
            }
        }
        return tipStr;
    }
    return nil;
}

+ (void)showHudTipStr:(NSString *)tipStr
{
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabel.font = [UIFont boldSystemFontOfSize:15.0];
        hud.detailsLabel.text = tipStr;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hideAnimated:YES afterDelay:1.0];
    }
}
+ (instancetype)showHUDQueryStr:(NSString *)titleStr{
    titleStr = titleStr.length > 0? titleStr: @"正在获取数据...";
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
    hud.tag = 101;
    hud.label.text = titleStr;
    hud.label.font = [UIFont boldSystemFontOfSize:15.0];
    hud.margin = 10.f;
    return hud;
}

#pragma mark URL
+(NSString *)baseURLStr
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kBaseURLStr] ?: kBaseURLStr;
}

+ (void)changeBaseURLStrTo:(NSString *)baseURLStr
{
    if (baseURLStr.length <= 0) {
        baseURLStr = kBaseURLStr;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:baseURLStr forKey:kBaseURLStr];
    [CodingNetAPIClient changeJsonClient];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:![self baseURLStrIsProduction] ?@"0x3bbd79": @"0x28303b"]] forBarMetrics:UIBarMetricsDefault];
}

+(BOOL)baseURLStrIsProduction
{
    return [[self baseURLStr] isEqualToString:kBaseURLStr];
}




#pragma mark NetError
-(id)handleResponse:(id)responseJSON{
    return [self handleResponse:responseJSON autoShowError:YES];
}
-(id)handleResponse:(id)responseJSON autoShowError:(BOOL)autoShowError
{
    NSError *error = nil;
    //code为非0值时，表示有错
    NSInteger errorCode = [(NSNumber *)[responseJSON valueForKeyPath:@"code"] integerValue];
    
    if (errorCode != 0) {
        error = [NSError errorWithDomain:[NSObject baseURLStr] code:errorCode userInfo:responseJSON];
        if (errorCode == 1000 || errorCode == 3207) {//用户未登录
            if ([Login isLogin]) {
                [Login doLogout];//已登录的状态要抹掉
                //更新 UI 要延迟 >1.0 秒，否则屏幕可能会不响应触摸事件。。暂不知为何
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [((AppDelegate *)[UIApplication sharedApplication].delegate) setupLoginViewController];
                    kTipAlert(@"%@", [NSObject tipFromError:error]);
                });
            }
        }else{
            //验证码弹窗
            NSMutableDictionary *params = nil;
            if (errorCode == 907) {//operation_need_captcha 比如：每日新增关注用户超过 20 个
                params = @{@"type": @3}.mutableCopy;
            }else if (errorCode == 1018){//user_not_get_request_too_many
                params = @{@"type": @1}.mutableCopy;
            }
            if (params) {
                [NSObject showCaptchaViewParams:params];
            }
            //错误提示
            if (autoShowError) {
                [NSObject showError:error];
            }
        }
    }
    return error;
}

- (void)showCaptchaViewParams:(NSMutableDictionary *)params
{
    //Data
    if (!params) {
        params = @{}.mutableCopy;
    }
    if (!params[@"type"]) {
        params[@"type"] = @1;
    }
    NSString *path = @"api/request_valid";
    NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/getCaptcha?type=%@", [NSObject baseURLStr], params[@"type"]]];
    //UI
    SDCAlertController *alertV = [SDCAlertController alertControllerWithTitle:@"提示" message:@"亲，您操作这么快，不会是机器人吧？\n来，输个验证码先？" preferredStyle:SDCAlertControllerStyleAlert];
    UITextField *textF = [UITextField new];
    textF.backgroundColor = [UIColor whiteColor];
    textF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
    [textF doBorderWidth:0.5 color:nil cornerRadius:2.0];
    UIImageView *imageV = [UIImageView new];
    imageV.backgroundColor = [UIColor lightGrayColor];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    imageV.clipsToBounds = YES;
    imageV.userInteractionEnabled = YES;
    [imageV sd_setImageWithURL:imageURL placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies)];
    [alertV.contentView addSubview:textF];
    [alertV.contentView addSubview:imageV];
    
    [textF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(alertV.contentView).offset(15);
        make.height.mas_equalTo(25);
        make.bottom.equalTo(alertV.contentView).offset(-10);
    }];
    
    [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(alertV.contentView).offset(-15);
        make.left.equalTo(alertV.contentView).offset(10);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(25);
        make.centerY.equalTo(textF);
    }];
    
    kWeakSelf(imageV);
    [imageV bk_whenTapped:^{
        [weakimageV sd_setImageWithURL:imageURL placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies)];
    }];
    kWeakSelf(alertV);
    [alertV addAction:[SDCAlertAction actionWithTitle:@"取消" style:SDCAlertActionStyleCancel handler:nil]];
    [alertV addAction:[SDCAlertAction actionWithTitle:@"还真不是" style:SDCAlertActionStyleDefault handler:nil]];
    alertV.shouldDismissBlock = ^BOOL(SDCAlertAction *action){
        BOOL shouldDismiss = [action.title isEqualToString:@"取消"];
        if (!shouldDismiss) {
            params[@"j_captcha"] = textF.text;}
        [[CodingNetAPIClient sharedJsonClient] requestJsonDataWithPath:path withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
            if (data) {
                [weakalertV dismissWithCompletion:^{
                    [NSObject showHudTipStr:@"验证码正确"];
                }];
            } else {
                [weakimageV sd_setImageWithURL:imageURL placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies)];
            }
        }];
        return shouldDismiss;
    };
    [alertV presentWithCompletion:^{
        [textF becomeFirstResponder];
    }];
}

- (BOOL)showError:(NSError *)error
{
    if ([JDStatusBarNotification isVisible]) {
        return NO;
    }
    NSString *tipStr = [NSObject tipFromError:error];
    [NSObject showHudTipStr:tipStr];
    return YES;
}

#pragma mark LoadData
+ (BOOL)saveResponseData:(NSDictionary *)data toPath:(NSString *)requestPath{
    User *loginUser = [Login curLoginUser];
    if (!loginUser) {
        return NO;
    }else{
        requestPath = [NSString stringWithFormat:@"%@_%@", loginUser.global_key, requestPath];
    }
    if ([self createDirInCache:kPath_ResponseCache]) {
        NSString *abslutePath = [NSString stringWithFormat:@"%@/%@.plist", [self pathInCacheDirectory:kPath_ResponseCache], [requestPath md5Str]];
        return [data writeToFile:abslutePath atomically:YES];
    }else{
        return NO;
    }
}

//返回一个NSDictionary类型的json数据
+ (id) loadResponseWithPath:(NSString *)requestPath{//返回一个NSDictionary类型的json数据
    User *loginUser = [Login curLoginUser];
    if (!loginUser) {
        return nil;
    }else{
        requestPath = [NSString stringWithFormat:@"%@_%@", loginUser.global_key, requestPath];
    }
    NSString *abslutePath = [NSString stringWithFormat:@"%@/%@.plist", [self pathInCacheDirectory:kPath_ResponseCache], [requestPath md5Str]];
    return [NSMutableDictionary dictionaryWithContentsOfFile:abslutePath];
}


+ (BOOL)deleteResponseCacheForPath:(NSString *)requestPath{
    User *loginUser = [Login curLoginUser];
    if (!loginUser) {
        return NO;
    }else{
        requestPath = [NSString stringWithFormat:@"%@_%@", loginUser.global_key, requestPath];
    }
    NSString *abslutePath = [NSString stringWithFormat:@"%@/%@.plist", [self pathInCacheDirectory:kPath_ResponseCache], [requestPath md5Str]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:abslutePath]) {
        return [fileManager removeItemAtPath:abslutePath error:nil];
    }else{
        return NO;
    }
}

+ (BOOL) deleteResponseCache{
    return [self deleteCacheWithPath:kPath_ResponseCache];
}

+ (NSUInteger)getResponseCacheSize {
    NSString *dirPath = [self pathInCacheDirectory:kPath_ResponseCache];
    NSUInteger size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}


+ (BOOL) deleteCacheWithPath:(NSString *)cachePath{
    NSString *dirPath = [self pathInCacheDirectory:cachePath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    bool isDeleted = false;
    if ( isDir == YES && existed == YES )
    {
        isDeleted = [fileManager removeItemAtPath:dirPath error:nil];
    }
    return isDeleted;
}

#pragma mark - File
//获取fileName的完整地址
+ (NSString* )pathInCacheDirectory:(NSString *)fileName
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    return [cachePath stringByAppendingPathComponent:fileName];
}
+ (BOOL)createDirInCache:(NSString *)dirName
{
    NSString *path = [self pathInCacheDirectory:dirName];
    BOOL isDir = NO;
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL existed = [manager fileExistsAtPath:path isDirectory:&isDir];
    BOOL isCreat = NO;
    if (!(isDir == YES && existed == YES)) {
        isCreat = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        isCreat = YES;
    }
    return isCreat;
}

// 图片缓存到本地
+ (BOOL) saveImage:(UIImage *)image imageName:(NSString *)imageName inFolder:(NSString *)folderName
{
    if (!image) {
        return NO;
    }
    if (!folderName) {
        folderName = kPath_ImageCache;
    }
    if ([self createDirInCache:folderName]) {
        NSString * directoryPath = [self pathInCacheDirectory:folderName];
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
        bool isSaved = false;
        if ( isDir == YES && existed == YES )
        {
            isSaved = [[image dataForCodingUpload] writeToFile:[directoryPath stringByAppendingPathComponent:imageName] options:NSAtomicWrite error:nil];
        }
        return isSaved;
    }else{
        return NO;
    }
}
// 获取缓存图片
+ (NSData*) loadImageDataWithName:( NSString *)imageName inFolder:(NSString *)folderName
{
    if (!folderName) {
        folderName = kPath_ImageCache;
    }
    NSString * directoryPath = [self pathInCacheDirectory:folderName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirExisted = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if ( isDir == YES && dirExisted == YES )
    {
        NSString *abslutePath = [NSString stringWithFormat:@"%@/%@", directoryPath, imageName];
        BOOL fileExisted = [fileManager fileExistsAtPath:abslutePath];
        if (!fileExisted) {
            return NULL;
        }
        NSData *imageData = [NSData dataWithContentsOfFile : abslutePath];
        return imageData;
    }
    else
    {
        return NULL;
    }
}

// 删除图片缓存
+ (BOOL) deleteImageCacheInFolder:(NSString *)folderName{
    if (!folderName) {
        folderName = kPath_ImageCache;
    }
    return [self deleteCacheWithPath:folderName];
}

@end
