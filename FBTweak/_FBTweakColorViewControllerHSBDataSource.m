/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBTweakColorViewControllerHSBDataSource.h"
#import "_FBColorComponentCell.h"
#import "_FBColorWheelCell.h"
#import "_FBColorUtils.h"

@interface _FBTweakColorViewControllerHSBDataSource () <_FBColorComponentCellDelegate, _FBColorWheelCellDelegate>

@end

@implementation _FBTweakColorViewControllerHSBDataSource {
  NSArray *_titles;
  NSArray *_maxValues;
  HSB _colorComponents;
  NSArray *_colorComponentCells;
  UITableViewCell *_colorSampleCell;
  _FBColorWheelCell *_colorWheelCell;
}

- (instancetype)init
{
  if (self = [super init]) {
    _titles = @[@"H", @"S", @"B", @"A"];
    _maxValues = @[
      @(_FBHSBColorComponentMaxValue),
      @(_FBHSBColorComponentMaxValue),
      @(_FBHSBColorComponentMaxValue),
      @(_FBAlphaComponentMaxValue),
    ];
    [self _createCells];
  }
  return self;
}

- (void)setValue:(UIColor *)value
{
  _colorComponents = _FBRGB2HSB(_FBRGBColorComponents(value));
  [self _reloadData];
}

- (UIColor *)value
{
  return [UIColor colorWithHue:_colorComponents.hue saturation:_colorComponents.saturation brightness:_colorComponents.brightness alpha:_colorComponents.alpha];
}

#pragma mark - _FBColorComponentCellDelegate

- (void)colorComponentCell:(_FBColorComponentCell *)cell didChangeValue:(CGFloat)value
{
  [self _setValue:cell.value forColorComponent:[_colorComponentCells indexOfObject:cell]];
  [self _reloadData];
}

#pragma mark - _FBColorWheelCellDelegate

- (void)colorWheelCellDidChangeColor:(_FBColorWheelCell *)cell
{
  [self _setValue:cell.hue forColorComponent:_FBHSBColorComponentHue];
  [self _setValue:cell.saturation forColorComponent:_FBHSBColorComponentSaturation];
  [self _reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2; // color sample + color components
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    return 1;
  }
  return _colorComponentCells.count + 1; // color wheel + hsba components
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    return _colorSampleCell;
  }
  if (indexPath.row == 0) {
    return _colorWheelCell;
  }
  return _colorComponentCells[indexPath.row - 1];
}

#pragma mark - Private methods

- (void)_reloadData
{
  _colorSampleCell.backgroundColor = self.value;
  _colorWheelCell.hue = _colorComponents.hue;
  _colorWheelCell.saturation = _colorComponents.saturation;

  NSArray *components = [self _colorComponentsWithHSB:_colorComponents];
  for (int i = 0; i < _FBHSBAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = _colorComponentCells[i];
    if (i == _FBRGBAColorComponentsSize - 2) { // set colors for brightness component only
      UIColor *tmp = [UIColor colorWithHue:_colorComponents.hue saturation:_colorComponents.saturation brightness:1.0f alpha:1.0f];
      cell.colors = @[(id)[UIColor blackColor].CGColor, (id)tmp.CGColor];
    }
    cell.value = [components[i] floatValue] * (i == _FBHSBAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
  }
}

- (void)_createCells
{
  NSArray *components = [self _colorComponentsWithHSB:_colorComponents];
  NSMutableArray *tmp = [NSMutableArray array];
  for (int i = 0; i < _FBHSBAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = [[_FBColorComponentCell alloc] init];
    if (i == _FBRGBAColorComponentsSize - 2) { // set colors for brightness component only
      UIColor *tmp = [UIColor colorWithHue:_colorComponents.hue saturation:_colorComponents.saturation brightness:1.0f alpha:1.0f];
      cell.colors = @[(id)[UIColor blackColor].CGColor, (id)tmp.CGColor];
    }
    cell.format = i == _FBHSBAColorComponentsSize - 1 ? @"%.f" : @"%.2f";
    cell.value = [components[i] floatValue] * (i == _FBHSBAColorComponentsSize - 1 ? [_maxValues[i] floatValue] : 1);
    cell.title = _titles[i];
    cell.maximumValue = [_maxValues[i] floatValue];
    cell.delegate = self;
    [tmp addObject:cell];
  }
  _colorComponentCells = [tmp copy];

  _colorSampleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  _colorSampleCell.backgroundColor = self.value;

  _colorWheelCell = [[_FBColorWheelCell alloc] init];
  _colorWheelCell.delegate = self;
}

- (void)_setValue:(CGFloat)value forColorComponent:(_FBHSBColorComponent)colorComponent
{
  [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
  switch (colorComponent) {
    case _FBHSBColorComponentHue:
      _colorComponents.hue = value;
      break;
    case _FBHSBColorComponentSaturation:
      _colorComponents.saturation = value;
      break;
    case _FBHSBColorComponentBrightness:
      _colorComponents.brightness = value;
      break;
    case _FBHSBColorComponentAlpha:
      _colorComponents.alpha = value / _FBAlphaComponentMaxValue;
      break;
  }
  [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
}

- (NSArray *)_colorComponentsWithHSB:(HSB)hsb
{
  return @[@(hsb.hue), @(hsb.saturation), @(hsb.brightness), @(hsb.alpha)];
}

@end
