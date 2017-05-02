//
//  TweetMediaItemCCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCCellIdentifier_TweetMediaItemSingle @"TweetMediaItemSingleCCell"

#import "TweetMediaItemCCell.h"
#import "HtmlMedia.h"

@interface TweetMediaItemSingleCCell : TweetMediaItemCCell
@property (copy, nonatomic) void (^refreshSingleCCellBlock)();
+(CGSize)ccellSizeWithObj:(id)obj;

@end
