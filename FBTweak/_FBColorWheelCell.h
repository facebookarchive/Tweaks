/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class _FBColorWheelCell;

@protocol _FBColorWheelCellDelegate <NSObject>

- (void)colorWheelCell:(_FBColorWheelCell*)cell didChangeHue:(CGFloat)hue saturation:(CGFloat)saturation;

@end

/**
 @abstract A cell to edit the hue and saturation color components.
 */
@interface _FBColorWheelCell : UITableViewCell

- (void)setHue:(CGFloat)hue;
- (void)setSaturation:(CGFloat)saturation;

//! @abstract The cell's delegate.
@property(nonatomic, weak) id<_FBColorWheelCellDelegate> delegate;

@end
