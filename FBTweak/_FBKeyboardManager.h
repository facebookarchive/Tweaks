/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

/**
  @abstract Keyboard manager.
  @discussion Adjusts the content so that the target object remains visible.
 */
@interface _FBKeyboardManager : NSObject

/**
  @abstract Creates a keyboard manager.
  @discussion This is the designated initializer.
  @param scrollView The that contains the content to adjust.
 */
- (instancetype)initWithViewScrollView:(UIScrollView *)scrollView;

/**
  @abstract Enables the keyboard manager. The manager is enabled by default.
 */
- (void)enable;

/**
  @abstract Disables the keyboard manager.
 */
- (void)disable;

@end
