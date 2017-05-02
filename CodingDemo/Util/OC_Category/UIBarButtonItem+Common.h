//
//  UIBarButtonItem+Common.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/1.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Common)

+ (UIBarButtonItem *)itemWithBtnTitle:(NSString *)title target:(id)obj action:(SEL)selector;

@end
