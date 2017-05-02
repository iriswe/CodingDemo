//
//  UITTTAttributedLabel.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/2.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "TTTAttributedLabel.h"

typedef void(^UITTTLabelTapBlock)(id aObj);

@interface UITTTAttributedLabel : TTTAttributedLabel
-(void)addLongPressForCopy;
-(void)addLongPressForCopyWithBGColor:(UIColor *)color;
-(void)addTapBlock:(UITTTLabelTapBlock)block;
-(void)addDeleteBlock:(UITTTLabelTapBlock)block;
@end
