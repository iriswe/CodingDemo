//
//  ConversationCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/30.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_Conversation @"ConversationCell"

#import <UIKit/UIKit.h>

@interface ConversationCell : UITableViewCell
@property (strong, nonatomic) PrivateMessage *curPriMsg;

+ (CGFloat)cellHeight;
@end
