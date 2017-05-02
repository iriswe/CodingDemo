//
//  ProjectAboutMeListCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/21.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

/**
 *  全部项目 我创建的 我参与的   cell样式     :(1)支持公开/私有 两种状态，(2)支持侧滑，(3)支持置顶标识
 */
#define kProjectAboutMeListCellHeight 104

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "CodingModel.h"

@interface ProjectAboutMeListCell : SWTableViewCell
@property(nonatomic,assign)BOOL openKeywords;
@property(nonatomic,assign)BOOL hidePrivateIcon;
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;
@end
