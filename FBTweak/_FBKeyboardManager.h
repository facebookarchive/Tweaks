/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

/**
 @abstract Keyboard TextField manager. Adjust the content so that the target object remains visible.
 */
@interface FBKeyboardManager : NSObject

/**
 *  Enables the keyboard manager. The manager is enabled by default.
 */
- (void)enable;

/**
 *  Disables the keyboard manager.
 */
- (void)disable;

@end
