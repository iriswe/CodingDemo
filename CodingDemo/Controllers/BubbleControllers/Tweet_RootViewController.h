//
//  Tweet_RootViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/14.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"
typedef NS_ENUM(NSUInteger, Tweet_RootViewControllerType) {
    Tweet_RootViewControllerTypeAll = 0,
    Tweet_RootViewControllerTypeFriend,
    Tweet_RootViewControllerTypeHot,
    Tweet_RootViewControllerTypeMine
};
@interface Tweet_RootViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

+ (instancetype)newTweetVCWithType:(Tweet_RootViewControllerType)type;

@end
