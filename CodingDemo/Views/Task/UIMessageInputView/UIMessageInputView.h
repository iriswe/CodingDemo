//
//  UIMessageInputView.h
//  CodingDemo
//
//  Created by Dylan.Wei on 16/9/23.
//  Copyright © 2016年 Dylan.Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGEmojiKeyBoardView.h"
#import "CodingModel.h"


typedef NS_ENUM(NSInteger, UIMessageInputViewContentType) {
    UIMessageInputViewContentTypeTweet = 0,
    UIMessageInputViewContentTypePriMsg,
    UIMessageInputViewContentTypeTopic,
    UIMessageInputViewContentTypeTask
};

typedef NS_ENUM(NSInteger, UIMessageInputViewState) {
    UIMessageInputViewStateSystem,
    UIMessageInputViewStateEmotion,
    UIMessageInputViewStateAdd,
    UIMessageInputViewStateVoice
};
@protocol UIMessageInputViewDelegate;

@interface UIMessageInputView : UIView<UITextViewDelegate>
@property (strong, nonatomic) NSString *placeHolder;
@property (assign, nonatomic) BOOL isAlwaysShow;
@property (assign, nonatomic, readonly) UIMessageInputViewContentType contentType;
@property (strong, nonatomic) User *toUser;
@property (strong, nonatomic) NSNumber *commentOfId;
@property (strong, nonatomic) Project *curProject;

@property (nonatomic, weak) id<UIMessageInputViewDelegate> delegate;
+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type;
+ (instancetype)messageInputViewWithType:(UIMessageInputViewContentType)type placeHolder:(NSString *)placeHolder;

- (void)prepareToShow;
- (void)prepareToDismiss;
- (BOOL)notAndBecomeFirstResponder;
- (BOOL)isAndResignFirstResponder;
- (BOOL)isCustomFirstResponder;
@end

@protocol UIMessageInputViewDelegate <NSObject>
@optional
- (void)messageInputView:(UIMessageInputView *)inputView sendText:(NSString *)text;
- (void)messageInputView:(UIMessageInputView *)inputView sendBigEmotion:(NSString *)emotionName;
- (void)messageInputView:(UIMessageInputView *)inputView sendVoice:(NSString *)file duration:(NSTimeInterval)duration;
- (void)messageInputView:(UIMessageInputView *)inputView addIndexClicked:(NSInteger)index;
- (void)messageInputView:(UIMessageInputView *)inputView heightToBottomChenged:(CGFloat)heightToBottom;
@end
