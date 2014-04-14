//
//  SliderView.m
//  VBColorPicker
//
//  Created by Maksym Shcheglov on 06/04/14.
//  Copyright (c) 2014 www.injoit.com. All rights reserved.
//

#import "_FBSliderView.h"

static const CGFloat sSliderHeight = 28.0f;
static const CGFloat sMargin = sSliderHeight / 2.0f;
static const CGFloat sBarHeight = 3.0f;

@interface FBSliderView ()

@property(nonatomic, strong) CALayer* indicatorLayer;
@property(nonatomic, strong) CAGradientLayer* backgroundLayer;

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
    _backgroundLayer.cornerRadius = sBarHeight / 2.0f;
    _backgroundLayer.startPoint = CGPointMake(0.0f, 0.5f);
    _backgroundLayer.endPoint = CGPointMake(1.0f, 0.5f);
    _backgroundLayer.locations = @[@(0.0f), @(0.5f), @(1.0f)];
    [self.layer addSublayer:_backgroundLayer];

    _indicatorLayer = [CALayer layer];
    _indicatorLayer.cornerRadius = sSliderHeight / 2;
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
  return CGSizeMake(UIViewNoIntrinsicMetric, sSliderHeight);
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
  [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
  if (layer == self.layer) {
    CGFloat height = sSliderHeight;
    CGFloat width = CGRectGetWidth(self.bounds) - 2 * sMargin;
    _backgroundLayer.bounds = CGRectMake(0, 0, width , sBarHeight);
    _backgroundLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / 2, height / 2);
    CGFloat dimension = sSliderHeight;
    CGFloat percentage = (self.value - self.minimumValue) / (self.maximumValue - self.minimumValue);
    _indicatorLayer.bounds = CGRectMake(0, 0, dimension, dimension);
    _indicatorLayer.position = CGPointMake(width * percentage + sMargin, sSliderHeight / 2);
  }
}

@end
