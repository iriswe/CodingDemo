//
//  Close2FAViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/12.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"
#import "Coding_NetAPIManager.h"
#import "TPKeyboardAvoidingTableView.h"
#import "Input_OnlyText_Cell.h"

@interface Close2FAViewController : BaseViewController
+ (id)vcWithPhone:(NSString *)phone sucessBlock:(void (^)(UIViewController *vc))block;

@end
