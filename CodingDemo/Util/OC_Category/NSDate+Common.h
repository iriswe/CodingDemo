//
//  NSDate+Common.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/13.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+convenience.h"
#import "NSDate+Helper.h"

@interface NSDate (Common)

- (BOOL)isSameDay:(NSDate*)anotherDate;
+ (BOOL)isDuringMidAutumn;

+ (NSString *)convertStr_yyyy_MM_ddToDisplay:(NSString *)str_yyyy_MM_dd;

- (NSString *)string_yyyy_MM_dd_EEE;//@"yyyy-MM-dd EEE" + (今天/昨天)
- (NSString *)string_yyyy_MM_dd;//@"yyyy-MM-dd"
- (NSString *)stringDisplay_HHmm;//n秒前 / 今天 HH:mm
- (NSString *)stringDisplay_MMdd;//n秒前 / 今天 / MM/dd

- (NSInteger)leftDayCount;
@end
