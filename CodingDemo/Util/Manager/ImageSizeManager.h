//
//  ImageSizeManager.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/29.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSizeManager : NSObject
+ (instancetype)shareManager;

- (NSMutableDictionary *)read;
- (BOOL)save;

- (void)saveImage:(NSString *)imagePath size:(CGSize)size;
- (CGFloat)sizeOfImage:(NSString *)imagePath;
- (BOOL)hasSrc:(NSString *)src;

//Image Resize (used in tweet and message)
- (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight;
- (CGSize)sizeWithImage:(UIImage *)image originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight;
- (CGSize)sizeWithSrc:(NSString *)src originalWidth:(CGFloat)originalWidth maxHeight:(CGFloat)maxHeight minWidth:(CGFloat)minWidth;

@end
