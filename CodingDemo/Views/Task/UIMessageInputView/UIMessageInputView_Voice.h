//
//  UIMessageInputView_Voice.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/23.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMessageInputView_Voice : UIView

@property (copy, nonatomic) void(^recordSuccessfully)(NSString*, NSTimeInterval);

@end
