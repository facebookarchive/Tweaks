/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@protocol FBColorViewDelegate;

/**
 @abstract The `FBColorView` protocol declares a view's interface for displaying and editing color value.
 */
@protocol FBColorView <NSObject>

@required

//! @abstract The current color value.
@property(nonatomic, strong) UIColor* value;

//! @abstract The object that acts as the delegate of the receiving color selection view.
@property(nonatomic, weak) id<FBColorViewDelegate> delegate;

//! @abstract The the scroll view.
@property(nonatomic, strong, readonly) UIScrollView* scrollView;

/**
 *  Reloads the content of the receiver.
 */
- (void)reloadData;

@end

/**
 *  The delegate of a FBColorView object must adopt the FBColorViewDelegate protocol.
 *  Methods of the protocol allow the delegate to handle color value changes.
 */
@protocol FBColorViewDelegate <NSObject>

@required

/**
 *  Tells the data source to return the color components.
 *
 *  @param colorView The color view.
 *  @param colorValue The new color value.
 *  @return The color components.
 */
- (void)colorView:(id<FBColorView>)colorView didChangeValue:(UIColor*)colorValue;

@end
