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

@interface FBHSBViewController () <UITextFieldDelegate, FBHSBViewDataSource> {

  BOOL _keyboardIsShown;
  UITextField* __weak _activeField;

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

- (void)viewWillAppear:(BOOL)animated
{
  // register for keyboard notifications
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_keyboardWillBeShown:)
                                               name:UIKeyboardWillShowNotification object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(_keyboardWillBeHidden:)
                                               name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
  // unregister for keyboard notifications while not visible.
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillShowNotification
                                                object:nil];

  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIKeyboardWillHideNotification
                                                object:nil];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
  _activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  _activeField = nil;
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

- (void)_keyboardWillBeShown:(NSNotification*)aNotification
{
  NSDictionary* info = [aNotification userInfo];
  NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  CGFloat kbHeight = kbSize.height;
  if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
    kbHeight = kbSize.width;
  }
  UIEdgeInsets contentInsets = self.view.scrollView.contentInset;
  contentInsets.bottom = kbHeight;

  CGRect aRect = self.view.scrollView.frame;
  aRect.size.height = aRect.size.height - contentInsets.top - contentInsets.bottom;
  CGRect activeFieldFrame = [self.view.contentView convertRect:_activeField.frame fromView:_activeField.superview];
  CGPoint offset = self.view.scrollView.contentOffset;
  if (!CGRectContainsPoint(aRect, activeFieldFrame.origin) ) {
    offset = CGPointMake(0, CGRectGetMaxY(activeFieldFrame) - contentInsets.bottom);
  }
  __weak typeof(self.view.scrollView) weakScrollView = self.view.scrollView;
  void (^animations)() = ^{
    weakScrollView.contentInset = contentInsets;
    weakScrollView.scrollIndicatorInsets = contentInsets;
    weakScrollView.contentOffset = offset;
  };
  UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;
  [UIView animateWithDuration:duration delay:0 options:options animations:animations completion:NULL];
}

- (void)_keyboardWillBeHidden:(NSNotification*)aNotification
{
  UIEdgeInsets contentInsets = self.view.scrollView.contentInset;
  contentInsets.bottom = 0;
  self.view.scrollView.contentInset = contentInsets;
  self.view.scrollView.scrollIndicatorInsets = contentInsets;
  self.view.scrollView.contentOffset = CGPointMake(0, -contentInsets.top);
}

- (NSString*)_hexColorString
{
  UIColor* selectedColor = [UIColor colorWithHue:_colorComponents.hue saturation:_colorComponents.saturation brightness:_colorComponents.brightness alpha:_colorComponents.alpha];
  return [selectedColor hexString];
}

@end
