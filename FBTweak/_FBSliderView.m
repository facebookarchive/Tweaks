//
//  SliderView.m
//  VBColorPicker
//
//  Created by Maksym Shcheglov on 06/04/14.
//  Copyright (c) 2014 www.injoit.com. All rights reserved.
//

#import "_FBSliderView.h"

static const CGFloat _FBSliderViewHeight = 28.0f;
static const CGFloat _FBSliderViewMargin = _FBSliderViewHeight / 2.0f;
static const CGFloat _FBSliderViewHeightTrackHeight = 3.0f;

@interface FBSliderView () {
  CALayer* _indicatorLayer;
  CAGradientLayer* _backgroundLayer;
}

@end

@implementation FBSliderView

+ (BOOL)requiresConstraintBasedLayout
{
  return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    _minimumValue = 0.0f;
    _maximumValue = 1.0f;
    _value = 0.5f;

    self.layer.delegate = self;

    _backgroundLayer = [CAGradientLayer layer];
    _backgroundLayer.cornerRadius = _FBSliderViewHeightTrackHeight / 2.0f;
    _backgroundLayer.startPoint = CGPointMake(0.0f, 0.5f);
    _backgroundLayer.endPoint = CGPointMake(1.0f, 0.5f);
    [self.layer addSublayer:_backgroundLayer];

    _indicatorLayer = [CALayer layer];
    _indicatorLayer.cornerRadius = _FBSliderViewHeight / 2;
    _indicatorLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _indicatorLayer.shadowColor = [UIColor blackColor].CGColor;
    _indicatorLayer.shadowOffset = CGSizeZero;
    _indicatorLayer.shadowRadius = 2;
    _indicatorLayer.shadowOpacity = 0.5f;
    [self.layer addSublayer:_indicatorLayer];

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
  CGFloat width = CGRectGetWidth(self.bounds) - 2 * _FBSliderViewMargin;
  CGFloat percentage = (_value - _minimumValue) / (_maximumValue - _minimumValue);
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue
                   forKey:kCATransactionDisableActions];
  _indicatorLayer.position = CGPointMake(width * percentage + _FBSliderViewMargin, _FBSliderViewHeight / 2);
  [CATransaction commit];
}

- (void)setColors:(NSArray*)colors
{
  _backgroundLayer.colors = colors;
  [self _updateLocations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint position = [[touches anyObject] locationInView:self];
  [self _setValueWithPosition:position.x];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint position = [[touches anyObject] locationInView:self];
  [self _setValueWithPosition:position.x];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint position = [[touches anyObject] locationInView:self];
  [self _setValueWithPosition:position.x];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
  if (layer == self.layer) {
    CGFloat height = _FBSliderViewHeight;
    CGFloat width = CGRectGetWidth(self.bounds) - 2 * _FBSliderViewMargin;
    _backgroundLayer.bounds = CGRectMake(0, 0, width , _FBSliderViewHeightTrackHeight);
    _backgroundLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, height / 2);
    CGFloat dimension = _FBSliderViewHeight;
    CGFloat percentage = (_value - _minimumValue) / (_maximumValue - _minimumValue);
    _indicatorLayer.bounds = CGRectMake(0, 0, dimension, dimension);
    _indicatorLayer.position = CGPointMake(width * percentage + _FBSliderViewMargin, _FBSliderViewHeight / 2);
  }
}

#pragma mark - Private methods

- (void)_setValueWithPosition:(CGFloat)position
{
  CGFloat width = CGRectGetWidth(self.bounds) - 2 * _FBSliderViewMargin;
  position -= _FBSliderViewMargin;
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
  NSUInteger size = [_backgroundLayer.colors count];
  if (size == [_backgroundLayer.locations count]) {
    return;
  }
  CGFloat step = 1.0f / (size - 1);
  NSMutableArray* locations = [NSMutableArray array];
  [locations addObject:@(0.0f)];
  for (NSUInteger i = 1; i < size - 1; ++i) {
    [locations addObject:@(i * step)];
  }
  [locations addObject:@(1.0f)];
  _backgroundLayer.locations = [locations copy];
}

@end
