//
//  UIMessageInputView_Media.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/23.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UIMessageInputView_MediaState) {
    UIMessageInputView_MediaStateInit,
    UIMessageInputView_MediaStateUploading,
    UIMessageInputView_MediaStateUploadSucess,
    UIMessageInputView_MediaStateUploadFailed
};

@interface UIMessageInputView_Media : NSObject
@property (strong, nonatomic) ALAsset *curAsset;
@property (strong, nonatomic) NSURL *assetURL;
@property (strong, nonatomic) NSString *urlStr;
@property (assign, nonatomic) UIMessageInputView_MediaState state;
+ (id)mediaWithAsset:(ALAsset *)asset urlStr:(NSString *)urlStr;
@end
