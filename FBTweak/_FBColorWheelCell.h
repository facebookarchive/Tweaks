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

/**
  @abstract Called when the color wheel changes the selected color.
  @discussion The cell will already have been updated with the new color.
 */
- (void)colorWheelCellDidChangeColor:(_FBColorWheelCell *)cell;

@end

/**
  @abstract A cell to edit the hue and saturation color components.
 */
@interface _FBColorWheelCell : UITableViewCell

//! @abstract The hue shown in the cell.
@property (nonatomic, readwrite) CGFloat hue;

//! @abstract The saturation shown in the cell.
@property (nonatomic, readwrite) CGFloat saturation;

//! @abstract The cell's delegate.
@property(nonatomic, weak) id<_FBColorWheelCellDelegate> delegate;

@end
