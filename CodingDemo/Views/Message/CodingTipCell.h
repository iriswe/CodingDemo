//
//  CodingTipCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/30.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_CodingTip @"CodingTipCell"

#import <UIKit/UIKit.h>
#import "CodingModel.h"
#import "UITTTAttributedLabel.h"

@interface CodingTipCell : UITableViewCell <TTTAttributedLabelDelegate>
@property (strong, nonatomic) CodingTip *curTip;
@property (copy, nonatomic) void(^linkClickedBlock)(HtmlMediaItem *item, CodingTip *tip);
+ (CGFloat)cellHeightWithObj:(id)obj;

@end
