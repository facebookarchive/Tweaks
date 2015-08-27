/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

/**
  @abstract A slider with a gradient track.
 */
@interface _FBSliderView : UIControl

/**
  @abstract The slider's current value. The default value is 0.0.
 */
@property(nonatomic, assign) CGFloat value;

/**
  @abstract The minimum value of the slider. The default value is 0.0.
 */
@property(nonatomic, assign) CGFloat minimumValue;

/**
  @abstract The maximum value of the slider. The default value is 1.0.
 */
@property(nonatomic, assign) CGFloat maximumValue;

/**
  @abstract The array of CGColorRef objects defining the color of each gradient stop on the track.
  @discussion The location of each gradient stop is evaluated with formula: i * width_of_the_track / number_of_colors.
 */
@property(nonatomic, copy) NSArray *colors;

@end
