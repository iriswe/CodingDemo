//
//  OTPTableViewCell.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/13.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTPAuthURL.h"

@interface OTPTableViewCell : UITableViewCell
@property (strong, nonatomic) OTPAuthURL *authURL;
+ (CGFloat)cellHeight;
@end
@interface TOTPTableViewCell : OTPTableViewCell
//@property (strong, nonatomic) TOTPAuthURL *curAuthURL;
@end

@interface HOTPTableViewCell : OTPTableViewCell
//@property (strong, nonatomic) HOTPAuthURL *curAuthURL;
@end
