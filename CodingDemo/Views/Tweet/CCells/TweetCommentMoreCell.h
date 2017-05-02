//
//  TweetCommentMoreCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_TweetCommentMore @"TweetCommentMoreCell"

#import <UIKit/UIKit.h>

@interface TweetCommentMoreCell : UITableViewCell
@property (strong, nonatomic) NSNumber *commentNum;
+(CGFloat)cellHeight;
@end
