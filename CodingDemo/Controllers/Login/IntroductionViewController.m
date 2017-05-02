//
//  IntroductionViewController.m
//  CodingDemo
//
//  Created by Dylan.Wei on 16/8/31.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import "IntroductionViewController.h"
#import "SMPageControl.h"
#import "UIColor+expanded.h"
#import "Masonry.h"
#import "IFTTTJazzHands.h"
#import "RegisterViewController.h"
#import "BaseNavigationController.h"
#import "LoginViewController.h"

@interface IntroductionViewController ()

@property (nonatomic, strong) UIButton *loginBtn, *registerBtn;
@property (nonatomic, strong) SMPageControl *pageControl;

@property (strong, nonatomic) NSMutableDictionary *iconsDict, *tipsDict;

@end

@implementation IntroductionViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.numberOfPages = 7;
    }
    _iconsDict = [@{
                    @"0_image" : @"intro_icon_6",
                    @"1_image" : @"intro_icon_0",
                    @"2_image" : @"intro_icon_1",
                    @"3_image" : @"intro_icon_2",
                    @"4_image" : @"intro_icon_3",
                    @"5_image" : @"intro_icon_4",
                    @"6_image" : @"intro_icon_5",
                    } mutableCopy];
    _tipsDict = [@{
                   @"1_image" : @"intro_tip_0",
                   @"2_image" : @"intro_tip_1",
                   @"3_image" : @"intro_tip_2",
                   @"4_image" : @"intro_tip_3",
                   @"5_image" : @"intro_tip_4",
                   @"6_image" : @"intro_tip_5",
                   } mutableCopy];
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];

    [self configureViews];
    [self configureAnimations];
}

- (void)configureAnimations
{
    [self configureTipAndTitleViewAnimations];
}

- (void)configureTipAndTitleViewAnimations
{
    for (int index; index < self.numberOfPages; index++) {
        NSString *viewKey = [self viewKeyForIndex:index];
        UIView *iconView = [self.iconsDict objectForKey:viewKey];
        UIView *tipView = [self.tipsDict objectForKey:viewKey];
        if (iconView) {
            if (index == 0) {
                [self keepView:iconView onPages:@[@(index +1), @(index)] atTimes:@[@(index - 1), @(index)]];
                
                [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(SCREENH_HEIGHT/7);
                }];
            }else{
                [self keepView:iconView onPage:index];
                
                [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(-SCREENH_HEIGHT/6);
                }];
            }
            IFTTTAlphaAnimation *iconAlphaAnimation = [IFTTTAlphaAnimation animationWithView:iconView];
            [iconAlphaAnimation addKeyframeForTime:index - 0.5 alpha:0.f];
            [iconAlphaAnimation addKeyframeForTime:index alpha:1.f];
            [iconAlphaAnimation addKeyframeForTime:index + 0.5 alpha:0.f];
            [self.animator addAnimation:iconAlphaAnimation];
        }
        if (tipView) {
            [self keepView:tipView onPages:@[@(index +1), @(index), @(index-1)] atTimes:@[@(index - 1), @(index), @(index +1)]];
            IFTTTAlphaAnimation *tipAlphaAnimation = [IFTTTAlphaAnimation animationWithView:tipView];
            [tipAlphaAnimation addKeyframeForTime:index -0.5 alpha:0.f];
            [tipAlphaAnimation addKeyframeForTime:index alpha:1.f];
            [tipAlphaAnimation addKeyframeForTime:index +0.5 alpha:0.f];
            [self.animator addAnimation:tipAlphaAnimation];
            
            [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(iconView.mas_bottom).offset(SCREENHEIGHTSCALE * 45);
            }];
        }
    }
}

- (void)configureViews
{
    [self configureButtonsAndPageControl];
}

- (void)configureButtonsAndPageControl
{
    //button
    UIColor *color = [UIColor colorWithHexString:@"0x28303b"];
    CGFloat buttonWidth = SCREEN_WIDTH * 0.4;
    CGFloat buttonHeight = SCREENHEIGHTSCALE * 38;
    CGFloat paddingToCenter = SCREENWITHSCALE * 10;
    CGFloat paddingToBottom = SCREENHEIGHTSCALE * 20;
    
    self.registerBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(registerBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        button.backgroundColor = color;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"注册" forState:UIControlStateNormal];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = buttonHeight/2;
        button;
    });
    self.loginBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [button setTitleColor:color forState:UIControlStateNormal];
        [button setTitle:@"登录" forState:UIControlStateNormal];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = buttonHeight/2;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = color.CGColor;
        button;
    });

    [self.view addSubview:self.loginBtn];
    [self.view addSubview:self.registerBtn];
    
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
        make.right.mas_equalTo(self.view.mas_centerX).offset(-paddingToCenter);
        make.bottom.mas_equalTo(self.view).offset(-paddingToBottom);
    }];
    
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
        make.left.mas_equalTo(self.view.mas_centerX).offset(paddingToCenter);
        make.bottom.mas_equalTo(self.view).offset(-paddingToBottom);
    }];
    
    //pageControl
    UIImage *pageIndicatorImage = [UIImage imageNamed:@"intro_dot_unselected"];
    UIImage *currentPageIndicatorImage = [UIImage imageNamed:@"intro_dot_selected"];
    
    self.pageControl = ({
        SMPageControl *pageControl = [[SMPageControl alloc] init];
        pageControl.numberOfPages = self.numberOfPages;
        pageControl.userInteractionEnabled = NO;
        pageControl.pageIndicatorImage = pageIndicatorImage;
        pageControl.currentPageIndicatorImage = currentPageIndicatorImage;
        [pageControl sizeToFit];
        pageControl.currentPage = 0;
        pageControl;
    });
    
    [self.view addSubview:self.pageControl];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, SCREENHEIGHTSCALE * 20));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.registerBtn.mas_top).offset(-SCREENHEIGHTSCALE * 20);
    }];
    
    //Views
    for (int i = 0; i < self.numberOfPages; i++) {
        NSString *imageKey = [self imageKeyForIndex:i];
        NSString *viewKey = [self viewKeyForIndex:i];
        NSString *iconImageName = [self.iconsDict objectForKey:imageKey];
        NSString *tipImageName = [self.tipsDict objectForKey:imageKey];
        if (iconImageName) {
            UIImage *iconImage = [UIImage imageNamed:iconImageName];
            if (iconImage) {
                UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
                [self.contentView addSubview:iconView];
                [self.iconsDict setObject:iconView forKey:viewKey];
            }
        }
        
        if (tipImageName) {
            UIImage *tipImage = [UIImage imageNamed:tipImageName];
            if (tipImage) {
                UIImageView *tipView = [[UIImageView alloc] initWithImage:tipImage];
                [self.contentView addSubview:tipView];
                [self.tipsDict setObject:tipView forKey:viewKey];
            }
        }
    }
}
- (NSString *)imageKeyForIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%ld_image", (long)index];
}

- (NSString *)viewKeyForIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%ld_view", (long)index];
}
- (void)registerBtnClicked
{
    RegisterViewController *vc = [RegisterViewController initWithRegisterMethodTYpe:RegisterMethodPhone registerModel:nil];
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)loginBtnClicked
{
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.showDismissButton = YES;
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self animateCurrentFrame];
    NSInteger nearestPage = floorf(self.pageOffset + 0.5);
    self.pageControl.currentPage = nearestPage;
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
