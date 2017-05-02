//
//  ZXScanCodeViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/13.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "ZXScanCodeViewController.h"
#import "ScanBGView.h"
#import "Helper.h"

@interface ZXScanCodeViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) ScanBGView *myScanBGView;
@property (strong, nonatomic) UIImageView *scanRectView, *lineView;
@property (strong, nonatomic) UILabel *tipLabel;

@property (strong, nonatomic) CIDetector *detector;
@end

@implementation ZXScanCodeViewController

- (CIDetector *)detector
{
    if (!_detector) {
        _detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    }
    return _detector;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"扫描二维码";
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithBtnTitle:@"相册" target:self action:@selector(clickRightBarButton:)];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(applicationDidBecomeActive:)
               name:UIApplicationDidBecomeActiveNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(applicationWillResignActive:)
               name:UIApplicationWillResignActiveNotification
             object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_videoPreviewLayer) {
        [self configUI];
    }else{
        [self startScan];
    }
}

- (void)configUI
{
    CGFloat width = SCREEN_WIDTH * 2 / 3;
    CGFloat padding = (SCREEN_WIDTH - width)/2;
    CGRect scanRect = CGRectMake(padding, SCREEN_WIDTH / 10, width, width);
    if (!_videoPreviewLayer) {
        NSError *error;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        if (!input) {
            kTipAlert(@"%@", error.localizedDescription);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            //设置会话的输入设备
            AVCaptureSession *session = [AVCaptureSession new];
            [session addInput:input];
            //对应输出
            AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
            [output setMetadataObjectsDelegate:self queue:dispatch_queue_create("ease_capture_queue", NULL)];
            [session addOutput:output];
            if (![output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
                kTipAlert(@"摄像头不支持二维码");
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [output setMetadataObjectTypes:output.availableMetadataObjectTypes];
            }
            output.rectOfInterest = CGRectMake(CGRectGetMinY(scanRect)/CGRectGetHeight(self.view.frame),
                                               1 - CGRectGetMaxX(scanRect)/CGRectGetWidth(self.view.frame),
                                               CGRectGetHeight(scanRect)/CGRectGetHeight(self.view.frame),
                                               CGRectGetWidth(scanRect)/CGRectGetWidth(self.view.frame));//设置扫描区域。。默认是手机头向左的横屏坐标系（逆时针旋转90度）
            //将捕获的数据流展现出来
            _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
            [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
            [_videoPreviewLayer setFrame:self.view.bounds];
            
        }
    }
    if (!_myScanBGView) {
        _myScanBGView = [[ScanBGView alloc] initWithFrame:self.view.bounds];
        _myScanBGView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _myScanBGView.scanRect = scanRect;
    }
    if (!_scanRectView) {
        _scanRectView = [[UIImageView alloc] initWithFrame:scanRect];
        _scanRectView.image = [[UIImage imageNamed:@"scan_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 25, 25, 25)];
        _scanRectView.clipsToBounds = YES;
    }
    if (!_lineView) {
        UIImage *lineImage = [UIImage imageNamed:@"scan_line"];
        CGFloat lineHeight = 2;
        CGFloat lineWidth = CGRectGetWidth(_scanRectView.frame);
        _lineView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -lineHeight, lineWidth, lineHeight)];
        _lineView.contentMode = UIViewContentModeScaleToFill;
        _lineView.image = lineImage;
    }
    [self.view.layer addSublayer:_videoPreviewLayer];
    [self.view addSubview:_myScanBGView];
    [self.view addSubview:_scanRectView];
    [self.view addSubview:_tipLabel];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_scanRectView.mas_bottom).offset(20);
        make.height.mas_equalTo(30);
    }];
    [_scanRectView addSubview:_lineView];
    [_videoPreviewLayer.session startRunning];
    [self scanLineStartAction];

}

- (void)scanLineStartAction
{
    [self scanLineStopAction];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.fromValue = @(-CGRectGetHeight(_lineView.frame));
    animation.toValue = @(CGRectGetHeight(_lineView.frame) + CGRectGetHeight(_scanRectView.frame));
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = CGFLOAT_MAX;
    animation.duration = 2.0;
    [self.lineView.layer addAnimation:animation forKey:@"basic"];
    
}

- (void)scanLineStopAction{
    [self.lineView.layer removeAllAnimations];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopScan];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        __block AVMetadataMachineReadableCodeObject *result = nil;
        [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataMachineReadableCodeObject *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.type isEqualToString:AVMetadataObjectTypeQRCode]) {
                result = obj;
                *stop = YES;
            }
        }];
        if (!result) {
            result = [metadataObjects firstObject];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self analyseResult:result];
        });
    }
}

- (void)analyseResult:(AVMetadataMachineReadableCodeObject *)result{
    NSString *resultStr = result.stringValue;
    if (resultStr.length <= 0) {
        return;
    }
    //停止扫描
    [self stopScan];
    //震动反馈
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //交给 block 处理
    if (_scanResultBlock) {
        _scanResultBlock(self, resultStr);
    }
}
#pragma mark Notification
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self startScan];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self stopScan];
}

#pragma mark Photo
-(void)clickRightBarButton:(UIBarButtonItem*)item{
    if (![Helper checkPhotoLibraryAuthorizationStatus]) {
        return;
    }
    //停止扫描
    [self stopScan];
    
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [self handleImageInfo:info];
    }];
}

- (void)handleImageInfo:(NSDictionary *)info{
    //停止扫描
    [self stopScan];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    __block NSString *resultStr = nil;
    NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    [features enumerateObjectsUsingBlock:^(CIQRCodeFeature *obj, NSUInteger idx, BOOL *stop) {
        if (obj.messageString.length > 0) {
            resultStr = obj.messageString;
            *stop = YES;
        }
    }];
    //震动反馈
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //交给 block 处理
    if (_scanResultBlock) {
        _scanResultBlock(self, resultStr);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark public

- (BOOL)isScaning
{
    return _videoPreviewLayer.session.isRunning;
}

- (void)startScan
{
    [_videoPreviewLayer.session startRunning];
    [self scanLineStartAction];
}

- (void)stopScan
{
    [_videoPreviewLayer.session stopRunning];
    [self scanLineStopAction];
}


- (void)dealloc {
    [self.videoPreviewLayer removeFromSuperlayer];
    self.videoPreviewLayer = nil;
    [self scanLineStopAction];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
