//
//  NSString+AttributeStr.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/21.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "NSString+Attribute.h"

@implementation NSString (Attribute)
+(NSAttributedString*)getAttributeFromText:(NSString*)text emphasizeTag:(NSString*)tag emphasizeColor:(UIColor*)color
{
    if (text.length==0) {
        return nil;
    }
    
    NSString *sepratorStart=[NSString stringWithFormat:@"<%@>",tag];
    NSString *sepratorEnd=[NSString stringWithFormat:@"</%@>",tag];
    
    NSMutableString *mutTitle=[[NSMutableString alloc] initWithString:text];
    NSMutableAttributedString *resultStr=[NSMutableAttributedString new];
    
    while ([mutTitle rangeOfString:sepratorStart].location!=NSNotFound) {
        NSRange startRange=[mutTitle rangeOfString:sepratorStart];
        
        [resultStr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[mutTitle substringWithRange:NSMakeRange(0,startRange.location)]]];
        [mutTitle deleteCharactersInRange:NSMakeRange(0,startRange.location+startRange.length)];
        
        if ([mutTitle rangeOfString:sepratorEnd].location!=NSNotFound) {
            NSRange endRange=[mutTitle rangeOfString:sepratorEnd];
            NSRange storeRange=NSMakeRange(resultStr.length, endRange.location);
            [resultStr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[mutTitle substringWithRange:NSMakeRange(0,endRange.location)]]];
            resultStr=[NSString getAttributeFromText:resultStr range:storeRange emphasizeColor:color];
            [mutTitle deleteCharactersInRange:NSMakeRange(0,endRange.location+endRange.length)];
        }
    }
    //尾部
    if (mutTitle.length>0) {
        [resultStr appendAttributedString:[[NSMutableAttributedString alloc] initWithString:mutTitle]];
    }
    return resultStr;
}

+(NSMutableAttributedString*)getAttributeFromText:(NSMutableAttributedString*)text range:(NSRange)range emphasizeColor:(UIColor*)color{
    [text addAttribute:NSForegroundColorAttributeName value:color range:range];
    return text;
}

+(NSAttributedString*)getAttributeFromText:(NSString*)text emphasize:(NSString*)emphasize emphasizeColor:(UIColor*)color
{
    NSMutableAttributedString *titleColorStr=[[NSMutableAttributedString alloc] initWithString:text];
    [titleColorStr addAttribute:NSForegroundColorAttributeName value:color range:[text rangeOfString:emphasize]];
    return [titleColorStr copy];
}

+(NSString*)getStr:(NSString*)str removeEmphasize:(NSString*)emphasize
{
    NSString *sepratorStart=[NSString stringWithFormat:@"<%@>",emphasize];
    NSString *sepratorEnd=[NSString stringWithFormat:@"</%@>",emphasize];
    NSString *resultStr=str;
    resultStr=[resultStr stringByReplacingOccurrencesOfString:sepratorStart withString:@""];
    resultStr=[resultStr stringByReplacingOccurrencesOfString:sepratorEnd withString:@""];
    return resultStr;
}

@end
