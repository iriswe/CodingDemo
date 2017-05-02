//
//  CountryCodeCell.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/6.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "CountryCodeCell.h"

@interface CountryCodeCell ()
@property (strong, nonatomic) UILabel *leftL, *rightL;
@end

@implementation CountryCodeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _leftL = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
            label;
        });
        _rightL = ({
            UILabel *label = [UILabel new];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
            label;
        });
    }
    return self;
}
- (void)setCountryCodeDict:(NSDictionary *)countryCodeDict
{
    _countryCodeDict = countryCodeDict;
    _leftL.text = _countryCodeDict[@"country"];
    _rightL.text = [NSString stringWithFormat:@"+%@", _countryCodeDict[@"country_code"]];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
