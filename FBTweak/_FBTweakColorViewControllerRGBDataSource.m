/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBTweakColorViewControllerRGBDataSource.h"
#import "_FBColorComponentCell.h"
#import "_FBColorUtils.h"

@interface _FBTweakColorViewControllerRGBDataSource () <_FBColorComponentCellDelegate>

@end

@implementation _FBTweakColorViewControllerRGBDataSource {
  NSArray *_titles;
  NSArray *_maxValues;
  RGB _colorComponents;
  NSArray *_colorComponentCells;
  UITableViewCell *_colorSampleCell;
}

- (instancetype)init
{
  if (self = [super init]) {
    _titles = @[@"R", @"G", @"B", @"A"];
    _maxValues = @[
      @(_FBRGBColorComponentMaxValue),
      @(_FBRGBColorComponentMaxValue),
      @(_FBRGBColorComponentMaxValue),
      @(_FBAlphaComponentMaxValue),
    ];
    [self _createCells];
  }
  return self;
}

- (void)setValue:(UIColor *)value
{
  [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
  _colorComponents = _FBRGBColorComponents(value);
  [self _reloadData];
  [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
}

- (UIColor *)value
{
  return [UIColor colorWithRed:_colorComponents.red green:_colorComponents.green blue:_colorComponents.blue alpha:_colorComponents.alpha];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    return 1;
  }
  return [_colorComponentCells count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    return _colorSampleCell;
  }
  return _colorComponentCells[indexPath.row];
}

#pragma mark - _FBColorComponentCellDelegate

- (void)colorComponentCell:(_FBColorComponentCell*)cell didChangeValue:(CGFloat)value
{
  [self _setValue:cell.value / cell.maximumValue forColorComponent:[_colorComponentCells indexOfObject:cell]];
  [self _reloadData];
}

#pragma mark - Private methods

- (void)_reloadData
{
  _colorSampleCell.backgroundColor = self.value;
  NSArray *components = [self _colorComponentsWithRGB:_colorComponents];
  for (int i = 0; i < _FBRGBAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = _colorComponentCells[i];
    cell.value = [components[i] floatValue] * [_maxValues[i] floatValue];
    if (i < _FBRGBAColorComponentsSize - 1) {
      cell.colors = [self _colorsWithComponents:components colorIndex:i];
    }
  }
}

- (void)_createCells
{
  NSMutableArray *tmp = [NSMutableArray array];
  NSArray *components = [self _colorComponentsWithRGB:_colorComponents];
  for (int i = 0; i < _FBRGBAColorComponentsSize; ++i) {
    _FBColorComponentCell *cell = [[_FBColorComponentCell alloc] init];
    if (i < _FBRGBAColorComponentsSize - 1) {
      cell.colors = [self _colorsWithComponents:components colorIndex:i];
    }
    cell.value = [components[i] floatValue] * [_maxValues[i] floatValue];
    cell.title = _titles[i];
    cell.maximumValue = [_maxValues[i] floatValue];
    cell.delegate = self;
    [tmp addObject:cell];
  }
  _colorComponentCells = [tmp copy];
  _colorSampleCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
  _colorSampleCell.backgroundColor = self.value;
}

- (NSArray *)_colorComponentsWithRGB:(RGB)rgb
{
  return @[@(rgb.red), @(rgb.green), @(rgb.blue), @(rgb.alpha)];
}

- (NSArray *)_colorsWithComponents:(NSArray *)colorComponents colorIndex:(NSUInteger)colorIndex
{
  CGFloat currentColorValue = [colorComponents[colorIndex] floatValue];
  CGFloat colors[12];
  for (NSUInteger i = 0; i < _FBRGBAColorComponentsSize; i++)
  {
    colors[i] = [colorComponents[i] floatValue];
    colors[i + 4] = [colorComponents[i] floatValue];
    colors[i + 8] = [colorComponents[i] floatValue];
  }
  colors[colorIndex] = 0;
  colors[colorIndex + 4] = currentColorValue;
  colors[colorIndex + 8] = 1.0;
  UIColor *start = [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:1.0f];
  UIColor *middle = [UIColor colorWithRed:colors[4] green:colors[5] blue:colors[6] alpha:1.0f];
  UIColor *end = [UIColor colorWithRed:colors[8] green:colors[9] blue:colors[10] alpha:1.0f];
  return @[(id)start.CGColor, (id)middle.CGColor, (id)end.CGColor];
}

- (void)_setValue:(CGFloat)value forColorComponent:(_FBRGBColorComponent)colorComponent
{
  [self willChangeValueForKey:NSStringFromSelector(@selector(value))];
  switch (colorComponent) {
    case _FBRGBColorComponentRed:
      _colorComponents.red = value;
      break;
    case _FBRGBColorComponentGreed:
      _colorComponents.green = value;
      break;
    case _FBRGBColorComponentBlue:
      _colorComponents.blue = value;
      break;
    case _FBRGBColorComponentAlpha:
      _colorComponents.alpha = value;
      break;
  }
  [self didChangeValueForKey:NSStringFromSelector(@selector(value))];
}

@end
