//
//  NSString+AttributeStr.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/21.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Attribute)
+(NSAttributedString*)getAttributeFromText:(NSString*)text emphasizeTag:(NSString*)tag emphasizeColor:(UIColor*)color;
+(NSAttributedString*)getAttributeFromText:(NSString*)text emphasize:(NSString*)emphasize emphasizeColor:(UIColor*)color;
+(NSString*)getStr:(NSString*)str removeEmphasize:(NSString*)emphasize;
@end
