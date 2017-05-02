//
//  ProjectTagLabel.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/23.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodingModel.h"

@interface ProjectTagLabel : UILabel
@property (strong, nonatomic) ProjectTag *curTag;
- (void)setup;//调整UI。设置 curTag 的时候会自动调整，其他属性默认不调整。

+ (instancetype)labelWithTag:(ProjectTag *)curTag font:(UIFont *)font height:(CGFloat)height widthPadding:(CGFloat)width_padding;
@end
