//
//  ProjectPublicListCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/21.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

/**
 *  项目广场
 */

#define kProjectPublicListCellHeight 114

#import <UIKit/UIKit.h>
#import "CodingModel.h"
#import "SWTableViewCell.h"

@interface ProjectPublicListCell : SWTableViewCell
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;

@end