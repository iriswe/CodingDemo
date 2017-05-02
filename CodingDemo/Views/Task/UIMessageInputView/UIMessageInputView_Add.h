//
//  UIMessageInputView_Add.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/23.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMessageInputView_Add : UIView
@property (copy, nonatomic) void(^addIndexBlock)(NSInteger);

@end
