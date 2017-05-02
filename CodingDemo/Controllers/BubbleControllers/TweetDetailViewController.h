//
//  TweetDetailViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/20.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"

@interface TweetDetailViewController : BaseViewController
@property (strong, nonatomic) Tweet *curTweet;
@property (copy, nonatomic) void(^deleteTweetBlock)(Tweet *);
@end
