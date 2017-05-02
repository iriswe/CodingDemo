//
//  WebViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/2.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "WebViewController.h"
#import "RootTabViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
+ (instancetype)webVCWithUrlStr:(NSString *)curUrlStr{
    if (!curUrlStr || curUrlStr.length <= 0 || [curUrlStr hasPrefix:kCodingAppScheme]) {
        return nil;
    }
    
    //    NSString *tasksRegexStr = @"/user/tasks[\?]?";
    NSString *tasksRegexStr = @"/user/tasks";
    if ([curUrlStr captureComponentsMatchedByRegex:tasksRegexStr].count > 0){
        if ([kKeyWindow.rootViewController isKindOfClass:[RootTabViewController class]]) {
            RootTabViewController *vc = (RootTabViewController *)kKeyWindow.rootViewController;
            vc.selectedIndex = 1;
            return nil;
        }
    }
    
    NSString *proName = [NSString stringWithFormat:@"/%@.app/", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSURL *curUrl;
    if (![curUrlStr hasPrefix:@"/"] || [curUrlStr rangeOfString:proName].location != NSNotFound) {
        curUrl = [NSURL URLWithString:curUrlStr];
    }else{
        curUrl = [NSURL URLWithString:curUrlStr relativeToURL:[NSURL URLWithString:[NSObject baseURLStr]]];
    }
    
    if (!curUrl) {
        return nil;
    }else{
        return [[self alloc] initWithURL:curUrl];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
