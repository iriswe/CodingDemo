//
//  UIImage+Common.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/8/31.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "UIImage+Common.h"

@implementation UIImage (Common)

+(UIImage *)imageWithColor:(UIColor *)aColor
{
    return [UIImage imageWithColor:aColor withFrame:CGRectMake(0.0f, 0.0f, 1.0f, 1.0f)];
}
/**
 *  颜色转图片
 *
 *  @param aColor 颜色
 *  @param aFrame aFrame
 *
 *  @return 图片
 */
+(UIImage *)imageWithColor:(UIColor *)aColor withFrame:(CGRect)aFrame
{
    UIGraphicsBeginImageContext(aFrame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [aColor CGColor]);
    CGContextFillRect(context, aFrame);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/**
 *  压缩图片尺寸
 *
 *  @param targetSize targetSize
 *
 *  @return 图片
 */
-(UIImage*)scaledToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat scaleFactor = 0.0;
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetSize.width / imageSize.width;
        CGFloat heightFactor = targetSize.height / imageSize.height;
        if (widthFactor < heightFactor)
            scaleFactor = heightFactor; // scale to fit height
        else
            scaleFactor = widthFactor; // scale to fit width
    }
    scaleFactor = MIN(scaleFactor, 1.0);
    CGFloat targetWidth = imageSize.width* scaleFactor;
    CGFloat targetHeight = imageSize.height* scaleFactor;
    
    targetSize = CGSizeMake(floorf(targetWidth), floorf(targetHeight));
    UIGraphicsBeginImageContext(targetSize); // this will crop
    [sourceImage drawInRect:CGRectMake(0, 0, ceilf(targetWidth), ceilf(targetHeight))];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        kLog(@"could not scale image");
        newImage = sourceImage;
    }
    UIGraphicsEndImageContext();
    return newImage;
}


- (NSData *)dataSmallerThan:(NSUInteger)dataLength{
    NSData *data = UIImageJPEGRepresentation(self, 1.0);
    while (data.length > dataLength) {
        UIImage *image = [UIImage imageWithData:data];
        data = UIImageJPEGRepresentation(image, 0.7);
    }
    return data;
}
- (NSData *)dataForCodingUpload{
    return [self dataSmallerThan:1024 * 1000];
}

+ (UIImage *)fullScreenImageALAsset:(ALAsset *)asset
{
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    CGImageRef imageRef = [assetRep fullScreenImage];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    return image;
}

@end
