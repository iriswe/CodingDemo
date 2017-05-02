//
//  PopFliterMenu.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/19.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopFliterMenu : UIView
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items;

@property (assign) BOOL showStatus;
@property (nonatomic,assign) NSInteger selectNum;  //选中数据
@property (nonatomic, copy) void(^clickBlock)(NSInteger);
@property (nonatomic , copy) void (^closeBlock)();
//显示视图
- (void)showMenuAtView:(UIView *)containerView;
//取消视图
- (void)dismissMenu;
- (void)refreshMenuDate;
@end
