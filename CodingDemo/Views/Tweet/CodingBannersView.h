//
//  CodingBannersView.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/28.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CodingBanner;
@interface CodingBannersView : UIView
@property (strong, nonatomic) NSArray *curBannerList;
@property (nonatomic , copy) void (^tapActionBlock)(CodingBanner *tapedBanner);
- (void)reloadData;
@end
@interface CodingBanner : NSObject
@property (strong, nonatomic) NSNumber *id, *status;
@property (strong, nonatomic) NSString *title, *image, *link, *name;
@end