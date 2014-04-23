/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the self directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBHSBView.h"
#import "_FBColorWheelView.h"
#import "_FBColorComponentView.h"
#import "_FBSliderView.h"

static CGFloat const _FBAlphaMaxValue = 100.0f;

@interface FBHSBView () {

@private

  FBColorWheelView* _colorWheel;
  FBColorComponentView* _brightnessView;
  FBColorComponentView* _alphaView;
  UIView* _colorSample;
  UIScrollView* _scrollView;
  UIView* _contentView;
  UIView* _hsView;
  UILabel* _hueLabel;
  UITextField* _hueTextField;
  UILabel* _saturationLabel;
  UITextField* _saturationTextField;

  BOOL _didSetupConstraints;
}

@end

@implementation FBHSBView

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
  HSB colorComponents = [self.dataSource colorComponents];
  [self _reloadDataWithColorComponents:colorComponents];
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

  _colorWheel = [[FBColorWheelView alloc] init];
  _colorWheel.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:_colorWheel];

  _hsView = [[UIView alloc] init];
  _hsView.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:_hsView];

  _hueLabel = [[UILabel alloc] init];
  _hueLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [_hueLabel setText:@"Hue:"];
  [_hueLabel sizeToFit];
  [_hsView addSubview:_hueLabel];

  _hueTextField = [[UITextField alloc] init];
  _hueTextField.borderStyle = UITextBorderStyleRoundedRect;
  _hueTextField.translatesAutoresizingMaskIntoConstraints = NO;
  [_hueTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [_hsView addSubview:_hueTextField];

  _saturationLabel = [[UILabel alloc] init];
  _saturationLabel.translatesAutoresizingMaskIntoConstraints = NO;
  [_saturationLabel setText:@"Sat:"];
  [_saturationLabel sizeToFit];
  [_hsView addSubview:_saturationLabel];

  _saturationTextField = [[UITextField alloc] init];
  _saturationTextField.borderStyle = UITextBorderStyleRoundedRect;
  _saturationTextField.translatesAutoresizingMaskIntoConstraints = NO;
  [_saturationTextField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
  [_hsView addSubview:_saturationTextField];


  _brightnessView = [[FBColorComponentView alloc] init];
  _brightnessView.label.text = @"Brightness";
  _brightnessView.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:_brightnessView];


  _alphaView = [[FBColorComponentView alloc] init];
  _alphaView.label.text = @"Alpha";
  _alphaView.translatesAutoresizingMaskIntoConstraints = NO;
  _alphaView.slider.maximumValue = _FBAlphaMaxValue;
  [_contentView addSubview:_alphaView];
}

- (void)_setupConstraints
{
  NSDictionary *views = NSDictionaryOfVariableBindings(_scrollView);
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:views]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:views]];
  views = NSDictionaryOfVariableBindings(_contentView);
  [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|" options:0 metrics:nil views:views]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView
                                                   attribute:NSLayoutAttributeLeading
                                                   relatedBy:0
                                                      toItem:self
                                                   attribute:NSLayoutAttributeLeft
                                                  multiplier:1.0
                                                    constant:0]];
  [self addConstraint:[NSLayoutConstraint constraintWithItem:_contentView
                                                   attribute:NSLayoutAttributeTrailing
                                                   relatedBy:0
                                                      toItem:self
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1.0
                                                    constant:0]];

  views = NSDictionaryOfVariableBindings(_colorSample, _colorWheel);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_colorSample]-10-|" options:0 metrics:nil views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_colorWheel(200)]" options:0 metrics:nil views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_colorSample(30)]-20-[_colorWheel]" options:0 metrics:nil views:views]];
  [_contentView addConstraint:[NSLayoutConstraint
                               constraintWithItem:_colorWheel
                               attribute:NSLayoutAttributeWidth
                               relatedBy:NSLayoutRelationEqual
                               toItem:_colorWheel
                               attribute:NSLayoutAttributeHeight
                               multiplier:1.0f
                               constant:0]];

  views = NSDictionaryOfVariableBindings(_colorSample, _colorWheel, _hsView, _hueLabel, _hueTextField, _saturationLabel, _saturationTextField);
  [_hsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_hueLabel]-5-[_hueTextField(50)]|" options:0 metrics:nil views:views]];
  [_hsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_saturationLabel]-5-[_saturationTextField(50)]|" options:0 metrics:nil views:views]];
  [_hsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hueLabel]-10-[_saturationLabel]|" options:0 metrics:nil views:views]];
  [_hsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hueTextField]-10-[_saturationTextField]|" options:0 metrics:nil views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_colorWheel]-10-[_hsView]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:views]];

  views = NSDictionaryOfVariableBindings(_colorWheel, _brightnessView, _alphaView);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_brightnessView]-10-|" options:0 metrics:nil views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_colorWheel]-20-[_brightnessView]" options:0 metrics:nil views:views]];

  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_alphaView]-10-|" options:0 metrics:nil views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_brightnessView]-20-[_alphaView]-|" options:0 metrics:nil views:views]];
}

- (void)_reloadDataWithColorComponents:(HSB)colorComponents
{
  UIColor* selectedColor = [UIColor colorWithHue:colorComponents.hue saturation:colorComponents.saturation brightness:colorComponents.brightness alpha:colorComponents.alpha];
  [_colorSample setBackgroundColor:selectedColor];
  _colorWheel.hue = colorComponents.hue;
  _colorWheel.saturation = colorComponents.saturation;
  [self _updateSlidersWithColorComponents:colorComponents];
  [self _updateTextFieldsWithColorComponents:colorComponents];
}

- (void)_updateSlidersWithColorComponents:(HSB)colorComponents
{
  [_alphaView.slider setValue:colorComponents.alpha * _FBAlphaMaxValue];
  UIColor* tmp = [UIColor colorWithHue:colorComponents.hue saturation:colorComponents.saturation brightness:1.0f alpha:1.0f];
  [_brightnessView.slider setColors:@[(id)[UIColor blackColor].CGColor, (id)tmp.CGColor]];
  [_brightnessView.slider setValue:colorComponents.brightness];
}

- (void)_updateTextFieldsWithColorComponents:(HSB)colorComponents
{
  _hueTextField.text = [NSString stringWithFormat:@"%.2f", colorComponents.hue];
  _saturationTextField.text = [NSString stringWithFormat:@"%.2f", colorComponents.saturation];
  _brightnessView.textField.text = [NSString stringWithFormat:@"%.2f", colorComponents.brightness];
  _alphaView.textField.text = [NSString stringWithFormat:@"%d", (NSUInteger)(colorComponents.alpha * _FBAlphaMaxValue)];
}

@end
