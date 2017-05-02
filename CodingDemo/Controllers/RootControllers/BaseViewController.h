//
//  BaseViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/8/31.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

typedef NS_ENUM(NSInteger, AnalyseMethodType) {
    AnalyseMethodTypeJustRefresh = 0,
    AnalyseMethodTypeLazyCreate,
    AnalyseMethodTypeForceCreate
};

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
- (void)tabBarItemClicked;
+ (UIViewController *)analyseVCFromLinkStr:(NSString *)linkStr;
+ (UIViewController *)presentingVC;
@end