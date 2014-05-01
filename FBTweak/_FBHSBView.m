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
#import "FBColorUtils.h"

extern CGFloat const FBAlphaComponentMaxValue;
extern CGFloat const FBHSBColorComponentMaxValue;

static CGFloat const _FBColorSampleViewHeight = 30.0f;
static CGFloat const _FBViewSpacing = 20.0f;
static CGFloat const _FBViewMargin = 10.0f;
static CGFloat const _FBTextFieldWidth = 50.0f;
static CGFloat const _FBLabelSpacing = 5.0f;
static CGFloat const _FBColorWheelHeight = 200.0f;

@interface FBHSBView () <UITextFieldDelegate>
{

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

  HSB _colorComponents;
}

@end

@implementation FBHSBView

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
  [self _reloadViewsWithColorComponents:_colorComponents];
}

- (void)setValue:(UIColor *)value
{
  FBRGB2HSB(FBRGBColorComponents(value), &_colorComponents);
  [self reloadData];
}

- (UIColor*)value
{
  return[UIColor colorWithHue:_colorComponents.hue saturation:_colorComponents.saturation brightness:_colorComponents.brightness alpha:_colorComponents.alpha];
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  if (textField == _hueTextField) {
    _colorComponents.hue = [textField.text floatValue];
  } else if (textField == _saturationTextField) {
    _colorComponents.saturation = [textField.text floatValue];
  }
  [self.delegate colorView:self didChangeValue:[self value]];
  [self reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
  NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];

  //first, check if the new string is numeric only. If not, return NO;
  NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789,."] invertedSet];
  if ([newString rangeOfCharacterFromSet:characterSet].location != NSNotFound) {
    return NO;
  }

  return [newString floatValue] <= FBHSBColorComponentMaxValue;
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
  _brightnessView.title = @"Brightness";
  _brightnessView.maximumValue = FBHSBColorComponentMaxValue;
  _brightnessView.format = @"%.2f";
  _brightnessView.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:_brightnessView];


  _alphaView = [[FBColorComponentView alloc] init];
  _alphaView.title = @"Alpha";
  _alphaView.translatesAutoresizingMaskIntoConstraints = NO;
  _alphaView.maximumValue = FBAlphaComponentMaxValue;
  [_contentView addSubview:_alphaView];

  [_colorWheel addTarget:self action:@selector(_colorDidChangeValue:) forControlEvents:UIControlEventValueChanged];
  [_brightnessView addTarget:self action:@selector(_brightnessDidChangeValue:) forControlEvents:UIControlEventValueChanged];
  [_alphaView addTarget:self action:@selector(_alphaDidChangeValue:) forControlEvents:UIControlEventValueChanged];
  _hueTextField.delegate = self;
  _saturationTextField.delegate = self;
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

  NSDictionary* metrics = @{ @"spacing" : @(_FBViewSpacing),
                             @"height" : @(_FBColorSampleViewHeight),
                             @"margin" : @(_FBViewMargin),
                             @"text_field_width" : @(_FBTextFieldWidth),
                             @"color_wheel_height" : @(_FBColorWheelHeight),
                             @"small_spacing" : @(_FBLabelSpacing)};

  views = NSDictionaryOfVariableBindings(_colorSample, _colorWheel);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_colorSample]-margin-|" options:0 metrics:metrics views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_colorWheel(color_wheel_height)]" options:0 metrics:metrics views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[_colorSample(height)]-spacing-[_colorWheel]" options:0 metrics:metrics views:views]];
  [_contentView addConstraint:[NSLayoutConstraint
                               constraintWithItem:_colorWheel
                               attribute:NSLayoutAttributeWidth
                               relatedBy:NSLayoutRelationEqual
                               toItem:_colorWheel
                               attribute:NSLayoutAttributeHeight
                               multiplier:1.0f
                               constant:0]];

  views = NSDictionaryOfVariableBindings(_colorSample, _colorWheel, _hsView, _hueLabel, _hueTextField, _saturationLabel, _saturationTextField);
  [_hsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_hueLabel]-small_spacing-[_hueTextField(text_field_width)]|" options:0 metrics:metrics views:views]];
  [_hsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_saturationLabel]-small_spacing-[_saturationTextField(text_field_width)]|" options:0 metrics:metrics views:views]];
  [_hsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hueLabel]-margin-[_saturationLabel]|" options:0 metrics:metrics views:views]];
  [_hsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hueTextField]-margin-[_saturationTextField]|" options:0 metrics:metrics views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_colorWheel]-margin-[_hsView]" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];

  views = NSDictionaryOfVariableBindings(_colorWheel, _brightnessView, _alphaView);
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_brightnessView]-margin-|" options:0 metrics:metrics views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_colorWheel]-spacing-[_brightnessView]" options:0 metrics:metrics views:views]];

  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[_alphaView]-margin-|" options:0 metrics:metrics views:views]];
  [_contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_brightnessView]-spacing-[_alphaView]-|" options:0 metrics:metrics views:views]];
}

- (void)_reloadViewsWithColorComponents:(HSB)colorComponents
{
  _colorWheel.hue = colorComponents.hue;
  _colorWheel.saturation = colorComponents.saturation;
  [self _updateSlidersWithColorComponents:colorComponents];
  [self _updateTextFieldsWithColorComponents:colorComponents];
}

- (void)_updateSlidersWithColorComponents:(HSB)colorComponents
{
  [_alphaView setValue:colorComponents.alpha * FBAlphaComponentMaxValue];
  [_brightnessView setValue:colorComponents.brightness];
  UIColor* tmp = [UIColor colorWithHue:colorComponents.hue saturation:colorComponents.saturation brightness:1.0f alpha:1.0f];
  [_brightnessView.slider setColors:@[(id)[UIColor blackColor].CGColor, (id)tmp.CGColor]];
}

- (void)_updateTextFieldsWithColorComponents:(HSB)colorComponents
{
  _hueTextField.text = [NSString stringWithFormat:@"%.2f", colorComponents.hue];
  _saturationTextField.text = [NSString stringWithFormat:@"%.2f", colorComponents.saturation];
}

- (void)_colorDidChangeValue:(FBColorWheelView*)sender
{
  _colorComponents.hue = sender.hue;
  _colorComponents.saturation = sender.saturation;
  [self.delegate colorView:self didChangeValue:[self value]];
  [self reloadData];
}

- (void)_brightnessDidChangeValue:(FBColorComponentView*)sender
{
  _colorComponents.brightness = sender.value;
  [self.delegate colorView:self didChangeValue:[self value]];
  [self reloadData];
}

- (void)_alphaDidChangeValue:(FBColorComponentView*)sender
{
  _colorComponents.alpha = sender.value / FBAlphaComponentMaxValue;
  [self.delegate colorView:self didChangeValue:[self value]];
  [self reloadData];
}

@end
