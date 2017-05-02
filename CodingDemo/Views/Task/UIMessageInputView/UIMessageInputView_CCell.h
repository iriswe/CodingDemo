//
//  UIMessageInputView_CCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/23.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#define kCCellIdentifier_UIMessageInputView_CCell @"UIMessageInputView_CCell"

#import <UIKit/UIKit.h>
#import "UIMessageInputView_Media.h"


@interface UIMessageInputView_CCell : UICollectionViewCell
@property (copy, nonatomic) void (^deleteBlock)(UIMessageInputView_Media *toDelete);
- (void)setCurMedia:(UIMessageInputView_Media *)curMedia andTotalCount:(NSInteger)totalCount;
@end
