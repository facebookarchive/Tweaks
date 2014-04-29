/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBKeyboardManager.h"

static CGFloat const _FBDistanceBetweenKeyboardAndTextfield = 10.0f;

@interface FBKeyboardManager ()
{
  UIView* _activeTextField;
}

@end

@implementation FBKeyboardManager

- (void)enable
{
  // register for keyboard notifications
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

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

- (UIViewController*)_topMostController
{
  UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

  while (topController.presentedViewController) {
    topController = topController.presentedViewController;
  }

  return topController;
}

-(void)_setRootViewFrame:(CGRect)frame withDuration:(CGFloat)duration options:(UIViewAnimationOptions)options
{
  UIViewController *controller = [self _topMostController];
  [UIView animateWithDuration:duration delay:0 options:options animations:^{
    [controller.view setFrame:frame];
  } completion:nil];
}

- (void)_keyboardWillHide:(NSNotification*)notification
{
  NSDictionary* userInfo = [notification userInfo];
  CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
  UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;
  CGRect appFrame = [[UIScreen mainScreen] applicationFrame];

  UIViewController *controller = [self _topMostController];

  if([controller isKindOfClass:[UINavigationController class]]) {
    appFrame = [[UIApplication sharedApplication] keyWindow].frame;
  } else {
    if ([controller modalPresentationStyle] == UIModalPresentationFormSheet ||
        [controller modalPresentationStyle] == UIModalPresentationPageSheet) {
      appFrame.origin = CGPointZero;
      appFrame.size = controller.view.frame.size;
    } else {
      appFrame.size = controller.view.frame.size;
    }
  }

  [self _setRootViewFrame:appFrame withDuration:duration options:options];
}

-(void)_keyboardWillShow:(NSNotification*)notification
{
  NSDictionary* userInfo = [notification userInfo];
  CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
  UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;
  CGSize kbSize = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

  UIWindow *window = [[UIApplication sharedApplication] keyWindow];
  UIViewController *rootController = [self _topMostController];

  CGRect activeTextFieldRect = [_activeTextField.superview convertRect:_activeTextField.frame toView:window];
  CGRect rootViewRect = rootController.view.frame;

  CGFloat move;
  //Move positive = textField is hidden.
  //Move negative = textField is showing.

  //Common for both normal and special cases.
  switch (rootController.interfaceOrientation)
  {
    case UIInterfaceOrientationLandscapeLeft:
      kbSize.width += _FBDistanceBetweenKeyboardAndTextfield;
      move = CGRectGetMaxX(activeTextFieldRect)-(CGRectGetWidth(window.frame)-kbSize.width);
      break;
    case UIInterfaceOrientationLandscapeRight:
      kbSize.width += _FBDistanceBetweenKeyboardAndTextfield;
      move = kbSize.width-CGRectGetMinX(activeTextFieldRect);
      break;
    case UIInterfaceOrientationPortrait:
      kbSize.height += _FBDistanceBetweenKeyboardAndTextfield;
      move = CGRectGetMaxY(activeTextFieldRect)-(CGRectGetHeight(window.frame)-kbSize.height);
      break;
    case UIInterfaceOrientationPortraitUpsideDown:
      kbSize.height += _FBDistanceBetweenKeyboardAndTextfield;
      move = kbSize.height-CGRectGetMinY(activeTextFieldRect);
      break;
    default:
      break;
  }

  //Special case.
  if ([[self _topMostController] modalPresentationStyle] == UIModalPresentationFormSheet ||
      [[self _topMostController] modalPresentationStyle] == UIModalPresentationPageSheet)
  {
    //Positive or zero.
    if (move>=0)
    {
      //We should only manipulate y.
      rootViewRect.origin.y -= move;
      [self _setRootViewFrame:rootViewRect withDuration:duration options:options];
    }
    //Negative
    else
    {
      CGRect appFrame = CGRectMake(0, 0, rootViewRect.size.width, rootViewRect.size.height);
      CGFloat disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(appFrame);

      //Move Negative = frame disturbed.
      //Move positive or frame not disturbed.
      if(disturbDistance<0)
      {
        rootViewRect.origin.y -= MAX(move, disturbDistance);
        [self _setRootViewFrame:rootViewRect withDuration:duration options:options];
      }
    }
  }
  else
  {
    //Positive or zero.
    if (move>=0)
    {
      //        switch ([[UIApplication sharedApplication] statusBarOrientation])
      switch (rootController.interfaceOrientation)
      {
        case UIInterfaceOrientationLandscapeLeft:       rootViewRect.origin.x -= move;  break;
        case UIInterfaceOrientationLandscapeRight:      rootViewRect.origin.x += move;  break;
        case UIInterfaceOrientationPortrait:            rootViewRect.origin.y -= move;  break;
        case UIInterfaceOrientationPortraitUpsideDown:  rootViewRect.origin.y += move;  break;
        default:    break;
      }

      [self _setRootViewFrame:rootViewRect withDuration:duration options:options];
    }
    //Negative
    else
    {
      CGRect appFrame;
      if([rootController isKindOfClass:[UINavigationController class]])
        appFrame = window.frame;
      else if ([rootController isKindOfClass:[UIViewController class]])
        appFrame = [[UIScreen mainScreen] applicationFrame];


      CGFloat disturbDistance;

      //        switch ([[UIApplication sharedApplication] statusBarOrientation])
      switch (rootController.interfaceOrientation)
      {
        case UIInterfaceOrientationLandscapeLeft:
          disturbDistance = CGRectGetMinX(rootViewRect)-CGRectGetMinX(appFrame);
          break;
        case UIInterfaceOrientationLandscapeRight:
          disturbDistance = CGRectGetMinX(appFrame)-CGRectGetMinX(rootViewRect);
          break;
        case UIInterfaceOrientationPortrait:
          disturbDistance = CGRectGetMinY(rootViewRect)-CGRectGetMinY(appFrame);
          break;
        case UIInterfaceOrientationPortraitUpsideDown:
          disturbDistance = CGRectGetMinY(appFrame)-CGRectGetMinY(rootViewRect);
          break;
        default:
          break;
      }

      //Move Negative = frame disturbed.
      //Move positive or frame not disturbed.
      if(disturbDistance<0)
      {
        //            switch ([[UIApplication sharedApplication] statusBarOrientation])
        switch (rootController.interfaceOrientation)
        {
          case UIInterfaceOrientationLandscapeLeft:       rootViewRect.origin.x -= MAX(move, disturbDistance);  break;
          case UIInterfaceOrientationLandscapeRight:      rootViewRect.origin.x += MAX(move, disturbDistance);  break;
          case UIInterfaceOrientationPortrait:            rootViewRect.origin.y -= MAX(move, disturbDistance);  break;
          case UIInterfaceOrientationPortraitUpsideDown:  rootViewRect.origin.y += MAX(move, disturbDistance);  break;
          default:    break;
        }

        [self _setRootViewFrame:rootViewRect withDuration:duration options:options];
      }
    }
  }
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
