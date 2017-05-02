//
//  CountryViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/6.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"

@interface CountryViewController : BaseViewController
@property (nonatomic, copy) void(^selectedBlock)(NSDictionary *country);
@end
