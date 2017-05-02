//
//  Input_OnlyText_Cell.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/1.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "Input_OnlyText_Cell.h"

@implementation Input_OnlyText_Cell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (NSString *)randomCellIdentifierOfPhoneCodeType{
    return [NSString stringWithFormat:@"%@_%ld", kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix, random()];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_textField) {
            _textField = ({
                UITextField *textField = [[UITextField alloc] init];
                [textField addTarget:self action:@selector(editDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
                [textField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
                [textField addTarget:self action:@selector(editDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
                textField;
            });
            [self.contentView addSubview:_textField];
            [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
                make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
        }
        if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Text]) {
        } else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Captcha]) {
            kWeakSelf(self)
            if (!_captchaView) {
                _captchaView = ({
                    UITapImageView *captchaView = [[UITapImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60 - kLoginPaddingLeftWidth, (44-25)/2, 60, 25)];
                    captchaView.layer.masksToBounds = YES;
                    captchaView.layer.cornerRadius = 5;
                    [captchaView addTapBlock:^(id obj) {
                        [weakself refreshCaptchaImage];
                    }];
                    captchaView;
                });
                [self.contentView addSubview:_captchaView];
            }
            if (!_activityIndicator) {
                _activityIndicator = ({
                    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    _activityIndicator.hidesWhenStopped = YES;
                    [self.contentView addSubview:_activityIndicator];
                    [_activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.center.equalTo(self.captchaView);
                    }];
                    activityIndicator;
                });
            }
        } else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]) {
            if (!_passwordBtn) {
                _textField.secureTextEntry = YES;
                _passwordBtn = ({
                    UIButton *passwordBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 44- kLoginPaddingLeftWidth, 0, 44, 44)];
                    [passwordBtn setImage:[UIImage imageNamed:@"password_unlook"] forState:UIControlStateNormal];
                    [passwordBtn addTarget:self action:@selector(passwordBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [self.contentView addSubview:passwordBtn];
                    passwordBtn;
                });

        }
        } else if ([reuseIdentifier hasPrefix:kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix]) {
            if (!_verify_codeBtn) {
                _verify_codeBtn = ({
                    PhoneCodeButton *btn = [[PhoneCodeButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80 - kLoginPaddingLeftWidth, (44-25)/2, 80, 25)];
                    [btn addTarget:self action:@selector(phoneCodeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [self.contentView addSubview:btn];
                    btn;
                });
            }
        } else if ([reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Phone]){
            _countryCodeL = ({
                UILabel *label = [UILabel new];
                label.font = [UIFont systemFontOfSize:17];
                label.textColor = [UIColor colorWithHexString:@"0x3bbd79"];
                [self.contentView addSubview:label];
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                    make.centerY.equalTo(self.contentView);
                }];
                label;
            });
            UIView *lineView = [UIView new];
            lineView.backgroundColor = [UIColor colorWithHexString:@"0xCCCCCC"];
            [self.contentView addSubview:lineView];
            [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.countryCodeL.mas_right).offset(8);
                make.centerY.equalTo(self.countryCodeL);
                make.width.mas_offset(0.5);
                make.height.mas_equalTo(15.0);
            }];
            UIButton *bgBtn = ({
                UIButton *button = [UIButton new];
                [self.contentView addSubview:button];
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.top.bottom.equalTo(self.contentView);
                    make.right.equalTo(lineView);
                }];
                button;
            });
            [bgBtn addTarget:self action:@selector(countryCodeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [_textField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(20);
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(lineView.mas_right).offset(8.0);
            }];
        }
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_isForLoginVC) {
        if (!_clearBtn) {
            _clearBtn = [UIButton new];
            _clearBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            [_clearBtn setImage:[UIImage imageNamed:@"text_clear_btn"] forState:UIControlStateNormal];
            [_clearBtn addTarget:self action:@selector(clearBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_clearBtn];
            [_clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
        }
        if (!_lineView) {
            _lineView = [UIView new];
            _lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff" andAlpha:0.5];
            [self.contentView addSubview:_lineView];
            [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0.5);
                make.left.equalTo(self.contentView).offset(kLoginPaddingLeftWidth);
                make.right.equalTo(self.contentView).offset(-kLoginPaddingLeftWidth);
                make.bottom.equalTo(self.contentView);
            }];
        }
    }
    self.backgroundColor = _isForLoginVC? [UIColor clearColor]: [UIColor whiteColor];
    self.textField.clearButtonMode = _isForLoginVC? UITextFieldViewModeNever: UITextFieldViewModeWhileEditing;
    self.textField.textColor = _isForLoginVC? [UIColor whiteColor]: [UIColor colorWithHexString:@"0x222222"];
    self.lineView.hidden = !_isForLoginVC;
    self.clearBtn.hidden = YES;
    
    UIView *rightElement;
    if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Text]) {
        rightElement = nil;
    }else if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Captcha]){
        rightElement = _captchaView;
        [self refreshCaptchaImage];
    }else if ([self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]){
        rightElement = _passwordBtn;
    }else if ([self.reuseIdentifier hasPrefix:kCellIdentifier_Input_OnlyText_Cell_PhoneCode_Prefix]){
        rightElement = _verify_codeBtn;
    }
    
    [_clearBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = rightElement? (CGRectGetMinX(rightElement.frame) - SCREEN_WIDTH - 10): -kLoginPaddingLeftWidth;
        make.right.equalTo(self.contentView).offset(offset);
    }];
    
    [_textField mas_updateConstraints:^(MASConstraintMaker *make) {
        CGFloat offset = rightElement? (CGRectGetMinX(rightElement.frame) - SCREEN_WIDTH - 10): -kLoginPaddingLeftWidth;
        offset -= _isForLoginVC? 30: 0;
        make.right.equalTo(self.contentView).offset(offset);
    }];
    
}
//this is called just before the cell is returned from the table view methoddequeueReusableCellWithIdentifier
- (void)prepareForReuse
{
    [super prepareForReuse];
    _isForLoginVC = NO;
    if (![self.reuseIdentifier isEqualToString:kCellIdentifier_Input_OnlyText_Cell_Password]) {
        self.textField.secureTextEntry = NO;
    }
    self.textField.userInteractionEnabled = YES;
    self.textField.keyboardType = UIKeyboardTypeDefault;
    
    self.textValueChangedBlock = nil;
    self.editDidBeginBlock = nil;
    self.editDidEndBlock = nil;
    self.phoneCodeBtnClickedBlock = nil;
}

