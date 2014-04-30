/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBRGBViewController.h"
#import "_FBSliderView.h"
#import "_FBColorComponentView.h"
#import "_FBRGBView.h"
#import "FBTweak.h"
#import "UIColor+HEX.h"

@interface FBRGBViewController () <UITextFieldDelegate, FBColorViewDelegate>
{
  RGB _colorComponents;
  FBTweak* _tweak;
}

@property(nonatomic, strong) FBRGBView* view;

@end

@implementation FBRGBViewController

- (instancetype)initWithTweak:(FBTweak *)tweak
{
  self = [super init];
  if (self) {
    _tweak = tweak;
    self.title = _tweak.name;

    FBTweakValue value = (_tweak.currentValue ?: _tweak.defaultValue);
    _colorComponents = RGBColorComponents([UIColor colorWithHexString:value]);
  }
  return self;
}

- (void)loadView
{
  self.view = [[FBRGBView alloc] init];
  self.view.delegate = self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view reloadData];
}

#pragma mark - FBRGBViewDataSource methods

- (RGB)colorComponents
{
  return _colorComponents;
}

#pragma mark - Private methods

- (IBAction)_colorComponentDidChangeValue:(FBColorComponentView*)sender
{
  [self _setColorComponentValue:sender.value / sender.maximumValue atIndex:sender.tag];
  [self.view reloadData];
  _tweak.currentValue = [self _hexColorString];
}

- (NSString*)_hexColorString
{
  UIColor* selectedColor = [UIColor colorWithRed:_colorComponents.red green:_colorComponents.green blue:_colorComponents.green alpha:_colorComponents.alpha];
  return [selectedColor hexString];
}

- (void)_setColorComponentValue:(CGFloat)value atIndex:(NSUInteger)index
{
  switch (index) {
    case 0:
      _colorComponents.red = value;
      break;
    case 1:
      _colorComponents.green = value;
      break;
    case 2:
      _colorComponents.blue = value;
      break;
    default:
      _colorComponents.alpha = value;
      break;
  }
}

@end
