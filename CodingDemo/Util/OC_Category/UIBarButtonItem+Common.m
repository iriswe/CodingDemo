//
//  UIBarButtonItem+Common.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/1.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "UIBarButtonItem+Common.h"

@implementation UIBarButtonItem (Common)

+ (UIBarButtonItem *)itemWithBtnTitle:(NSString *)title target:(id)obj action:(SEL)selector
{
    UIBarButtonItem *barbtnItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:obj action:selector];
    [barbtnItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} forState:UIControlStateDisabled];
    return barbtnItem;
}

@end
