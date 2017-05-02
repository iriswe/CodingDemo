//
//  TweetCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/28.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_Tweet @"TweetCell"

#import <UIKit/UIKit.h>
#import "CodingModel.h"
#import "UITapImageView.h"
#import "UITTTAttributedLabel.h"

typedef void (^CommentClickedBlock) (Tweet *curTweet, NSInteger index, id sender);
typedef void(^DeleteClickedBlock)(Tweet *curTweet, NSInteger outTweetsIndex);
typedef void (^UserBtnClickedBlock) (User *curUser);
typedef void (^MoreLikersBtnClickedBlock) (Tweet *curTweet);
typedef void (^LocationClickedBlock) (Tweet *curTweet);

@interface TweetCell : UITableViewCell <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TTTAttributedLabelDelegate>

@property (nonatomic, assign) NSInteger outTweetsIndex;
@property (nonatomic, copy) CommentClickedBlock commentClickedBlock;
@property (nonatomic, copy) UserBtnClickedBlock userBtnClickedBlock;
@property (nonatomic, copy) MoreLikersBtnClickedBlock moreLikersBtnClickedBlock;
@property (nonatomic, copy) DeleteClickedBlock deleteClickedBlock;
@property (nonatomic, copy) void(^goToDetailTweetBlock) (Tweet *curTweet);
@property (copy, nonatomic) void (^cellRefreshBlock)();
@property (copy, nonatomic) void (^mediaItemClickedBlock)(HtmlMediaItem *curItem);

- (void)setTweet:(Tweet *)tweet needTopView:(BOOL)needTopView;
+ (CGFloat)cellHeightWithObj:(id)obj needTopView:(BOOL)needTopView;
@end
