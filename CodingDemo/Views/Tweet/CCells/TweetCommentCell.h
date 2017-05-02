//
//  TweetCommentCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_TweetComment @"TweetCommentCell"

#import <UIKit/UIKit.h>
#import "CodingModel.h"
#import "UITTTAttributedLabel.h"

@interface TweetCommentCell : UITableViewCell
@property (strong, nonatomic) UITTTAttributedLabel *commentLabel;
- (void)configWithComment:(Comment *)curComment topLine:(BOOL)has;
+(CGFloat)cellHeightWithObj:(id)obj;
@end
