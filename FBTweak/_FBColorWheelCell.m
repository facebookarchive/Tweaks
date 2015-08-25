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

@implementation _FBColorWheelCell {
  _FBColorWheelView *_colorWheel;
}

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

-(void)layoutSubviews
{
  [super layoutSubviews];

  _colorWheel.center = (CGPoint){CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds)};
}

#pragma mark - Private methods

- (void)_init
{
  self.selectionStyle = UITableViewCellSelectionStyleNone;

  _colorWheel = [[_FBColorWheelView alloc] init];
  _colorWheel.translatesAutoresizingMaskIntoConstraints = NO;
  _colorWheel.bounds = (CGRect){0, 0, _FBColorWheelDimention, _FBColorWheelDimention};
  [_colorWheel addTarget:self action:@selector(_didChangeValue:) forControlEvents:UIControlEventValueChanged];
  [self.contentView addSubview:_colorWheel];
}

- (void)_didChangeValue:(_FBColorWheelView*)sender
{
  [self.delegate colorWheelCell:self didChangeHue:self.hue saturation:self.saturation];
}

@end
