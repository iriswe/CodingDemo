//
//  UITapImageView.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/5.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "UITapImageView.h"

@interface UITapImageView ()

@property (nonatomic, copy) void(^tapAction)(id);

@end

@implementation UITapImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)addTapBlock:(void(^)(id obj))tapAction
{
    self.tapAction = tapAction;
    if (![self gestureRecognizers]) {
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
}

- (void)tap
{
    if (self.tapAction) {
        self.tapAction(self);
    }
}

-(void)setImageWithUrl:(NSURL *)imgUrl placeholderImage:(UIImage *)placeholderImage tapBlock:(void(^)(id obj))tapAction{
    [self sd_setImageWithURL:imgUrl placeholderImage:placeholderImage];
    [self addTapBlock:tapAction];
}


@end
