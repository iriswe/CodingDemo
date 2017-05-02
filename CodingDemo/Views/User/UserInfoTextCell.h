//
//  UserInfoTextCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/10/12.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_UserInfoTextCell @"UserInfoTextCell"

#import <UIKit/UIKit.h>

@interface UserInfoTextCell : UITableViewCell
- (void)setTitle:(NSString *)title value:(NSString *)value;
+ (CGFloat)cellHeight;
@end
