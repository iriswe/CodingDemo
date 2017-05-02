//
//  Project_RootViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/14.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"
#import "CodingModel.h"
#import "XTSegmentControl.h"
#import "iCarousel.h"
#import "SearchBar.h"

@interface Project_RootViewController : BaseViewController
@property (assign, nonatomic) BOOL icarouselScrollEnabled;
@property (assign, nonatomic) BOOL useNewStyle;
@property (strong, nonatomic) XTSegmentControl *mySegmentControl;
@property (assign, nonatomic) NSInteger oldSelectedIndex;

@end
