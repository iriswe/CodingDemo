//
//  TweetLikeUserCCell.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kTweetCell_LikeUserCCell_Height 25.0

#import "TweetLikeUserCCell.h"
@interface TweetLikeUserCCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *likesLabel;

@end
@implementation TweetLikeUserCCell
- (void)configWithUser:(User *)user rewarded:(BOOL)rewarded
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTweetCell_LikeUserCCell_Height, kTweetCell_LikeUserCCell_Height)];
        _imgView.layer.masksToBounds = YES;
        _imgView.layer.cornerRadius = kTweetCell_LikeUserCCell_Height/2;
        _imgView.layer.borderColor = [UIColor colorWithHexString:@"0xFFAE03"].CGColor;
        [self.contentView addSubview:_imgView];
    }
    if (user) {
        [self.imgView sd_setImageWithURL:[user.avatar urlImageWithCodePathResizeToView:_imgView] placeholderImage:kPlaceholderMonkeyRoundView(_imgView)];
        if (_likesLabel) {
            _likesLabel.hidden = YES;
        }
    }else{
        [self.imgView sd_setImageWithURL:nil];
        [self.imgView setImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xdadada"]]];
        if (!_likesLabel) {
            _likesLabel = [[UILabel alloc] initWithFrame:_imgView.bounds];
            _likesLabel.backgroundColor = [UIColor clearColor];
            _likesLabel.textColor = [UIColor whiteColor];
            _likesLabel.font = [UIFont systemFontOfSize:15];
            _likesLabel.minimumScaleFactor = 0.5;
            _likesLabel.textAlignment = NSTextAlignmentCenter;
            [self.imgView addSubview:_likesLabel];
        }
        _likesLabel.text = @"···";
        _likesLabel.hidden = NO;
    }
    self.imgView.layer.borderWidth = rewarded? 1.0 : 0.0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}
@end
