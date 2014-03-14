/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class FBTweakCategory;

/**
  @abstract Displays configuration options for tweak collections.
 */
@interface _FBTweakCollectionViewController : UIViewController

/**
  @abstract Create a tweak collection view controller.
  @param category The tweak category to show the collections in.
  @discussion This is the designated initializer.
 */
- (instancetype)initWithTweakCategory:(FBTweakCategory *)category;

//! @abstract The tweak category to show the collections in.
@property (nonatomic, strong, readonly) FBTweakCategory *tweakCategory;

@end
