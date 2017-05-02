//
//  ProjectListTaCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/21.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCellIdentifier_ProjectListTaCell @"ProjectListTaCell"

#import <UIKit/UIKit.h>
#import "CodingModel.h"

@interface ProjectListTaCell : UITableViewCell
@property (nonatomic, strong) Project *project;
+ (CGFloat)cellHeight;
@end