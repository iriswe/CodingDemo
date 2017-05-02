//
//  SearchBar.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/14.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SelectBlock)();

@interface SearchBar : UISearchBar
-(void)patchWithCategoryWithSelectBlock:(SelectBlock)block;
-(void)setSearchCategory:(NSString*)title;
@end

@interface MainSearchBar : UISearchBar
@property (strong, nonatomic) UIButton *scanBtn;
@end