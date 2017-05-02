//
//  CodingShareView.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CodingShareView : UIView
+ (void)showShareViewWithObj:(NSObject *)curObj;
@end

@interface CodingShareView_Item : UIView
@property (strong, nonatomic) NSString *snsName;
@property (copy, nonatomic) void(^clickedBlock)(NSString *snsName);
+ (instancetype)itemWithSnsName:(NSString *)snsName;
+ (CGFloat)itemWidth;
+ (CGFloat)itemHeight;
@end
