/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorWheelCell.h"
#import "_FBColorWheelView.h"

static CGFloat const _FBColorWheelDimention = 200.0f;
static CGFloat const _FBViewMargin = 10.0f;

@interface _FBColorWheelCell () {

@private

  _FBColorWheelView* _colorWheel;
}

@end

@implementation _FBColorWheelCell

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self _init];
  }
  return self;
}

- (CGFloat)hue
{
  return _colorWheel.hue;
}

- (void)setHue:(CGFloat)hue
{
  _colorWheel.hue = hue;
}

- (CGFloat)saturation
{
  return _colorWheel.saturation;
}

- (void)setSaturation:(CGFloat)saturation
{
  _colorWheel.saturation = saturation;
}

#pragma mark - Private methods

- (void)_init
{
  self.selectionStyle = UITableViewCellSelectionStyleNone;

  _colorWheel = [[_FBColorWheelView alloc] init];
  _colorWheel.translatesAutoresizingMaskIntoConstraints = NO;
  [_colorWheel addTarget:self action:@selector(_didChangeValue:) forControlEvents:UIControlEventValueChanged];
  [self.contentView addSubview:_colorWheel];

  [self _installConstraints];
}

- (void)_installConstraints
{
  NSDictionary* views = NSDictionaryOfVariableBindings(_colorWheel);
  NSDictionary* metrics = @{ @"color_wheel_dimension" : @(_FBColorWheelDimention),
                             @"margin" : @(_FBViewMargin)};
  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(>=margin)-[_colorWheel(color_wheel_dimension)]-(>=margin)-|" options:0 metrics:metrics views:views]];
  [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[_colorWheel(color_wheel_dimension)]-margin-|" options:0 metrics:metrics views:views]];
  [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_colorWheel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
}

- (void)_didChangeValue:(_FBColorWheelView*)sender
{
  [self.delegate colorWheelCell:self didChangeHue:self.hue saturation:self.saturation];
}

@end
