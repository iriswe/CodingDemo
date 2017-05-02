//
//  UIBadgeView.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/20.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBadgeView : UIView
@property (nonatomic, copy) NSString *badgeValue;

+ (UIBadgeView *)viewWithBadgeTip:(NSString *)badgeValue;
+ (CGSize)badgeSizeWithStr:(NSString *)badgeValue font:(UIFont *)font;

- (CGSize)badgeSizeWithStr:(NSString *)badgeValue;
@end
