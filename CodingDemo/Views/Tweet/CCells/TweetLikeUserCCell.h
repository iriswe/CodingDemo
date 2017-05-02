//
//  TweetLikeUserCCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCCellIdentifier_TweetLikeUser @"TweetLikeUserCCell"

#import <UIKit/UIKit.h>
#import "CodingModel.h"

@interface TweetLikeUserCCell : UICollectionViewCell

- (void)configWithUser:(User *)user rewarded:(BOOL)rewarded;

@end
