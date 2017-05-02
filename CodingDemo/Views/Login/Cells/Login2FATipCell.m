//
//  Login2FATipCell.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/12.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "Login2FATipCell.h"

@implementation Login2FATipCell

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
        self.userInteractionEnabled = NO;
        if (!_tipLabel) {
            _tipLabel = [UILabel new];
            _tipLabel.layer.masksToBounds = YES;
            _tipLabel.layer.cornerRadius = 2.0;
            
            _tipLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.minimumScaleFactor = 0.5;
            _tipLabel.adjustsFontSizeToFitWidth = YES;
            
            _tipLabel.textColor = [UIColor whiteColor];
            [self.contentView addSubview:_tipLabel];
            [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, kLoginPaddingLeftWidth, 0, kLoginPaddingLeftWidth));
            }];
        }
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
