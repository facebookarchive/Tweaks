/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBKeyboardManager.h"

static CGFloat const _FBDistanceBetweenKeyboardAndTextfield = 10.0f;

@interface _FBKeyboardManager ()
{
  __weak UIView* _activeTextField;
  __weak UIScrollView* _scrollView;
}

@end

@implementation _FBKeyboardManager

- (instancetype)init
{
  return [self initWithViewScrollView:nil];
}

- (instancetype)initWithViewScrollView:(UIScrollView*)scrollView
{
  self = [super init];
  if (self) {
    _scrollView = scrollView;
    [self enable];
  }
  return self;
}

- (void)setScrollView:(UIScrollView*)scrollView
{
  _scrollView = scrollView;
}

- (void)enable
{
  [self disable];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
}

- (void)disable
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
}

- (void)dealloc
{
  [self disable];
}

#pragma mark - Private methods

- (void)_keyboardFrameChanged:(NSNotification *)notification
{
  if (!_activeTextField) {
    return;
  }

  UIView* contentView = _scrollView.superview;

  NSDictionary* userInfo = [notification userInfo];
  CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  CGSize kbSize = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

  endFrame = [contentView.window convertRect:endFrame fromWindow:nil];
  endFrame = [contentView convertRect:endFrame fromView:contentView.window];

  CGRect activeTextFieldRect = [_activeTextField.superview convertRect:_activeTextField.frame toView:_scrollView];
  CGRect rootViewRect = _scrollView.frame;
  CGFloat kbHeight = kbSize.height;

  CGFloat move = CGRectGetMaxY(activeTextFieldRect) - (CGRectGetHeight(rootViewRect) - kbHeight - _FBDistanceBetweenKeyboardAndTextfield);

  void (^animations)() = ^{
    CGPoint contentOffset = _scrollView.contentOffset;
    contentOffset.y = move;
    _scrollView.contentOffset = contentOffset;

    UIEdgeInsets contentInset = _scrollView.contentInset;
    contentInset.bottom = (contentView.bounds.size.height - CGRectGetMinY(endFrame));
    _scrollView.contentInset = contentInset;

    UIEdgeInsets scrollIndicatorInsets = _scrollView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = (contentView.bounds.size.height - CGRectGetMinY(endFrame));
    _scrollView.scrollIndicatorInsets = scrollIndicatorInsets;
  };

  UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;

  [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:NULL];
}

-(void)_textFieldDidBeginEditing:(NSNotification*)notification
{
  _activeTextField = notification.object;
}

-(void)_textFieldDidEndEditing:(NSNotification*)notification
{
  _activeTextField = nil;
}

@end
