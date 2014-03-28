/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.
 
 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import <UIKit/UIKit.h>

@class FBTweakStore;
@protocol FBTweakViewControllerDelegate;

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

/**
  @abstract Responds to tweak view controller actions.
  @discussion Named {@ref tweaksDelegate} to avoid conflicting with UINavigationController.
 */
@property (nonatomic, weak, readwrite) id<FBTweakViewControllerDelegate> tweaksDelegate;

@end

/**
  @abstract Responds to actions from the tweak view controller.
 */
@protocol FBTweakViewControllerDelegate <UINavigationControllerDelegate>
@required

/**
  @abstract Called when the tweak view controller pressed done.
  @param tweakViewController The view controller that had done pressed.
  @discussion The implementation should dismiss the tweak view controller.
 */
- (void)tweakViewControllerPressedDone:(FBTweakViewController *)tweakViewController;

@end
