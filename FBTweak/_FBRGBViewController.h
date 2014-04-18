/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

/**
 *  @abstract Displays a view to edit RGBA color components.
 */
@interface FBRGBViewController : UIViewController

/**
 *  The callback, that is called when the color value is changed.
 */
@property(nonatomic, copy) void(^colorValueDidChangeCallback)(UIColor* color);

/**
 *  Sets the current color value.
 *
 *  @param color The current color value.
 */
- (void)setColor:(UIColor*)color;

@end
