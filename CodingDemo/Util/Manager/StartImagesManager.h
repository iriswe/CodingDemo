//
//  StartImagesManager.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/12.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StartImage;
@class Group;
@interface StartImagesManager : NSObject
@property (strong, nonatomic) NSMutableArray *imageLoadedArray;
@property (strong, nonatomic) StartImage *startImage;

+ (StartImagesManager *)sharedManager;

- (StartImage *)randomImage;
- (StartImage *)curImage;
- (void)handleStartLink;

- (void)refreshImagesPlist;
- (void)startDownloadImages;
@end

@interface StartImage : NSObject
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSString *fileName, *descriptionStr, *pathDisk;

+ (StartImage *)defautImage;
+ (StartImage *)midAutumnImage;

- (UIImage *)image;
- (void)startDownloadImage;
@end

@interface Group : NSObject
@property (strong, nonatomic) NSString *name, *author, *link;
@end