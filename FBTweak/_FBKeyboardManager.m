/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBKeyboardManager.h"

static CGFloat const _FBDistanceBetweenKeyboardAndTextfield = 10.0f;

@interface UIView (Utils)
- (id)firstSubviewOfClass:(Class)className;
@end

@implementation UIView (Utils)

- (id)firstSubviewOfClass:(Class)className
{
  return [self firstSubviewOfClass:className depthLevel:3];
}

- (id)firstSubviewOfClass:(Class)className depthLevel:(NSInteger)depthLevel
{
  if (depthLevel == 0) {
    return nil;
  }

  NSInteger count = depthLevel;

  NSArray *subviews = self.subviews;

  while (count > 0) {
    for (UIView *v in subviews) {
      if ([v isKindOfClass:className]) {
        return v;
      }
    }

    count--;

    for (UIView *v in subviews) {
      UIView *retVal = [v firstSubviewOfClass:className depthLevel:count];
      if (retVal) {
        return retVal;
      }
    }
  }

  return nil;
}

@end

@interface FBKeyboardManager ()
{
  UIView* _activeTextField;
}

@end

@implementation FBKeyboardManager

- (id)init
{
  self = [super init];
  if (self) {
    [self enable];
  }
  return self;
}

- (void)enable
{
  // register for keyboard notifications
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];

  // register for testfield notifications
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textFieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textFieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
}

- (void)disable
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
  [self disable];
}

#pragma mark - Private methods

- (UIViewController*)_topViewController
{
  UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

  while (topController.presentedViewController) {
    topController = topController.presentedViewController;
  }
  if ([topController isKindOfClass:UINavigationController.class]) {
    topController = [(UINavigationController*)topController topViewController];
  }

  return topController;
}

-(void)_setRootViewFrame:(CGRect)frame withDuration:(CGFloat)duration options:(UIViewAnimationOptions)options
{
  UIViewController *controller = [self _topViewController];
  [UIView animateWithDuration:duration delay:0 options:options animations:^{
    [controller.view setFrame:frame];
  } completion:nil];
}

- (void)_keyboardFrameChanged:(NSNotification *)notification
{
  UIView* view = [self _topViewController].view;
  UIScrollView* scrollView = [view firstSubviewOfClass:[UIScrollView class]];
  if (scrollView == nil) {
    return;
  }
  NSDictionary* userInfo = [notification userInfo];
  CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  CGSize kbSize = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;


  endFrame = [view.window convertRect:endFrame fromWindow:nil];
  endFrame = [view convertRect:endFrame fromView:view.window];

  CGRect activeTextFieldRect = [_activeTextField.superview convertRect:_activeTextField.frame toView:scrollView];
  CGRect rootViewRect = scrollView.frame;
  CGFloat kbHeight = kbSize.height;
  if (UIInterfaceOrientationIsLandscape([self _topViewController].interfaceOrientation)) {
    kbHeight = kbSize.width;
  }
  CGFloat move = CGRectGetMaxY(activeTextFieldRect) - (CGRectGetHeight(rootViewRect) - kbHeight - _FBDistanceBetweenKeyboardAndTextfield);

  void (^animations)() = ^{
    scrollView.contentOffset = CGPointMake(0, move);
    CGFloat height = CGRectGetHeight(view.bounds);
    UIEdgeInsets contentInset = scrollView.contentInset;
    contentInset.bottom = (height - CGRectGetMinY(endFrame));
    scrollView.contentInset = contentInset;

    UIEdgeInsets scrollIndicatorInsets = scrollView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = (height - CGRectGetMinY(endFrame));
    scrollView.scrollIndicatorInsets = scrollIndicatorInsets;
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
