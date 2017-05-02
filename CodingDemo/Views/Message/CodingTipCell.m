//
//  CodingTipCell.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/30.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCodingTipCell_WidthContent (SCREEN_WIDTH - padding_left - kPaddingLeftWidth)
#define kCodingTipCell_FontContent [UIFont systemFontOfSize:15]

#import "CodingTipCell.h"
@interface CodingTipCell ()
@property (strong, nonatomic) UITapImageView *ownerImgView;
@property (strong, nonatomic) UILabel *ownerL;
@property (strong, nonatomic) UIButton *ownerNameBtn;
@property (strong, nonatomic) UILabel *timeLabel;


@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;

@property (strong, nonatomic) UIButton *targetBgBtn;
@property (strong, nonatomic) UIImageView *targetIconView;
@property (strong, nonatomic) UILabel *targetLabel;
@end
@implementation CodingTipCell
static CGFloat padding_height = 45;
static CGFloat padding_left = 30.0;
static CGFloat padding_between_content = 15.0;
static CGFloat target_height = 45.0;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!self.ownerNameBtn) {
            self.ownerNameBtn = [UIButton buttonWithUserStyle];
            self.ownerNameBtn.frame = CGRectMake(padding_left, 15, 50, 20);
            [self.ownerNameBtn addTarget:self action:@selector(userBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.ownerNameBtn];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - kPaddingLeftWidth - 100, 15, 100, 15)];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_timeLabel];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(padding_left, padding_height, kCodingTipCell_WidthContent, 20)];
            _contentLabel.font = kCodingTipCell_FontContent;
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            _contentLabel.delegate = self;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_targetBgBtn) {
            _targetBgBtn = [[UIButton alloc] initWithFrame:CGRectMake(padding_left, 0, kCodingTipCell_WidthContent, target_height)];
            [_targetBgBtn setBackgroundColor:[UIColor colorWithHexString:@"0xEEEEEE"]];
            //target_icon
            _targetIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, target_height, target_height)];
            _targetIconView.contentMode = UIViewContentModeCenter;
            [_targetBgBtn addSubview:_targetIconView];
            //target_content
            _targetLabel = [[UILabel alloc] initWithFrame:CGRectMake(target_height + 10, 0, kCodingTipCell_WidthContent - target_height - 10, target_height)];
            _targetLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _targetLabel.font = [UIFont systemFontOfSize:14];
            _targetLabel.numberOfLines = 0;
            //            _targetLabel.userInteractionEnabled = NO;
            [_targetBgBtn addSubview:_targetLabel];
            
            [self.targetBgBtn addTarget:self action:@selector(targetBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_targetBgBtn];
        }
        
    }
    return self;
}

- (void)targetBtnClicked
{
    if (self.curTip.target_item && self.linkClickedBlock) {
        self.linkClickedBlock(self.curTip.target_item, self.curTip);
    }
}

- (void)userBtnClicked
{
    if (self.curTip.user_item && self.linkClickedBlock) {
        self.linkClickedBlock(self.curTip.user_item, self.curTip);
    }
}

- (void)setCurTip:(CodingTip *)curTip
{
    _curTip = curTip;
    if (!_curTip) {
        return;
    }
    NSString *userName = curTip.user_item.displayStr;
    [_ownerNameBtn setTitleColor:[UIColor colorWithHexString:curTip.user_item.type != HtmlMediaItemType_CustomLink? @"0x3bbd79": @"0x222222"] forState:UIControlStateNormal];
    [_ownerNameBtn setUserTitle:userName font:[UIFont systemFontOfSize:17.0] maxWidth:(kCodingTipCell_WidthContent -80)];
    _timeLabel.text = [_curTip.created_at stringDisplay_HHmm];
    [_contentLabel setLongString:_curTip.content withFitWidth:kCodingTipCell_WidthContent];
    for (HtmlMediaItem *item in _curTip.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    //target
    if (_curTip.target_item) {
        _targetBgBtn.hidden = NO;
        CGFloat curBottomY = padding_height;
        curBottomY += _curTip.content.length > 0? [_curTip.content getHeightWithFont:kCodingTipCell_FontContent constrainedToSize:CGSizeMake(kCodingTipCell_WidthContent, CGFLOAT_MAX)] + padding_between_content: 0;;
        
        [_targetIconView setBackgroundColor:[UIColor colorWithHexString:_curTip.target_type_ColorName]];
        [_targetIconView setImage:[UIImage imageNamed:_curTip.target_type_imageName]];
        _targetLabel.text = _curTip.target_item.displayStr;
        [_targetBgBtn setY:curBottomY];
    }else{
        _targetBgBtn.hidden = YES;
    }
    //unread
    [self.contentView addBadgeTip:_curTip.status.boolValue? @"": kBadgeTipStr withCenterPosition:CGPointMake(kPaddingLeftWidth + 4.0, _ownerNameBtn.center.y)];

}

+ (CGFloat)cellHeightWithObj:(id)obj
{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[CodingTip class]]) {
        CodingTip *curTip = (CodingTip *)obj;
        cellHeight = padding_height;
        cellHeight += curTip.content.length > 0? [curTip.content getHeightWithFont:kCodingTipCell_FontContent constrainedToSize:CGSizeMake(kCodingTipCell_WidthContent, CGFLOAT_MAX)] + padding_between_content: 0;
        if (curTip.target_item) {
            cellHeight += target_height + padding_between_content;
        }
    }
    return cellHeight;
}

#pragma mark TTTAttributedLabelDelegate M
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    HtmlMediaItem *item = [components objectForKey:@"value"];
    if (item && self.linkClickedBlock) {
        self.linkClickedBlock(item, _curTip);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    
    
}

@end
