//
//  TweetCommentMoreCell.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kTweet_CommentFont [UIFont systemFontOfSize:14]

#import "TweetCommentMoreCell.h"
@interface TweetCommentMoreCell ()
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIImageView *commentIconView, *splitLineView;
@end
@implementation TweetCommentMoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        if (!_commentIconView) {
            _commentIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 13, 13)];
            _commentIconView.image = [UIImage imageNamed:@"tweet_more_comment_icon"];
            [self.contentView addSubview:_commentIconView];
        }
        if (!_contentLabel) {
            _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 245, 20)];
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.font = kTweet_CommentFont;
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_contentLabel];
        }
        if (!_splitLineView) {
            _splitLineView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 250, 1)];
            _splitLineView.image = [UIImage imageNamed:@"splitlineImg"];
            [self.contentView addSubview:_splitLineView];
            [_splitLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(10);
                make.top.right.equalTo(self.contentView);
                make.height.mas_equalTo(1.0);
            }];
        }
    }
    return self;
}

+(CGFloat)cellHeight {
    return 12+10*2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.contentLabel.text = [NSString stringWithFormat:@"查看全部%d条评论", _commentNum.intValue];
}
@end
