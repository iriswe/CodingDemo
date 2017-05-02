//
//  NSMutableString+Common.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/21.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "NSMutableString+Common.h"

@implementation NSMutableString (Common)
- (void)saveAppendString:(NSString *)aString{
    if (aString.length > 0) {
        [self appendString:aString];
    }
}
@end
