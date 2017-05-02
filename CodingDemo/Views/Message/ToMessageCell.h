//
//  ToMessageCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/30.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_ToMessage @"ToMessageCell"

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ToMessageType) {
    ToMessageTypeAT = 0,
    ToMessageTypeComment,
    ToMessageTypeSystemNotification
};

@interface ToMessageCell : UITableViewCell

@property (assign, nonatomic) ToMessageType type;
@property (strong, nonatomic) NSNumber *unreadCount;
+ (CGFloat)cellHeight;


@end