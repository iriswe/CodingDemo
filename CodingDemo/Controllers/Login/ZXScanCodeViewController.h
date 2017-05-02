//
//  ZXScanCodeViewController.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/13.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ZXScanCodeViewController : BaseViewController

@property (strong, nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;
- (BOOL)isScaning;
- (void)startScan;
- (void)stopScan;

@property (nonatomic, copy) void(^scanResultBlock)(ZXScanCodeViewController *, NSString *);

@end
