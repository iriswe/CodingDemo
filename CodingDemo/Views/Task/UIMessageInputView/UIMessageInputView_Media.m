//
//  UIMessageInputView_Media.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/23.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "UIMessageInputView_Media.h"

@implementation UIMessageInputView_Media
+ (id)mediaWithAsset:(ALAsset *)asset urlStr:(NSString *)urlStr{
    UIMessageInputView_Media *media = [[UIMessageInputView_Media alloc] init];
    media.curAsset = asset;
    media.assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    media.urlStr = urlStr;
    media.state = urlStr.length > 0? UIMessageInputView_MediaStateUploadSucess: UIMessageInputView_MediaStateInit;
    return media;
}
@end
