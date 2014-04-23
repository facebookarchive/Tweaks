/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>
#import "UIColor+HEX.h"

@class FBColorWheelView;
@class FBColorComponentView;

/**
 *  This interface declares the color components data source object with the information to construct and modify
 *  a color components view.
 */
@protocol FBHSBViewDataSource <NSObject>

@required

/**
 *  Tells the data source to return the color components.
 *
 *  @return The color components.
 */
- (HSB)colorComponents;

@end


/**
 @abstract A view to edit HSB color components.
 */
@interface FBHSBView : UIView

@property(nonatomic, strong, readonly) FBColorWheelView* colorWheel;
@property(nonatomic, strong, readonly) FBColorComponentView* brightnessView;
@property(nonatomic, strong, readonly) FBColorComponentView* alphaView;
@property(nonatomic, strong, readonly) UITextField* hueTextField;
@property(nonatomic, strong, readonly) UILabel* saturationLabel;
@property(nonatomic, strong, readonly) UITextField* saturationTextField;
@property(nonatomic, strong, readonly) UIScrollView* scrollView;
@property(nonatomic, strong, readonly) UIView* contentView;

//! @abstract The data source that provides current color components values
@property(nonatomic, weak) id<FBHSBViewDataSource> dataSource;

/**
 *  Reloads the content of the receiver.
 */
- (void)reloadData;

@end
