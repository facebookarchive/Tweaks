/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBSliderView.h"

static const CGFloat sSliderHeight = 28.0f;
static const CGFloat sMargin = sSliderHeight / 2.0f;
static const CGFloat sBarHeight = 3.0f;

@interface FBSliderView ()

@property(nonatomic, strong) CALayer* indicatorLayer;
@property(nonatomic, strong) CAGradientLayer* backgroundLayer;

@end

@implementation FBSliderView

- (instancetype)initWithFrame:(CGRect)frame
{
  NSParameterAssert(CGRectGetWidth(frame) > sMargin * 2 );
  CGSize sliderSize = frame.size;
  sliderSize.height = sSliderHeight;
  frame.size = sliderSize;
  self = [super initWithFrame:frame];
  if (self) {
    _minimumValue = 0.0f;
    _maximumValue = 1.0f;
    _value = 0.5f;

    CGFloat height = sSliderHeight;
    CGFloat width = CGRectGetWidth(self.bounds);
    _backgroundLayer = [CAGradientLayer layer];
    _backgroundLayer.cornerRadius = sBarHeight / 2.0f;
    _backgroundLayer.startPoint = CGPointMake(0.0f, 0.5f);
    _backgroundLayer.endPoint = CGPointMake(1.0f, 0.5f);
    _backgroundLayer.locations = @[@(0.0f), @(0.5f), @(1.0f)];
    _backgroundLayer.bounds = CGRectMake(0, 0, width - 2 * sMargin, sBarHeight);
    _backgroundLayer.position = CGPointMake(width / 2, height / 2);
    [self.layer addSublayer:_backgroundLayer];

    CGFloat dimension = sSliderHeight;
    _indicatorLayer = [CALayer layer];
    _indicatorLayer.cornerRadius = dimension / 2;
    _indicatorLayer.backgroundColor = [UIColor whiteColor].CGColor;
    _indicatorLayer.bounds = CGRectMake(0, 0, dimension, dimension);
    _indicatorLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, sSliderHeight / 2);
    _indicatorLayer.shadowColor = [UIColor blackColor].CGColor;
    _indicatorLayer.shadowOffset = CGSizeZero;
    _indicatorLayer.shadowRadius = 2;
    _indicatorLayer.shadowOpacity = 0.5f;
    [self.layer addSublayer:_indicatorLayer];

    _value = 0.5f;
    __attribute__((objc_precise_lifetime)) id color = (__bridge id)[UIColor whiteColor].CGColor;
    [self setColors:@[color, color]];
  }
  return self;
}

- (void)setValue:(CGFloat)value
{
  if (value < self.minimumValue) {
    _value = self.minimumValue;
  } else if (value > self.maximumValue) {
    _value = self.maximumValue;
  } else {
    _value = value;
  }
  CGFloat width = CGRectGetWidth(self.bounds) - 2 * sMargin;
  CGFloat percentage = (self.value - self.minimumValue) / (self.maximumValue - self.minimumValue);
  [CATransaction begin];
  [CATransaction setValue:(id)kCFBooleanTrue
                   forKey:kCATransactionDisableActions];
  self.indicatorLayer.position = CGPointMake(width * percentage + sMargin, sSliderHeight / 2);
  [CATransaction commit];
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setColors:(NSArray*)colors
{
  self.backgroundLayer.colors = colors;
  NSUInteger size = [colors count];
  if (size == [self.backgroundLayer.locations count]) {
    return;
  }
  CGFloat step = 1.0f / (size - 1);
  NSMutableArray* locations = [NSMutableArray array];
  [locations addObject:@(0.0f)];
  for (NSUInteger i = 1; i < size - 1; ++i) {
    [locations addObject:@(i * step)];
  }
  [locations addObject:@(1.0f)];
  self.backgroundLayer.locations = [locations copy];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint position = [[touches anyObject] locationInView:self];
  [self setValueWithPosition:position.x];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint position = [[touches anyObject] locationInView:self];
  [self setValueWithPosition:position.x];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  CGPoint position = [[touches anyObject] locationInView:self];
  [self setValueWithPosition:position.x];
}

- (void)setValueWithPosition:(CGFloat)position
{
  CGFloat width = CGRectGetWidth(self.bounds) - 2 * sMargin;
  position -= sMargin;
  if (position < 0) {
    position = 0;
  } else if (position > width) {
    position = width;
  }
  CGFloat percentage = position / width;
  CGFloat value = self.minimumValue + percentage * (self.maximumValue - self.minimumValue);
  [self setValue:value];
}

@end
