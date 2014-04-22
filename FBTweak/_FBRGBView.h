/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

/**
 *  These options define UI elements to reload.
 */
typedef NS_OPTIONS(NSUInteger, FBRGBViewReloadOption)
{
  /**
   *  The option to reload sliders only.
   */
  FBRGBViewReloadOptionSliders = 1 << 1,
  /**
   *  The option to reload text fields only.
   */
  FBRGBViewReloadOptionTextFields = 1 << 2,
  /**
   *  The option to reload all UI elements.
   */
  FBRGBViewReloadOptionAll = FBRGBViewReloadOptionSliders | FBRGBViewReloadOptionTextFields
};

extern NSUInteger const _FBRGBAColorComponentsSize;

/**
 *  This interface declares the color components data source object with the information to construct and modify
 *  a color components view.
 */
@protocol FBRGBViewDataSource <NSObject>

@required

/**
 *  Tells the data source to return the color components.
 *
 *  @return The color components.
 */
- (CGFloat*)colorComponents;

@end

/**
 @abstract A view to edit RGBA color components.
 */
@interface FBRGBView : UIView

@property(nonatomic, strong, readonly) UIView* colorSample;
@property(nonatomic, strong, readonly) UIScrollView* scrollView;
@property(nonatomic, strong, readonly) UIView* contentView;
@property(nonatomic, strong, readonly) NSArray* colorComponentViews;

//! @abstract The data source that provides current color components values
@property(nonatomic, weak) id<FBRGBViewDataSource> dataSource;

/**
 *  Reloads view accroding to the specified options.
 *
 *  @param options The options to use while reload.
 */
- (void)reloadDataWithOptions:(FBRGBViewReloadOption)options;

@end
