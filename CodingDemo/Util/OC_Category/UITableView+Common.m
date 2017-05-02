//
//  UITableView+Common.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/8.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "UITableView+Common.h"

@implementation UITableView (Common)
- (void)addLineforPlainCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withLeftSpace:(CGFloat)leftSpace
{
    [self addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:leftSpace hasSectionLine:YES];

}
- (void)addLineforPlainCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withLeftSpace:(CGFloat)leftSpace hasSectionLine:(BOOL)hasSectionLine
{
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = CGRectInset(cell.bounds, 0, 0);
    CGPathAddRect(path, nil, bounds);
    layer.path = path;
    CFRelease(path);
    if (cell.backgroundColor) {
        layer.fillColor = cell.backgroundColor.CGColor;
    } else if (cell.backgroundView && cell.backgroundView.backgroundColor) {
        layer.fillColor = cell.backgroundView.backgroundColor.CGColor;
    } else {
        layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
    }
    CGColorRef lineColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
    CGColorRef sectionLineColor = lineColor;
    if (indexPath.row == 0 && indexPath.row == [self numberOfRowsInSection:indexPath.section] - 1) {
        //只有一个cell。加上长线&下长线
        if (hasSectionLine) {
            [self layer:layer addLineUp:YES andLong:YES andColor:sectionLineColor andBounds:bounds withLeftSpace:0];
            [self layer:layer addLineUp:NO andLong:YES andColor:sectionLineColor andBounds:bounds withLeftSpace:0];
        }
    } else if (indexPath.row == 0) {
        //第一个cell。加上长线&下短线
        if (hasSectionLine) {
            [self layer:layer addLineUp:YES andLong:YES andColor:sectionLineColor andBounds:bounds withLeftSpace:0];
        }
        [self layer:layer addLineUp:NO andLong:NO andColor:lineColor andBounds:bounds withLeftSpace:leftSpace];
    } else if (indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {
        //最后一个cell。加下长线
        if (hasSectionLine) {
            [self layer:layer addLineUp:NO andLong:YES andColor:sectionLineColor andBounds:bounds withLeftSpace:0];
        }
    } else {
        //中间的cell。只加下短线
        [self layer:layer addLineUp:NO andLong:NO andColor:lineColor andBounds:bounds withLeftSpace:leftSpace];
    }
    UIView *view = [[UIView alloc] initWithFrame:bounds];
    [view.layer insertSublayer:layer atIndex:0];
    cell.backgroundView = view;
}
- (void)layer:(CALayer *)layer addLineUp:(BOOL)isUp andLong:(BOOL)isLong andColor:(CGColorRef)color andBounds:(CGRect)bounds withLeftSpace:(CGFloat)leftSpace
{
    CALayer *linelayer = [[CALayer alloc] init];
    CGFloat lineHeight = (1.0f / [UIScreen mainScreen].scale);
    CGFloat top, left;
    if (isUp) {
        top = 0;
    } else {
        top = bounds.size.height - lineHeight;
    }
    if (isLong) {
        left = 0;
    } else {
        left = leftSpace;
    }
    linelayer.frame = CGRectMake(CGRectGetMinX(bounds) + left, top, bounds.size.width - left, lineHeight);
    linelayer.backgroundColor = color;
    [layer addSublayer:linelayer];
}

- (void)addLineforPlainCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withLeftSpaceAndSectionLine:(CGFloat)leftSpace{
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGRect bounds = CGRectInset(cell.bounds, 0, 0);
    
    CGPathAddRect(pathRef, nil, bounds);
    
    layer.path = pathRef;
    
    CFRelease(pathRef);
    if (cell.backgroundColor) {
        layer.fillColor = cell.backgroundColor.CGColor;//layer的填充色用cell原本的颜色
    }else if (cell.backgroundView && cell.backgroundView.backgroundColor){
        layer.fillColor = cell.backgroundView.backgroundColor.CGColor;
    }else{
        layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
    }
    CGColorRef lineColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
    
    //判断整个tableview 最后的元素
    if ((self.numberOfSections==(indexPath.section+1))&&indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {
        //上短,下长
        //        [self layer:layer addLineUp:TRUE andLong:YES andColor:lineColor andBounds:bounds withLeftSpace:leftSpace];
        [self layer:layer addLineUp:NO andLong:YES andColor:lineColor andBounds:bounds withLeftSpace:0];
    }else
    {
        [self layer:layer addLineUp:NO andLong:NO andColor:lineColor andBounds:bounds withLeftSpace:leftSpace];
    }
    
    UIView *testView = [[UIView alloc] initWithFrame:bounds];
    [testView.layer insertSublayer:layer atIndex:0];
    cell.backgroundView = testView;
    
}

- (UITapImageView *)getHeaderViewWithStr:(NSString *)headerStr andBlock:(void(^)(id obj))tapAction{
    return [self getHeaderViewWithStr:headerStr color:[UIColor colorWithHexString:@"0xeeeeee"] andBlock:tapAction];
}

- (UITapImageView *)getHeaderViewWithStr:(NSString *)headerStr color:(UIColor *)color andBlock:(void(^)(id obj))tapAction{
    UITapImageView *headerView = [[UITapImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,30)];
    [headerView setImage:[UIImage imageWithColor:color]];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, CGRectGetHeight(headerView.frame))];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
    if (kDevice_Is_iPhone6Plus) {
        headerLabel.font = [UIFont systemFontOfSize:14];
    }else{
        headerLabel.font = [UIFont systemFontOfSize:kScaleFrom_iPhone5_Desgin(12)];
    }
    headerLabel.text = headerStr;
    [headerView addSubview:headerLabel];
    [headerView addTapBlock:tapAction];
    return headerView;
}

- (UITapImageView *)getHeaderViewWithStr:(NSString *)headerStr color:(UIColor *)color leftNoticeColor:(UIColor*)noticeColor andBlock:(void(^)(id obj))tapAction{
    UITapImageView *headerView = [[UITapImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    [headerView setImage:[UIImage imageWithColor:color]];
    
    UIView* noticeView=[[UIView alloc] initWithFrame:CGRectMake(12, 14, 3, 16)];
    noticeView.backgroundColor=noticeColor;
    [headerView addSubview:noticeView];
    
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12+3+10, 7, SCREEN_WIDTH-20, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
    if (kDevice_Is_iPhone6Plus) {
        headerLabel.font = [UIFont systemFontOfSize:14];
    }else{
        headerLabel.font = [UIFont systemFontOfSize:kScaleFrom_iPhone5_Desgin(12)];
    }
    
    CGFloat lineHeight = (1.0f / [UIScreen mainScreen].scale);
    UIView *seperatorline=[[UIView alloc] initWithFrame:CGRectMake(0, 44-lineHeight,SCREEN_WIDTH , lineHeight)];
    seperatorline.backgroundColor=[UIColor colorWithHexString:@"0xdddddd"];
    [headerView addSubview:seperatorline];
    
    headerLabel.text = headerStr;
    [headerView addSubview:headerLabel];
    [headerView addTapBlock:tapAction];
    return headerView;
    
}
@end
