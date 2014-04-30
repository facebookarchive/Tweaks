/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBTweakColorViewController.h"
#import "_FBRGBView.h"
#import "_FBHSBView.h"
#import "UIColor+HEX.h"
#import "FBTweak.h"

@interface FBTweakColorViewController () <FBColorViewDelegate>
{
  UIView<FBColorView>* _currentView;
  NSArray* _colorSelectionViews;
  FBTweak* _tweak;
}

@end

@implementation FBTweakColorViewController

- (instancetype)initWithTweak:(FBTweak *)tweak
{
  self = [super init];
  if (self) {
    _tweak = tweak;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  UISegmentedControl* segmentedControl = [self _createSegmentedControl];
  self.navigationItem.titleView = segmentedControl;
  segmentedControl.selectedSegmentIndex = 0;
  [self _segmentControlDidChangeValue:segmentedControl];
}

#pragma mark - FBColorViewDelegate methods

- (void)colorView:(id<FBColorView>)colorView didChangeValue:(UIColor*)colorValue
{
  _tweak.currentValue = [colorValue hexString];
}

#pragma mark - Private methods

- (UIView<FBColorView>*)_colorSelectionViewAtIndex:(NSUInteger)idx
{
  if (!_colorSelectionViews) {
    UIView* rgbView = [[FBRGBView alloc] initWithFrame:self.view.bounds];
    UIView* hsbView = [[FBHSBView alloc] initWithFrame:self.view.bounds];
    _colorSelectionViews = @[rgbView, hsbView];
  }
  return idx < [_colorSelectionViews count] ? _colorSelectionViews[idx] : nil;
}

- (IBAction)_segmentControlDidChangeValue:(UISegmentedControl *)sender
{
  _currentView.delegate = nil;
  [_currentView removeFromSuperview];
  _currentView = [self _colorSelectionViewAtIndex:sender.selectedSegmentIndex];
  FBTweakValue value = (_tweak.currentValue ?: _tweak.defaultValue);
  _currentView.value = [UIColor colorWithHexString:value];
  _currentView.delegate = self;
  [self.view addSubview:_currentView];
}

- (UISegmentedControl*)_createSegmentedControl
{
  UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"RGB", @"HSB"]];
  [segmentedControl addTarget:self action:@selector(_segmentControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
  [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
  [segmentedControl sizeToFit];
  return segmentedControl;
}

@end
