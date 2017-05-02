//
//  UISearchBar+Common.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/19.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "UISearchBar+Common.h"

@implementation UISearchBar (Common)
- (void)insertBGColor:(UIColor *)backgroundColor
{
    static NSInteger customBGTag = 999;
    UIView *view = [[self subviews] firstObject];
    [[view subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == customBGTag) {
            [obj removeFromSuperview];
        }
    }];
    
    if (backgroundColor) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:backgroundColor withFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) + 20)]];
        [imageView setY:-20];
        imageView.tag = customBGTag;
        [[[self subviews] firstObject] insertSubview:imageView atIndex:1];
    }
}
@end
