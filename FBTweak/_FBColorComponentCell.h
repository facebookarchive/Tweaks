/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class _FBColorComponentCell;

@protocol _FBColorComponentCellDelegate <NSObject>

/**
  @abstract Called when the component cell changes value.
  @param cell The cell that changed its value.
  @param value The new value.
 */
- (void)colorComponentCell:(_FBColorComponentCell *)cell didChangeValue:(CGFloat)value;

@end

/**
  @abstract A cell to edit a color component.
 */
@interface _FBColorComponentCell : UITableViewCell

//! @abstract The title shown in the cell.
@property(nonatomic, copy) NSString *title;

//! @abstract The current value. The default value is 0.0.
@property(nonatomic, assign) CGFloat value;

//! @abstract The minimum value. The default value is 0.0.
@property(nonatomic, assign) CGFloat minimumValue;

//! @abstract The maximum value. The default value is 255.0.
@property(nonatomic, assign) CGFloat maximumValue;

//! @abstract The format string to apply for textfield value. `%.f` by default.
@property(nonatomic, copy) NSString *format;

//! @abstract The array of CGColorRef objects defining the color of each gradient stop on the track.
@property(nonatomic, copy) NSArray *colors;

//! @abstract The cell's delegate.
@property(nonatomic, weak) id<_FBColorComponentCellDelegate> delegate;

@end
