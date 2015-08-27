/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

/**
  @abstract Provides cells for table view to edit a color value.
 */
@protocol _FBTweakColorViewControllerDataSource <UITableViewDataSource>
@required

//! @abstract The current color value.
@property(nonatomic, strong) UIColor *value;

@end
