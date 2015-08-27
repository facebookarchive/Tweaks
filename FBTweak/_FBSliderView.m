/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBSliderView.h"

static const CGFloat _FBSliderViewHeight = 28.0f;
static const CGFloat _FBSliderViewThumbDimension = 28.0f;
static const CGFloat _FBSliderViewTrackHeight = 3.0f;

@implementation _FBSliderView {
  CALayer *_thumbLayer;
  CAGradientLayer *_trackLayer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
    _minimumValue = 0.0f;
    _maximumValue = 1.0f;
    _value = 0.0f;

    self.layer.delegate = self;

    _trackLayer = [CAGradientLayer layer];
    _trackLayer.cornerRadius = _FBSliderViewTrackHeight / 2.0f;
    _trackLayer.startPoint = CGPointMake(0.0f, 0.5f);
    _trackLayer.endPoint = CGPointMake(1.0f, 0.5f);
    [self.layer addSublayer:_trackLayer];

    _thumbLayer = [CALayer layer];
    _thumbLayer.cornerRadius = _FBSliderViewHeight / 2;
    _thumbLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _thumbLayer.shadowColor = [UIColor blackColor].CGColor;
    _thumbLayer.shadowOffset = CGSizeZero;
    _thumbLayer.shadowRadius = 2;
    _thumbLayer.shadowOpacity = 0.5f;
    [self.layer addSublayer:_thumbLayer];

    __attribute__((objc_precise_lifetime)) id color = (__bridge id)[UIColor blueColor].CGColor;
    [self setColors:@[color, color]];
  }
  return self;
}

- (CGSize)intrinsicContentSize
{
  return CGSizeMake(UIViewNoIntrinsicMetric, _FBSliderViewHeight);
}

- (void)setValue:(CGFloat)value
{
  if (value < _minimumValue) {
    _value = _minimumValue;
  } else if (value > _maximumValue) {
    _value = _maximumValue;
  } else {
    _value = value;
  }
  [self _updateThumbPositionWithValue:_value];
}

- (void)setColors:(NSArray*)colors
{
  _trackLayer.colors = colors;
  [self _updateLocations];
}

- (NSArray*)colors
{
  return _trackLayer.colors;
}

#pragma mark - UIControl touch tracking events

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  CGPoint touchPoint = [touch locationInView:self];
  if (CGRectContainsPoint(CGRectInset(_thumbLayer.frame, -10.0, -10.0), touchPoint)) {
    [self _setValueWithPosition:touchPoint.x];
    return YES;
  }
  return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  CGPoint touchPoint = [touch locationInView:self];
  [self _setValueWithPosition:touchPoint.x];
  return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
  CGPoint touchPoint = [touch locationInView:self];
  [self _setValueWithPosition:touchPoint.x];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
  if (layer == self.layer) {
    CGFloat height = _FBSliderViewHeight;
    CGFloat width = CGRectGetWidth(self.bounds);
    _trackLayer.bounds = CGRectMake(0, 0, width , _FBSliderViewTrackHeight);
    _trackLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, height / 2);
    _thumbLayer.bounds = CGRectMake(0, 0, _FBSliderViewThumbDimension, _FBSliderViewThumbDimension);
    [self _updateThumbPositionWithValue:_value];
  }
}

#pragma mark - Private methods

- (void)_setValueWithPosition:(CGFloat)position
{
  CGFloat width = CGRectGetWidth(self.bounds);
  if (position < 0) {
    position = 0;
  } else if (position > width) {
    position = width;
  }
  CGFloat percentage = position / width;
  CGFloat value = _minimumValue + percentage * (_maximumValue - _minimumValue);
  [self setValue:value];
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_updateLocations
{
  NSUInteger size = [_trackLayer.colors count];
  if (size == [_trackLayer.locations count]) {
    return;
  }
  CGFloat step = 1.0f / (size - 1);
  NSMutableArray *locations = [NSMutableArray array];
  [locations addObject:@(0.0f)];
  for (NSUInteger i = 1; i < size - 1; ++i) {
    [locations addObject:@(i * step)];
  }
  [locations addObject:@(1.0f)];
  _trackLayer.locations = [locations copy];
}

- (void)_updateThumbPositionWithValue:(CGFloat)value
{
  CGFloat width = CGRectGetWidth(self.bounds);
  if (width == 0) {
    return;
  }

  CGFloat percentage = (_value - _minimumValue) / (_maximumValue - _minimumValue);
  CGFloat position = width * percentage;

  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  _thumbLayer.position = CGPointMake(position - ((position - width / 2) / (width / 2)) * _FBSliderViewThumbDimension / 2, _FBSliderViewHeight / 2);
  [CATransaction commit];
}

@end
