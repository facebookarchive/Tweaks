/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class FBSliderView;

/**
 @abstract A view to edit a color component.
 */
@interface FBColorComponentView : UIControl

//! @abstract The title.
@property(nonatomic, copy) NSString* title;

//! @abstract The current value. The default value is 0.0.
@property(nonatomic, assign) CGFloat value;

//! @abstract The minimum value. The default value is 0.0.
@property(nonatomic, assign) CGFloat minimumValue;

//! @abstract The maximum value. The default value is 255.0.
@property(nonatomic, assign) CGFloat maximumValue;

//! @abstract The format string to use apply for textfield value. `%.f` by default. 
@property(nonatomic, copy) NSString* format;

//! @abstract The color slider to edit color component.
@property(nonatomic, strong, readonly) FBSliderView* slider;

@end