#pragma mark Button

- (void)clearBtnClicked:(id)sender {
    self.textField.text = @"";
    [self textValueChanged:nil];
}

- (void)phoneCodeButtonClicked:(id)sender{
    if (self.phoneCodeBtnClickedBlock) {
        self.phoneCodeBtnClickedBlock(sender);
    }
}
- (void)countryCodeBtnClicked:(id)sender{
    if (_countryCodeBtnClickedBlock) {
        _countryCodeBtnClickedBlock();
    }
}
//CaptView
- (void)refreshCaptchaImage
{
    kWeakSelf(self)
    if (_activityIndicator.isAnimating) {
        return;
    }
    [_activityIndicator startAnimating];
    [self.captchaView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@api/getCaptcha", [NSObject baseURLStr]]] placeholderImage:nil options:(SDWebImageRetryFailed | SDWebImageRefreshCached | SDWebImageHandleCookies) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakself.activityIndicator stopAnimating];
    }];
    
}
#pragma mark TextField
- (void)editDidBegin:(id )sender
{
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff"];
    self.clearBtn.hidden = _isForLoginVC? self.textField.text.length <= 0: YES;
}


- (void)editDidEnd:(id)sender {
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"0xffffff" andAlpha:0.5];
    self.clearBtn.hidden = YES;
    
    if (self.editDidEndBlock) {
        self.editDidEndBlock(self.textField.text);
    }
}

- (void)textValueChanged:(id)sender {
    self.clearBtn.hidden = _isForLoginVC? self.textField.text.length <= 0: YES;
    
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(self.textField.text);
    }
}

//PassWord
- (void)passwordBtnClicked:(UIButton *)button
{
    _textField.secureTextEntry = !_textField.secureTextEntry;
    [button setImage:[UIImage imageNamed:_textField.secureTextEntry? @"password_unlook": @"password_look"] forState:UIControlStateNormal];
}

- (void)setPlaceholder:(NSString *)phStr value:(NSString *)valueStr
{
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:phStr? phStr: @"" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:_isForLoginVC? @"0xffffff": @"0x999999" andAlpha: _isForLoginVC? 0.5: 1.0]}];
    self.textField.text = valueStr;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
