//
//  ProjectListCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/20.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_ProjectList @"ProjectListCell"
#import "SWTableViewCell.h"
#import "CodingModel.h"

@interface ProjectListCell : SWTableViewCell
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;

+ (CGFloat)cellHeight;
@end
