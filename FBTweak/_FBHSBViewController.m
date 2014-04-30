/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBHSBViewController.h"
#import "_FBColorWheelView.h"
#import "_FBColorComponentView.h"
#import "_FBSliderView.h"
#import "_FBHSBView.h"
#import "FBTweak.h"
#import "UIColor+HEX.h"

@interface FBHSBViewController () <UITextFieldDelegate>
{
  FBTweak* _tweak;
  HSB _colorComponents;
}

@property(nonatomic, strong) FBHSBView* view;

@end

@implementation FBHSBViewController

- (instancetype)initWithTweak:(FBTweak *)tweak
{
  self = [super init];
  if (self) {
    _tweak = tweak;

    self.title = _tweak.name;

    FBTweakValue value = (_tweak.currentValue ?: _tweak.defaultValue);
    RGB2HSB(RGBColorComponents([UIColor colorWithHexString:value]), &_colorComponents);
  }
  return self;
}

- (void)loadView
{
  self.view = [[FBHSBView alloc] init];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view reloadData];
}

#pragma mark - FBHSBViewDataSource methods

- (HSB)colorComponents
{
  return _colorComponents;
}

@end
