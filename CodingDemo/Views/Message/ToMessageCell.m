//
//  ToMessageCell.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/30.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "ToMessageCell.h"

@implementation ToMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setType:(ToMessageType)type{
    _type = type;
    NSString *imageName, *titleStr;
    switch (_type) {
        case ToMessageTypeAT:
            imageName = @"messageAT";
            titleStr = @"@我的";
            break;
        case ToMessageTypeComment:
            imageName = @"messageComment";
            titleStr = @"评论";
            break;
        case ToMessageTypeSystemNotification:
            imageName = @"messageSystem";
            titleStr = @"系统通知";
            break;
        default:
            break;
    }
    self.imageView.image = [UIImage imageNamed:imageName];
    self.textLabel.text = titleStr;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(kPaddingLeftWidth, ([ToMessageCell cellHeight]-48)/2, 48, 48);
    self.textLabel.frame = CGRectMake(75, ([ToMessageCell cellHeight]-30)/2, (SCREEN_WIDTH - 120), 30);
    NSString *badgeTip = @"";
    if (_unreadCount && _unreadCount.integerValue > 0) {
        if (_unreadCount.integerValue > 99) {
            badgeTip = @"99+";
        }else{
            badgeTip = _unreadCount.stringValue;
        }
        self.accessoryType = UITableViewCellAccessoryNone;
    }else{
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [self.contentView addBadgeTip:badgeTip withCenterPosition:CGPointMake(SCREEN_WIDTH-25, [ToMessageCell cellHeight]/2)];
}

+ (CGFloat)cellHeight{
    return 61.0;
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
