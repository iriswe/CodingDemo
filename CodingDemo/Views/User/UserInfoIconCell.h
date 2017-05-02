//
//  UserInfoIconCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/10/12.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_UserInfoIconCell @"UserInfoIconCell"

#import <UIKit/UIKit.h>

@interface UserInfoIconCell : UITableViewCell
- (void)setTitle:(NSString *)title icon:(NSString *)iconName;
+ (CGFloat)cellHeight;
- (void)addTipIcon;
- (void)removeTip;
@end
