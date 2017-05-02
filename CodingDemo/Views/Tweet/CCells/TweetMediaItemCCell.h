//
//  TweetMediaItemCCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCCellIdentifier_TweetMediaItem @"TweetMediaItemCCell"

#import <UIKit/UIKit.h>
#import "YLImageView.h"

@interface TweetMediaItemCCell : UICollectionViewCell
@property (strong, nonatomic) HtmlMediaItem *curMediaItem;
@property (strong, nonatomic) YLImageView *imgView;
@property (strong, nonatomic) UIImageView *gifMarkView;

+(CGSize)ccellSizeWithObj:(id)obj;
@end
