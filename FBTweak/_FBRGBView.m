/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBRGBView.h"
#import "_FBColorComponentView.h"
#import "_FBSliderView.h"
#import "FBColorUtils.h"

extern CGFloat const FBRGBColorComponentMaxValue;
extern CGFloat const FBAlphaComponentMaxValue;

static CGFloat const _FBColorSampleViewHeight = 30.0f;
static CGFloat const _FBViewSpacing = 20.0f;
static CGFloat const _FBContentViewMargin = 10.0f;
static NSUInteger const _FBRGBAColorComponentsSize = 4;

@interface FBRGBView () {

@private

  BOOL _didSetupConstraints;
  UIView* _colorSample;
  UIScrollView* _scrollView;
  UIView* _contentView;
  NSArray* _colorComponentViews;
  RGB _colorComponents;
}

@end

@implementation FBRGBView

@synthesize delegate = _delegate, scrollView = _scrollView;

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self _baseInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self _baseInit];
  }
  return self;
}

- (void)updateConstraints
{
  if (_didSetupConstraints == NO){
    [self _setupConstraints];
    _didSetupConstraints = YES;
  }
  [super updateConstraints];
}

- (void)reloadData
{
  [_colorSample setBackgroundColor:self.value];
  [self _reloadColorComponentViews:_colorComponents];
}

- (void)setValue:(UIColor *)value
{
  _colorComponents = FBRGBColorComponents(value);
  [self reloadData];
}

- (UIColor*)value
{
  return [UIColor colorWithRed:_colorComponents.red green:_colorComponents.green blue:_colorComponents.blue alpha:_colorComponents.alpha];
}

#pragma mark - Private methods

- (void)_baseInit
{
  _scrollView = [[UIScrollView alloc] init];
  _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
  [self addSubview:_scrollView];

  _contentView = [[UIView alloc] init];
  _contentView.translatesAutoresizingMaskIntoConstraints = NO;
  [_scrollView addSubview:_contentView];

  _colorSample = [[UIView alloc] init];
  _colorSample.layer.borderColor = [UIColor blackColor].CGColor;
  _colorSample.layer.borderWidth = .5f;
  _colorSample.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:_colorSample];

  NSMutableArray* tmp = [NSMutableArray array];
  NSArray* titles = @[@"Red", @"Green", @"Blue", @"Alpha"];
  NSArray* maxValues = @[@(FBRGBColorComponentMaxValue), @(FBRGBColorComponentMaxValue), @(FBRGBColorComponentMaxValue),
                         @(FBAlphaComponentMaxValue)];
  for(int i = 0; i < _FBRGBAColorComponentsSize; ++i) {
    UIControl* colorComponentView = [self _colorComponentViewWithTitle:titles[i] tag:i maxValue:[maxValues[i] floatValue]];
    [_contentView addSubview:colorComponentView];
    [colorComponentView addTarget:self action:@selector(_colorComponentDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    [tmp addObject:colorComponentView];
  }
  _colorComponentViews = [tmp copy];
}

- (IBAction)_colorComponentDidChangeValue:(FBColorComponentView*)sender
{
  [self _setColorComponentValue:sender.value / sender.maximumValue atIndex:sender.tag];
  [self.delegate colorView:self didChangeValue:[self value]];
  [self reloadData];
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

- (UIControl*)_colorComponentViewWithTitle:(NSString*)title tag:(NSUInteger)tag maxValue:(CGFloat)maxValue
{
  FBColorComponentView* colorComponentView = [[FBColorComponentView alloc] init];
  colorComponentView.title = title;
  colorComponentView.translatesAutoresizingMaskIntoConstraints = NO;
  colorComponentView.tag  = tag;
  colorComponentView.maximumValue = maxValue;
  return colorComponentView;
}

- (void)_setupConstraints
{
  __block NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView);
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:views]];

  views = NSDictionaryOfVariableBindings(_contentView);
  [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:0 metrics:nil views:views]];
  NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:_contentView
                                                                    attribute:NSLayoutAttributeLeading
                                                                    relatedBy:0
                                                                       toItem:self
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1.0
                                                                     constant:0];
  [self addConstraint:leftConstraint];

  NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:_contentView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:0
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1.0
                                                                      constant:0];
  [self addConstraint:rightConstraint];

  NSDictionary* metrics = @{ @"spacing" : @(_FBViewSpacing),
                             @"margin" : @(_FBContentViewMargin),
                             @"height" : @(_FBColorSampleViewHeight) };

  views = NSDictionaryOfVariableBindings(_colorSample);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_colorSample]-margin-|" options:0 metrics:metrics views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[_colorSample(height)]" options:0 metrics:metrics views:views]];

  __block UIView* previousView = _colorSample;
  [_colorComponentViews enumerateObjectsUsingBlock:^(UIView* colorComponentView, NSUInteger idx, BOOL *stop) {
    views = NSDictionaryOfVariableBindings(previousView, colorComponentView);
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[colorComponentView]-margin-|" options:0 metrics:metrics views:views]];
    [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-spacing-[colorComponentView]" options:0 metrics:metrics views:views]];
    previousView = colorComponentView;
  }];
  views = NSDictionaryOfVariableBindings(previousView);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousView]-spacing-|" options:0 metrics:metrics views:views]];
}

- (NSArray*)_colorComponentsWithRGB:(RGB)rgb
{
  return @[@(rgb.red), @(rgb.green), @(rgb.blue), @(rgb.alpha)];
}

- (void)_reloadColorComponentViews:(RGB)colorComponents
{
  NSArray* components = [self _colorComponentsWithRGB:colorComponents];
  [_colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* colorComponentView, NSUInteger idx, BOOL *stop) {
    FBSliderView* slider = colorComponentView.slider;
    if (idx < _FBRGBAColorComponentsSize - 1) {
      [self _updateSlider:slider withColorComponents:components];
    }
    colorComponentView.value = [components[idx] floatValue] * colorComponentView.maximumValue;
  }];
}

- (void)_updateSlider:(FBSliderView*)slider withColorComponents:(NSArray*)colorComponents
{
  NSUInteger colorIndex = slider.tag;
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
  UIColor* start = [UIColor colorWithRed:colors[0] green:colors[1] blue:colors[2] alpha:1.0f];
  UIColor* middle = [UIColor colorWithRed:colors[4] green:colors[5] blue:colors[6] alpha:1.0f];
  UIColor* end = [UIColor colorWithRed:colors[8] green:colors[9] blue:colors[10] alpha:1.0f];
  [slider setColors:@[(id)start.CGColor, (id)middle.CGColor, (id)end.CGColor]];
}

@end
