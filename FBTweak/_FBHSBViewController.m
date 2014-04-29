/**
 Copyright (c) 2014-present, Facebook, Inc.
 All rights reserved.

 This source code is licensed under the BSD-style license found in the
 LICENSE file in the root directory of this source tree. An additional grant
 of patent rights can be found in the PATENTS file in the same directory.
 */

#import "_FBHSBViewController.h"
#import "_FBColorWheelView.h"
#import "_FBColorComponentView.h"
#import "_FBSliderView.h"
#import "_FBHSBView.h"
#import "FBTweak.h"
#import "UIColor+HEX.h"

static CGFloat const _FBColorComponentMaxValue = 1.0f;
static CGFloat const _FBAlphaMaxValue = 100.0f;

@interface FBHSBViewController () <UITextFieldDelegate, FBHSBViewDataSource>
{
  FBTweak* _tweak;
  HSB _colorComponents;
}

@property(nonatomic, strong) FBHSBView* view;

@end

@implementation FBHSBViewController

- (instancetype)initWithTweak:(FBTweak *)tweak
{
  self = [super init];
  if (self) {
    _tweak = tweak;

    self.title = _tweak.name;

    FBTweakValue value = (_tweak.currentValue ?: _tweak.defaultValue);
    RGB2HSB(RGBColorComponents([UIColor colorWithHexString:value]), &_colorComponents);
  }
  return self;
}

- (void)loadView
{
  self.view = [[FBHSBView alloc] init];
  self.view.dataSource = self;

  [self.view.colorWheel addTarget:self action:@selector(onColorChanged:) forControlEvents:UIControlEventValueChanged];
  [self.view.brightnessView.slider addTarget:self action:@selector(onBrightnessChanged:) forControlEvents:UIControlEventValueChanged];
  [self.view.alphaView.slider addTarget:self action:@selector(onAlphaChanged:) forControlEvents:UIControlEventValueChanged];
  self.view.hueTextField.delegate = self;
  self.view.saturationTextField.delegate = self;
  self.view.brightnessView.textField.delegate = self;
  self.view.alphaView.textField.delegate = self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.view reloadData];
}

- (IBAction)onColorChanged:(FBColorWheelView*)sender
{
  _colorComponents.hue = sender.hue;
  _colorComponents.saturation = sender.saturation;
  _tweak.currentValue = [self _hexColorString];
  [self.view reloadData];
}

- (IBAction)onBrightnessChanged:(FBSliderView*)sender
{
  _colorComponents.brightness = sender.value;
  _tweak.currentValue = [self _hexColorString];
  [self.view reloadData];
}

- (IBAction)onAlphaChanged:(FBSliderView*)sender
{
  _colorComponents.alpha = sender.value / _FBAlphaMaxValue;
  _tweak.currentValue = [self _hexColorString];
  [self.view reloadData];
}

#pragma mark - FBHSBViewDataSource methods

- (HSB)colorComponents
{
  return _colorComponents;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  if (textField == self.view.hueTextField) {
    _colorComponents.hue = [textField.text floatValue];
  } else if (textField == self.view.saturationTextField) {
    _colorComponents.saturation = [textField.text floatValue];
  } else if (textField == self.view.brightnessView.textField) {
    _colorComponents.brightness = [textField.text floatValue];
  } else if (textField == self.view.alphaView.textField) {
    _colorComponents.alpha = [textField.text floatValue] / _FBAlphaMaxValue;
  }
  _tweak.currentValue = [self _hexColorString];
  [self.view reloadData];
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

  BOOL isValid = YES;
  if (textField == self.view.hueTextField || textField == self.view.saturationTextField ||
      textField == self.view.brightnessView.textField) {
    isValid = [newString floatValue] <= _FBColorComponentMaxValue;
  } else if (textField == self.view.alphaView.textField) {
    isValid = [newString intValue] <= _FBAlphaMaxValue;
  }
  return isValid;
}

#pragma mark - Private methods

- (NSString*)_hexColorString
{
  UIColor* selectedColor = [UIColor colorWithHue:_colorComponents.hue saturation:_colorComponents.saturation brightness:_colorComponents.brightness alpha:_colorComponents.alpha];
  return [selectedColor hexString];
}

@end
