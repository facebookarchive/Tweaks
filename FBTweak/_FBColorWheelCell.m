/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBColorWheelCell.h"
#import "_FBColorUtils.h"

static CGFloat const _FBColorWheelDiameter = 200.0;
static CGFloat const _FBColorWheelIndicatorDiameter = 33.0;

@interface _FBColorWheelCell () <UIGestureRecognizerDelegate>

@end

@implementation _FBColorWheelCell {
  CALayer *_colorWheelLayer;
  CALayer *_indicatorLayer;
  CGFloat _hue;
  CGFloat _saturation;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    _colorWheelLayer = [CALayer layer];
    _colorWheelLayer.anchorPoint = (CGPoint){0.5, 0.5};
    _colorWheelLayer.bounds = (CGRect){0, 0, _FBColorWheelDiameter, _FBColorWheelDiameter};
    _colorWheelLayer.contents = (__bridge_transfer id)_FBCreateColorWheelImage(_FBColorWheelDiameter);
    [self.layer addSublayer:_colorWheelLayer];
    _indicatorLayer = [self _createIndicatorLayer];
    [self.layer addSublayer:_indicatorLayer];

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handlePanGesture:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
  }
  return self;
}

- (void)setHue:(CGFloat)hue
{
  _hue = hue;
  [self _setSelectedPoint:[self _selectedPoint]];
}

- (void)setSaturation:(CGFloat)saturation
{
  _saturation = saturation;
  [self _setSelectedPoint:[self _selectedPoint]];
}

- (void)layoutSubviews
{
  [super layoutSubviews];

  _colorWheelLayer.position = (CGPoint){CGRectGetMidX(self.contentView.bounds), CGRectGetMidY(self.contentView.bounds)};
  [self _setSelectedPoint:[self _selectedPoint]];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  CGPoint position = [touch locationInView:self];
  return [self _shouldHandleTouchAtPosition:position];
}

#pragma mark - Private methods

- (CALayer *)_createIndicatorLayer
{
  UIColor *edgeColor = [UIColor colorWithWhite:0.9 alpha:0.8];
  CALayer *indicatorLayer = [CALayer layer];
  indicatorLayer.cornerRadius = _FBColorWheelIndicatorDiameter / 2;
  indicatorLayer.borderColor = edgeColor.CGColor;
  indicatorLayer.borderWidth = 2;
  indicatorLayer.backgroundColor = [UIColor whiteColor].CGColor;
  indicatorLayer.bounds = CGRectMake(0, 0, _FBColorWheelIndicatorDiameter, _FBColorWheelIndicatorDiameter);
  indicatorLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
  indicatorLayer.shadowColor = [UIColor blackColor].CGColor;
  indicatorLayer.shadowOffset = CGSizeZero;
  indicatorLayer.shadowRadius = 1;
  indicatorLayer.shadowOpacity = 0.5f;
  return indicatorLayer;
}

- (BOOL)_shouldHandleTouchAtPosition:(CGPoint)position
{
  CGFloat radius = _FBColorWheelDiameter / 2;
  CGPoint center = self.contentView.center;
  CGFloat dist = sqrtf((center.x - position.x) * (center.x - position.x) + (center.y - position.y) * (center.y - position.y));
  return dist <= radius;
}

- (void)_handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
  CGPoint position = [panGestureRecognizer locationInView:self];
  if (![self _shouldHandleTouchAtPosition:position]) {
    return;
  }

  CGFloat radius = _FBColorWheelDiameter / 2;
  CGPoint center = self.contentView.center;
  _hue = _FBGetColorWheelHue(position, center, radius);
  _saturation = _FBGetColorWheelSaturation(position, center, radius);
  [self _setSelectedPoint:position];
  [_delegate colorWheelCellDidChangeColor:self];
}

- (void)_setSelectedPoint:(CGPoint)point
{
  UIColor *selectedColor = [UIColor colorWithHue:_hue saturation:_saturation brightness:1.0f alpha:1.0f];
  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  _indicatorLayer.position = point;
  _indicatorLayer.backgroundColor = selectedColor.CGColor;
  [CATransaction commit];
}

- (CGPoint)_selectedPoint
{
  CGFloat radius = _saturation * _FBColorWheelDiameter / 2;
  CGFloat x = _FBColorWheelDiameter / 2 + radius * cosf(_hue * M_PI * 2.0f) + CGRectGetMinX(_colorWheelLayer.frame);
  CGFloat y = _FBColorWheelDiameter / 2 + radius * sinf(_hue * M_PI * 2.0f) + CGRectGetMinY(_colorWheelLayer.frame);
  return CGPointMake(x, y);
}

@end
