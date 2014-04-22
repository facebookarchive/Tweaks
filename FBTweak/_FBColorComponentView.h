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
@interface FBColorComponentView : UIView

//! @abstract The label for color component title.
@property(nonatomic, strong, readonly) UILabel* label;

//! @abstract The color slider to edit color component.
@property(nonatomic, strong, readonly) FBSliderView* slider;

//! @abstract The text field to edit color component.
@property(nonatomic, strong, readonly) UITextField* textField;

@end
