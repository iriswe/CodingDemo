//
//  RegisterViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/1.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"
#import "CodingModel.h"

typedef NS_ENUM(NSInteger) {
    RegisterMethodEamil = 0,
    RegisterMethodPhone
} RegisterMethodType;

@interface RegisterViewController : BaseViewController

+ (instancetype)initWithRegisterMethodTYpe:(RegisterMethodType)type registerModel:(Register *)obj;

@end
