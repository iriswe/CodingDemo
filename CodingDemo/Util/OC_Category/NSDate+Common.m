//
//  NSDate+Common.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/13.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "NSDate+Common.h"

@implementation NSDate (Common)

- (BOOL)isSameDay:(NSDate*)anotherDate{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components1 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    NSDateComponents* components2 = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:anotherDate];
    return ([components1 year] == [components2 year] && [components1 month] == [components2 month] && [components1 day] == [components2 day]);
}

+ (NSString *)convertStr_yyyy_MM_ddToDisplay:(NSString *)str_yyyy_MM_dd{
    if (str_yyyy_MM_dd.length <= 0) {
        return nil;
    }
    NSDate *date = [NSDate dateFromString:str_yyyy_MM_dd withFormat:@"yyyy-MM-dd"];
    if (!date) {
        return nil;
    }
    NSString *displayStr = @"";
    if ([date year] != [[NSDate date] year]) {
        displayStr = [date stringWithFormat:@"yyyy年MM月dd日"];
    }else{
        switch ([date leftDayCount]) {
            case 2:
                displayStr = @"后天";
                break;
            case 1:
                displayStr = @"明天";
                break;
            case 0:
                displayStr = @"今天";
                break;
            case -1:
                displayStr = @"昨天";
                break;
            case -2:
                displayStr = @"前天";
                break;
            default:
                displayStr = [date stringWithFormat:@"MM月dd日"];
                break;
        }
    }
    return displayStr;
}

+ (BOOL)isDuringMidAutumn{
    //    return YES;
    BOOL isDuringMidAutumn;
    NSDate *curDate = [NSDate date];
    if (curDate.year != 2015 ||
        curDate.month != 9 ||
        curDate.day < 25 ||
        curDate.day > 27) {//中秋节期间才显示
        isDuringMidAutumn = NO;
    }else{
        isDuringMidAutumn = YES;
    }
    return isDuringMidAutumn;
}

- (NSString *)string_yyyy_MM_dd_EEE{
    NSString *text = [self stringWithFormat:@"yyyy-MM-dd EEE"];
    NSInteger daysAgo = [self daysAgoAgainstMidnight];
    switch (daysAgo) {
        case 0:
            text = [text stringByAppendingString:@"（今天）"];
            break;
        case 1:
            text = [text stringByAppendingString:@"（昨天）"];
            break;
        default:
            break;
    }
    return text;
}

- (NSString *)string_yyyy_MM_dd
{
    return [self stringWithFormat:@"yyyy-MM-dd"];
}

- (NSString *)stringDisplay_HHmm
{
    NSString *displayStr = @"";
    if ([self year] != [[NSDate date] year]) {
        displayStr = [self stringWithFormat:@"yy/MM/dd HH:mm"];
    }else if ([self leftDayCount] != 0){
        displayStr = [self stringWithFormat:@"MM/dd HH:mm"];
    }else if ([self hoursAgo] > 0){
        displayStr = [self stringWithFormat:@"今天 HH:mm"];
    }else if ([self minutesAgo] > 0){
        displayStr = [NSString stringWithFormat:@"%ld 分钟前", (long)[self minutesAgo]];
    }else if ([self secondsAgo] > 10){
        displayStr = [NSString stringWithFormat:@"%ld 秒前", (long)[self secondsAgo]];
    }else{
        displayStr = @"刚刚";
    }
    return displayStr;
}

- (NSInteger)leftDayCount{
    NSDate *today = [NSDate dateFromString:[[NSDate date] stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];//时分清零
    NSDate *selfCopy = [NSDate dateFromString:[self stringWithFormat:@"yyyy-MM-dd"] withFormat:@"yyyy-MM-dd"];//时分清零
    
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit)
                                               fromDate:today
                                                 toDate:selfCopy
                                                options:0];
    return [components day];
}
- (NSInteger)secondsAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSSecondCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components second];
}
- (NSInteger)minutesAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSMinuteCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components minute];
}
- (NSInteger)hoursAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components hour];
}
- (NSInteger)monthsAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSMonthCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components month];
}

- (NSInteger)yearsAgo{
    NSCalendar *calendar = [[self class] sharedCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit)
                                               fromDate:self
                                                 toDate:[NSDate date]
                                                options:0];
    return [components year];
}
- (NSString *)stringDisplay_MMdd
{
    NSString *displayStr = @"";
    if ([self year] != [[NSDate date] year]) {
        displayStr = [self stringWithFormat:@"yy/MM/dd"];
    }else if ([self leftDayCount] != 0){
        displayStr = [self stringWithFormat:@"MM/dd"];
    }else if ([self hoursAgo] > 0){
        displayStr = [self stringWithFormat:@"今天"];
    }else if ([self minutesAgo] > 0){
        displayStr = [NSString stringWithFormat:@"%ld 分钟前", (long)[self minutesAgo]];
    }else if ([self secondsAgo] > 10){
        displayStr = [NSString stringWithFormat:@"%ld 秒前", (long)[self secondsAgo]];
    }else{
        displayStr = @"刚刚";
    }
    return displayStr;
}

@end
