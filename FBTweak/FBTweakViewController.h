/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

/**
  @abstract A view controller that shows the list of tweaks.
 */
@interface FBTweakViewController : UINavigationController

/**
  @abstract Create a tweak view controller.
  @param store The tweak store to show. Usually +[FBTweakStore sharedInstance].
  @discussion The designated initializer.
 */
- (instancetype)initWithStore:(FBTweakStore *)store;

@end
