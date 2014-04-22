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

static CGFloat const _FBColorComponentMaxValue = 255.0f;
static CGFloat const _FBColorSampleViewHeight = 30.0f;
static CGFloat const _FBRGBViewSpacing = 20.0f;
static CGFloat const _FBRGBContentViewMargin = 10.0f;

NSUInteger const _FBRGBAColorComponentsSize = 4;

@interface FBRGBView () {

  @private

  BOOL _didSetupConstraints;
}

@property(nonatomic, strong, readwrite) UIView* colorSample;
@property(nonatomic, strong, readwrite) UIScrollView* scrollView;
@property(nonatomic, strong, readwrite) UIView* contentView;
@property(nonatomic, strong, readwrite) NSArray* colorComponentViews;

@end

@implementation FBRGBView

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

- (void)reloadDataWithOptions:(FBRGBViewReloadOption)options
{
  CGFloat* colorComponents = [self.dataSource colorComponents];
  [self _reloadDataWithOptions:options colorComponents:colorComponents];
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
  for(int i = 0; i < _FBRGBAColorComponentsSize; ++i) {
    UIView* colorComponentView = [self _colorComponentViewWithTitle:titles[i] tag:i];
    [_contentView addSubview:colorComponentView];
    [tmp addObject:colorComponentView];
  }
  _colorComponentViews = [tmp copy];
}

- (UIView*)_colorComponentViewWithTitle:(NSString*)title tag:(NSUInteger)tag
{
  FBColorComponentView* colorComponentView = [[FBColorComponentView alloc] init];
  colorComponentView.label.text = title;
  colorComponentView.translatesAutoresizingMaskIntoConstraints = NO;
  colorComponentView.tag  = tag;
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

  NSDictionary* metrics = @{ @"spacing" : @(_FBRGBViewSpacing),
                             @"margin" : @(_FBRGBContentViewMargin),
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

- (void)_reloadDataWithOptions:(FBRGBViewReloadOption)options colorComponents:(CGFloat[_FBRGBAColorComponentsSize])colorComponents
{
  UIColor* selectedColor = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:colorComponents[3]];
  [_colorSample setBackgroundColor:selectedColor];
  if (options & FBRGBViewReloadOptionSliders) {
    [self _updateSlidersWithColorComponents:colorComponents];
  }
  if (options & FBRGBViewReloadOptionTextFields) {
    [self _updateTextFieldsWithColorComponents:colorComponents];
  }
}

- (void)_updateSlidersWithColorComponents:(CGFloat[_FBRGBAColorComponentsSize])colorComponents
{
  [_colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* colorComponentView, NSUInteger idx, BOOL *stop) {
    FBSliderView* slider = colorComponentView.slider;
    if (idx < _FBRGBAColorComponentsSize - 1) {
      [self _updateSlider:slider withColorComponents:colorComponents];
    }
    [slider setValue:colorComponents[slider.tag]];
  }];
}

- (void)_updateTextFieldsWithColorComponents:(CGFloat[_FBRGBAColorComponentsSize])colorComponents
{
  [_colorComponentViews enumerateObjectsUsingBlock:^(FBColorComponentView* colorComponentView, NSUInteger idx, BOOL *stop) {
    colorComponentView.textField.text = [NSString stringWithFormat:@"%d", (NSInteger)(colorComponents[idx] * _FBColorComponentMaxValue)];
  }];
}

- (void)_updateSlider:(FBSliderView*)slider withColorComponents:(CGFloat[_FBRGBAColorComponentsSize])colorComponents
{
  NSUInteger colorIndex = slider.tag;
  float currentColorValue = colorComponents[colorIndex];
  float colors[12];
  for (int i = 0; i < _FBRGBAColorComponentsSize; i++)
  {
    colors[i] = colorComponents[i];
    colors[i + 4] = colorComponents[i];
    colors[i + 8] = colorComponents[i];
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
