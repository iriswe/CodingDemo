//
//  RootTabViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/14.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "RootTabViewController.h"
#import "Project_RootViewController.h"
#import "RDVTabBarItem.h"
#import "UnReadManager.h"
#import "MyTask_RootViewController.h"
#import "BaseNavigationController.h"
#import "RKSwipeBetweenViewControllers.h"
#import "Tweet_RootViewController.h"
#import "Message_RootViewController.h"
#import "Me_RootViewController.h"

@interface RootTabViewController ()

@end

@implementation RootTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViewControllers];

}
#pragma mark Private_M
- (void)setupViewControllers
{
    Project_RootViewController *project = [[Project_RootViewController alloc] init];
    RAC(project, rdv_tabBarItem.badgeValue) = [RACSignal combineLatest:
                                               @[RACObserve([UnReadManager shareManager], project_update_count)]
                                                                reduce:^id(NSNumber *project_update_count){
                                                                    return project_update_count.integerValue > 0? kBadgeTipStr: @"";
                                                                }];
    UINavigationController *nav_project = [[BaseNavigationController alloc] initWithRootViewController:project];
    
    MyTask_RootViewController *mytask = [[MyTask_RootViewController alloc] init];
    UINavigationController *nav_mytask = [[BaseNavigationController alloc] initWithRootViewController:mytask];
    
    
    RKSwipeBetweenViewControllers *nav_tweet = [RKSwipeBetweenViewControllers newSwipeBetweenViewControllers];
    [nav_tweet.viewControllerArray addObjectsFromArray:@[[Tweet_RootViewController newTweetVCWithType:Tweet_RootViewControllerTypeAll],
                                                        [Tweet_RootViewController newTweetVCWithType:Tweet_RootViewControllerTypeFriend],
                                                        [Tweet_RootViewController newTweetVCWithType:Tweet_RootViewControllerTypeHot]]];
    nav_tweet.buttonText = @[@"冒泡广场", @"朋友圈", @"热门冒泡"];
    Message_RootViewController *message = [[Message_RootViewController alloc] init];
    RAC(message, rdv_tabBarItem.badgeValue) = [RACSignal combineLatest:@[RACObserve([UnReadManager shareManager], messages),
                                                                         RACObserve([UnReadManager shareManager], notifications)]
                                                                reduce:^id(NSNumber *messages, NSNumber *notifications){
                                                                    NSString *badgeTip = @"";
                                                                    NSNumber *unreadCount = [NSNumber numberWithInteger:messages.integerValue +notifications.integerValue];
                                                                    if (unreadCount.integerValue > 0) {
                                                                        if (unreadCount.integerValue > 99) {
                                                                            badgeTip = @"99+";
                                                                        }else{
                                                                            badgeTip = unreadCount.stringValue;
                                                                        }
                                                                    }
                                                                    return badgeTip;
                                                                }];
    UINavigationController *nav_message = [[BaseNavigationController alloc] initWithRootViewController:message];
    
    Me_RootViewController *me = [[Me_RootViewController alloc] init];
    me.isRoot = YES;
    UINavigationController *nav_me = [[BaseNavigationController alloc] initWithRootViewController:me];
    
    [self setViewControllers:@[nav_project, nav_mytask, nav_tweet, nav_message, nav_me]];
    self.delegate = self;
    
    [self customizeTabBarForController];

}

- (void)customizeTabBarForController
{
    UIImage *backImage = [UIImage imageNamed:@"tabbar_background"];
    NSArray *tabbarItemImages = @[@"project", @"task", @"tweet", @"privatemessage", @"me"];
    NSArray *tabbarItemNames = @[@"项目", @"任务", @"冒泡", @"消息", @"我"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [self tabBar].items) {
        item.titlePositionAdjustment = UIOffsetMake(0, 3);
        [item setBackgroundSelectedImage:backImage withUnselectedImage:backImage];
        UIImage *selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", [tabbarItemImages objectAtIndex:index]]];
        UIImage *unselectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabbarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        [item setTitle:[tabbarItemNames objectAtIndex:index]];
        index ++;
    }
}

#pragma mark - RDVTabBarControllerDelegate
- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if (tabBarController.selectedViewController != viewController) {
        return YES;
    }
    if (![viewController isKindOfClass:[UINavigationController class]]) {
        return YES;
    }
    UINavigationController *nav = (UINavigationController *)viewController;
    if (nav.topViewController != nav.viewControllers[0]) {
        return YES;
    }
    if ([nav isKindOfClass:[RKSwipeBetweenViewControllers class]]) {
        RKSwipeBetweenViewControllers *swipeVC = (RKSwipeBetweenViewControllers *)nav;
        if ([[swipeVC curViewController] isKindOfClass:[BaseViewController class]]) {
            BaseViewController *rootVC = (BaseViewController *)[swipeVC curViewController];
            [rootVC tabBarItemClicked];
        }
    }else{
        if ([nav.topViewController isKindOfClass:[BaseViewController class]]) {
            BaseViewController *rootVC = (BaseViewController *)nav.topViewController;
            [rootVC tabBarItemClicked];
        }
    }
    return YES;
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
