//
//  UserHeaderView.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/10/10.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "UITapImageView.h"

@interface UserHeaderView : UITapImageView
@property (nonatomic, strong) User *curUser;
@property (nonatomic ,strong) UIImage *bgImage;
@property (nonatomic, copy) void(^userIconClicked)();
@property (nonatomic, copy) void(^fansCountBtnClicked)();
@property (nonatomic, copy) void (^followsCountBtnClicked)();
@property (nonatomic, copy) void (^followBtnClicked)();

+ (id)userHeaderViewWithUser:(User *)user image:(UIImage *)image;
- (void)updateData;
@end
