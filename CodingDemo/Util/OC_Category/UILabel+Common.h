//
//  UILabel+Common.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/23.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Common)

- (void) setLongString:(NSString *)str withFitWidth:(CGFloat)width;
- (void) setLongString:(NSString *)str withFitWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight;
- (void) setLongString:(NSString *)str withVariableWidth:(CGFloat)maxWidth;

- (void)setAttrStrWithStr:(NSString *)text diffColorStr:(NSString *)diffColorStr diffColor:(UIColor *)diffColor;
- (void)addAttrDict:(NSDictionary *)attrDict toStr:(NSString *)str;
- (void)addAttrDict:(NSDictionary *)attrDict toRange:(NSRange)range;

+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor;
@end
