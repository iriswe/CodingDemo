//
//  ProjectAboutOthersListCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/21.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

/**
 *  我关注的 我收藏的   只用公开一种状态 不支持侧滑置顶
 */


#define kProjectAboutOthersListCellHeight 104

#import <UIKit/UIKit.h>
#import "CodingModel.h"
#import "SWTableViewCell.h"

@interface ProjectAboutOthersListCell : SWTableViewCell
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;

@end