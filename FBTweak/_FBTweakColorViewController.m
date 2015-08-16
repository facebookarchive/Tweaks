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
#import "_FBKeyboardManager.h"
#import "FBColorUtils.h"
#import "FBTweak.h"

@interface _FBTweakColorViewController () <_FBColorViewDelegate>
{
  @private

  UIView<_FBColorView>* _currentView;
  NSArray* _colorSelectionViews;
  FBTweak* _tweak;
  _FBKeyboardManager* _keyboardManager;
}

@end

@implementation _FBTweakColorViewController

- (instancetype)initWithTweak:(FBTweak*)tweak
{
  NSParameterAssert(tweak != nil);
  NSParameterAssert([tweak.possibleValues isKindOfClass:[UIColor class]]);
  self = [super init];
  if (self) {
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tweak = tweak;
    _keyboardManager = [[_FBKeyboardManager alloc] init];
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

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [_keyboardManager enable];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [_keyboardManager disable];
}

#pragma mark - FBColorViewDelegate methods

- (void)colorView:(id<_FBColorView>)colorView didChangeValue:(UIColor*)colorValue
{
  _tweak.currentValue = FBHexStringFromColor(colorValue);
}

#pragma mark - Private methods

- (UIView<_FBColorView>*)_colorSelectionViewAtIndex:(NSUInteger)idx
{
  if (!_colorSelectionViews) {
    UIView* rgbView = [[_FBRGBView alloc] initWithFrame:self.view.bounds];
    UIView* hsbView = [[_FBHSBView alloc] initWithFrame:self.view.bounds];
    _colorSelectionViews = @[rgbView, hsbView];
  }
  return idx < [_colorSelectionViews count] ? _colorSelectionViews[idx] : nil;
}

- (IBAction)_segmentControlDidChangeValue:(UISegmentedControl*)sender
{
  _currentView.delegate = nil;
  [_currentView removeFromSuperview];
  _currentView = [self _colorSelectionViewAtIndex:sender.selectedSegmentIndex];
  FBTweakValue value = (_tweak.currentValue ?: _tweak.defaultValue);
  _currentView.value = FBColorFromHexString(value);
  _currentView.delegate = self;
  [self _applyNavBarInsetsForView:_currentView];
  [self.view addSubview:_currentView];
  _currentView.translatesAutoresizingMaskIntoConstraints = NO;
  NSDictionary *views = NSDictionaryOfVariableBindings(_currentView);
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_currentView]|" options:0 metrics:nil views:views]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_currentView]|" options:0 metrics:nil views:views]];

  [_keyboardManager setScrollView:_currentView.scrollView];
}

- (UISegmentedControl*)_createSegmentedControl
{
  UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"RGB", @"HSB"]];
  [segmentedControl addTarget:self action:@selector(_segmentControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
  [segmentedControl sizeToFit];
  return segmentedControl;
}

- (void)_applyNavBarInsetsForView:(UIView<_FBColorView>*)view
{
  // For insetting with a navigation bar
  CGFloat topInset = CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
  if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
    topInset = CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetWidth([UIApplication sharedApplication].statusBarFrame);
  }
  UIEdgeInsets insets = UIEdgeInsetsMake(topInset, 0, 0, 0);
  view.scrollView.contentInset = insets;
  view.scrollView.scrollIndicatorInsets = insets;
}

@end
