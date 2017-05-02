//
//  UITapImageView.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/5.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITapImageView : UIImageView

- (void)addTapBlock:(void(^)(id obj))tapAction;
-(void)setImageWithUrl:(NSURL *)imgUrl placeholderImage:(UIImage *)placeholderImage tapBlock:(void(^)(id obj))tapAction;

@end
